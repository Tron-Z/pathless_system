#!/usr/bin/env python3
"""Restore Pathless RK3566 DTS onto kernel branches via GitHub API."""
from __future__ import annotations

import base64
import json
import os
import subprocess
import sys
from pathlib import Path

REPO = "Tron-Z/pathless_system"
ROOT = Path(__file__).resolve().parents[1]


def put_file(
    branch: str,
    remote_path: str,
    content: bytes,
    message: str,
    sha: str | None = None,
) -> None:
    body = {
        "message": message,
        "content": base64.b64encode(content).decode("ascii"),
        "branch": branch,
    }
    if sha is None:
        try:
            meta = json.loads(gh_api(f"repos/{REPO}/contents/{remote_path}?ref={branch}"))
            sha = meta.get("sha")
        except SystemExit:
            sha = None
    if sha:
        body["sha"] = sha
    gh_api(
        "--method",
        "PUT",
        f"repos/{REPO}/contents/{remote_path}",
        "--input",
        "-",
        input_data=json.dumps(body).encode(),
    )


def gh_api(*args: str, input_data: bytes | None = None) -> str:
    cmd = ["gh", "api", *args]
    r = subprocess.run(cmd, input=input_data, capture_output=True)
    if r.returncode != 0:
        sys.stderr.write(r.stderr.decode("utf-8", "replace"))
        raise SystemExit(r.returncode)
    return r.stdout.decode("utf-8")


def restore(branch: str, dts_rel: str) -> None:
    dts_path = ROOT / "external/branding/kernel" / dts_rel / "rk3566-pathless-3b.dts"
    if not dts_path.is_file():
        raise SystemExit(f"missing {dts_path}")
    content_b64 = base64.b64encode(dts_path.read_bytes()).decode("ascii")
    remote_path = "arch/arm64/boot/dts/rockchip/rk3566-pathless-3b.dts"

    # Create or update DTS
    sha = None
    try:
        meta = json.loads(
            gh_api(f"repos/{REPO}/contents/{remote_path}?ref={branch}")
        )
        sha = meta.get("sha")
    except SystemExit:
        sha = None

    body = {
        "message": f"pathless: restore rk3566-pathless-3b.dts on {branch}",
        "content": content_b64,
        "branch": branch,
    }
    if sha:
        body["sha"] = sha
    gh_api(
        "--method",
        "PUT",
        f"repos/{REPO}/contents/{remote_path}",
        "--input",
        "-",
        input_data=json.dumps(body).encode(),
    )
    print(f"OK dts -> {branch}:{remote_path}")

    v2_path = ROOT / "external/branding/kernel" / dts_rel / "rk3566-pathless-3b-v2.dts"
    if v2_path.is_file():
        put_file(
            branch,
            "arch/arm64/boot/dts/rockchip/rk3566-pathless-3b-v2.dts",
            v2_path.read_bytes(),
            f"pathless: restore rk3566-pathless-3b-v2.dts on {branch}",
        )
        print(f"OK dts v2 -> {branch}")
    elif dts_rel == "6.6":
        raise SystemExit(f"missing {v2_path}")

    # Ensure Makefile references pathless dtbs (v1 + v2 on 6.6)
    mk_path = "arch/arm64/boot/dts/rockchip/Makefile"
    mk = json.loads(gh_api(f"repos/{REPO}/contents/{mk_path}?ref={branch}"))
    mk_text = base64.b64decode(mk["content"]).decode("utf-8", "replace")
    want_v2 = dts_rel == "6.6" and v2_path.is_file()
    if "rk3566-pathless-3b.dtb" not in mk_text or (
        want_v2 and "rk3566-pathless-3b-v2.dtb" not in mk_text
    ):
        mk_text = mk_text.replace("rk3566-orangepi-3b-v2.dtb", "rk3566-pathless-3b-v2.dtb")
        mk_text = mk_text.replace("rk3566-orangepi-3b.dtb", "rk3566-pathless-3b.dtb")
        if "rk3566-pathless-3b.dtb" not in mk_text:
            mk_text += "dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3566-pathless-3b.dtb\n"
        if want_v2 and "rk3566-pathless-3b-v2.dtb" not in mk_text:
            mk_text = mk_text.replace(
                "rk3566-pathless-3b.dtb",
                "rk3566-pathless-3b.dtb \\\n\trk3566-pathless-3b-v2.dtb",
                1,
            )
        put_file(
            branch,
            mk_path,
            mk_text.encode(),
            f"pathless: add rk3566-pathless-3b dtb(s) to Makefile on {branch}",
            sha=mk["sha"],
        )
        print(f"OK makefile -> {branch}:{mk_path}")
    else:
        print(f"OK makefile already has pathless dtb on {branch}")


def main() -> None:
    targets = [
        ("pathless-5.10-rk35xx", "5.10"),
        ("pathless-6.6-rk35xx", "6.6"),
    ]
    only = os.environ.get("ONLY_BRANCH")
    for branch, rel in targets:
        if only and only != branch:
            continue
        restore(branch, rel)


if __name__ == "__main__":
    main()

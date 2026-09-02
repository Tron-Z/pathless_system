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

    # Ensure Makefile references pathless dtb
    mk_path = "arch/arm64/boot/dts/rockchip/Makefile"
    mk = json.loads(gh_api(f"repos/{REPO}/contents/{mk_path}?ref={branch}"))
    mk_text = base64.b64decode(mk["content"]).decode("utf-8", "replace")
    line = "dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3566-pathless-3b.dtb"
    if line not in mk_text:
        if "rk3566-orangepi-3b.dtb" in mk_text:
            mk_text = mk_text.replace("rk3566-orangepi-3b.dtb", "rk3566-pathless-3b.dtb")
        else:
            # append after first rk3566 dtb line if possible
            lines = mk_text.splitlines(keepends=True)
            out = []
            inserted = False
            for ln in lines:
                out.append(ln)
                if (not inserted) and "rk3566-" in ln and ln.strip().endswith(".dtb"):
                    out.append(line + "\n")
                    inserted = True
            if not inserted:
                out.append(line + "\n")
            mk_text = "".join(out)
        body = {
            "message": f"pathless: add rk3566-pathless-3b.dtb to Makefile on {branch}",
            "content": base64.b64encode(mk_text.encode()).decode("ascii"),
            "branch": branch,
            "sha": mk["sha"],
        }
        gh_api(
            "--method",
            "PUT",
            f"repos/{REPO}/contents/{mk_path}",
            "--input",
            "-",
            input_data=json.dumps(body).encode(),
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

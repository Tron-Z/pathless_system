#!/bin/bash
#
# Mirror all Pathless dependency repos into pathless_system as branches.
# Branch names match old repo names (or keep existing multi-branch names).
#
# Usage:
#   export GIT_PROXY_PREFIX=https://gh-proxy.com/https://github.com   # optional
#   bash tools/migrate-unified-repos.sh
#
set -euo pipefail

ORG="${ORG:-Tron-Z}"
DST_REPO="${DST_REPO:-pathless_system}"
SRC_PREFIX="${GIT_PROXY_PREFIX:-https://github.com}"
DST_URL="${DST_PUSH_URL:-https://github.com/${ORG}/${DST_REPO}.git}"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

mirror_branch() {
	local src_repo=$1 src_branch=$2 dst_branch=$3
	local dir="${workdir}/${src_repo//\//_}_${src_branch}"
	echo "==> ${ORG}/${src_repo}:${src_branch} -> ${DST_REPO}:${dst_branch}"
	rm -rf "${dir}"
	git clone --bare --branch "${src_branch}" --single-branch \
		"${SRC_PREFIX}/${ORG}/${src_repo}.git" "${dir}"
	git -C "${dir}" push --force "${DST_URL}" "${src_branch}:${dst_branch}"
}

echo "Mirroring into ${ORG}/${DST_REPO} ..."

# BSP — branch name = old repo name
mirror_branch pathless-bsp-u-boot v2017.09-rk3588 pathless-bsp-u-boot
mirror_branch pathless-bsp-firmware master pathless-bsp-firmware
mirror_branch pathless-bsp-config master pathless-bsp-config

# Kernel — keep existing branch names
mirror_branch pathless-bsp-kernel pathless-6.6-rk35xx pathless-6.6-rk35xx
mirror_branch pathless-bsp-kernel pathless-5.10-rk35xx pathless-5.10-rk35xx

# Rockchip — keep existing branch names
mirror_branch pathless-rockchip rkbin rkbin
mirror_branch pathless-rockchip rk35xx_packages rk35xx_packages

# Third-party — branch name = old repo name
mirror_branch oh-my-zsh master oh-my-zsh
mirror_branch evalcache master evalcache
mirror_branch wiringOP next wiringOP
mirror_branch wiringOP-Python next wiringOP-Python

echo
echo "Done. Branches on ${DST_URL}:"
git ls-remote --heads "${DST_URL}" | sed 's#.*refs/heads/##'
echo
echo "Next: verify build, then delete old repos (see tools/delete-redundant-repos.sh)."

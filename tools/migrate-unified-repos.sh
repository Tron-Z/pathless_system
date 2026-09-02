#!/bin/bash
#
# Mirror all legacy Pathless split repos into pathless_system (multi-branch).
# Safe to re-run (force push branches). Does NOT delete old repos.
#
set -euo pipefail

OWNER="${OWNER:-Tron-Z}"
DST_REPO="${DST_REPO:-pathless_system}"
SRC_PREFIX="${GIT_PROXY_PREFIX:-https://github.com}"
DST_PREFIX="${DST_GIT_PREFIX:-https://github.com}"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

mirror_branch() {
	local src_repo=$1 src_branch=$2 dst_branch=$3
	local dir="${workdir}/${src_repo//\//_}_${src_branch}"
	echo "==> ${OWNER}/${src_repo}:${src_branch} -> ${OWNER}/${DST_REPO}:${dst_branch}"
	rm -rf "${dir}"
	git clone --bare --branch "${src_branch}" --single-branch \
		"${SRC_PREFIX}/${OWNER}/${src_repo}.git" "${dir}"
	git -C "${dir}" push --force \
		"${DST_PREFIX}/${OWNER}/${DST_REPO}.git" \
		"${src_branch}:${dst_branch}"
}

echo "Mirroring into ${OWNER}/${DST_REPO} ..."

mirror_branch pathless-bsp-kernel pathless-6.6-rk35xx pathless-6.6-rk35xx
mirror_branch pathless-bsp-kernel pathless-5.10-rk35xx pathless-5.10-rk35xx
mirror_branch pathless-bsp-u-boot v2017.09-rk3588 u-boot
mirror_branch pathless-bsp-firmware master firmware
mirror_branch pathless-bsp-config master config
mirror_branch pathless-rockchip rkbin rkbin
mirror_branch pathless-rockchip rk35xx_packages rk35xx_packages
mirror_branch oh-my-zsh master oh-my-zsh
mirror_branch evalcache master evalcache
mirror_branch wiringOP next wiringOP
mirror_branch wiringOP-Python next wiringOP-Python

echo
echo "Done. Branches on ${DST_REPO}:"
git ls-remote --heads "${DST_PREFIX}/${OWNER}/${DST_REPO}.git" | sed 's#.*refs/heads/##'
echo
echo "Next: verify build, then delete legacy repos."

#!/bin/bash
#
# Mirror legacy split repos into unified pathless-bsp / pathless-3rdparty.
# Run once on a machine that can reach GitHub (or via gh-proxy).
#
set -euo pipefail

GIT_SERVER="${GIT_SERVER:-https://github.com/Tron-Z}"
# Optional: export GIT_PROXY_PREFIX="https://gh-proxy.com/https://github.com"
SRC_PREFIX="${GIT_PROXY_PREFIX:-https://github.com}"
DST_AUTH_PREFIX="${DST_AUTH_PREFIX:-https://github.com}"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

mirror_branch() {
	local src_repo=$1 src_branch=$2 dst_repo=$3 dst_branch=$4
	local dir="${workdir}/${src_repo//\//_}_${src_branch}"
	echo "==> ${src_repo}:${src_branch} -> ${dst_repo}:${dst_branch}"
	git clone --bare --branch "${src_branch}" --single-branch \
		"${SRC_PREFIX}/${src_repo}.git" "${dir}"
	git -C "${dir}" push --force \
		"${DST_AUTH_PREFIX}/${dst_repo}.git" \
		"${src_branch}:${dst_branch}"
}

echo "Mirroring into unified Pathless repos..."

mirror_branch Tron-Z/pathless-bsp-u-boot v2017.09-rk3588 Tron-Z/pathless-bsp u-boot
mirror_branch Tron-Z/pathless-bsp-firmware master Tron-Z/pathless-bsp firmware
mirror_branch Tron-Z/pathless-bsp-config master Tron-Z/pathless-bsp config
mirror_branch Tron-Z/pathless-rockchip rkbin Tron-Z/pathless-bsp rkbin
mirror_branch Tron-Z/pathless-rockchip rk35xx_packages Tron-Z/pathless-bsp rk35xx_packages

mirror_branch Tron-Z/oh-my-zsh master Tron-Z/pathless-3rdparty oh-my-zsh
mirror_branch Tron-Z/evalcache master Tron-Z/pathless-3rdparty evalcache
mirror_branch Tron-Z/wiringOP next Tron-Z/pathless-3rdparty wiringOP
mirror_branch Tron-Z/wiringOP-Python next Tron-Z/pathless-3rdparty wiringOP-Python

echo
echo "Done. Verify:"
echo "  git ls-remote ${GIT_SERVER}/pathless-bsp.git"
echo "  git ls-remote ${GIT_SERVER}/pathless-3rdparty.git"
echo
echo "Legacy split repos can be archived after verification."

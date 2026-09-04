#!/bin/bash
#
# Pre-build checks for Pathless RK3566 (u-boot + kernel device trees).
#
set -e

SRC="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="${BOARD:-pathless-rk3566}"
BRANCH="${BRANCH:-current}"
FAIL=0

branch2dir() {
	[[ "${1}" == "head" ]] && echo "HEAD" || echo "${1##*:}"
}

# shellcheck source=/dev/null
source "${SRC}/userpatches/config-default.conf" 2>/dev/null || true
# shellcheck source=/dev/null
source "${SRC}/external/config/sources/arm64.conf"
# shellcheck source=/dev/null
source "${SRC}/external/config/boards/${BOARD}.conf"
# shellcheck source=/dev/null
source "${SRC}/external/config/sources/families/rockchip-rk356x.conf"

UBOOT_DTS="${SRC}/u-boot/$(branch2dir "${BOOTBRANCH}")/arch/arm/dts/rk3566-pathless-3b.dts"
KERNEL_DTS="${SRC}/kernel/$(branch2dir "${KERNELBRANCH}")/arch/arm64/boot/dts/rockchip/rk3566-pathless-3b.dts"
KERNEL_DTS_V2_BRANDING="${SRC}/external/branding/kernel/6.6/rk3566-pathless-3b-v2.dts"

check_file() {
	local label=$1 path=$2
	if [[ -f $path ]]; then
		echo "[ok] $label: $path"
	else
		echo "[FAIL] $label missing: $path"
		echo "       Run: bash tools/refresh-bsp-sources.sh"
		FAIL=1
	fi
}

check_absent() {
	local label=$1 path=$2
	if [[ -f $path ]]; then
		echo "[FAIL] $label should not exist (stale tree): $path"
		FAIL=1
	else
		echo "[ok] $label absent (expected): $(basename "$path")"
	fi
}

echo "Pathless RK3566 BSP verification (BOARD=$BOARD BRANCH=$BRANCH)"
echo

check_file "U-Boot DTS" "$UBOOT_DTS"
check_absent "legacy U-Boot DTS" "${UBOOT_DTS%/rk3566-pathless-3b.dts}/rk3566-orangepi-3b.dts"
check_file "Kernel DTS" "$KERNEL_DTS"
check_file "Kernel DTS v2 branding" "$KERNEL_DTS_V2_BRANDING"
check_absent "legacy Kernel DTS" "${KERNEL_DTS%/rk3566-pathless-3b.dts}/rk3566-orangepi-3b.dts"

if [[ $FAIL -ne 0 ]]; then
	echo
	echo "Fix: bash tools/refresh-bsp-sources.sh && re-run build"
	exit 1
fi

echo
echo "BSP device trees OK — safe to build."

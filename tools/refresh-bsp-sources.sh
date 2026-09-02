#!/bin/bash
#
# Force re-fetch of U-Boot and kernel trees (Pathless RK3566 BSP refresh).
#
set -e
SRC="$(cd "$(dirname "$0")/.." && pwd)"

echo "Removing cached U-Boot and kernel source trees under ${SRC} ..."
rm -rf "${SRC}/u-boot" "${SRC}/kernel"

echo "Done. Re-run build, e.g.:"
echo "  sudo ./build.sh BUILD_OPT=u-boot BOARD=pathless-rk3566 BRANCH=current"

#!/usr/bin/env bash
# Slim clone: only main (build scripts). Kernel/u-boot branches are fetched on demand by build.sh.
set -euo pipefail

DEST="${1:-pathless_system}"
REPO="${REPO_URL:-https://github.com/Tron-Z/pathless_system.git}"

echo "Cloning ${REPO} (single-branch: main) -> ${DEST}"
git clone --single-branch --branch main "${REPO}" "${DEST}"
chmod +x "${DEST}/build.sh" "${DEST}/tools/"*.sh 2>/dev/null || true
echo
echo "Done. Next:"
echo "  cd ${DEST}"
echo "  sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=u-boot KERNEL_CONFIGURE=no"
echo
echo "Note: do NOT use plain 'git clone' without --single-branch; that fetches every branch"
echo "(including huge kernel histories) and can exceed 1GB+."

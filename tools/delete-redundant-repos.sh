#!/bin/bash
#
# Delete redundant Pathless repos after pathless_system migration is verified.
# Requires: gh auth with delete_repo scope.
#
set -euo pipefail

ORG="${ORG:-Tron-Z}"

REQUIRED_BRANCHES=(
	main
	pathless-bsp-u-boot
	pathless-bsp-firmware
	pathless-bsp-config
	pathless-6.6-rk35xx
	pathless-5.10-rk35xx
	rkbin
	rk35xx_packages
	oh-my-zsh
	evalcache
	wiringOP
	wiringOP-Python
)

echo "Checking pathless_system branches..."
remote_branches="$(git ls-remote --heads "https://github.com/${ORG}/pathless_system.git" | sed 's#.*refs/heads/##')"
missing=0
for b in "${REQUIRED_BRANCHES[@]}"; do
	if ! grep -qx "$b" <<<"$remote_branches"; then
		echo "MISSING branch: $b"
		missing=1
	else
		echo "OK  $b"
	fi
done
[[ $missing -eq 0 ]] || { echo "Abort delete: migration incomplete."; exit 1; }

REPOS_TO_DELETE=(
	pathless-bsp-u-boot
	pathless-bsp-firmware
	pathless-bsp-config
	pathless-bsp-kernel
	pathless-rockchip
	pathless-bsp
	pathless-3rdparty
	oh-my-zsh
	evalcache
	wiringOP
	wiringOP-Python
)

echo
echo "Will delete:"
printf '  - %s/%s\n' "${ORG}" "${REPOS_TO_DELETE[@]}"
echo
read -r -p "Type YES to delete: " ans
[[ $ans == YES ]] || { echo "Cancelled."; exit 0; }

for r in "${REPOS_TO_DELETE[@]}"; do
	echo "Deleting ${ORG}/${r} ..."
	gh repo delete "${ORG}/${r}" --yes
done

echo "Done. Only ${ORG}/pathless_system remains for Pathless build deps."

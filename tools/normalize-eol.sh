#!/bin/bash
# Normalize Windows CRLF to Unix LF for bash build scripts.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fix_file() {
	local f="$1"
	if grep -q $'\r' "$f" 2>/dev/null; then
		sed -i 's/\r$//' "$f"
		echo "fixed: $f"
	fi
}

export -f fix_file
export ROOT

find "$ROOT" -type f \( -name '*.sh' -o -name '*.conf' -o -name '*.inc' \) \
	! -path '*/output/*' ! -path '*/.git/*' ! -path '*/cache/*' \
	-exec bash -c 'fix_file "$0"' {} \;

for f in build.sh; do
	[[ -f "$f" ]] && fix_file "$f"
done

echo "Line endings normalized. Run: sudo ./build.sh ..."

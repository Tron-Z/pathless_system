#!/bin/bash
#
# Copyright (c) 2026 Rockchip Electronics Co., Ltd
#
# SPDX-License-Identifier: GPL-2.0
#

set -euo pipefail

usage() {
	echo "Usage: "
	echo "    $0 -p <plat> -f <file> -c <commit> -s <severity> [-new [content_en] [content_cn]] [-fix <n> [-s severity]]"
	echo
	echo "Note:"
	echo "    quote -f when it contains special characters '{', '}', or ','. Example: \"rv1106_ddr_{924...792}MHz{_tb}_v1.16.bin\""
	echo
	echo "Example: "
	echo "    ./scripts/release-doc.sh -p rk3572 -f rk3572_bl31_v1.09.elf -c 0aa962ed3ab -s important -new \"Supports MCU wake-up|Supports CCI SIP\" \"支持大核断电|支持1G频率的cpu timer\" -fix 3 -s moderate"
	exit 1
}

plat=
manual_file=
add_new=0
add_fix=0
new_content=
new_content_cn=
new_content_en=
fix_rows=0
current_scope=
new_severity=
fix_severity=
build_commit=

while [ "$#" -gt 0 ]; do
	case "$1" in
	-p)
		shift
		[ "$#" -gt 0 ] || usage
		plat="$1"
		;;
	-f)
		shift
		[ "$#" -gt 0 ] || usage
		manual_file="$1"
		;;
	-new)
		add_new=1
		current_scope="new"
		if [ "$#" -gt 1 ] && [ "${2#-}" = "$2" ]; then
			shift
			new_content="$1"
			if [ "$#" -gt 1 ] && [ "${2#-}" = "$2" ]; then
				shift
				if printf '%s' "$new_content" | grep -q '[一-龥]'; then
					new_content_cn="$new_content"
					new_content_en="$1"
				elif printf '%s' "$1" | grep -q '[一-龥]'; then
					new_content_en="$new_content"
					new_content_cn="$1"
				else
					new_content_en="$new_content"
					new_content_cn="$1"
				fi
			fi
		fi
		;;
	-fix)
		add_fix=1
		shift
		[ "$#" -gt 0 ] || usage
		case "$1" in
		''|*[!0-9]*)
			usage
			;;
		esac
		[ "$1" -ge 1 ] || usage
		fix_rows="$1"
		current_scope="fix"
		;;
	-c)
		shift
		[ "$#" -gt 0 ] || usage
		build_commit="$1"
		;;
	-s)
		shift
		[ "$#" -gt 0 ] || usage
		case "$current_scope" in
		fix)
			fix_severity="$1"
			;;
		*)
			new_severity="$1"
			;;
		esac
		;;
	*)
		usage
		;;
	esac
	shift
done

[ -n "$plat" ] || usage
[ -n "$manual_file" ] || usage
[ -n "$build_commit" ] || usage
[ -n "$new_severity" ] || usage
if [ "$add_new" -eq 0 ] && [ "$add_fix" -eq 0 ]; then
	add_new=1
	add_fix=1
	fix_rows=4
fi

if [ "$add_fix" -eq 1 ] && [ "$fix_rows" -eq 0 ]; then
	usage
fi

script_dir=$(cd "$(dirname "$0")" && pwd)
repo_dir=$(cd "$script_dir/.." && pwd)
plat_upper=$(printf '%s' "$plat" | tr '[:lower:]' '[:upper:]')
current_date=$(date +%F)

get_build_commit() {
	git -C "$repo_dir" show --format=%B -s HEAD | awk '
		BEGIN {
			seen = 0
		}
		/^[[:space:]]*[Bb][Uu][Ii][Ll][Dd][[:space:]]+[Ff][Rr][Oo][Mm]/ {
			seen = 1
			next
		}
		seen && /^[[:space:]]*$/ {
			next
		}
		seen {
			if (match($0, /[0-9a-fA-F]+/)) {
				print substr($0, RSTART, RLENGTH)
			}
			exit
		}
	'
}

get_release_file() {
	local line_count
	line_count=$(git -C "$repo_dir" diff-tree --root --no-commit-id --name-status -r --find-renames HEAD | \
		awk '
			$1 == "A" && $2 ~ /^bin\// {
				count++
			}
			$1 ~ /^R[0-9]*$/ && $3 ~ /^bin\// {
				count++
			}
			END {
				print count + 0
			}
		')

	if [ "$line_count" -ne 1 ]; then
		return 0
	fi

	git -C "$repo_dir" diff-tree --root --no-commit-id --name-status -r --find-renames HEAD | awk '
		$1 == "A" && $2 ~ /^bin\// {
			print $2
			exit
		}
		$1 ~ /^R[0-9]*$/ && $3 ~ /^bin\// {
			print $3
			exit
		}
	' | xargs -r basename
}

if [ -n "$manual_file" ]; then
	release_file="$manual_file"
else
	release_file=$(get_release_file)
fi

get_section_title() {
	if [ -n "$release_file" ]; then
		printf '%s\n' "$release_file"
	else
		printf 'rkxxx\n'
	fi
}

get_table_file() {
	printf '%s\n' "$release_file"
}

get_summary_header() {
	local lang="$1"

	if [ "$lang" = "CN" ]; then
		printf '%s\n' '| 时间 | 文件 | 编译 commit | 重要程度 |'
		printf '%s\n' '| ---- | :--- | ----------- | -------- |'
	else
		printf '%s\n' '| Date | File | Build commit | Severity |'
		printf '%s\n' '| ---- | :--- | ------------ | -------- |'
	fi
}

get_fix_header() {
	local lang="$1"

	if [ "$lang" = "CN" ]; then
		printf '%s\n' '| Index | 重要程度 | 更新说明 | 问题现象 | 问题来源 |'
		printf '%s\n' '| ----- | -------- | -------- | -------- | -------- |'
	else
		printf '%s\n' '| Index | Severity | Update | Issue description | Issue source |'
		printf '%s\n' '| ----- | -------- | ------ | ----------------- | ------------ |'
	fi
}

print_summary_section() {
	local lang="$1"
	local section_title="$2"
	local table_file="$3"
	local summary_commit="$4"
	local summary_severity="$5"

	printf '## %s\n\n' "$section_title"
	get_summary_header "$lang"
	printf '| %s | %s | %s | %s |\n\n' \
		"$current_date" "$table_file" "$summary_commit" "$summary_severity"
}

format_severity() {
	local lang="$1"
	local severity="$2"

	case "$severity" in
	"")
		printf '\n'
		;;
	紧急|critical)
		if [ "$lang" = "CN" ]; then
			printf '紧急\n'
		else
			printf 'critical\n'
		fi
		;;
	重要|important)
		if [ "$lang" = "CN" ]; then
			printf '重要\n'
		else
			printf 'important\n'
		fi
		;;
	普通|moderate)
		if [ "$lang" = "CN" ]; then
			printf '普通\n'
		else
			printf 'moderate\n'
		fi
		;;
	*)
		echo "Invalid severity: $severity" >&2
		usage
		;;
	esac
}

print_new_items() {
	local lang="$1"
	local content="$2"

	if [ -z "$content" ]; then
		if [ "$lang" = "CN" ]; then
			cat <<'EOF'
1. xxx。
2. yyy。
EOF
		else
			cat <<'EOF'
1. xxx.
2. yyy.
EOF
		fi
		return 0
	fi

	printf '%s\n' "$content" | awk -v lang="$lang" '
		function trim(s) {
			sub(/^[[:space:]\t.。]+/, "", s)
			sub(/[[:space:]\t.。]+$/, "", s)
			return s
		}
		{
			n = split($0, items, /\|/)
			idx = 0
			for (i = 1; i <= n; i++) {
				item = trim(items[i])
				if (item == "") {
					continue
				}
				idx++
				if (lang == "CN") {
					if (item !~ /[。！？]$/) {
						item = item "。"
					}
				} else {
					if (item !~ /[.!?]$/) {
						item = item "."
					}
				}
				printf "%d. %s\n", idx, item
			}
		}
	'
}

print_new_section() {
	local lang="$1"
	local content

	[ "$add_new" -eq 1 ] || return 0

	case "$lang" in
	CN)
		if [ -n "$new_content_cn" ]; then
			content="$new_content_cn"
		else
			content="$new_content"
		fi
		;;
	*)
		if [ -n "$new_content_en" ]; then
			content="$new_content_en"
		else
			content="$new_content"
		fi
		;;
	esac

	cat <<'EOF'
### New

EOF
	print_new_items "$lang" "$content"
	echo
}

print_fix_section() {
	local lang="$1"
	local rows="$2"
	local severity="$3"
	local i

	[ "$add_fix" -eq 1 ] || return 0

	printf '### Fixed\n\n'
	get_fix_header "$lang"

	i=1
	while [ "$i" -le "$rows" ]; do
		if [ "$lang" = "CN" ]; then
			printf '| %d     | %s |          |          |          |\n' "$i" "$severity"
		else
			printf '| %d     | %s |        |                   |              |\n' "$i" "$severity"
		fi
		i=$((i + 1))
	done
	echo
}

insert_template() {
	local target="$1"
	local lang="$2"
	local tmp
	local section_title
	local table_file
	local header_severity
	local fix_row_severity

	section_title=$(get_section_title)
	table_file=$(get_table_file)
	header_severity=$(format_severity "$lang" "$new_severity")
	fix_row_severity=$(format_severity "$lang" "$fix_severity")

	if [ ! -f "$target" ]; then
		echo "Missing file: $target" >&2
		exit 1
	fi

	tmp=$(mktemp)
	{
		sed -n '1p' "$target"
		echo
		print_summary_section "$lang" "$section_title" "$table_file" "$build_commit" "$header_severity"
		print_new_section "$lang"
		print_fix_section "$lang" "$fix_rows" "$fix_row_severity"
		echo "------"
		sed -n '2,$p' "$target"
	} > "$tmp"
	mv "$tmp" "$target"
}

insert_template \
	"$repo_dir/doc/release/${plat_upper}_CN.md" \
	"CN"
insert_template \
	"$repo_dir/doc/release/${plat_upper}_EN.md" \
	"EN"

git diff doc/release/
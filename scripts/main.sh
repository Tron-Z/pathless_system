#!/bin/bash
#
# Copyright (c) 2013-2021 Igor Pecovnik, igor.pecovnik@gma**.com
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# Main program
#


cleanup_list() {
	local varname="${1}"
	local list_to_clean="${!varname}"
	list_to_clean="${list_to_clean#"${list_to_clean%%[![:space:]]*}"}"
	list_to_clean="${list_to_clean%"${list_to_clean##*[![:space:]]}"}"
	echo ${list_to_clean}
}




if [[ $(basename "$0") == main.sh ]]; then

	echo "Please use build.sh to start the build process"
	exit 255

fi




# default umask for root is 022 so parent directories won't be group writeable without this
# this is used instead of making the chmod in prepare_host() recursive
umask 002

# destination
if [ -d "$CONFIG_PATH/output" ]; then
	DEST="${CONFIG_PATH}"/output
else
	DEST="${SRC}"/output
fi

[[ -z $REVISION ]] && REVISION="3.0.8"

[[ $DOWNLOAD_MIRROR == "china" ]] && NTP_SERVER="cn.pool.ntp.org"

if [[ $BUILD_ALL != "yes" ]]; then
	# override stty size
	[[ -n $COLUMNS ]] && stty cols $COLUMNS
	[[ -n $LINES ]] && stty rows $LINES
	TTY_X=$(($(stty size | awk '{print $2}')-6)) 			# determine terminal width
	TTY_Y=$(($(stty size | awk '{print $1}')-6)) 			# determine terminal height
fi

# We'll use this title on all menus
backtitle="Pathless building script, https://github.com/Tron-Z" 
titlestr="Choose an option"

# Warnings mitigation
[[ -z $LANGUAGE ]] && export LANGUAGE="en_US:en"            # set to english if not set
[[ -z $CONSOLE_CHAR ]] && export CONSOLE_CHAR="UTF-8"       # set console to UTF-8 if not set

# Libraries include

# shellcheck source=debootstrap.sh
source "${SRC}"/scripts/debootstrap.sh	# system specific install
# shellcheck source=image-helpers.sh
source "${SRC}"/scripts/image-helpers.sh	# helpers for OS image building
# shellcheck source=distributions.sh
source "${SRC}"/scripts/distributions.sh	# system specific install
# shellcheck source=desktop.sh
source "${SRC}"/scripts/desktop.sh		# desktop specific install
# shellcheck source=compilation.sh
source "${SRC}"/scripts/compilation.sh	# patching and compilation of kernel, uboot, ATF
# shellcheck source=compilation-prepare.sh
#source "${SRC}"/scripts/compilation-prepare.sh	# drivers that are not upstreamed
# shellcheck source=makeboarddeb.sh
source "${SRC}"/scripts/makeboarddeb.sh		# board support package
# shellcheck source=general.sh
source "${SRC}"/scripts/general.sh		# general functions
# shellcheck source=chroot-buildpackages.sh
source "${SRC}"/scripts/chroot-buildpackages.sh	# chroot packages building
# shellcheck source=pack.sh
source "${SRC}"/scripts/pack-uboot.sh
# shellcheck source=build-cix-image.sh
source "${SRC}"/scripts/build-cix-image.sh


# set log path
LOG_SUBPATH=${LOG_SUBPATH:=debug}

# compress and remove old logs
mkdir -p "${DEST}"/${LOG_SUBPATH}
(cd "${DEST}"/${LOG_SUBPATH} && tar -czf logs-"$(<timestamp)".tgz ./*.log) > /dev/null 2>&1
rm -f "${DEST}"/${LOG_SUBPATH}/*.log > /dev/null 2>&1
date +"%d_%m_%Y-%H_%M_%S" > "${DEST}"/${LOG_SUBPATH}/timestamp

# delete compressed logs older than 7 days
(cd "${DEST}"/${LOG_SUBPATH} && find . -name '*.tgz' -mtime +7 -delete) > /dev/null

if [[ $PROGRESS_DISPLAY == none ]]; then

	OUTPUT_VERYSILENT=yes

elif [[ $PROGRESS_DISPLAY == dialog ]]; then

	OUTPUT_DIALOG=yes

fi

if [[ $PROGRESS_LOG_TO_FILE != yes ]]; then unset PROGRESS_LOG_TO_FILE; fi



SHOW_WARNING=yes



if [[ $USE_CCACHE != no ]]; then

	CCACHE=ccache
	export PATH="/usr/lib/ccache:$PATH"
	# private ccache directory to avoid permission issues when using build script with "sudo"
	# see https://ccache.samba.org/manual.html#_sharing_a_cache for alternative solution
	[[ $PRIVATE_CCACHE == yes ]] && export CCACHE_DIR=$EXTER/cache/ccache

else

	CCACHE=""

fi




if [[ -n $REPOSITORY_UPDATE ]]; then

		# select stable/beta configuration
		if [[ $BETA == yes ]]; then
				DEB_STORAGE=$DEST/debs-beta
				REPO_STORAGE=$DEST/repository-beta
				REPO_CONFIG="aptly-beta.conf"
		else
				DEB_STORAGE=$DEST/debs
				REPO_STORAGE=$DEST/repository
				REPO_CONFIG="aptly.conf"
		fi

		# For user override
		if [[ -f "${USERPATCHES_PATH}"/lib.config ]]; then
				display_alert "Using user configuration override" "userpatches/lib.config" "info"
			source "${USERPATCHES_PATH}"/lib.config
		fi

		repo-manipulate "$REPOSITORY_UPDATE"
		exit

fi




if [[ -z $BOARD ]]; then
	BOARD="pathless-rk3566"
fi

BOARD_TYPE="conf"
# shellcheck source=/dev/null
source "${EXTER}/config/boards/${BOARD}.${BOARD_TYPE}"
LINUXFAMILY="${BOARDFAMILY}"

[[ -z $KERNEL_TARGET ]] && exit_with_error "Board configuration does not define valid kernel config"

# if BUILD_OPT, KERNEL_CONFIGURE, BOARD, BRANCH or RELEASE are not set, display selection menu
if [[ -z $BUILD_OPT ]]; then

	if [[ $BOARDFAMILY != "cix" ]]; then
		options+=("u-boot"	 "U-boot  — 仅编译 U-Boot")
	fi
	options+=("kernel"	 "Kernel  — 仅编译内核")
	options+=("rootfs"	 "Rootfs  — 仅编译 rootfs 及 deb 包")
	options+=("pack"	 "Pack    — 仅打包镜像 (与 Image 相同流程, 跳过 u-boot/内核)")
	options+=("image"	 "Image   — 完整编译并打包镜像")

	if [[ $BOARDFAMILY != "cix" ]]; then
		menustr="请选择编译目标: u-boot | kernel | rootfs | pack | image"
	else
		menustr="请选择编译目标: kernel | rootfs | pack | image"
	fi
	BUILD_OPT=$(whiptail --title "${titlestr}" --backtitle "${backtitle}" --notags \
			  --menu "${menustr}" "${TTY_Y}" "${TTY_X}" $((TTY_Y - 8))  \
			  --cancel-button Exit --ok-button Select "${options[@]}" \
			  3>&1 1>&2 2>&3)

	unset options
	[[ -z $BUILD_OPT ]] && exit_with_error "No option selected"
	[[ $BUILD_OPT == rootfs ]] && ROOT_FS_CREATE_ONLY="yes"
fi




if [[ ${BUILD_OPT} =~ kernel|image ]]; then

	if [[ -z $KERNEL_CONFIGURE ]]; then

		options+=("no" "不修改内核配置")
		options+=("yes" "编译前打开内核配置菜单")

		menustr="请选择是否配置内核"
		KERNEL_CONFIGURE=$(whiptail --title "${titlestr}" --backtitle "$backtitle" --notags \
						 --menu "${menustr}" $TTY_Y $TTY_X $((TTY_Y - 8)) \
						 --cancel-button Exit --ok-button Select "${options[@]}" \
						 3>&1 1>&2 2>&3)

		unset options
		[[ -z $KERNEL_CONFIGURE ]] && exit_with_error "No option selected"
	fi
fi




if [[ -z $BRANCH ]]; then

	options=()
	[[ $KERNEL_TARGET == *current* ]] && options+=("current"	 "Current — 推荐，支持最好 (6.6)")
	[[ $KERNEL_TARGET == *legacy* ]] && options+=("legacy"	 "Legacy  — 旧稳定版 (5.10)")
	[[ $KERNEL_TARGET == *next* ]] && options+=("next"	 "Next    — 最新内核")

	menustr="请选择内核分支 (与 Orange Pi RK3566 对齐)"
	# do not display selection dialog if only one kernel branch is available
	if [[ "${#options[@]}" == 2 ]]; then
		BRANCH="${options[0]}"
	else
		BRANCH=$(whiptail --title "${titlestr}" --backtitle "${backtitle}" \
				  --menu "${menustr}" "${TTY_Y}" "${TTY_X}" $((TTY_Y - 8))  \
				  --cancel-button Exit --ok-button Select "${options[@]}" \
				  3>&1 1>&2 2>&3)
	fi
	unset options
	[[ -z $BRANCH ]] && exit_with_error "No kernel branch selected"
	[[ $BRANCH == dev && $SHOW_WARNING == yes ]] && show_developer_warning

fi

if [[ $BUILD_OPT =~ rootfs|image|pack && -z $RELEASE ]]; then

	options=()

	distros_options

	menustr="请选择文件系统 / 发行版版本"
	RELEASE=$(whiptail --title "选择文件系统版本" --backtitle "${backtitle}" \
			  --menu "${menustr}" "${TTY_Y}" "${TTY_X}" $((TTY_Y - 8))  \
			  --cancel-button Exit --ok-button Select "${options[@]}" \
			  3>&1 1>&2 2>&3)
	#echo "options : ${options}"
	[[ -z $RELEASE ]] && exit_with_error "No release selected"

	unset options
fi

# don't show desktop option if we choose minimal build
[[ $BUILD_MINIMAL == yes ]] && BUILD_DESKTOP=no

if [[ $BUILD_OPT =~ rootfs|image|pack && -z $BUILD_DESKTOP ]]; then

	# read distribution support status which is written to the pathless-release file
	set_distribution_status

	options=()
	options+=("no" "Server  — 无桌面镜像")
	options+=("yes" "Desktop — 带桌面镜像")

	menustr="请选择镜像类型"
	BUILD_DESKTOP=$(whiptail --title "选择镜像类型" --backtitle "${backtitle}" \
			  --menu "${menustr}" "${TTY_Y}" "${TTY_X}" $((TTY_Y - 8))  \
			  --cancel-button Exit --ok-button Select "${options[@]}" \
			  3>&1 1>&2 2>&3)
	unset options
	[[ -z $BUILD_DESKTOP ]] && exit_with_error "No option selected"
	if [[ ${BUILD_DESKTOP} == "yes" ]]; then
		BUILD_MINIMAL=no
		SELECTED_CONFIGURATION="desktop"
	fi

fi

if [[ $BUILD_OPT =~ rootfs|image|pack && $BUILD_DESKTOP == no && -z $BUILD_MINIMAL ]]; then

	options=()
	options+=("no" "Standard — 标准镜像")
	options+=("yes" "Minimal  — 精简镜像")
	menustr="请选择镜像精简程度"
	BUILD_MINIMAL=$(whiptail --title "选择镜像类型" --backtitle "${backtitle}" \
			  --menu "${menustr}" "${TTY_Y}" "${TTY_X}" $((TTY_Y - 8))  \
			  --cancel-button Exit --ok-button Select "${options[@]}" \
			  3>&1 1>&2 2>&3)
	unset options
	[[ -z $BUILD_MINIMAL ]] && exit_with_error "No option selected"
	if [[ $BUILD_MINIMAL == "yes" ]]; then
		SELECTED_CONFIGURATION="cli_minimal"
	else
		SELECTED_CONFIGURATION="cli_standard"
	fi

fi

#prevent conflicting setup
if [[ $BUILD_DESKTOP == "yes" ]]; then
	BUILD_MINIMAL=no
	SELECTED_CONFIGURATION="desktop"
elif [[ $BUILD_MINIMAL != "yes" || -z "${BUILD_MINIMAL}" ]]; then
	BUILD_MINIMAL=no # Just in case BUILD_MINIMAL is not defined
	BUILD_DESKTOP=no
	SELECTED_CONFIGURATION="cli_standard"
elif [[ $BUILD_MINIMAL == "yes" ]]; then
	BUILD_DESKTOP=no
	SELECTED_CONFIGURATION="cli_minimal"
fi

#[[ ${KERNEL_CONFIGURE} == prebuilt ]] && [[ -z ${REPOSITORY_INSTALL} ]] && \
#REPOSITORY_INSTALL="u-boot,kernel,bsp,pathless-zsh,pathless-config,pathless-firmware${BUILD_DESKTOP:+,pathless-desktop}"


#shellcheck source=configuration.sh
source "${SRC}"/scripts/configuration.sh

# optimize build time with 100% CPU usage
CPUS=$(grep -c 'processor' /proc/cpuinfo)
if [[ $USEALLCORES != no ]]; then

	CTHREADS="-j$((CPUS + CPUS/2))"

else

	CTHREADS="-j1"

fi

call_extension_method "post_determine_cthreads" "config_post_determine_cthreads" << 'POST_DETERMINE_CTHREADS'
*give config a chance modify CTHREADS programatically. A build server may work better with hyperthreads-1 for example.*
Called early, before any compilation work starts.
POST_DETERMINE_CTHREADS

if [[ $BETA == yes ]]; then
	IMAGE_TYPE=nightly
elif [[ $BETA != "yes" && $BUILD_ALL == yes && -n $GPG_PASS ]]; then
	IMAGE_TYPE=stable
else
	IMAGE_TYPE=user-built
fi

branch2dir() {
	[[ "${1}" == "head" ]] && echo "HEAD" || echo "${1##*:}"
}

BOOTSOURCEDIR="${BOOTDIR}/$(branch2dir "${BOOTBRANCH}")"
LINUXSOURCEDIR="${KERNELDIR}/$(branch2dir "${KERNELBRANCH}")"
[[ -n $ATFSOURCE ]] && ATFSOURCEDIR="${ATFDIR}/$(branch2dir "${ATFBRANCH}")"

BSP_CLI_PACKAGE_NAME="pathless-bsp-cli-${BOARD}"
BSP_CLI_PACKAGE_FULLNAME="${BSP_CLI_PACKAGE_NAME}_${REVISION}_${ARCH}"
BSP_DESKTOP_PACKAGE_NAME="pathless-bsp-desktop-${BOARD}"
BSP_DESKTOP_PACKAGE_FULLNAME="${BSP_DESKTOP_PACKAGE_NAME}_${REVISION}_${ARCH}"

CHOSEN_UBOOT=linux-u-boot-${BRANCH}-${BOARD}
CHOSEN_KERNEL=linux-image-${BRANCH}-${LINUXFAMILY}
CHOSEN_ROOTFS=${BSP_CLI_PACKAGE_NAME}
CHOSEN_DESKTOP=pathless-${RELEASE}-desktop-${DESKTOP_ENVIRONMENT}
CHOSEN_KSRC=linux-source-${BRANCH}-${LINUXFAMILY}

do_default() {

start=$(date +%s)

# Check and install dependencies, directory structure and settings
# The OFFLINE_WORK variable inside the function
prepare_host

[[ "${JUST_INIT}" == "yes" ]] && exit 0

[[ $CLEAN_LEVEL == *sources* ]] && cleaning "sources"

# fetch_from_repo <url> <dir> <ref> <subdir_flag>

# ignore updates help on building all images - for internal purposes
if [[ ${IGNORE_UPDATES} != yes ]]; then

	display_alert "Downloading sources" "" "info"

	if [[ $BOARDFAMILY != "cix" ]]; then

		[[ $BUILD_OPT =~ u-boot|image ]] && fetch_from_repo "$BOOTSOURCE" "$BOOTDIR" "$BOOTBRANCH" "yes"

		if [[ $BOARD == pathless-rk3566 && $BUILD_OPT =~ u-boot|image ]]; then
			[[ -f "${BOOTSOURCEDIR}/arch/arm/dts/rk3566-pathless-3b.dts" ]] || \
				exit_with_error "Missing U-Boot device tree" "rm -rf ${BOOTDIR} && rebuild (need rk3566-pathless-3b.dts from pathless-bsp-u-boot)"
		fi

	fi

	if [[ $BOARDFAMILY == "cix" ]]; then

		if [[ ${GITEE_SERVER} == yes ]]; then
			fetch_from_repo "https://github.com/Tron-Z/component_cix-$BRANCH.git" "${EXTER}/cache/sources/component_cix-$BRANCH" "branch:main"

			if [[ ! -f "${EXTER}/cache/sources/component_cix-$BRANCH/debs/cix-npu-onnxruntime_1.2.0_arm64.deb" ]]; then
				display_alert "Downloading deb" "cix-npu-onnxruntime" "info"
				wget -c -t 5 -P "${EXTER}/cache/sources/component_cix-$BRANCH/debs/" \
				http://www.iplaystore.cn/upload/debs/cix-npu-onnxruntime_1.2.0_arm64.deb
			fi
		else
			fetch_from_repo "https://github.com/Tron-Z/component_cix-$BRANCH.git" "${EXTER}/cache/sources/component_cix-$BRANCH" "branch:main"

			if [[ ! -f "${EXTER}/cache/sources/component_cix-$BRANCH/debs/cix-npu-onnxruntime_1.2.0_arm64.deb" ]]; then
				display_alert "Downloading deb" "cix-npu-onnxruntime" "info"
				wget -c -t 5 -P "${EXTER}/cache/sources/component_cix-$BRANCH/debs/" \
				https://github.com/Tron-Z/component_cix-${BRANCH}/releases/download/v1.2.0/cix-npu-onnxruntime_1.2.0_arm64.deb
			fi
		fi

	fi

	[[ $BUILD_OPT =~ kernel|image ]] && fetch_from_repo "$KERNELSOURCE" "$KERNELDIR" "$KERNELBRANCH" "yes"

	if [[ $BOARD == pathless-rk3566 && $BUILD_OPT =~ kernel|image ]]; then
		[[ -f "${LINUXSOURCEDIR}/arch/arm64/boot/dts/rockchip/rk3566-pathless-3b.dts" ]] || \
			exit_with_error "Missing kernel device tree" "rm -rf ${KERNELDIR} && rebuild (need rk3566-pathless-3b.dts from pathless-bsp-kernel)"
	fi

	if [[ -n ${ATFSOURCE} ]]; then

		[[ ${BUILD_OPT} =~ u-boot|image ]] && fetch_from_repo "$ATFSOURCE" "${EXTER}/cache/sources/$ATFDIR" "$ATFBRANCH" "yes"

	fi

	if [[ ${BOARDFAMILY} == "rockchip-rk356x" && $RELEASE =~ bullseye|focal|jammy|raspi ]]; then

		[[ ${BUILD_OPT} =~ image|pack ]] && fetch_from_repo "${PATHLESS_ROCKCHIP_REPO}" "${EXTER}/cache/sources/rk35xx_packages" "${PATHLESS_RK35XX_PACKAGES_BRANCH}"

	fi

	call_extension_method "fetch_sources_tools"  <<- 'FETCH_SOURCES_TOOLS'
	*fetch host-side sources needed for tools and build*
	Run early to fetch_from_repo or otherwise obtain sources for needed tools.
	FETCH_SOURCES_TOOLS

	call_extension_method "build_host_tools"  <<- 'BUILD_HOST_TOOLS'
	*build needed tools for the build, host-side*
	After sources are fetched, build host-side tools needed for the build.
	BUILD_HOST_TOOLS
fi

for option in $(tr ',' ' ' <<< "$CLEAN_LEVEL"); do
	[[ $option != sources ]] && cleaning "$option"
done

# Compile u-boot if packed .deb does not exist or use the one from Pathless
if [[ $BUILD_OPT == u-boot || $BUILD_OPT == image ]]; then

	if [[ $BOARDFAMILY != "cix" ]]; then
		if [[ ! -f "${DEB_STORAGE}"/u-boot/${CHOSEN_UBOOT}_${REVISION}_${ARCH}.deb ]]; then

			[[ -n "${ATFSOURCE}" && "${REPOSITORY_INSTALL}" != *u-boot* ]] && compile_atf

			[[ ${REPOSITORY_INSTALL} != *u-boot* ]] && compile_uboot
		fi

		if [[ $BUILD_OPT == "u-boot" ]]; then
			unset BUILD_MINIMAL BUILD_DESKTOP COMPRESS_OUTPUTIMAGE
			display_alert "U-boot build done" "@host" "info"
			display_alert "Target directory" "${DEB_STORAGE}/u-boot" "info"
			display_alert "File name" "${CHOSEN_UBOOT}_${REVISION}_${ARCH}.deb" "info"
		fi
	fi
fi

# Compile kernel if packed .deb does not exist or use the one from Pathless
if [[ $BUILD_OPT == kernel || $BUILD_OPT == image ]]; then

	if [[ ! -f ${DEB_STORAGE}/${CHOSEN_KERNEL}_${REVISION}_${ARCH}.deb ]]; then 

		KDEB_CHANGELOG_DIST=$RELEASE
		[[ "${REPOSITORY_INSTALL}" != *kernel* ]] && compile_kernel
	fi

	if [[ $BUILD_OPT == "kernel" ]]; then
		unset BUILD_MINIMAL BUILD_DESKTOP COMPRESS_OUTPUTIMAGE
		display_alert "Kernel build done" "@host" "info"
		display_alert "Target directory" "${DEB_STORAGE}/" "info"
		display_alert "File name" "${CHOSEN_KERNEL}_${REVISION}_${ARCH}.deb" "info"
	fi
fi

if [[ $BUILD_OPT == rootfs || $BUILD_OPT == image || $BUILD_OPT == pack ]]; then

	# Compile pathless-config if packed .deb does not exist or use the one from Pathless
	if [[ ! -f ${DEB_STORAGE}/pathless-config_${REVISION}_all.deb ]]; then

		[[ $IGNORE_UPDATES != yes ]] && fetch_from_repo "${PATHLESS_BSP_CONFIG_REPO}" "${EXTER}/cache/sources/pathless-config" "${PATHLESS_CONFIG_BRANCH:-branch:master}"
		[[ "${REPOSITORY_INSTALL}" != *pathless-config* ]] && compile_pathless-config
	fi

	# Compile pathless-zsh if packed .deb does not exist or use the one from repository
	if [[ ! -f ${DEB_STORAGE}/pathless-zsh_${REVISION}_all.deb ]]; then

	        [[ "${REPOSITORY_INSTALL}" != *pathless-zsh* ]] && compile_pathless-zsh
	fi

	# Compile plymouth-theme-pathless if packed .deb does not exist or use the one from repository
	if [[ ! -f ${DEB_STORAGE}/plymouth-theme-pathless_${REVISION}_all.deb && $PLYMOUTH == yes ]]; then

		[[ "${REPOSITORY_INSTALL}" != *plymouth-theme-pathless* ]] && compile_plymouth-theme-pathless
	fi

	# Compile pathless-firmware if packed .deb does not exist or use the one from repository
	if [[ "${REPOSITORY_INSTALL}" != *pathless-firmware* ]]; then

		if ! ls "${DEB_STORAGE}/pathless-firmware_${REVISION}_all.deb" 1> /dev/null 2>&1; then

			FULL=""
			REPLACE="-full"
			compile_firmware

		fi

	fi

	overlayfs_wrapper "cleanup"
	
	# create board support package
	[[ -n $RELEASE && ! -f ${DEB_STORAGE}/$RELEASE/${BSP_CLI_PACKAGE_FULLNAME}.deb ]] && create_board_package

	[[ -n $RELEASE && $DESKTOP_ENVIRONMENT ]] && create_desktop_package
	[[ -n $RELEASE && $DESKTOP_ENVIRONMENT ]] && create_bsp_desktop_package
	
	# build additional packages
	[[ $EXTERNAL_NEW == compile ]] && chroot_build_packages

	[[ $BSP_BUILD != yes ]] && debootstrap_ng

fi

# hook for function to run after build, i.e. to change owner of $SRC
# NOTE: this will run only if there were no errors during build process
[[ $(type -t run_after_build) == function ]] && run_after_build || true

end=$(date +%s)
runtime=$(((end-start)/60))
display_alert "Runtime" "$runtime min" "info"

# Make it easy to repeat build by displaying build options used
[ "$(systemd-detect-virt)" == 'docker' ] && BUILD_CONFIG='docker'

display_alert "Repeat Build Options" "sudo ./build.sh ${BUILD_CONFIG} BOARD=${BOARD} BRANCH=${BRANCH} \
$([[ -n $BUILD_OPT ]] && echo "BUILD_OPT=${BUILD_OPT} ")\
$([[ -n $RELEASE ]] && echo "RELEASE=${RELEASE} ")\
$([[ -n $BUILD_MINIMAL ]] && echo "BUILD_MINIMAL=${BUILD_MINIMAL} ")\
$([[ -n $BUILD_DESKTOP ]] && echo "BUILD_DESKTOP=${BUILD_DESKTOP} ")\
$([[ -n $KERNEL_CONFIGURE ]] && echo "KERNEL_CONFIGURE=${KERNEL_CONFIGURE} ")\
$([[ -n $DESKTOP_ENVIRONMENT ]] && echo "DESKTOP_ENVIRONMENT=${DESKTOP_ENVIRONMENT} ")\
$([[ -n $DESKTOP_ENVIRONMENT_CONFIG_NAME  ]] && echo "DESKTOP_ENVIRONMENT_CONFIG_NAME=${DESKTOP_ENVIRONMENT_CONFIG_NAME} ")\
$([[ -n $DESKTOP_APPGROUPS_SELECTED ]] && echo "DESKTOP_APPGROUPS_SELECTED=\"${DESKTOP_APPGROUPS_SELECTED}\" ")\
$([[ -n $DESKTOP_APT_FLAGS_SELECTED ]] && echo "DESKTOP_APT_FLAGS_SELECTED=\"${DESKTOP_APT_FLAGS_SELECTED}\" ")\
$([[ -n $COMPRESS_OUTPUTIMAGE ]] && echo "COMPRESS_OUTPUTIMAGE=${COMPRESS_OUTPUTIMAGE} ")\
" "ext"

} # end of do_default()

if [[ -z $1 ]]; then
	do_default
else
	eval "$@"
fi

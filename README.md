# Pathless Build

Pathless 官方镜像构建系统，当前支持 **Rockchip RK3566** 平台。

## 仓库结构（GitHub: [Tron-Z](https://github.com/Tron-Z)）

| 仓库 | 来源 | 内容 |
|:--|:--|:--|
| [pathless-build](https://github.com/Tron-Z/pathless-build) | Pathless | 构建工程 |
| [pathless-bsp-kernel](https://github.com/Tron-Z/pathless-bsp-kernel) | Pathless 内核 | `pathless-6.6-rk35xx` / `pathless-5.10-rk35xx`（每月自动同步） |
| [pathless-rockchip](https://github.com/Tron-Z/pathless-rockchip) | 瑞芯微二进制 | `rkbin`、`rk35xx_packages`（每月自动同步上游） |
| [pathless-bsp-u-boot](https://github.com/Tron-Z/pathless-bsp-u-boot) | Pathless U-Boot | U-Boot + `pathless-rk3566_defconfig` |
| [pathless-bsp-firmware](https://github.com/Tron-Z/pathless-bsp-firmware) | Pathless firmware | 板级 firmware |
| [pathless-bsp-config](https://github.com/Tron-Z/pathless-bsp-config) | Pathless 系统配置 | pathless-config 工具 |

## 快速开始

```bash
git clone https://github.com/Tron-Z/pathless-build.git
cd pathless-build
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

远程地址与分支名见 `external/config/sources/pathless-repos.conf`。

## 构建选项（BUILD_OPT）

运行 `sudo ./build.sh` 时会弹出编译目标菜单（另含仅打包项）：

| 选项 | 说明 |
|:--|:--|
| `u-boot` | 仅编译 U-Boot |
| `kernel` | 仅编译内核 |
| `rootfs` | 仅编译 rootfs 及 deb 包 |
| `pack` | **仅打包镜像**（与 `image` 打包流程相同；跳过 u-boot/内核编译，适用于分步编译后手动打包） |
| `image` | 完整编译并打包镜像 |

非交互指定目标示例：

```bash
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=pack RELEASE=jammy BUILD_DESKTOP=no
```

`userpatches/config-default.conf` 中 `BUILD_OPT` 留空即可每次启动显示菜单。

分步编译示例：先分别执行 `u-boot`、`kernel`、`rootfs`，产物就绪后再执行 `pack` 生成镜像（打包步骤与 `BUILD_OPT=image` 完全一致）。

## U-Boot / 内核设备树

Pathless RK3566 使用 **`rk3566-pathless-3b.dts`**，产物为 **`rk3566-pathless-3b.dtb`**（源码在 `pathless-bsp-u-boot` / `pathless-bsp-kernel` 仓库，无 orangepi 命名）。

更新源码后若编译仍用旧树，请强制刷新：

```bash
rm -rf u-boot kernel external/cache/sources/pathless-firmware-git
sudo ./build.sh BUILD_OPT=u-boot BOARD=pathless-rk3566 BRANCH=current
```

查看详细错误：`tail -80 output/debug/compilation.log`

## 从 Windows 拷贝到 Linux 后报错 `$'\r'`

脚本必须是 **Unix LF** 换行。在工程根目录执行：

```bash
bash tools/normalize-eol.sh
```

或：`find . -type f \( -name '*.sh' -o -name '*.conf' -o -name '*.inc' \) -exec sed -i 's/\r$//' {} + && sed -i 's/\r$//' build.sh`

建议工程放在 Linux 本地目录（如 `~/pathless-build`），不要长期在 `/mnt/c` 或 SMB 共享盘上编译。

## 许可证

构建脚本 GPL-2.0；瑞芯微闭源二进制版权归 Rockchip 所有。

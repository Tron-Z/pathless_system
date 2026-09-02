# Pathless Build

Pathless 官方镜像构建系统，当前支持 **Rockchip RK3566** 平台。

## 仓库结构（GitHub: [Tron-Z](https://github.com/Tron-Z)）

| 仓库 | 来源 | 内容 |
|:--|:--|:--|
| [pathless-build](https://github.com/Tron-Z/pathless-build) | Pathless | 构建工程 |
| [pathless-bsp-kernel](https://github.com/Tron-Z/pathless-bsp-kernel) | Orange Pi 内核 fork | `pathless-6.6-rk35xx` / `pathless-5.10-rk35xx`（每月自动同步） |
| [pathless-rockchip](https://github.com/Tron-Z/pathless-rockchip) | 瑞芯微 | `rkbin`、`rk35xx_packages`（每月自动同步上游） |
| [pathless-bsp-u-boot](https://github.com/Tron-Z/pathless-bsp-u-boot) | Orange Pi U-Boot fork | U-Boot + `pathless-rk3566_defconfig` |
| [pathless-bsp-firmware](https://github.com/Tron-Z/pathless-bsp-firmware) | Orange Pi firmware fork | 板级 firmware |
| [pathless-bsp-config](https://github.com/Tron-Z/pathless-bsp-config) | Armbian config fork | pathless-config 工具 |

## 快速开始

```bash
git clone https://github.com/Tron-Z/pathless-build.git
cd pathless-build
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

远程地址与分支名见 `external/config/sources/pathless-repos.conf`。

## 构建选项（BUILD_OPT）

| 值 | 说明 |
|:--|:--|
| `u-boot` | 仅编译 U-Boot |
| `kernel` | 仅编译内核 |
| `rootfs` | rootfs 及 deb 包 |
| `image` | **完整镜像**（推荐，含上述全部） |

`userpatches/config-default.conf` 已默认 `BUILD_OPT=image`。非交互全量编译：

```bash
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

## 从 Windows 拷贝到 Linux 后报错 `$'\r'`

脚本必须是 **Unix LF** 换行。在工程根目录执行：

```bash
bash tools/normalize-eol.sh
```

或：`find . -type f \( -name '*.sh' -o -name '*.conf' -o -name '*.inc' \) -exec sed -i 's/\r$//' {} + && sed -i 's/\r$//' build.sh`

建议工程放在 Linux 本地目录（如 `~/pathless-build`），不要长期在 `/mnt/c` 或 SMB 共享盘上编译。

## 许可证

构建脚本 GPL-2.0；瑞芯微闭源二进制版权归 Rockchip 所有。

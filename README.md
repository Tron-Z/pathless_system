# Pathless Build

Pathless 官方镜像构建系统，当前支持 **Rockchip RK3566** 平台。

## 仓库结构（GitHub: [Tron-Z](https://github.com/Tron-Z)）

Fork 来源按类别归并，统一 Pathless 命名：

| 仓库 | 来源 | 内容 |
|:--|:--|:--|
| [pathless-build](https://github.com/Tron-Z/pathless-build) | Pathless | 构建工程 |
| [pathless-rockchip](https://github.com/Tron-Z/pathless-rockchip) | 瑞芯微 | 闭源二进制：`rkbin`、`rk35xx_packages` |
| [pathless-bsp](https://github.com/Tron-Z/pathless-bsp) | Orange Pi 内核 fork | 内核分支（Pathless 命名） |
| [pathless-bsp-u-boot](https://github.com/Tron-Z/pathless-bsp-u-boot) | Orange Pi U-Boot fork | U-Boot + `pathless-rk3566_defconfig` |
| [pathless-bsp-firmware](https://github.com/Tron-Z/pathless-bsp-firmware) | Orange Pi firmware fork | 板级 firmware |
| [pathless-bsp-config](https://github.com/Tron-Z/pathless-bsp-config) | Armbian config fork | pathless-config 工具 |

### pathless-bsp 内核分支

- `pathless-6.6-rk35xx` — current
- `pathless-5.10-rk35xx` — legacy

### pathless-rockchip 分支

- `rkbin` — Rockchip rkbin 工具
- `rk35xx_packages` — GPU/VPU/MPP 预编译 deb

## 快速开始

```bash
git clone https://github.com/Tron-Z/pathless-build.git
cd pathless-build
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

远程地址与分支名集中在 `external/config/sources/pathless-repos.conf`。

## 许可证

构建脚本 GPL-2.0；瑞芯微闭源二进制版权归 Rockchip 所有。

# Pathless Build

Pathless 官方镜像构建系统，当前支持 **Rockchip RK3566** 平台（同型 RK3566 硬件参考设计，品牌为 Pathless）。

构建框架基于 Armbian 脚本体系，内核与 U-Boot 使用 Pathless 维护的 Rockchip 分支。

## 支持板型

| SoC | 板型 |
|:--|:--|
| Rockchip RK3566 | Pathless RK3566 |

后续可在 `external/config/boards/` 与 `external/config/sources/families/` 中扩展其他芯片。

## 依赖仓库（GitHub: [Tron-Z](https://github.com/Tron-Z)）

构建前请在 GitHub 组织 **Tron-Z** 下准备以下仓库（可从上游 fork 并重命名分支）：

| 仓库 | 说明 |
|:--|:--|
| [pathless-build](https://github.com/Tron-Z/pathless-build) | 本构建工程 |
| [linux-rk3566](https://github.com/Tron-Z/linux-rk3566) | 内核，需含分支 `pathless-6.6-rk35xx`、`pathless-5.10-rk35xx` |
| [u-boot-rk3566](https://github.com/Tron-Z/u-boot-rk3566) | U-Boot，需含 `pathless-rk3566_defconfig` |
| [rk-rootfs-build](https://github.com/Tron-Z/rk-rootfs-build) | RK35xx 闭源/预编译 deb 包（分支 `rk35xx_packages`） |
| [firmware](https://github.com/Tron-Z/firmware) | 板级 firmware 覆盖 |
| [pathless-config](https://github.com/Tron-Z/pathless-config) | 系统配置工具（可选） |

## 构建主机

- Ubuntu 22.04（推荐）
- 需要 root 权限（`sudo`）

## 快速开始

```bash
git clone https://github.com/Tron-Z/pathless-build.git
cd pathless-build
cp userpatches/config-default.conf userpatches/config-default.conf.local  # 可选

# 非交互式构建 Ubuntu 22.04 (jammy) CLI 镜像
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

常用参数：

| 参数 | 说明 |
|:--|:--|
| `BOARD=pathless-rk3566` | 目标板型 |
| `BRANCH=current` | 内核分支（6.6） |
| `BRANCH=legacy` | 内核分支（5.10） |
| `BUILD_OPT=image` | 完整镜像 |
| `RELEASE=jammy` | Ubuntu 22.04 |

产物位于 `output/images/`。

## 目录结构

```
pathless-build/
├── build.sh              # 入口脚本
├── scripts/              # 构建逻辑
├── external/
│   ├── config/boards/    # 板级配置
│   ├── config/sources/   # SoC family 配置
│   └── packages/bsp/     # 板级 BSP 文件
└── userpatches/          # 用户本地配置（config-default.conf 已提交模板）
```

## 许可证

构建脚本遵循 GPL-2.0（继承自 Armbian）。闭源二进制包版权归 Rockchip 及相应上游所有。

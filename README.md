# Pathless Build

Pathless 官方镜像构建系统，当前支持 **Rockchip RK3566**（`pathless-rk3566`）。

## 单一仓库（GitHub: [Tron-Z/pathless_system](https://github.com/Tron-Z/pathless_system)）

构建脚本与依赖源码均在本仓库不同分支：

| 分支 | 内容 |
|:--|:--|
| `main` | 构建工程 |
| `pathless-bsp-u-boot` | U-Boot |
| `pathless-bsp-firmware` / `pathless-bsp-config` | 板级固件与配置 |
| `pathless-6.6-rk35xx` / `pathless-5.10-rk35xx` | 内核 |
| `rkbin` / `rk35xx_packages` | Rockchip 二进制与包 |
| `oh-my-zsh` / `evalcache` / `wiringOP` / `wiringOP-Python` | 第三方 |

## 快速开始

```bash
git clone https://github.com/Tron-Z/pathless_system.git
cd pathless_system
sudo ./build.sh
```

交互菜单可选：

- 编译目标：u-boot / kernel / rootfs / pack / image  
- 内核分支：current (6.6) / legacy (5.10)  
- 文件系统：按内核分支过滤的发行版  
- 桌面 / 精简类型  

`BRANCH` / `RELEASE` / `BUILD_OPT` / `BUILD_DESKTOP` 在 `userpatches/config-default.conf` 中留空即可弹出菜单。

```bash
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=legacy BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

## 上游同步

GitHub Actions `Sync upstream sources` 可按计划从上游内核 / Rockchip 包镜像到本仓库对应分支（产品命名仍为 Pathless）。

## 许可证

构建脚本 GPL-2.0；瑞芯微闭源二进制版权归 Rockchip 所有。

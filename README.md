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

## 快速开始（推荐：瘦身克隆）

默认裸 `git clone` 会拉取**全部分支**（含超大内核历史），体积可达数 GB。请只拉 `main`：

```bash
# 方式一
git clone --single-branch --branch main https://github.com/Tron-Z/pathless_system.git
cd pathless_system

# 方式二
curl -fsSL https://raw.githubusercontent.com/Tron-Z/pathless_system/main/tools/clone-slim.sh | bash

sudo ./build.sh
```

若 `build.sh` 仍不可执行（个别文件系统未保留 Git 可执行位）：

```bash
chmod +x build.sh tools/*.sh
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

构建过程中会按需从本仓库其它分支拉取 U-Boot / 内核等，无需事先 `git clone --mirror`。

## 上游同步

GitHub Actions `Sync upstream sources` 可按计划从上游内核 / Rockchip 包镜像到本仓库对应分支（产品命名仍为 Pathless）。

## 许可证

构建脚本 GPL-2.0；瑞芯微闭源二进制版权归 Rockchip 所有。

# Pathless Build

Pathless 官方镜像构建系统，当前支持 **Rockchip RK3566** 平台。

## 仓库结构（GitHub: [Tron-Z](https://github.com/Tron-Z)）

### 目标统一结构（推荐）

| 仓库 | 分支 / 内容 |
|:--|:--|
| [pathless_system](https://github.com/Tron-Z/pathless_system) | 构建工程 |
| [pathless-bsp-kernel](https://github.com/Tron-Z/pathless-bsp-kernel) | 内核：`pathless-6.6-rk35xx` / `pathless-5.10-rk35xx` |
| [pathless-bsp](https://github.com/Tron-Z/pathless-bsp) | BSP 合一：`u-boot` / `firmware` / `config` / `rkbin` / `rk35xx_packages` |
| [pathless-3rdparty](https://github.com/Tron-Z/pathless-3rdparty) | 第三方：`oh-my-zsh` / `evalcache` / `wiringOP` / `wiringOP-Python` |

空壳仓库已创建。在 Linux 编译机执行一次迁移（把旧拆分仓镜像进去）：

```bash
export GIT_PROXY_PREFIX=https://gh-proxy.com/https://github.com   # 按需
bash tools/migrate-unified-repos.sh
```

迁移成功后，把 `external/config/sources/pathless-repos.conf` 切到统一仓库（脚本注释中已说明），旧仓可归档。

### 当前仍可用的拆分仓库

`pathless-bsp-u-boot` / `pathless-bsp-firmware` / `pathless-bsp-config` / `pathless-rockchip` 以及 `oh-my-zsh` 等，构建默认仍指向它们，保证迁移完成前可继续编译。

## 快速开始

```bash
git clone https://github.com/Tron-Z/pathless_system.git
cd pathless_system
sudo ./build.sh
```

交互菜单与 Orange Pi 对齐，可选：

- 编译目标：u-boot / kernel / rootfs / pack / image  
- 内核分支：current (6.6) / legacy (5.10)  
- 文件系统：按内核分支过滤的发行版（与 Orange Pi 3B 支持列表对齐）  
- 桌面 / 精简类型  

`BRANCH` / `RELEASE` / `BUILD_OPT` / `BUILD_DESKTOP` 在 `userpatches/config-default.conf` 中留空即可弹出菜单。

```bash
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=legacy BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

## 许可证

构建脚本 GPL-2.0；瑞芯微闭源二进制版权归 Rockchip 所有。

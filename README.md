# Pathless Build

Pathless 官方镜像构建系统，当前支持 **Rockchip RK3566** 平台。

## 仓库结构（GitHub: [Tron-Z](https://github.com/Tron-Z)）

统一后仅保留少数仓库（多分支）：

| 仓库 | 分支 / 内容 |
|:--|:--|
| [pathless-build](https://github.com/Tron-Z/pathless-build) | 构建工程 |
| [pathless-bsp-kernel](https://github.com/Tron-Z/pathless-bsp-kernel) | 内核：`pathless-6.6-rk35xx` / `pathless-5.10-rk35xx` |
| [pathless-bsp](https://github.com/Tron-Z/pathless-bsp) | BSP 合一：`u-boot` / `firmware` / `config` / `rkbin` / `rk35xx_packages` |
| [pathless-3rdparty](https://github.com/Tron-Z/pathless-3rdparty) | 第三方：`oh-my-zsh` / `evalcache` / `wiringOP` / `wiringOP-Python` |

首次部署或从旧拆分仓库迁移时，在能访问 GitHub 的机器执行：

```bash
# 若直连失败，可：export GIT_PROXY_PREFIX=https://gh-proxy.com/https://github.com
bash tools/migrate-unified-repos.sh
```

## 快速开始

```bash
git clone https://github.com/Tron-Z/pathless-build.git
cd pathless-build
sudo ./build.sh
```

交互菜单与 Orange Pi 对齐，可选：

- 编译目标：u-boot / kernel / rootfs / pack / image  
- 内核分支：current (6.6) / legacy (5.10)  
- 文件系统：按内核分支过滤的发行版（focal/jammy/bullseye/bookworm…）  
- 桌面 / 精简类型  

非交互示例：

```bash
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=current BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
sudo ./build.sh BOARD=pathless-rk3566 BRANCH=legacy BUILD_OPT=image RELEASE=jammy BUILD_DESKTOP=no
```

`userpatches/config-default.conf` 中 `BRANCH` / `RELEASE` / `BUILD_OPT` / `BUILD_DESKTOP` 留空即可每次弹出菜单。

## U-Boot / 内核设备树

Pathless RK3566 使用 **`rk3566-pathless-3b.dts`**，产物为 **`rk3566-pathless-3b.dtb`**。

```bash
bash tools/refresh-bsp-sources.sh
bash tools/verify-rk3566-bsp.sh
sudo ./build.sh BUILD_OPT=u-boot BOARD=pathless-rk3566 BRANCH=current
```

## 保持与 GitHub 同步

```bash
git fetch origin
git reset --hard origin/main
bash tools/normalize-eol.sh
bash tools/refresh-bsp-sources.sh
bash tools/verify-rk3566-bsp.sh
```

查看详细错误：`tail -80 output/debug/compilation.log`

## 从 Windows 拷贝到 Linux 后报错 `$'\r'`

脚本必须是 **Unix LF** 换行。在工程根目录执行：

```bash
bash tools/normalize-eol.sh
```

## 许可证

构建脚本 GPL-2.0；瑞芯微闭源二进制版权归 Rockchip 所有。

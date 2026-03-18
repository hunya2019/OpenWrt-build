# ImmortalWrt 25.12 编译指南

## 快速开始

本仓库已配置为编译 ImmortalWrt 25.12 版本。

### 系统要求

- Linux操作系统（推荐 Ubuntu 20.04/22.04）
- 至少 30GB 可用磁盘空间
- 4GB+ RAM（推荐8GB+）
- 稳定的网络连接

### 必需工具

```bash
# Ubuntu/Debian
sudo apt-get install build-essential clang libssl-dev libncurses5-dev \
    libncursesw5-dev zlib1g-dev gawk git gettext wget python3 python3-pip

# CentOS/RHEL  
sudo yum install gcc clang make libssl-devel ncurses-devel zlib-devel \
    gawk git gettext wget python3 python3-pip
```

## 构建步骤

### 方法 1: 使用新的25.12专用脚本（推荐）

```bash
# 完整编译流程
bash smpackage/build_25_12.sh full

# 或分步执行
bash smpackage/build_25_12.sh check    # 检查依赖
bash smpackage/build_25_12.sh init     # 初始化
bash smpackage/build_25_12.sh feeds    # 更新feeds
bash smpackage/build_25_12.sh config   # 应用配置
bash smpackage/build_25_12.sh build    # 编译
```

### 方法 2: 手动编译

```bash
# 1. 进入OpenWrt源码目录
cd /path/to/openwrt/source

# 2. 更新software packages
./scripts/feeds update -a
./scripts/feeds install -a

# 3. 配置编译
cp config/immortalwrt.info .config
make defconfig

# 4. 开始编译
make -j$(nproc) V=s

# 5. 编译成功后，固件在 bin/ 目录下
ls -la bin/targets/*/*/
```

## 配置说明

### immortalwrt.info 配置文件

此文件包含25.12版本的预设配置，包括：

- **LuCI Web界面**: 已启用
- **中文支持**: 已配置
- **现代主题**: Argon/Bootstrap主题
- **高级功能**:
  - PassWall2 (翻墙工具)
  - OpenClash (Clash前端)
  - AdGuardHome (DNS拦截)
  - iStore (应用商店)

### 自定义配置

编辑 `config/immortalwrt.info` 或使用 `make menuconfig` 进行高级配置：

```bash
make menuconfig
```

## 编译脚本说明

### immortalwrt-all-1.sh

在feeds更新前执行，负责：
- 克隆自定义software packages
- 配置feeds源
- 设置编译环境变量
- 检查编译依赖

### immortalwrt-all-2.sh  

在配置加载前执行，负责：
- 验证.config配置文件
- 应用25.12版本特定的优化
- 检查和调整关键配置项
- 预编译环境检查

### build_25_12.sh

新的25.12专用编译脚本，提供完整的编译工作流：
- 依赖检查
- 源码初始化
- Feeds更新
- 配置应用
- 编译执行
- 输出打包

## GitHub Actions 编译

项目已启用GitHub Actions自动编译，配置文件在 `.github/workflows/test.yml`

推送到25.12分支将自动触发编译：

```bash
git push -u origin 25.12
```

编译结果在 Actions 标签页下载。

## 常见问题

### Q: 编译速度很慢？
A: 
- 增加CPU线程数: `make -j8` 或更高
- 启用ccache加速: `export CCACHE_DIR=/path/to/cache; make -j$(nproc)`
- 确保磁盘是SSD

### Q: 编译出错怎么办？
A:
- 检查磁盘空间和内存
- 清理旧编译: `make clean`
- 查看build日志
- 确保所有依赖都已安装

### Q: 如何只编译特定的组件？
A:
```bash
make package/luci/compile V=s   # 编译LuCI
make tools/compile V=s          # 编译工具
make toolchain/compile V=s      # 编译工具链
```

### Q: 编译后的固件位置？
A: 
固件在 `bin/targets/` 下，针对不同的目标设备有不同的子目录。

例如x86_64: `bin/targets/x86/64/`

## 版本信息

- **构建版本**: 25.12
- **基础**: ImmortalWrt官方
- **更新时间**: 2026-03-18

## 获得帮助

- 官方论坛: https://github.com/immortalwrt/immortalwrt
- Issue跟踪: 在本仓库提交Issue
- 文档: 查阅 DOCS.md

## 许可证

遵循OpenWrt/ImmortalWrt原始许可证

---

**注意**: 此编译配置针对 25.12 版本优化。如需编译其他版本，请切换到相应分支。

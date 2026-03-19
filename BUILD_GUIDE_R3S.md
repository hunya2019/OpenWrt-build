# NanoPi R3S - ImmortalWrt 25.12 编译指南

## 设备信息

- **设备名称**: FriendlyElec NanoPi R3S
- **芯片组**: Rockchip RK3568 (ARM Cortex-A55)
- **内存**: 4GB DDR4
- **存储**: 32GB eMMC (可选)
- **网络**: 2x 1000M Ethernet (原生 + USB)
- **USB**: USB 3.0 Type C x1, USB 2.0 x2

## 配置文件

### 1. **config_r3s.seed** - 固件配置
位置: `config/config_r3s.seed`

包含以下功能:
- ✅ LuCI Web管理界面（中文）
- ✅ PassWall2 翻墙工具
- ✅ OpenClash 代理服务
- ✅ AdGuardHome DNS防护
- ✅ nikki 流量分析工具
- ✅ momo 内存优化工具
- ✅ 标准 opkg 包管理
- ✅ IPv6 支持
- ✅ 存储管理（NTFS/exFAT/ext4）

## 编译方式

### 方式一: 本地编译（Linux/WSL）

#### 前提条件
```bash
# Ubuntu/Debian 系统
sudo apt-get update
sudo apt-get install build-essential libncurses5-dev libssl-dev perl python3 \
  zlib1g-dev git gawk gcc wget unzip
```

#### 编译步骤

```bash
# 进入脚本目录
cd smpackage

# 查看帮助
bash build_r3s.sh help

# 检查环境
bash build_r3s.sh check

# 完整编译（推荐）
bash build_r3s.sh full

# 或分步编译
bash build_r3s.sh init      # 初始化/克隆源码
bash build_r3s.sh feeds     # 更新feeds
bash build_r3s.sh config    # 配置编译选项
bash build_r3s.sh build     # 执行编译
```

#### 编译速度预估
- 首次编译: 1-3小时 (取决于网络和硬件)
- 增量编译: 30分钟-1小时
- 完全清理后重新编译: 2-3小时

#### 输出文件
编译完成后的固件位置:
```
build_r3s/immortalwrt/bin/targets/rockchip/armv8/
├── friendlyarm_nanopi_r3s-ext4-combined.img.gz
├── friendlyarm_nanopi_r3s-ext4-factory.img
├── friendlyarch_nanopi_r3s-ext4-sysupgrade.img.gz
└── *.buildinfo / *.manifest
```

### 方式二: GitHub Actions 自动编译

#### 配置步骤

1. **Fork本仓库** (可选，但推荐用于持续构建)

2. **启用GitHub Actions**
   - 在仓库设置中启用Actions工作流

3. **设置密钥** (可选，用于自动发布Release)
   - 仓库 Settings → Secrets and variables → Actions
   - 添加 `GITHUB_TOKEN` (自动提供，无需手动设置)
   - 可选: 添加 `TELEGRAM_BOT_TOKEN` 和 `TELEGRAM_CHAT_ID` 用于通知

4. **手动触发编译**
   - 进入 Actions 选项卡
   - 选择 "ImmortalWrt 25.12 - NanoPi R3S Build" 工作流
   - 点击 "Run workflow"
   - 选择选项:
     - SSH: false (正常编译) 或 true (进入SSH调试)
   - 点击绿色 "Run workflow" 按钮

#### 编译任务流程
```
1. 初始化环境 (Ubuntu 22.04)
   ↓
2. 安装依赖 (build-essential, Python3等)
   ↓
3. 克隆源码 (ImmortalWrt openwrt-25.12分支)
   ↓
4. 加载自定义Feeds
   ↓
5. 更新和安装Feeds
   ↓
6. 应用自定义配置
   ↓
7. 下载编译依赖
   ↓
8. 编译固件
   ↓
9. 收集输出文件和APK包
   ↓
10. 创建Release并上传
```

#### GitHub Actions 输出
- **Artifacts**: 编译产物（保留5天）
- **Release**: 自动创建Release并上传固件

## 固件刷写

### 1. 准备刷写工具

**Windows:**
- [Etcher](https://www.balena.io/etcher/) - 图形化刷写工具
- [rufus](https://rufus.ie/) - 另一个刷写工具

**Linux/macOS:**
```bash
# 使用dd命令
sudo dd if=friendlyarm_nanopi_r3s-ext4-sysupgrade.img.gz of=/dev/sdX bs=4M status=progress
```

### 2. 进入刷写模式

1. **关闭R3S电源**
2. **进入Maskrom模式**:
   - 同时按住R3S上的 "RESET" 和 "LOADER" 按钮
   - 保持按住状态下连接USB-C电源
   - 保持按住约5秒后松开

3. **在Linux主机上验证**:
```bash
lsusb | grep 2207  # 应该看到Rockchip设备
```

### 3. 执行刷写

#### 使用 rkdeveloptool (推荐)

```bash
# 安装工具
sudo apt-get install python3-pyusb python3-usb libudev-dev
git clone https://github.com/rockchip-linux/rkdeveloptool.git
cd rkdeveloptool
# 编译和安装...

# 执行刷写
sudo rkdeveloptool ld                          # 列出设备
sudo rkdeveloptool wl 0 spl.bin               # 刷写SPL
sudo rkdeveloptool wl 0x4000 u-boot.itb       # 刷写U-Boot
sudo rkdeveloptool wl 0x8000 friendlyarm_nanopi_r3s-ext4-combined.img.gz
```

#### 使用 Etcher (更简单)

1. 打开Etcher
2. 选择固件文件 (.img 或 .img.gz)
3. 选择目标设备
4. 点击 Flash
5. 等待完成

### 4. 首次启动

```
1. 刷写完成后断电
2. 连接网线和电源
3. 等待30-60秒
4. 使用浏览器访问: http://192.168.1.1 或 http://openwrt.local
5. 默认用户名: root (无密码)
6. 设置管理员密码
```

## 常见问题

### Q: 编译失败，出现 "missing dependencies"
**A:** 重新运行检查:
```bash
bash build_r3s.sh clean
bash build_r3s.sh full
```

### Q: 编译速度很慢
**A:** 检查:
- 网络连接是否正常
- 是否使用了足够的CPU核心 (make -j$(nproc))
- 磁盘空间是否充足 (需要30GB+)

### Q: R3S连不上网
**A:** 检查:
- 网线是否正确插入 (有两个网口)
- LuCI中网络配置是否正确
- 运行 `dmesg | grep -i eth` 查看网卡识别

### Q: 无法SSH连接到R3S
**A:**
```bash
# 查找R3S的IP地址
arp-scan -l | grep FRIENDLY

# SSH连接
ssh root@<R3S_IP>
```

## 配置修改

如需修改编译配置，编辑 `config/config_r3s.seed`:

```bash
# 启用某个包
CONFIG_PACKAGE_htop=y

# 禁用某个包
# CONFIG_PACKAGE_某包 is not set

# 修改后，重新执行
bash build_r3s.sh config
bash build_r3s.sh build
```

## 文件清单

```
OpenWrt-build/
├── config/
│   ├── config_25_12.seed       (x86_64配置)
│   ├── config_r3s.seed         (R3S配置) ← NEW
│   └── immortalwrt.info
├── smpackage/
│   ├── immortalwrt-all-1.sh    (Feeds前脚本)
│   ├── immortalwrt-all-2.sh    (Feeds后脚本)
│   ├── build_25_12.sh          (x86_64编译脚本)
│   ├── build_r3s.sh            (R3S编译脚本) ← NEW
│   └── settings.patch
├── .github/workflows/
│   ├── build_25_12.yml         (x86_64 GitHub Actions)
│   └── build_r3s.yml           (R3S GitHub Actions) ← NEW
├── BUILD_GUIDE_R3S.md          (本文档)
└── ...
```

## 支持和更新

- **官方网站**: http://openwrt.org / https://immortalwrt.org
- **R3S官方Wiki**: https://wiki.friendlyelec.com/wiki/index.php/NanoPi_R3S/en
- **ImmortalWrt GitHub**: https://github.com/immortalwrt/immortalwrt
- **本仓库Issues**: 报告编译问题或建议

## 更新日志

### 2026-03-19
- 🆕 创建R3S专用配置文件和编译脚本
- 🆕 添加R3S的GitHub Actions工作流
- 📝 编写R3S编译指南

## 许可证

遵循 ImmortalWrt 和 OpenWrt 的许可证要求。

---

**最后更新**: 2026-03-19  
**维护者**: hunya2019  
**OpenWrt版本**: 25.12

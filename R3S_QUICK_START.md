# 🚀 R3S固件编译 - 5分钟快速开始

## 最简单的方式：使用 GitHub Actions（推荐）

> ⏱️ **预计时间**: 1-2小时自动编译，0手动操作

### 步骤1: 启用GitHub Actions
```
1. 打开此仓库 → Actions 选项卡
2. 确保 "ImmortalWrt 25.12 - NanoPi R3S Build" 工作流显示为活跃
   (如显示灰色，点击"Enable"按钮启用)
```

### 步骤2: 触发编译
```
1. 点击 "ImmortalWrt 25.12 - NanoPi R3S Build" 工作流
2. 点击 "Run workflow" 按钮
3. 在 "Choose a branch" 选择 25.12
4. SSH 字段选择 false (正常编译)
5. 点击绿色 "Run workflow" 按钮
```

### 步骤3: 等待完成
```
- 编译时间: 1-2小时
- 完成后自动创建 Release 并上载固件
- 在 Releases 页面下载固件文件
```

---

## 进阶方式：本地编译（Linux/WSL）

> 💻 **适合**: 需要频繁调试或无法使用GitHub Actions的用户

### 前置条件（仅需一次）
```bash
# Ubuntu 22.04 / Debian 12
sudo apt-get update
sudo apt-get install -y build-essential libncurses5-dev libssl-dev \
  perl python3 zlib1g-dev git gawk gcc wget unzip lzma

# 克隆此仓库
git clone https://github.com/hunya2019/OpenWrt-build.git
cd OpenWrt-build
git checkout 25.12
```

### 编译R3S固件 - 3种方式

#### 方式A: 完整编译（首次或完全重新编译）
```bash
cd smpackage
bash build_r3s.sh full
```

#### 方式B: 分步编译
```bash
cd smpackage

# 1. 检查环境
bash build_r3s.sh check

# 2. 初始化（克隆源码）
bash build_r3s.sh init

# 3. 更新feeds
bash build_r3s.sh feeds

# 4. 配置编译选项
bash build_r3s.sh config

# 5. 开始编译
bash build_r3s.sh build
```

#### 方式C: 快速编译（已初始化后）
```bash
cd smpackage
bash build_r3s.sh config
bash build_r3s.sh build
```

### 编译输出
```
完成后在以下位置找到固件：

build_r3s/immortalwrt/bin/targets/rockchip/armv8/
├── friendlyarm_nanopi_r3s-ext4-combined.img.gz     ← 完整固件
├── friendlyarm_nanopi_r3s-ext4-sysupgrade.img.gz   ← 升级固件
└── *.buildinfo, *.manifest                         ← 编译信息
```

---

## 固件刷写

### 使用 Etcher（最简单）
```
1. 下载 Balena Etcher: https://www.balena.io/etcher/
2. 打开 Etcher
3. 选择固件文件 (*.img.gz)
4. 选择 R3S USB 设备
5. 点击 Flash → 等待完成
```

### 使用命令行 (Linux)
```bash
# 列出设备
lsblk

# 刷写（将sdX替换为实际设备，如sdb）
sudo dd if=friendlyarm_nanopi_r3s-ext4-combined.img.gz \
     of=/dev/sdX bs=4M status=progress

sudo sync
```

---

## 首次启动 R3S

```
1. 连接网线到 LAN1 或 LAN2
2. 连接电源（USB-C）
3. 等待 60 秒
4. 浏览器访问: http://192.168.1.1
5. 用户名: root (无密码，首次登录需设置密码)
6. 完成！
```

---

## 常用命令参考

### 本地编译脚本帮助
```bash
cd smpackage
bash build_r3s.sh help
```

### 查看编译日志
```bash
cd build_r3s/immortalwrt
tail -f build.log              # 实时查看
cat build.log | tail -100      # 查看最后100行
grep "error" build.log         # 查找错误
```

### 清理编译输出
```bash
cd smpackage
bash build_r3s.sh clean        # 清理输出文件
bash build_r3s.sh distclean    # 完全清理（删除源码）
```

### 修改配置后重新编译
```bash
# 编辑配置文件
nano ../config/config_r3s.seed

# 然后重新编译
cd smpackage
bash build_r3s.sh config
bash build_r3s.sh build
```

---

## 常见问题解决

### Q: "bash: build_r3s.sh: No such file or directory"
**A:** 确保在 `smpackage/` 目录：
```bash
cd smpackage  # 重要！
bash build_r3s.sh full
```

### Q: "Checking 'python3-pyelftools'... failed"
**A:** 安装Python依赖：
```bash
pip3 install pyelftools pysocks unidecode
```

### Q: 编译速度很慢
**A:** 这是正常的（首次编译1-3小时），可以：
- 确认网络连接稳定
- 检查磁盘空间充足 (需要30GB+)
- 使用更高性能的CPU

### Q: GitHub Actions 工作流不显示
**A:** 在仓库설정中启用它：
```
Settings → Actions → General → 
Workflow Permissions: "Read and write permissions" ✓
```

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `config/config_r3s.seed` | R3S设备编译配置 |
| `smpackage/build_r3s.sh` | R3S本地编译脚本 |
| `.github/workflows/build_r3s.yml` | GitHub Actions工作流 |
| `BUILD_GUIDE_R3S.md` | 详细编译指南 |
| `config/config_25_12.seed` | x86_64编译配置（保留） |

---

## 下一步

- 📖 详细指南: 查看 [BUILD_GUIDE_R3S.md](BUILD_GUIDE_R3S.md)
- 🔧 修改配置: 编辑 `config/config_r3s.seed`
- 🐛 遇到问题: 查看 GitHub Issues
- 💬 讨论建议: GitHub Discussions

---

**优化小贴士** 💡
```
✅ 首次使用 GitHub Actions（无需本地环境）
✅ 频繁调试使用本地编译
✅ 编译前确保网络稳定
✅ 编译机器至少16GB内存
✅ 首次编译预留2-3小时
```

---

编译愉快！🎉

**文档更新**: 2026-03-19  
**设备**: FriendlyElec NanoPi R3S  
**版本**: ImmortalWrt 25.12

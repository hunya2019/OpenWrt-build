# SSH调试指南 - OpenWrt Jell编译Workflow

## 🔌 SSH连接概述

该Workflow提供了两种SSH调试方式，让你在GitHub Actions环境中实时调试编译过程。

## 📋 SSH支持选项

### 1️⃣ **编译前SSH调试（推荐用于配置调试）**

**何时使用：** 需要在编译前检查配置、测试feeds、调整.config等

**启用方法：**
1. 进入GitHub仓库 → **Actions** 标签
2. 选择 **openwrt-jell-r3s** 工作流
3. 点击 **Run workflow** 按钮
4. ✅ **勾选** `ssh: true`
5. 其他选项根据需要设置，点击 **Run workflow**

流程会运行到"SSH调试 - 编译前"步骤并暂停，等待你连接。

**连接方式：**
- 工作流运行后，在日志中查找SSH连接信息
- 复制连接命令（通常是 `ssh ...` 开头）
- 在本地终端粘贴并运行

**调试命令示例：**
```bash
# 进入OpenWrt目录
cd /tmp/openwrt-*

# 检查feeds配置
cat feeds.conf.default

# 查看.config文件
cat .config

# 查看jell库是否下载
ls -la feeds/jell/

# 手动执行feeds命令
./scripts/feeds update -a
./scripts/feeds install -a

# 修改配置
make menuconfig

# 编辑.config
nano .config
```

**超时设置：** SSH会话保留30分钟，超时后自动关闭

### 2️⃣ **编译失败后SSH调试（用于故障排查）**

**何时激活：** 编译失败时自动启动SSH连接

**自动触发条件：**
- 任何编译步骤失败时，工作流会自动提供SSH连接
- 无需手动配置，系统会自动进入SSH调试模式

**调试命令示例：**
```bash
# 查看错误日志
cd /tmp/openwrt-*/openwrt
make -j1 V=s  # 重新编译，显示详细信息

# 检查磁盘空间
df -h

# 查看内存使用
free -h

# 检查编译日志
ls -la logs/

# 查看失败的包信息
make -j1 V=s 2>&1 | tail -100

# 尝试单线程编译
make -j1 V=s
```

## 🔐 安全性说明

- ✅ **访问限制**：SSH连接仅限于PR作者或repo所有者
- ✅ **无密码认证**：使用GitHub账户认证，无需密码
- ✅ **自动超时**：30分钟无操作自动断开连接
- ✅ **日志记录**：所有操作会被记录在GitHub Actions日志中

## 💡 常用调试场景和命令

### 场景1：验证Feeds配置
```bash
cd /tmp/openwrt-*/openwrt

# 查看是否包含jell库
grep "jell" feeds.conf.default

# 列出所有feeds
cat feeds.conf.default

# 查看feeds/jell目录
ls -la feeds/jell/ | head -20
```

### 场景2：检查编译配置
```bash
cd /tmp/openwrt-*/openwrt

# 查看目标设备配置
grep "^CONFIG_TARGET" .config

# 查看选中的软件包
grep "=y$" .config | grep "CONFIG_PACKAGE" | head -20

# 搜索特定包
grep "CONFIG_PACKAGE_jell" .config
```

### 场景3：手动编译测试
```bash
cd /tmp/openwrt-*/openwrt

# 清理之前的编译
make clean

# 重新下载所有依赖
make download -j8

# 单线程编译（便于查看错误）
make -j1 V=s

# 如果编译成功，查看输出
ls -la bin/targets/
```

### 场景4：解决常见问题

**磁盘空间不足：**
```bash
# 查看磁盘使用情况
df -h

# 清理缓存和旧文件
rm -rf dl/
rm -rf .ccache

# 清理构建文件
make clean
```

**网络问题导致下载失败：**
```bash
cd /tmp/openwrt-*/openwrt

# 重新尝试下载
make download -j1

# 检查哪些文件下载失败
find dl/ -size -1024c -exec ls -l {} \;
```

**内存不足导致编译失败：**
```bash
# 检查可用内存
free -h

# 使用单线程编译以降低内存占用
make -j1 V=s

# 或尝试2线程
make -j2 V=s
```

## 📖 高级用法

### 保存修改后的配置

如果在SSH调试中修改了`.config`文件并成功编译：

```bash
# 将修改后的.config复制出来
cat /tmp/openwrt-*/openwrt/.config > /tmp/my-config.txt

# 或者直接编辑工作目录中的配置文件
cat .config > /github/workspace/config/openwrt-jell.info
```

然后手动拉取这个配置版本到本地仓库。

### 深度编译调试

启用详细日志输出：
```bash
cd /tmp/openwrt-*/openwrt

# 生成编译日志
make -j1 V=s 2>&1 | tee build.log

# 查看最后的错误信息
tail -200 build.log
```

## ❌ SSH连接失败排查

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 无法连接 | 工作流未运行SSH步骤 | 确认已勾选 `ssh: true` 设置 |
| 超时 | SSH会话超过30分钟 | 重新启动工作流 |
| Permission denied | 非repo所有者或PR作者 | 使用有权限的账户运行 |
| 找不到连接信息 | 日志未加载 | 等待几秒钟，刷新页面 |
| 命令不可用 | 环境配置问题 | 检查 `/tmp/openwrt-*/openwrt` 目录是否存在 |

## 📝 注意事项

⚠️ **重要提示：**
- SSH会话是临时的，修改会在工作流结束后丢失（除非上传为Artifact）
- SSH调试会增加工作流运行时间和GitHub Actions配额消耗
- 不要在SSH中修改系统文件，仅修改编译相关文件
- 长时间的调试会导致工作流超时（6小时上限）

## 🎯 典型工作流

1. **启用SSH + 编译前调试** → 检查配置 → 修复问题 → 退出SSH → 继续编译
2. **编译失败** → 自动触发SSH → 调试失败原因 → 退出SSH → 下次改进
3. **性能优化** → SSH调试 → 逐步测试 → 保存最优配置 → 上传到仓库

---

**需要帮助？** 检查完整的Workflow日志或参考 [WORKFLOW_OPENWRT_JELL.md](WORKFLOW_OPENWRT_JELL.md)

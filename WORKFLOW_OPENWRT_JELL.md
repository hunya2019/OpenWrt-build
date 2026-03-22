# OpenWrt + Jell 编译 Workflow 说明

## 📋 概述

`openwrt-jell-r3s.yml` 是一个GitHub Actions Workflow，用于编译和构建集成了Jell第三方包源的OpenWrt固件。

### 相关项目
- **OpenWrt**: https://github.com/openwrt/openwrt - 开源无线路由器操作系统
- **Jell**: https://github.com/kenzok8/jell - 优质第三方包源库

## 🚀 主要特性

✅ **编译OpenWrt原版** - 基于OpenWrt官方主分支  
✅ **集成Jell库** - 自动从kenzok8/jell库添加第三方包  
✅ **自动缓存加速** - 利用GitHub Actions缓存提速编译  
✅ **自动发布Release** - 编译完成后自动生成Release  
✅ **支持手动触发** - 可随时手动启动编译  
✅ **定时编译** - 每周日上午10点自动编译（北京时间）  

## 📁 文件结构

```
.github/workflows/
├── openwrt-jell-r3s.yml          # 新的Workflow定义文件
│
smpackage/
├── openwrt-jell-1.sh              # 编译前脚本1（feeds配置前）
├── openwrt-jell-2.sh              # 编译前脚本2（配置后）
│
config/
├── openwrt-jell.info              # 编译配置文件（首次编译后自动生成）
```

## ⚙️ Workflow 工作流程

1. **释放磁盘空间** - 清理不必要的系统文件，获得最大编译空间
2. **初始化系统环境** - 安装编译所需的依赖包
3. **准备代码** - Clone OpenWrt源代码
4. **配置缓存** - 设置ccache加速编译
5. **执行脚本1** - 自定义前期配置
6. **更新Feeds** - 获取最新的包源信息
7. **添加Jell库** - 将Jell库源添加到feeds配置
8. **安装Feeds** - 安装所有feeds中声明的包
9. **执行脚本2** - 自定义后期配置
10. **下载包** - 预下载所有依赖文件
11. **编译固件** - 执行实际的编译过程
12. **整理文件** - 组织编译输出的固件和软件包
13. **打包IPK** - 将所有软件包压缩为tar.gz
14. **上传工件** - 保存到GitHub Actions
15. **发布Release** - 创建GitHub Release并上传文件

## 🔧 主要环境变量

| 变量名 | 默认值 | 说明 |
|-------|-------|------|
| `REPO_URL` | https://github.com/openwrt/openwrt | OpenWrt源代码仓库 |
| `REPO_BRANCH` | main | OpenWrt源代码分支 |
| `JELL_REPO` | https://github.com/kenzok8/jell.git | Jell库源代码 |
| `Firmware_Name` | openwrt-jell | 固件名称 |
| `TZ` | Asia/Shanghai | 时区设置 |

## 📝 使用方法

### 1. 首次运行

编辑workflow文件中的自定义脚本（`smpackage/openwrt-jell-*.sh`），添加你需要的配置。

### 2. 手动触发编译

1. 进入GitHub仓库
2. 点击 **Actions** 标签
3. 选择 **openwrt-jell-r3s** 工作流
4. 点击 **Run workflow** 按钮
5. 设置编译选项：
   - **ssh**: 是否启用SSH连接用于调试（可选）
   - **CACHE_BUILD**: 是否使用缓存加速（建议打开）
   - **UPLOAD_FIRMWARE**: 是否上传固件
   - **UPLOAD_BUILDINFO**: 是否上传配置文件
   - **UPLOAD_PACKAGE**: 是否上传软件包
   - **UPLOAD_RELEASE**: 是否发布到Releases

### 3. 自动定时编译

Workflow已配置每周日北京时间上午10点自动逐行运行一次。可在workflow文件中修改 cron 表达式调整时间。

当前设置：
```yaml
- cron: '0 2 * * 0'  # UTC时间每周日凌晨2点 = 北京时间上午10点
```

## 📦 输出文件说明

编译完成后，会生成以下文件：

### 固件文件 (firmware/)
- `*.bin` - 固件二进制文件
- `*.gz` - 压缩的固件文件
- `*.img` - 镜像文件

### 构建信息 (buildinfo/)
- `openwrt-jell.config` - 完整编译配置
- `feeds.conf.default` - Feeds配置（包含Jell库）
- `*.buildinfo` - 构建信息文件
- `*.manifest` - 清单文件

### 软件包 (packages/)
- `ipk_packages.tar.gz` - 所有IPK软件包压缩包

所有输出文件都会根据编译时间加上日期前缀，例如：
- `20260322_1430__openwrt-jell.config`
- `20260322_1430__ipk_packages.tar.gz`

## 🔄 集成Jell库的工作原理

### Workflow中的关键步骤

```yaml
- name: 添加Jell库和安装源
  run: |
    cd openwrt
    # 1. 检查feeds.conf.default
    # 2. 添加Jell库源地址
    # 3. 更新feeds获取最新信息
    # 4. 安装所有feeds中的包
```

### 手动添加Jell包

完成编译后，如需使用Jell库中的特定包：

1. 下载配置文件：`openwrt-jell.config`
2. 在你的本地OpenWrt编译环境中，执行：
```bash
cp openwrt-jell.config .config
make menuconfig
```
3. 在menuconfig中搜索并选择Jell库中的包
4. 保存配置后重新编译

## 🎯 定制化编译

### 修改/添加编译选项

编辑 `smpackage/openwrt-jell-2.sh` 脚本，在其中添加你的配置：

```bash
# 示例：添加特定包到.config
echo "CONFIG_PACKAGE_luci-app-xxx=y" >> .config
```

### 修改编译配置

1. 首次编译完成后，下载 `openwrt-jell.config` 文件
2. 上传到仓库的 `config/openwrt-jell.info` 目录
3. 后续编译将使用此配置作为基础

## 🛠️ 故障排除

### 编译失败

常见原因：
1. **磁盘空间不足** - 工作流会自动清理，但如仍不足可删除缓存
2. **Feeds错误** - 检查feeds.conf配置是否正确
3. **网络问题** - Jell库下载失败，可稍后重试
4. **内存不足** - 尝试使用 `make -j1 V=s` 单线程编译

### SSH调试

启用SSH连接用于实时调试：
1. 在workflow输入中选择 `ssh: true`
2. 按日志中的指示连接SSH会话
3. 可手动执行命令进行调试

## 📚 相关文档

- [OpenWrt官方文档](https://openwrt.org/docs)
- [Jell项目主页](https://github.com/kenzok8/jell)
- [GitHub Actions文档](https://docs.github.com/en/actions)

## 💡 建议与最佳实践

1. **首次编译** - 建议先进行一次完整编译，验证流程无误
2. **缓存选项** - 启用缓存可大幅加速后续编译
3. **定时维护** - 定期检查Jell库更新以获得最新包
4. **版本管理** - 在GitHub Release中保存重要版本的配置

## 📄 许可证

遵循OpenWrt和Jell项目各自的开源许可证。

---

**有问题？** 检查Workflow执行日志或提交Issue进行反馈。

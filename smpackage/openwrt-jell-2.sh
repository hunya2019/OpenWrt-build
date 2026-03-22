#!/bin/bash

# OpenWrt + Jell编译前自定义脚本2
# 在配置加载后、编译前执行

echo "=== OpenWrt + Jell编译前自定义脚本2开始执行 ==="

# 显示当前状态
echo "当前目录: $(pwd)"
echo "执行时间: $(date)"

# ===== 验证配置文件 =====
echo "验证配置文件..."

if [ -f ".config" ]; then
    echo "✓ 配置文件存在"
    echo "配置文件大小: $(wc -l < .config) 行"
    
    # 显示关键配置项
    echo "关键配置项检查:"
    
    echo "目标架构:"
    grep "^CONFIG_TARGET_" .config | head -3 || echo "未找到TARGET配置"
    echo ""
    
    echo "LuCI配置:"
    luci_count=$(grep -c "^CONFIG_PACKAGE_luci.*=y" .config || echo "0")
    echo "  已启用LuCI组件: $luci_count 个"
    
    echo "其他关键配置验证:"
    grep "^CONFIG_PACKAGE_kmod" .config | wc -l | xargs echo "  内核模块: 个"
    
else
    echo "✗ 警告: 配置文件不存在"
    echo "创建基础配置..."
    make defconfig
fi

# ===== 检查Jell库 =====
echo ""
echo "检查Jell库集成状态..."

if [ -d "feeds/jell" ]; then
    echo "✓ Jell库源文件已下载"
    echo "Jell库包含的主要软件包:"
    ls -d feeds/jell/*/ 2>/dev/null | head -10 | while read dir; do
        basename "$dir"
    done
    echo ""
    
    # 检查是否有jell中的包被选中
    jell_packages=$(grep -c "^CONFIG_PACKAGE.*=y" .config 2>/dev/null | head -1 || echo "0")
    echo "已启用的Jell包数量: $jell_packages"
else
    echo "⚠ Jell库源文件目录未找到或未成功下载"
fi

# ===== 显示已启用的第三方包 =====
echo ""
echo "第三方包（Jell库）统计:"

if grep -q "jell_" .config; then
    echo "已选中的Jell包:"
    grep "^CONFIG_PACKAGE_jell" .config | grep "=y" || echo "未找到"
else
    echo "ℹ 未检测到选中的Jell包"
fi

echo ""
echo "✓ 脚本2执行完成"

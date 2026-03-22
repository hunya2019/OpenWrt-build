#!/bin/bash

# OpenWrt + Jell编译前自定义脚本1
# 在更新feeds之前执行

echo "=== OpenWrt + Jell编译前自定义脚本1开始执行 ==="

# 显示当前工作目录和基本信息
echo "当前目录: $(pwd)"
echo "系统信息: $(uname -a)"
echo "编译开始时间: $(date)"

# ===== 显示feeds配置 =====
echo "检查feeds配置..."

if [ -f "feeds.conf.default" ]; then
    echo "原始feeds.conf.default内容:"
    cat feeds.conf.default
    echo ""
    echo "备份原始配置..."
    cp feeds.conf.default feeds.conf.default.bak
else
    echo "警告: feeds.conf.default文件不存在"
fi

# ===== 显示版本信息 =====
echo "OpenWrt 版本信息:"
if [ -f "version" ]; then
    cat version
fi

echo ""
echo "✓ 脚本1执行完成"

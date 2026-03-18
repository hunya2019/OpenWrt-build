#!/bin/bash

# ImmortalWrt 25.12 完整编译脚本
# 此脚本为25.12版本的官方编译脚本
# 用法: bash build_25_12.sh

set -e

BUILD_VERSION="25.12"
BUILD_DATE=$(date +"%Y-%m-%d %H:%M:%S")
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$BUILD_DIR/smpackage"

# 颜色定义
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${Green}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${Yellow}[WARN]${NC} $1"
}

log_error() {
    echo -e "${Red}[ERROR]${NC} $1"
}

# 打印标题
print_header() {
    echo "===================================="
    echo "ImmortalWrt 25.12 编译系统"
    echo "构建日期: $BUILD_DATE"
    echo "工作目录: $BUILD_DIR"
    echo "===================================="
}

# 检查依赖
check_dependencies() {
    log_info "检查编译依赖..."
    
    local required_tools=("git" "gcc" "make" "python3" "wget" "curl" "gzip" "bzip2" "xz-utils")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "缺少以下工具: ${missing_tools[*]}"
        log_info "请使用包管理器安装缺失的工具"
        return 1
    fi
    
    log_info "✓ 所有依赖检查完成"
    return 0
}

# 初始化源码
init_source() {
    log_info "初始化源码仓库..."
    
    # 如果不是git仓库，转换为git仓库
    if [ ! -d ".git" ]; then
        log_warn "当前目录不是git仓库，正在初始化..."
        git init
        git add .
        git commit -m "Initial commit for ImmortalWrt 25.12"
    fi
    
    # 确保在正确的分支（使用openwrt-25.12）
    if ! git branch | grep -q "openwrt-25.12"; then
        log_warn "切换到openwrt-25.12分支..."
        git checkout -b openwrt-25.12 2>/dev/null || git checkout openwrt-25.12
    else
        git checkout openwrt-25.12
    fi
    
    log_info "✓ 源码初始化完成"
}

# 更新feeds
update_feeds() {
    log_info "更新软件源（feeds）..."
    
    # 运行预编译脚本1
    if [ -f "$SCRIPT_DIR/immortalwrt-all-1.sh" ]; then
        log_info "执行预编译脚本1..."
        bash "$SCRIPT_DIR/immortalwrt-all-1.sh"
    fi
    
    # 更新和安装feeds
    if [ -f "scripts/feeds" ]; then
        log_info "更新feeds源..."
        ./scripts/feeds update -a
        
        log_info "安装feeds软件包..."
        ./scripts/feeds install -a
    else
        log_warn "未找到feeds脚本"
    fi
    
    log_info "✓ Feeds更新完成"
}

# 应用配置
apply_config() {
    log_info "应用编译配置..."
    
    # 如果存在预设配置，复制到.config
    if [ -f "$BUILD_DIR/config/immortalwrt.info" ]; then
        log_info "加载预设配置..."
        cp "$BUILD_DIR/config/immortalwrt.info" .config
    else
        log_warn "未找到预设配置文件，使用默认配置"
        make defconfig || true
    fi
    
    # 运行预编译脚本2
    if [ -f "$SCRIPT_DIR/immortalwrt-all-2.sh" ]; then
        log_info "执行预编译脚本2..."
        bash "$SCRIPT_DIR/immortalwrt-all-2.sh"
    fi
    
    log_info "✓ 配置应用完成"
}

# 显示编译信息
show_build_info() {
    log_info "编译信息总结:"
    echo "  构建版本: $BUILD_VERSION"
    echo "  构建日期: $(date)"
    echo "  工作目录: $(pwd)"
    echo "  配置项数: $([ -f .config ] && wc -l < .config || echo 'N/A')"
    echo "  启用包数: $([ -f .config ] && grep -c "=y$" .config || echo 'N/A')"
    echo "  可用CPU: $(nproc)"
    echo "  可用内存: $(free -h | grep Mem | awk '{print $2}')"
    echo "  可用磁盘: $(df -h . | tail -1 | awk '{print $4}')"
}

# 主编译函数
build() {
    log_info "开始编译..."
    
    if [ ! -f "Makefile" ]; then
        log_error "Makefile不存在，请确保在OpenWrt根目录运行此脚本"
        return 1
    fi
    
    log_info "编译参数: make -j$(nproc) V=s"
    make -j$(nproc) V=s 2>&1 | tee build_$(date +%Y%m%d_%H%M%S).log
    
    log_info "✓ 编译完成"
}

# 打包输出
package_output() {
    log_info "打包编译输出..."
    
    if [ -d "bin" ]; then
        local output_dir="output_${BUILD_VERSION}_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$output_dir"
        cp -r bin/* "$output_dir/" 2>/dev/null || true
        
        log_info "输出已复制到: $output_dir"
        log_info "文件列表:"
        ls -lh "$output_dir"/ || true
    else
        log_warn "未找到bin目录"
    fi
    
    log_info "✓ 打包完成"
}

# 清理编译
clean_build() {
    log_warn "清理编译结果..."
    make clean
    log_info "✓ 清理完成"
}

# 主函数
main() {
    print_header
    
    # 检查参数
    case "${1:-build}" in
        check)
            check_dependencies
            ;;
        init)
            init_source
            ;;
        feeds)
            update_feeds
            ;;
        config)
            apply_config
            ;;
        build)
            check_dependencies || exit 1
            init_source || exit 1
            update_feeds || exit 1
            apply_config || exit 1
            show_build_info
            build || exit 1
            package_output
            ;;
        clean)
            clean_build
            ;;
        full)
            check_dependencies || exit 1
            init_source || exit 1
            clean_build
            update_feeds || exit 1
            apply_config || exit 1
            show_build_info
            build || exit 1
            package_output
            ;;
        *)
            echo "用法: $0 {check|init|feeds|config|build|clean|full}"
            echo "  check  - 检查依赖"
            echo "  init   - 初始化源码"
            echo "  feeds  - 更新软件源"
            echo "  config - 应用配置"
            echo "  build  - 执行编译"
            echo "  clean  - 清理编译"
            echo "  full   - 完整编译流程"
            exit 1
            ;;
    esac
    
    log_info "=== 所有操作完成 ==="
}

cd "$BUILD_DIR"
main "$@"

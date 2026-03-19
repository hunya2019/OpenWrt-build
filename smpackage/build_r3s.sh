#!/bin/bash

# ImmortalWrt 25.12 - NanoPi R3S 本地编译脚本
# 设备: FriendlyElec NanoPi R3S (Rockchip RK3568)
# 版本: 2026-03-19

set -e

# 配置变量
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGS_DIR="${WORKDIR}/config"
SCRIPTS_DIR="${WORKDIR}/smpackage"
CONFIG_FILE="${CONFIGS_DIR}/config_r3s.seed"
REPO_URL="https://github.com/immortalwrt/immortalwrt.git"
REPO_BRANCH="openwrt-25.12"
BUILD_DIR="${WORKDIR}/build_r3s"
SOURCE_DIR="${BUILD_DIR}/immortalwrt"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
NanoPi R3S 编译脚本 - ImmortalWrt 25.12

用法: $0 <命令> [选项]

命令:
    check       - 检查环境和依赖
    init        - 初始化编译环境（克隆源码）
    feeds       - 更新和安装feeds
    config      - 配置编译选项
    build       - 执行编译
    clean       - 清理编译输出
    distclean   - 完全清理（删除源代码）
    full        - 完整编译流程 (init -> feeds -> config -> build)
    help        - 显示帮助信息

示例:
    $0 check                # 检查环境
    $0 full                 # 完整编译
    $0 init                 # 初始化环境
    $0 build                # 执行编译

编译输出目录: ${BUILD_DIR}
配置文件: ${CONFIG_FILE}
源代码分支: ${REPO_BRANCH}

EOF
}

# 检查依赖
check_dependencies() {
    log_info "检查系统环境和依赖..."
    
    local missing_tools=()
    
    # 检查必要工具
    for tool in git gcc g++ make libncurses5-dev libssl-dev perl python3 bash wget; do
        if ! command -v "${tool}" &> /dev/null && ! dpkg -l | grep -q "^ii.*${tool}"; then
            missing_tools+=("${tool}")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "缺少以下工具: ${missing_tools[*]}"
        log_info "建议安装: sudo apt-get install build-essential libncurses5-dev libssl-dev perl python3 zlib1g-dev"
        return 1
    fi
    
    log_info "✓ 所有依赖都已安装"
    
    # 显示版本信息
    log_info "环境信息:"
    echo "  系统: $(uname -s) $(uname -r)"
    echo "  Git: $(git --version)"
    echo "  GCC: $(gcc --version | head -n 1)"
    echo "  Python3: $(python3 --version)"
    
    return 0
}

# 初始化环境
init_environment() {
    log_info "初始化编译环境..."
    
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    
    if [ -d "${SOURCE_DIR}" ]; then
        log_warn "源代码目录已存在: ${SOURCE_DIR}"
        log_info "更新现有源代码..."
        cd "${SOURCE_DIR}"
        git fetch origin
        git checkout "${REPO_BRANCH}"
    else
        log_info "克隆ImmortalWrt源代码..."
        log_info "分支: ${REPO_BRANCH}"
        git clone -b "${REPO_BRANCH}" "${REPO_URL}" immortalwrt
        cd "${SOURCE_DIR}"
    fi
    
    log_info "✓ 环境初始化完成"
    log_info "源代码目录: ${SOURCE_DIR}"
}

# 更新feeds
update_feeds() {
    log_info "更新和安装feeds..."
    cd "${SOURCE_DIR}"
    
    # 执行编译前自定义脚本1
    if [ -f "${SCRIPTS_DIR}/immortalwrt-all-1.sh" ]; then
        log_info "执行编译前自定义脚本1..."
        bash "${SCRIPTS_DIR}/immortalwrt-all-1.sh"
    fi
    
    log_info "更新feeds..."
    ./scripts/feeds update -a
    
    log_info "安装feeds..."
    ./scripts/feeds install -a
    
    # 执行编译前自定义脚本2
    if [ -f "${SCRIPTS_DIR}/immortalwrt-all-2.sh" ]; then
        log_info "执行编译前自定义脚本2..."
        bash "${SCRIPTS_DIR}/immortalwrt-all-2.sh"
    fi
    
    log_info "✓ Feeds更新完成"
}

# 配置编译选项
configure_build() {
    log_info "配置编译选项..."
    cd "${SOURCE_DIR}"
    
    if [ ! -f "${CONFIG_FILE}" ]; then
        log_error "配置文件不存在: ${CONFIG_FILE}"
        return 1
    fi
    
    log_info "应用配置文件: ${CONFIG_FILE}"
    cp "${CONFIG_FILE}" .config
    
    # 验证配置
    if command -v make &> /dev/null; then
        make defconfig
        log_info "✓ 配置完成"
    else
        log_error "make命令不可用"
        return 1
    fi
}

# 执行编译
start_build() {
    log_info "开始编译..."
    cd "${SOURCE_DIR}"
    
    if [ ! -f ".config" ]; then
        log_error "配置文件不存在，请先运行 $0 config"
        return 1
    fi
    
    # 获取CPU核心数
    local cpu_count=$(nproc || echo 4)
    log_info "使用 ${cpu_count} 个CPU核心编译..."
    
    make V=sc -j"${cpu_count}" 2>&1 | tee build.log
    
    if [ $? -eq 0 ]; then
        log_info "✓ 编译成功"
        
        # 收集输出文件
        if [ -d "bin/targets/rockchip/armv8/" ]; then
            log_info "输出文件位置:"
            ls -lh bin/targets/rockchip/armv8/
        fi
        
        return 0
    else
        log_error "编译失败，查看build.log获取详细错误信息"
        tail -n 50 build.log
        return 1
    fi
}

# 清理输出
clean_build() {
    log_info "清理编译输出..."
    cd "${SOURCE_DIR}"
    make clean
    log_info "✓ 清理完成"
}

# 完全清理
distclean_build() {
    log_warn "将删除编译目录: ${BUILD_DIR}"
    read -p "确认删除? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "${BUILD_DIR}"
        log_info "✓ 完全清理完成"
    else
        log_info "取消清理操作"
    fi
}

# 完整编译流程
full_build() {
    log_info "开始完整编译流程..."
    log_info "步骤: init -> feeds -> config -> build"
    
    check_dependencies || return 1
    init_environment || return 1
    update_feeds || return 1
    configure_build || return 1
    start_build || return 1
    
    log_info "✓ 完整编译流程完成!"
}

# 主功能
main() {
    local command="${1:-help}"
    
    case "${command}" in
        check)
            check_dependencies
            ;;
        init)
            check_dependencies && init_environment
            ;;
        feeds)
            check_dependencies && update_feeds
            ;;
        config)
            check_dependencies && configure_build
            ;;
        build)
            start_build
            ;;
        clean)
            clean_build
            ;;
        distclean)
            distclean_build
            ;;
        full)
            full_build
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: ${command}"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"

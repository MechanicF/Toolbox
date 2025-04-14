#!/bin/bash
# Mechanic 工具箱：系统优化模块 optimize.sh

SYSCTL_FILE="/etc/sysctl.d/99-mechanic-optimize.conf"
LIMITS_FILE="/etc/security/limits.d/99-mechanic-nofile.conf"

show_menu() {
    echo "==============================="
    echo "🚀 Mechanic 系统优化工具"
    echo "==============================="
    echo "1️⃣  一键优化内核参数（sysctl）"
    echo "2️⃣  设置文件描述符上限（ulimit）"
    echo "3️⃣  启用/管理 BBR 拥塞控制算法"
    echo "4️⃣  查看当前优化参数"
    echo "5️⃣  恢复为默认设置（危险）"
    echo "0️⃣  退出"
    echo "==============================="
    echo -n "请输入选项编号: "
}

optimize_sysctl() {
    echo "📦 正在写入内核优化参数..."
    cat <<EOF > $SYSCTL_FILE
fs.file-max = 1048576
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
EOF
    sysctl --system
    echo "✅ 内核参数优化完成。"
}

set_ulimit() {
    echo "📈 设置文件描述符限制为 65535..."
    cat <<EOF > $LIMITS_FILE
* soft nofile 65535
* hard nofile 65535
EOF
    ulimit -n 65535
    echo "✅ 已设置当前和持久化最大文件描述符数为 65535。"
}

install_bbr_kernel() {
    echo "⚙️ 正在尝试安装 BBR 支持内核（适用于 Debian/Ubuntu）..."
    apt update
    apt install -y wget curl gnupg lsb-release ca-certificates

    # 安装适配内核
    echo "📦 安装 backports 新内核..."
    echo "deb http://deb.debian.org/debian bookworm-backports main" > /etc/apt/sources.list.d/backports.list
    apt update
    apt install -y -t bookworm-backports linux-image-amd64

    echo "✅ 安装完成，建议重启系统以启用新内核并启用 BBR。"
}

enable_bbr() {
    while true; do
        echo "==============================="
        echo "🎯 BBR 拥塞控制算法配置"
        echo "==============================="
        echo "1️⃣  启用 BBRv1"
        echo "2️⃣  启用 BBRv2"
        echo "3️⃣  启用 BBRv3（需内核支持）"
        echo "4️⃣  查看当前 BBR 状态"
        echo "5️⃣  检查并安装支持 BBR 的内核"
        echo "0️⃣  返回主菜单"
        echo "==============================="
        echo -n "请输入选项编号: "
        read bbr_opt

        case $bbr_opt in
            1)
                echo "⚙️ 设置为 BBRv1..."
                modprobe tcp_bbr 2>/dev/null
                sysctl -w net.core.default_qdisc=fq
                sysctl -w net.ipv4.tcp_congestion_control=bbr
                ;;
            2)
                echo "⚙️ 设置为 BBRv2..."
                sysctl -w net.core.default_qdisc=fq
                sysctl -w net.ipv4.tcp_congestion_control=bbr2
                ;;
            3)
                echo "⚙️ 设置为 BBRv3..."
                sysctl -w net.core.default_qdisc=fq
                sysctl -w net.ipv4.tcp_congestion_control=bbr
                if uname -r | grep -qi "bbrv3"; then
                    echo "✅ 检测到内核支持 BBRv3，已启用。"
                else
                    echo "⚠️ 当前内核版本未标注 bbrv3，确认是否使用了支持版本。"
                fi
                ;;
            4)
                echo "📊 当前可用算法：$(sysctl net.ipv4.tcp_available_congestion_control)"
                echo "🎯 当前使用算法：$(sysctl -n net.ipv4.tcp_congestion_control)"
                echo "🧠 BBR 是否加载模块：$(lsmod | grep bbr || echo '未加载')"
                uname -r | grep -qi "bbrv3" && echo "✅ 当前为 BBRv3 内核"
                ;;
            5)
                install_bbr_kernel
                ;;
            0) break ;;
            *) echo "❌ 无效选项" ;;
        esac
        echo ""
    done
}

show_status() {
    echo "📊 当前关键优化参数状态："
    echo "-------------------------------"
    echo "🎯 拥塞控制算法：$(sysctl -n net.ipv4.tcp_congestion_control)  （当前 TCP 拥塞控制使用的算法）"
    echo "📡 最大连接队列长度：$(sysctl -n net.core.somaxconn)  （影响高并发连接数）"
    echo "📂 最大文件数：$(sysctl -n fs.file-max)  （系统级最大文件句柄数）"
    echo "🔧 ulimit 当前值：$(ulimit -n)  （当前 shell 的最大文件描述符）"
    echo "📄 配置文件路径："
    [ -f "$LIMITS_FILE" ] && echo "  ↪️ $LIMITS_FILE:" && tail -n 5 $LIMITS_FILE || echo "  ⚠️ 未设置 ulimit 配置"
}

restore_default() {
    echo "⚠️ 即将删除优化配置文件，是否继续？(yes/no)"
    read confirm
    if [[ "$confirm" == "yes" ]]; then
        rm -f $SYSCTL_FILE $LIMITS_FILE
        echo "🔄 已移除优化文件，正在重载 sysctl..."
        sysctl --system
        echo "⚠️ 建议重启系统使 ulimit 生效。"
    else
        echo "⏹ 已取消恢复操作。"
    fi
}

while true; do
    show_menu
    read opt
    case $opt in
        1) optimize_sysctl ;;
        2) set_ulimit ;;
        3) enable_bbr ;;
        4) show_status ;;
        5) restore_default ;;
        0) echo "👋 退出"; break ;;
        *) echo "❌ 无效选项，请输入 0-5。" ;;
    esac
    echo ""
done

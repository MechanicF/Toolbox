#!/bin/bash

SWAP_FILE="/swapfile"

show_menu() {
    clear
    echo "==============================="
    echo "🔧 Debian Swap 管理工具菜单"
    echo "==============================="
    echo "1️⃣  创建 Swap 文件"
    echo "2️⃣  设置 swappiness 值"
    echo "3️⃣  查看当前 Swap 状态"
    echo "4️⃣  删除 Swap 文件"
    echo "5️⃣  查看系统内存信息"
    echo "0️⃣  退出"
    echo "==============================="
    echo -n "请输入选项编号: "
}

create_swap() {
    read -p "请输入 swap 大小（如 2G 或 1024M）: " size
    if [ -z "$size" ]; then
        echo "❌ 输入为空，已取消操作。"
        return
    fi
    if swapon --show | grep -q "$SWAP_FILE"; then
        echo "⚠️ Swap 文件 $SWAP_FILE 已存在，跳过创建。"
        return
    fi
    echo "📦 正在创建 $size 的 swap 文件..."
    fallocate -l $size $SWAP_FILE || dd if=/dev/zero of=$SWAP_FILE bs=1M count=$(echo $size | sed 's/G/*1024/;s/M//' | bc)
    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    if ! grep -q "$SWAP_FILE" /etc/fstab; then
        echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
    fi
    echo "✅ Swap 文件创建并启用成功。"
}

set_swappiness() {
    read -p "请输入 swappiness 数值（推荐 10-60，默认 10）: " value
    value=${value:-10}
    sysctl vm.swappiness=$value
    if grep -q "vm.swappiness" /etc/sysctl.conf; then
        sed -i 's/^vm.swappiness=.*/vm.swappiness='"$value"'/' /etc/sysctl.conf
    else
        echo "vm.swappiness=$value" >> /etc/sysctl.conf
    fi
    echo "✅ swappiness 设置为 $value（已持久化）。"
}

show_swap_status() {
    echo "📋 当前 swap 使用状态："
    swapon --show
    free -h
    echo ""
    echo "按任意键继续..."
    read -n 1 -s  # 等待用户按下任意键
}

delete_swap() {
    if swapon --show | grep -q "$SWAP_FILE"; then
        echo "🧹 正在禁用并删除 swap 文件..."
        swapoff $SWAP_FILE
        rm -f $SWAP_FILE
        sed -i "\|$SWAP_FILE|d" /etc/fstab
        echo "✅ 已删除 swap 文件并清理配置。"
    else
        echo "⚠️ 当前没有使用中的 $SWAP_FILE。"
    fi
}

show_memory_info() {
    echo "🧠 系统内存使用情况："
    free -m
    echo ""
    echo "💡 swappiness 当前值: $(cat /proc/sys/vm/swappiness)"
}

while true; do
    show_menu
    read opt
    case $opt in
        1) create_swap ;;
        2) set_swappiness ;;
        3) show_swap_status ;;
        4) delete_swap ;;
        5) show_memory_info ;;
        0) 
            echo "👋 退出"
            break ;;  # 退出菜单
        *)
            echo "❌ 无效选项，请输入 0-5。"
            ;;
    esac
    echo ""  # 增加空行
    sleep 1  # 增加短暂的延时
done

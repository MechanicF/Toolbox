#!/bin/bash

SWAP_FILE="/swapfile"

pause() {
    echo ""
    echo "🔁 按任意键返回菜单..."
    read -n 1 -s
}

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
        pause
        return
    fi
    if swapon --show | grep -q "$SWAP_FILE"; then
        echo "⚠️ Swap 文件 $SWAP_FILE 已存在，跳过创建。"
        pause
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
    pause
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
    pause
}

show_swap_status() {
    echo "📋 当前 Swap 使用状态："
    echo "-------------------------------"
    swapon --show | awk 'BEGIN {print "名称\t\t类型\t大小\t已用\t优先级"} NR==1 {next} {printf "%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5}'
    echo "-------------------------------"
    echo "💡 注：如果没有显示内容，说明当前系统未启用任何 Swap。"
    echo ""
    echo "🔎 系统总内存使用情况："
    echo "-------------------------------"
    free -h | awk 'NR==1 {print $1, "\t总计\t已用\t空闲\t共享\t缓存\t可用"} NR==2 {print "内存:", $2, $3, $4, $5, $6, $7} NR==3 {print "Swap:", $2, $3, $4}'
    echo "-------------------------------"
    pause
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
    pause
}

show_memory_info() {
    echo "🧠 系统内存信息："
    echo "-------------------------------"
    free -m | awk 'NR==1 {print $1, "\t总计\t已用\t空闲\t共享\t缓存\t可用"} NR==2 {print "内存:", $2 "MB", $3 "MB", $4 "MB", $5 "MB", $6 "MB", $7 "MB"} NR==3 {print "Swap:", $2 "MB", $3 "MB", $4 "MB"}'
    echo "-------------------------------"
    echo ""
    echo "💡 swappiness 当前值：$(cat /proc/sys/vm/swappiness)"
    echo "   swappiness 决定了系统使用 Swap 的频率，范围 0-100："
    echo "   🔸 数值小：尽量使用物理内存，延迟使用 Swap（如 10）"
    echo "   🔸 数值大：更积极使用 Swap，减少内存占用（如 60）"
    echo ""
    pause
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
        0) echo "👋 退出"; break ;;
        *) echo "❌ 无效选项，请输入 0-5。"; pause ;;
    esac
done

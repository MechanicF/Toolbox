#!/bin/bash

show_menu() {
    echo "==============================="
    echo "🚀 Mechanic 工具箱"
    echo "==============================="
    echo "1️⃣  启用/管理 BBR"
    echo "2️⃣  设置文件描述符上限"
    echo "3️⃣  一键优化系统"
    echo "0️⃣  退出"
    echo "==============================="
    echo -n "请输入选项编号: "
}

# 模拟功能函数
enable_bbr() {
    echo "✅ 启用 BBR 完成！"
}

set_ulimit() {
    echo "✅ 设置文件描述符限制完成！"
}

optimize_sysctl() {
    echo "✅ 系统参数优化完成！"
}

while true; do
    show_menu
    read opt
    case $opt in
        1) enable_bbr ;;
        2) set_ulimit ;;
        3) optimize_sysctl ;;
        0) echo "👋 退出"; break ;;  # 退出
        *) echo "❌ 无效选项，请重新输入。" ;;  # 无效输入提示
    esac
    echo ""  # 空行
done

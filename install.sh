#!/bin/bash

TOOLS=(swapman fireman failman optimize netman servman)
BIN_DIR="/usr/local/bin"
REPO_BASE="https://raw.githubusercontent.com/MechanicF/toolbox/main/tools"

echo "🔧 安装 Mechanic 工具箱..."

for tool in "${TOOLS[@]}"; do
    echo "📦 安装 $tool ..."
    curl -fsSL "$REPO_BASE/$tool" -o "$BIN_DIR/$tool" && chmod +x "$BIN_DIR/$tool"
done

echo -e "\n✅ 安装完成！现在你可以使用如下命令："
for tool in "${TOOLS[@]}"; do
    echo "  → $tool"
done

#!/bin/bash

TOOLS=(swapman fireman failman optimize netman servman)
BIN_DIR="/usr/local/bin"
REPO_BASE="https://raw.githubusercontent.com/MechanicF/Toolbox/main/tool"

echo "🔧 安装 Mechanic 工具箱..."

mkdir -p "$BIN_DIR"

for tool in "${TOOLS[@]}"; do
    echo "📦 安装 $tool ..."
    curl -fsSL "$REPO_BASE/$tool.sh" -o "$BIN_DIR/$tool" && chmod +x "$BIN_DIR/$tool" || echo "❌ 下载失败: $tool"
done

echo -e "\n✅ 安装完成！现在你可以使用如下命令："
for tool in "${TOOLS[@]}"; do
    echo "  → $tool"
done

# 🧰 Mechanic 工具箱

> 面向 Linux 运维的终端工具套件，轻巧 · 实用 · 模块化  
> 适用于 Debian / Ubuntu / VPS / 自建服务器环境

---

## 📦 包含工具

| 模块       | 说明                                 |
|------------|--------------------------------------|
| swapman    | Swap 文件管理、swappiness 优化等     |
| fireman    | 快速配置 UFW / iptables 防火墙       |
| failman    | Fail2Ban 状态管理、封禁/解封等       |
| optimize   | 系统性能优化、内核参数调整等         |
| netman     | 网络状态、IP、测速工具               |
| servman    | 快速管理 systemctl 服务               |

---

## 🚀 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/MechanicF/toolbox/main/install.sh | bash
```

---

## 🧪 单独运行模块

```bash
sudo swapman
sudo failman
```

---

## 🛠 贡献开发

欢迎提交 PR 或 Issue！后续计划支持：
- ZRAM 动态 swap
- Fail2Ban 多服务联动
- 自定义配置模板管理

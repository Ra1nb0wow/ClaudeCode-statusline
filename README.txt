cc-statusline — Claude Code 状态栏插件
========================================

输入框下方常驻显示：
  问候语 | 模型名 | 单次花费 | 累计花费 | 余额 | 实时时钟

安装：
  powershell -ExecutionPolicy Bypass -File install.ps1

安装后重启 Claude Code 即生效。

环境要求：
  - Claude Code（任意版本）
  - settings.json 已配置 ANTHROPIC_AUTH_TOKEN（DeepSeek API key）
  - Windows Terminal（推荐，否则 emoji 可能不显示）

文件说明：
  statusline.ps1       — 每秒刷新，渲染状态栏
  session-tracker.ps1  — Stop Hook，每次回复后记录花费
  install.ps1          — 一键安装脚本

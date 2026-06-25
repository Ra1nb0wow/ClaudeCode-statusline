# ClaudeCode-statusline

Claude Code 输入框下方常驻状态栏插件(此状态栏仅支持DeepSeek模型)。

```
下午好！喵喵喵~ | 🤖 deepseek-v4-pro | ✦ 0.01 CNY | 💸 0.50 CNY | 💰 3.71 CNY | 🕐 13:01:30
```
<img width="1703" height="358" alt="image" src="https://github.com/user-attachments/assets/aeffd558-53f9-4dde-b565-ed974b7d7911" />

## 功能

| 图标 | 内容 | 说明 |
|------|------|------|
| 🌈 | 上午好/下午好/晚上好！喵喵喵~ | 根据时间自动切换，每字不同色 |
| 🤖 | deepseek-v4-pro | 当前模型名 |
| ✦ | 0.01 CNY | 上一次回复花费 |
| 💸 | 0.50 CNY | 本会话累计花费 |
| 💰 | 3.71 CNY | DeepSeek 实时余额 |
| 🕐 | 11:37:30 | 实时时钟（每秒刷新） |

## 安装

```powershell
cd ClaudeCode-statusline
powershell -ExecutionPolicy Bypass -File install.ps1
```

重启 Claude Code 即生效。

## 环境要求

- Claude Code
- settings.json 已配置 `ANTHROPIC_AUTH_TOKEN`（DeepSeek API key）
- Windows Terminal（推荐，否则 emoji 可能显示异常）


## 许可

MIT

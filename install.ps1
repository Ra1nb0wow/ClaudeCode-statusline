# Claude Code StatusLine 一键安装
# 用法: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = 'Stop'
$dir = "$env:USERPROFILE\.claude"
$cfg = "$dir\settings.json"
$sl  = "$dir\statusline.ps1"
$tr  = "$dir\session-tracker.ps1"

Write-Host "=== cc-statusline installer ===" -ForegroundColor Cyan

# 1. copy scripts
Copy-Item "$PSScriptRoot\statusline.ps1" $sl -Force
Copy-Item "$PSScriptRoot\session-tracker.ps1" $tr -Force
Write-Host "[OK] scripts installed" -ForegroundColor Green

# 2. read settings
if (-not (Test-Path $cfg)) { '{}' | Set-Content $cfg }
$raw = Get-Content $cfg -Raw -Encoding UTF8
$s = $raw | ConvertFrom-Json

# 3. set statusLine
$s | Add-Member -Name 'statusLine' -Value (@{
    type = 'command'
    command = "powershell -ExecutionPolicy Bypass -NoProfile -File `"$sl`""
    refreshInterval = 1
}) -MemberType NoteProperty -Force

# 4. add Stop hook (merge with existing)
$newHook = @{
    matcher = ''
    hooks   = @(@{ type = 'command'; command = "powershell -ExecutionPolicy Bypass -NoProfile -File `"$tr`"" })
}
$existing = if ($s.hooks -and $s.hooks.Stop) { $s.hooks.Stop } else { @() }
$merged = @($existing) + @($newHook)
$s | Add-Member -Name 'hooks' -Value (@{ Stop = $merged }) -MemberType NoteProperty -Force

# 5. save
$s | ConvertTo-Json -Depth 6 | Set-Content $cfg -Force -Encoding UTF8
Write-Host "[OK] settings updated" -ForegroundColor Green
Write-Host ""
Write-Host "Restart Claude Code. Status line appears below the input box." -ForegroundColor Cyan

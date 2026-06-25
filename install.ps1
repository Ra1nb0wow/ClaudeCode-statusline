# Claude Code StatusLine 一键安装
# 用法: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = 'Stop'
$dir = "$env:USERPROFILE\.claude"
$cfg = "$dir\settings.json"
$sl  = "$dir\statusline.ps1"
$ss  = "$dir\session-start.ps1"
$tr  = "$dir\session-tracker.ps1"

Write-Host "=== cc-statusline installer ===" -ForegroundColor Cyan

# 1. copy scripts
Copy-Item "$PSScriptRoot\statusline.ps1"     $sl -Force
Copy-Item "$PSScriptRoot\session-start.ps1"   $ss -Force
Copy-Item "$PSScriptRoot\session-tracker.ps1" $tr -Force
Write-Host "[OK] scripts installed (statusline + session-start + session-tracker)" -ForegroundColor Green

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

# 4. add SessionStart hook
$ssHook = @{
    matcher = ''
    hooks   = @(@{ type = 'command'; command = "powershell -ExecutionPolicy Bypass -NoProfile -File `"$ss`"" })
}
$existingSS = if ($s.hooks -and $s.hooks.SessionStart) { $s.hooks.SessionStart } else { @() }
$mergedSS = @($existingSS) + @($ssHook)

# 5. add Stop hook
$stHook = @{
    matcher = ''
    hooks   = @(@{ type = 'command'; command = "powershell -ExecutionPolicy Bypass -NoProfile -File `"$tr`"" })
}
$existingST = if ($s.hooks -and $s.hooks.Stop) { $s.hooks.Stop } else { @() }
$mergedST = @($existingST) + @($stHook)

$existingHooks = if ($s.hooks) { $s.hooks } else { @{} }
$s | Add-Member -Name 'hooks' -Value (@{
    SessionStart = $mergedSS
    Stop         = $mergedST
}) -MemberType NoteProperty -Force

# 6. save
$s | ConvertTo-Json -Depth 6 | Set-Content $cfg -Force -Encoding UTF8
Write-Host "[OK] settings updated (statusLine + SessionStart hook + Stop hook)" -ForegroundColor Green
Write-Host ""
Write-Host "Restart Claude Code. Status line appears below the input box." -ForegroundColor Cyan

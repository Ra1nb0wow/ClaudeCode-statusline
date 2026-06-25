# Stop Hook: track per-turn + total spending
$ErrorActionPreference = 'Stop'
$balFile = "$env:USERPROFILE\.claude\.spending.json"

$apiKey = $env:ANTHROPIC_AUTH_TOKEN
$currentBal = 0

if ($apiKey) {
    try {
        $r = Invoke-RestMethod -Uri "https://api.deepseek.com/user/balance" `
            -Method GET -Headers @{"Authorization"="Bearer $apiKey"} -TimeoutSec 8
        if ($r.balance_infos -and $r.balance_infos[0].total_balance) {
            $currentBal = [double]$r.balance_infos[0].total_balance
        }
    } catch { exit 0 }
}

if ($currentBal -le 0) { exit 0 }

# load previous state
$sp = $null
if (Test-Path $balFile) {
    try { $sp = Get-Content $balFile -Raw | ConvertFrom-Json } catch {}
}

if (-not $sp -or -not $sp.startBalance -or $sp.startBalance -le 0) {
    # first run: init
    $sp = @{
        startBalance   = $currentBal
        prevBalance    = $currentBal
        lastTurnCost   = 0.0
        totalSpent     = 0.0
        timestamp      = (Get-Date -Format 'o')
    }
} else {
    # calc this turn's cost
    $prev = [double]$sp.prevBalance
    $turnCost = $prev - $currentBal
    if ($turnCost -lt 0) { $turnCost = 0 }

    $total = [double]$sp.startBalance - $currentBal
    if ($total -lt 0) { $total = 0 }

    # if balance went up (top-up), reset baseline
    if ($currentBal -gt $prev) {
        $sp.startBalance = $currentBal
        $sp.prevBalance  = $currentBal
        $turnCost = 0
        $total = 0
    } else {
        $sp.prevBalance = $currentBal
    }

    $sp.lastTurnCost = [math]::Round($turnCost, 4)
    $sp.totalSpent   = [math]::Round($total, 4)
    $sp.timestamp    = (Get-Date -Format 'o')
}

$sp | ConvertTo-Json | Set-Content $balFile -Force

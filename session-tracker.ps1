# Stop Hook: track per-turn + session + total spending
$ErrorActionPreference = 'Stop'
$spendFile = "$env:USERPROFILE\.claude\.spending.json"

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
if (Test-Path $spendFile) {
    try { $sp = Get-Content $spendFile -Raw | ConvertFrom-Json } catch {}
}

if (-not $sp -or -not $sp.startBalance -or $sp.startBalance -le 0) {
    # first run: init
    $sp = [PSCustomObject]@{
        startBalance   = $currentBal
        prevBalance    = $currentBal
        lastTurnCost   = 0.0
        totalSpent     = 0.0
        sessionSpent   = 0.0
        sessionBalance = $currentBal
        timestamp      = (Get-Date -Format 'o')
    }
} else {
    # calc this turn's cost
    $prev = [double]$sp.prevBalance
    $diff = $prev - $currentBal

    # all-time total
    $total = [double]$sp.startBalance - $currentBal
    if ($total -lt 0) { $total = 0 }

    # session total (since last SessionStart)
    $sessStart = if ($sp.sessionBalance) { [double]$sp.sessionBalance } else { [double]$sp.startBalance }
    $sessSpent = $sessStart - $currentBal
    if ($sessSpent -lt 0) { $sessSpent = 0 }

    if ($diff -lt -0.005) {
        # actual top-up (balance increased > 0.005 CNY)
        $sp.startBalance   = $currentBal
        $sp.prevBalance    = $currentBal
        $sp.sessionBalance = $currentBal
        $turnCost  = 0
        $total     = 0
        $sessSpent = 0
    } elseif ($diff -lt 0) {
        # float jitter: balance slightly higher, not a real top-up
        # keep prevBalance unchanged to prevent drift
        $turnCost = 0
    } else {
        # normal spend: balance decreased
        $turnCost = $diff
        $sp.prevBalance = $currentBal
    }

    $sp.lastTurnCost = [math]::Round($turnCost, 4)
    $sp.totalSpent   = [math]::Round($total, 4)
    $sp.sessionSpent = [math]::Round($sessSpent, 4)
    $sp.timestamp    = (Get-Date -Format 'o')
}

$sp | ConvertTo-Json | Set-Content $spendFile -Force

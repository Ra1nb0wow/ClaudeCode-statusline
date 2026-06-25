# SessionStart Hook: reset session-level cost counter for new conversation
$ErrorActionPreference = 'Stop'
$spendFile = "$env:USERPROFILE\.claude\.spending.json"

$apiKey = $env:ANTHROPIC_AUTH_TOKEN
if (-not $apiKey) { exit 0 }

try {
    $r = Invoke-RestMethod -Uri "https://api.deepseek.com/user/balance" `
        -Method GET -Headers @{"Authorization"="Bearer $apiKey"} -TimeoutSec 5
    if ($r.balance_infos -and $r.balance_infos[0].total_balance) {
        $currentBal = [double]$r.balance_infos[0].total_balance
    } else { exit 0 }
} catch { exit 0 }

# load existing data (keep startBalance for all-time total)
$sp = $null
if (Test-Path $spendFile) {
    try { $sp = Get-Content $spendFile -Raw | ConvertFrom-Json } catch {}
}

if (-not $sp) {
    # very first run ever
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
    # new conversation starts: reset session counters
    $sp.lastTurnCost   = 0.0
    $sp.sessionSpent   = 0.0
    $sp.sessionBalance = $currentBal
    $sp.timestamp      = (Get-Date -Format 'o')
}

$sp | ConvertTo-Json | Set-Content $spendFile -Force

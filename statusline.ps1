# Claude Code StatusLine
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8
$ErrorActionPreference = 'SilentlyContinue'

$e = [char]27
$R  = "$e[0m"; $BD = "$e[1m"; $DM = "$e[2m"
$CY = "$e[36m"; $YL = "$e[33m"; $GN = "$e[32m"; $WT = "$e[37m"; $GY = "$e[90m"; $MG = "$e[35m"

$ro = [char]::ConvertFromUtf32(0x1F916)
$sp = [char]::ConvertFromUtf32(0x1F4B8)
$tr = [char]::ConvertFromUtf32(0x2726)
$ba = [char]::ConvertFromUtf32(0x1F4B0)
$cl = [char]::ConvertFromUtf32(0x1F550)

# --- model ---
$model = $env:ANTHROPIC_MODEL
if (-not $model) { $model = 'deepseek-v4-pro' }

# --- spending ---
$spendFile = "$env:USERPROFILE\.claude\.spending.json"
$turnVal = '--'; $sessVal = '--'; $balVal = '--'

if (Test-Path $spendFile) {
    try { $d = Get-Content $spendFile -Raw | ConvertFrom-Json } catch {}
    if ($d) {
        if ($d.lastTurnCost -ne $null) { $turnVal = [math]::Round($d.lastTurnCost, 2).ToString('0.00') }
        if ($d.sessionSpent -ne $null) { $sessVal = [math]::Round($d.sessionSpent, 2).ToString('0.00') }
        if ($d.prevBalance -ne $null)  { $balVal  = [math]::Round($d.prevBalance, 2).ToString('0.00') }
    }
}

if ($balVal -eq '--') {
    $key = $env:ANTHROPIC_AUTH_TOKEN
    if ($key) {
        try {
            $r = Invoke-RestMethod -Uri "https://api.deepseek.com/user/balance" `
                -Method GET -Headers @{"Authorization"="Bearer $key"} -TimeoutSec 3
            if ($r.balance_infos) { $balVal = [math]::Round([double]$r.balance_infos[0].total_balance, 2).ToString('0.00') }
        } catch {}
    }
}

$now = Get-Date -Format 'HH:mm:ss'

$hour = [int](Get-Date -Format 'HH')
$rawB64 = if ($hour -ge 6 -and $hour -lt 12) {
        '5LiK5Y2I5aW977yB5Za15Za15Za1fg=='        # 上午好！喵喵喵~
    } elseif ($hour -ge 12 -and $hour -lt 18) {
        '5LiL5Y2I5aW977yB5Za15Za15Za1fg=='        # 下午好！喵喵喵~
    } else {
        '5pma5LiK5aW977yB5Za15Za15Za1fg=='        # 晚上好！喵喵喵~
    }
$raw = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($rawB64))

# per-character rainbow: pink/purple gradient (256-color)
$pink = @(213,212,207,206,183,177,171,170)
$greet = ''
for ($i = 0; $i -lt $raw.Length; $i++) {
    $c = $pink[$i % $pink.Length]
    $greet += "$e[38;5;${c}m$($raw[$i])"
}
$greet += $R

$sep = " ${WT}${BD}|${R} "
$line  = "${greet} ${sep}"
$line += "${ro} ${CY}${BD}${model}${R}"
$line += "${sep}"
$line += "${tr} ${YL}${BD}${turnVal}${R} $e[38;5;81mCNY${R}"
$line += "${sep}"
$line += "${sp} ${YL}${BD}${sessVal}${R} $e[38;5;81mCNY${R}"
$line += "${sep}"
$line += "${ba} ${GN}${BD}${balVal}${R} $e[38;5;81mCNY${R}"
$line += "${sep}"
$line += "${cl} ${WT}${now}${R}"

Write-Output $line

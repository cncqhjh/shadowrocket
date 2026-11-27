$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$aiPath = Join-Path $root 'Shadowrocket\rules\ai.list'
$configPath = Join-Path $root 'Shadowrocket\perfect_rules.conf'

$requiredRules = @(
    'DOMAIN-SUFFIX,anthropic.com',
    'DOMAIN-SUFFIX,claude.ai',
    'DOMAIN-SUFFIX,claude.com',
    'DOMAIN-SUFFIX,ip.net.coffee',
    'DOMAIN-SUFFIX,ippure.com',
    'DOMAIN-SUFFIX,antigravity.google',
    'DOMAIN,antigravity-cli-auto-updater-974169037036.us-central1.run.app',
    'DOMAIN,antigravity-hub-auto-updater-974169037036.us-central1.run.app',
    'DOMAIN-SUFFIX,antigravity-unleash.goog'
)

$rules = @(Get-Content -LiteralPath $aiPath | ForEach-Object { $_.Trim() } | Where-Object {
    $_ -and -not $_.StartsWith('#')
})

foreach ($rule in $requiredRules) {
    if ($rules -notcontains $rule) { throw "AI.list missing: $rule" }
}

if (@($rules | Group-Object | Where-Object Count -gt 1).Count -ne 0) {
    throw 'AI.list contains duplicate rules'
}

$expectedReference = 'RULE-SET,https://raw.githubusercontent.com/cncqhjh/shadowrocket/main/Shadowrocket/rules/ai.list,AI'
$config = Get-Content -LiteralPath $configPath -Raw
if (-not $config.Contains($expectedReference)) {
    throw 'perfect_rules.conf does not use the self-hosted AI ruleset'
}

'AI_RULE_VALIDATION_OK'

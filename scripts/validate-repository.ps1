#Requires -Version 7.0
<#
.SYNOPSIS
    Validates the bei-LogicAppSandbox repository against the MODULE 2 blueprint.

.DESCRIPTION
    Runs the same class of checks as the pr-validation GitHub Actions workflow so a
    contributor can catch problems before opening a pull request:

      1. Required folders and files exist
      2. VERSION holds a semantic version
      3. Every JSON file parses
      4. Every YAML file parses (when a YAML parser is available)
      5. The Logic App Standard project boundary is intact
      6. Prohibited files are not tracked, and local.settings.json is ignored
      7. No obvious committed-secret pattern is present (values are never printed)
      8. No workflow contains an Azure login or deployment step

    Deploys nothing. Contacts nothing. Read-only.

.EXAMPLE
    pwsh ./scripts/validate-repository.ps1
#>
[CmdletBinding()]
param(
    [string] $RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Failures = @()
function Add-Failure { param([string] $Message) $script:Failures += $Message; Write-Host "  FAIL  $Message" -ForegroundColor Red }
function Write-Pass  { param([string] $Message) Write-Host "  PASS  $Message" -ForegroundColor Green }
function Write-Section { param([string] $Title) Write-Host "`n== $Title ==" -ForegroundColor Cyan }

Push-Location $RepositoryRoot
try {
    Write-Host "Validating repository at: $RepositoryRoot"

    # ---------------------------------------------------------------- 1. tree
    Write-Section 'Required structure'
    $requiredDirs = @(
        '.github/workflows', '.github/ISSUE_TEMPLATE',
        'src/logic-app/shopify-order-simulation',
        'src/logic-app/shopify-order-simulation/wf-shopify-order-ingest',
        'infra', 'infra/modules', 'infra/environments',
        'tests/payloads/valid', 'tests/payloads/invalid', 'tests/payloads/edge-cases',
        'tests/contracts', 'tests/integration', 'tests/smoke',
        'scripts',
        'docs/architecture', 'docs/decisions', 'docs/onboarding', 'docs/runbooks',
        'ops/alerts', 'ops/dashboards', 'ops/queries', 'ops/support'
    )
    $requiredFiles = @(
        '.editorconfig', '.gitignore', 'CHANGELOG.md', 'CONTRIBUTING.md',
        'README.md', 'SECURITY.md', 'VERSION',
        '.github/CODEOWNERS', '.github/dependabot.yml', '.github/PULL_REQUEST_TEMPLATE.md',
        '.github/ISSUE_TEMPLATE/feature.yml', '.github/ISSUE_TEMPLATE/defect.yml',
        '.github/workflows/pr-validation.yml', '.github/workflows/deploy-uat.yml',
        '.github/workflows/promote-prod.yml', '.github/workflows/release.yml',
        'src/logic-app/shopify-order-simulation/host.json',
        'src/logic-app/shopify-order-simulation/connections.json',
        'src/logic-app/shopify-order-simulation/parameters.json',
        'src/logic-app/shopify-order-simulation/local.settings.example.json',
        'src/logic-app/shopify-order-simulation/.funcignore',
        'src/logic-app/shopify-order-simulation/wf-shopify-order-ingest/workflow.json',
        'infra/main.bicep', 'infra/bicepconfig.json',
        'infra/environments/main.uat.bicepparam', 'infra/environments/main.prod.bicepparam'
    )
    foreach ($d in $requiredDirs) { if (Test-Path -LiteralPath $d -PathType Container) { } else { Add-Failure "Missing directory: $d" } }
    foreach ($f in $requiredFiles) { if (Test-Path -LiteralPath $f -PathType Leaf)      { } else { Add-Failure "Missing file: $f" } }
    if ($script:Failures.Count -eq 0) { Write-Pass 'Required tree is present' }

    # ------------------------------------------------------------- 2. version
    Write-Section 'VERSION'
    $version = (Get-Content -LiteralPath 'VERSION' -Raw).Trim()
    if ($version -match '^\d+\.\d+\.\d+$') { Write-Pass "VERSION = $version" }
    else { Add-Failure "VERSION must be MAJOR.MINOR.PATCH; found '$version'" }

    # ---------------------------------------------------------------- 3. JSON
    Write-Section 'JSON syntax'
    $jsonFiles = Get-ChildItem -Recurse -File -Filter '*.json' |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
    $jsonBad = 0
    foreach ($file in $jsonFiles) {
        try { $null = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -ErrorAction Stop }
        catch { Add-Failure "Invalid JSON: $($file.FullName)"; $jsonBad++ }
    }
    if ($jsonBad -eq 0) { Write-Pass "$($jsonFiles.Count) JSON file(s) parsed" }

    # ---------------------------------------------------------------- 4. YAML
    Write-Section 'YAML syntax'
    $yamlFiles = Get-ChildItem -Recurse -File -Include '*.yml', '*.yaml' |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
    $python = Get-Command python3 -ErrorAction SilentlyContinue
    if (-not $python) { $python = Get-Command python -ErrorAction SilentlyContinue }
    $hasPyYaml = $false
    if ($python) {
        & $python.Source -c "import yaml" 2>$null
        $hasPyYaml = ($LASTEXITCODE -eq 0)
    }
    if ($python -and $hasPyYaml) {
        $yamlBad = 0
        foreach ($file in $yamlFiles) {
            & $python.Source -c "import yaml,sys; list(yaml.safe_load_all(open(sys.argv[1], encoding='utf-8')))" $file.FullName 2>$null
            if ($LASTEXITCODE -ne 0) { Add-Failure "Invalid YAML: $($file.FullName)"; $yamlBad++ }
        }
        if ($yamlBad -eq 0) { Write-Pass "$($yamlFiles.Count) YAML file(s) parsed" }
    }
    else {
        # No local YAML parser. This is a tooling gap, not a repository fault -
        # pr-validation validates every YAML file on each pull request.
        Write-Host "  SKIP  No local YAML parser (PyYAML not installed); CI validates YAML on every PR." -ForegroundColor Yellow
    }

    # ------------------------------------------------- 5. Logic App boundary
    Write-Section 'Logic App Standard project boundary'
    $laRoot = 'src/logic-app/shopify-order-simulation'
    $wfDirs = Get-ChildItem -LiteralPath $laRoot -Directory -Filter 'wf-*' -ErrorAction SilentlyContinue
    if (-not $wfDirs) { Add-Failure "No wf-* workflow folder under $laRoot" }
    foreach ($wf in $wfDirs) {
        if (-not (Test-Path -LiteralPath (Join-Path $wf.FullName 'workflow.json'))) {
            Add-Failure "Workflow folder $($wf.Name) has no workflow.json"
        }
        if ($wf.Name -match 'uat|prod|dev|test') {
            Add-Failure "Workflow folder $($wf.Name) contains an environment name; the same artifact is promoted between environments"
        }
    }
    $external = Get-ChildItem -LiteralPath $laRoot -Recurse -File -ErrorAction SilentlyContinue |
        Select-String -Pattern 'shopify\.com', 'blob\.core\.windows\.net', 'vault\.azure\.net', 'office365' -ErrorAction SilentlyContinue
    if ($external) {
        foreach ($hit in $external) { Add-Failure "Placeholder workflow references an external endpoint at $($hit.Path):$($hit.LineNumber); it must call nothing" }
    }
    else { Write-Pass 'Project boundary is valid' }

    # -------------------------------------------------- 6. prohibited files
    Write-Section 'Prohibited files'
    $patterns = @('local.settings.json', '*.pfx', '*.pem', '*.key', '*.p12',
                  '*.publishsettings', '*.PublishSettings', '*.azurePubxml', '.env', '*.zip')
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        foreach ($p in $patterns) {
            $tracked = & git ls-files -- $p "**/$p"
            if ($tracked) { Add-Failure "Prohibited file tracked in git (pattern $p): $($tracked -join ', ')" }
        }
        $probe = Join-Path $laRoot 'local.settings.json'
        $existed = Test-Path -LiteralPath $probe
        if (-not $existed) { New-Item -ItemType File -Path $probe -Force | Out-Null }
        & git check-ignore -q $probe
        if ($LASTEXITCODE -ne 0) { Add-Failure 'local.settings.json is NOT ignored by .gitignore' } else { Write-Pass 'local.settings.json is ignored' }
        if (-not $existed) { Remove-Item -LiteralPath $probe -Force }
    }
    else { Write-Host '  SKIP  git not available; tracked-file check skipped.' -ForegroundColor Yellow }

    # ------------------------------------------------------ 7. secret scan
    Write-Section 'Committed-secret patterns'
    $secretPatterns = @(
        'AccountKey\s*=\s*[A-Za-z0-9+/]{20,}', 'SharedAccessSignature', 'sig=[A-Za-z0-9%]{20,}',
        'Endpoint=sb://.*SharedAccessKey', 'InstrumentationKey=[0-9a-fA-F-]{36}',
        '-----BEGIN [A-Z ]*PRIVATE KEY-----', 'client_secret', 'clientSecret\s*[:=]',
        'ghp_[A-Za-z0-9]{30,}', 'github_pat_[A-Za-z0-9_]{30,}', 'Server=tcp:.*Password='
    )
    $skip = @('SECURITY.md', 'CONTRIBUTING.md', 'validate-repository.ps1', 'pr-validation.yml')
    $hits = Get-ChildItem -Recurse -File |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' -and $skip -notcontains $_.Name } |
        Select-String -Pattern $secretPatterns -ErrorAction SilentlyContinue
    if ($hits) {
        # Report location only. Never print the matched value.
        foreach ($hit in $hits) { Add-Failure "Possible secret at $($hit.Path):$($hit.LineNumber) (value not printed)" }
    }
    else { Write-Pass 'No obvious committed-secret pattern found' }

    # -------------------------------------------- 8. deployment safety net
    Write-Section 'Deployment safety'
    foreach ($f in @('.github/workflows/deploy-uat.yml', '.github/workflows/promote-prod.yml', '.github/workflows/release.yml')) {
        $content = Get-Content -LiteralPath $f -Raw
        if ($content -match 'azure/login|az login|azure/webapps-deploy|azure/arm-deploy|az deployment') {
            Add-Failure "$f contains an Azure login or deployment step; MODULE 4 is not authorised"
        }
        if ($content -notmatch 'MODULE 4') {
            Add-Failure "$f must state that MODULE 4 configuration is required"
        }
    }
    if ($script:Failures.Count -eq 0) { Write-Pass 'No active Azure deployment path exists' }

    # ------------------------------------------------------------- summary
    Write-Host ''
    if ($script:Failures.Count -gt 0) {
        Write-Host "Repository validation FAILED with $($script:Failures.Count) problem(s)." -ForegroundColor Red
        exit 1
    }
    Write-Host 'Repository validation PASSED.' -ForegroundColor Green
    exit 0
}
finally { Pop-Location }

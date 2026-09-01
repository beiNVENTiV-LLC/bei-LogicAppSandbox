#Requires -Version 7.0
<#
.SYNOPSIS
    One-time GitHub governance bootstrap for bei-LogicAppSandbox.

.DESCRIPTION
    Applies the MODULE 2 governance controls that live in GitHub rather than in the
    repository tree: repository creation, merge settings, the protected-main ruleset,
    the UAT and PROD environments, and the CODEOWNERS team slug.

    NOTHING IS GUESSED. You must supply the organization slug and the team slug.
    The script verifies both before it changes anything, and runs read-only by
    default: pass -Apply to make changes.

    Requires the GitHub CLI (gh) authenticated as a user with admin rights on the
    repository and the ability to read organization teams.

.PARAMETER OrgSlug
    The exact GitHub organization slug (case-sensitive path segment), e.g. beinventiv.
    Confirm with:  gh api /user/orgs --jq '.[].login'

.PARAMETER TeamSlug
    The exact GitHub team slug that owns this repository.
    Confirm with:  gh api /orgs/<OrgSlug>/teams --jq '.[].slug'

.PARAMETER ProdReviewer
    One or more GitHub usernames or team slugs authorised to approve a PROD deployment.

.PARAMETER Apply
    Actually make changes. Without it the script only reports what it would do.

.EXAMPLE
    pwsh ./scripts/configure-github-governance.ps1 -OrgSlug <org> -TeamSlug azure-integration-maintainers -ProdReviewer <user> -WhatIfOnly

.EXAMPLE
    pwsh ./scripts/configure-github-governance.ps1 -OrgSlug <org> -TeamSlug azure-integration-maintainers -ProdReviewer <user> -Apply
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]   $OrgSlug,
    [Parameter(Mandatory)] [string]   $TeamSlug,
    [Parameter(Mandatory)] [string[]] $ProdReviewer,
    [string] $RepoName    = 'bei-LogicAppSandbox',
    [string] $Description = 'beiNVENTiV Azure Logic App Standard ALM accelerator and simulated Shopify integration learning repository.',
    [string] $Visibility  = 'private',
    [switch] $Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repo = "$OrgSlug/$RepoName"
function Step { param([string] $m) Write-Host "`n>> $m" -ForegroundColor Cyan }
function Do-It {
    param([string] $Description, [scriptblock] $Action)
    if ($Apply) { Write-Host "   APPLY  $Description"; & $Action }
    else        { Write-Host "   PLAN   $Description" -ForegroundColor Yellow }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI (gh) is required. Install it and run: gh auth login'
}

# --------------------------------------------------------------- preflight
Step 'Preflight: verifying the organization and team you supplied actually exist'
$null = gh api "/orgs/$OrgSlug" --jq '.login'
if ($LASTEXITCODE -ne 0) { throw "Organization slug '$OrgSlug' was not found or is not visible to you. Do not guess it." }
$null = gh api "/orgs/$OrgSlug/teams/$TeamSlug" --jq '.slug'
if ($LASTEXITCODE -ne 0) { throw "Team slug '$TeamSlug' was not found in '$OrgSlug'. Create it first, or supply the correct slug. Do not guess it." }
Write-Host "   Confirmed: $OrgSlug / $TeamSlug"

Step 'Preflight: repository'
$repoExists = $true
$null = gh api "/repos/$repo" --jq '.full_name' 2>$null
if ($LASTEXITCODE -ne 0) { $repoExists = $false }
Write-Host ("   Repository {0}: {1}" -f $repo, ($repoExists ? 'exists' : 'does NOT exist'))

if (-not $repoExists) {
    Do-It "Create $repo as $Visibility with main as the default branch" {
        gh repo create $repo --$Visibility --description $Description --disable-wiki
    }
}

# ------------------------------------------------------ repository settings
Step 'Repository settings: squash-only merges, auto-delete branches'
Do-It 'Enable squash merge; disable merge commits and rebase merges; delete head branch on merge' {
    gh api -X PATCH "/repos/$repo" `
        -f description="$Description" `
        -F allow_squash_merge=true `
        -F allow_merge_commit=false `
        -F allow_rebase_merge=false `
        -F delete_branch_on_merge=true `
        -F allow_auto_merge=true `
        -f squash_merge_commit_title=PR_TITLE `
        -f squash_merge_commit_message=PR_BODY | Out-Null
}

Step 'Repository access: grant the code-owning team write access'
Do-It "Grant $TeamSlug push access to $repo (CODEOWNERS is ignored without it)" {
    gh api -X PUT "/orgs/$OrgSlug/teams/$TeamSlug/repos/$repo" -f permission=push | Out-Null
}

# ---------------------------------------------------------------- CODEOWNERS
Step 'CODEOWNERS: replace the placeholder slug'
$codeowners = Join-Path (Split-Path -Parent $PSScriptRoot) '.github/CODEOWNERS'
if ((Get-Content -LiteralPath $codeowners -Raw) -match 'ORG-SLUG-PLACEHOLDER') {
    Do-It "Rewrite $codeowners with @$OrgSlug/$TeamSlug (commit this through a pull request)" {
        (Get-Content -LiteralPath $codeowners -Raw) -replace 'ORG-SLUG-PLACEHOLDER', $OrgSlug |
            Set-Content -LiteralPath $codeowners -NoNewline
    }
}
else { Write-Host '   CODEOWNERS already has a real slug.' }

# ------------------------------------------------------------------ ruleset
Step 'Branch protection: protected-main ruleset'
$ruleset = @{
    name        = 'protect-main'
    target      = 'branch'
    enforcement = 'active'
    # No bypass actors: rules apply to administrators and there is no routine bypass.
    bypass_actors = @()
    conditions  = @{ ref_name = @{ include = @('~DEFAULT_BRANCH'); exclude = @() } }
    rules       = @(
        @{ type = 'deletion' }
        @{ type = 'non_fast_forward' }          # blocks force pushes
        @{ type = 'required_linear_history' }
        @{
            type = 'pull_request'
            parameters = @{
                required_approving_review_count   = 1
                dismiss_stale_reviews_on_push     = $true
                require_code_owner_review         = $true
                require_last_push_approval        = $true
                required_review_thread_resolution = $true
                allowed_merge_methods             = @('squash')
            }
        }
        @{
            type = 'required_status_checks'
            parameters = @{
                strict_required_status_checks_policy = $true   # branch must be current with main
                required_status_checks = @(@{ context = 'pr-validation' })
            }
        }
    )
} | ConvertTo-Json -Depth 12

Do-It 'Create or update the protect-main ruleset (PR + 1 independent approval + code owners + pr-validation + strict + conversations resolved + linear history + no force push + no deletion + applies to admins)' {
    $existing = gh api "/repos/$repo/rulesets" --jq '.[] | select(.name=="protect-main") | .id' 2>$null
    if ($existing) { $ruleset | gh api -X PUT "/repos/$repo/rulesets/$existing" --input - | Out-Null }
    else           { $ruleset | gh api -X POST "/repos/$repo/rulesets"          --input - | Out-Null }
}

# ------------------------------------------------------------- environments
Step 'GitHub Environments: UAT and PROD'
Do-It 'Create the UAT environment, restricted to protected branches, no routine reviewer' {
    gh api -X PUT "/repos/$repo/environments/UAT" `
        -F "deployment_branch_policy[protected_branches]=true" `
        -F "deployment_branch_policy[custom_branch_policies]=false" | Out-Null
}

$prodReviewers = @()
foreach ($r in $ProdReviewer) {
    $userId = gh api "/users/$r" --jq '.id' 2>$null
    if ($LASTEXITCODE -eq 0) { $prodReviewers += @{ type = 'User'; id = [int] $userId }; continue }
    $teamId = gh api "/orgs/$OrgSlug/teams/$r" --jq '.id' 2>$null
    if ($LASTEXITCODE -eq 0) { $prodReviewers += @{ type = 'Team'; id = [int] $teamId }; continue }
    throw "PROD reviewer '$r' is neither a visible user nor a team in '$OrgSlug'. Do not guess reviewers."
}

$prodBody = @{
    wait_timer               = 0
    prevent_self_review      = $true
    reviewers                = $prodReviewers
    deployment_branch_policy = @{ protected_branches = $false; custom_branch_policies = $true }
} | ConvertTo-Json -Depth 8

Do-It 'Create the PROD environment with a required reviewer and self-approval prevented' {
    $prodBody | gh api -X PUT "/repos/$repo/environments/PROD" --input - | Out-Null
}
Do-It 'Restrict PROD deployments to main and to v* release tags only' {
    gh api -X POST "/repos/$repo/environments/PROD/deployment-branch-policies" -f name='main' -f type='branch' | Out-Null
    gh api -X POST "/repos/$repo/environments/PROD/deployment-branch-policies" -f name='v*'   -f type='tag'    | Out-Null
}

Step 'Environment configuration names (values are NOT set here)'
Write-Host '   AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID must be added as'
Write-Host '   environment VARIABLES on UAT and PROD once the Azure identities exist.'
Write-Host '   They are nonsecret identifiers. NEVER create an Azure client secret for Actions.'
Write-Host '   Status: BLOCKED - AZURE IDENTITY REQUIRED.' -ForegroundColor Yellow

Step 'Done'
if (-not $Apply) { Write-Host 'Ran in plan mode. Re-run with -Apply to make these changes.' -ForegroundColor Yellow }

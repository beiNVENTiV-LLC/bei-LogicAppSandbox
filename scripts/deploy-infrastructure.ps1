#Requires -Version 7.0
<#
.SYNOPSIS
    Deploys the Bicep infrastructure for one environment.

.DESCRIPTION
    STATUS: PLACEHOLDER. MODULE 4 IS NOT IMPLEMENTED.

    This script deliberately fails if it is run. It contains no Azure login, no
    deployment call, no artifact publication and no Azure identifier.

    Future responsibility:
    - Accept an environment name (uat or prod) and select infra/environments/main.<env>.bicepparam.
    - Run a what-if against infra/main.bicep, then deploy at subscription scope.
    - Never accept a secret as a parameter; secrets come from Key Vault.
    - Never create a second template for a second environment.

    Blocked on:
    - MODULE 3 Bicep templates that actually declare resources.
    - An Azure deployment identity - BLOCKED, AZURE IDENTITY REQUIRED.

    See docs/decisions/0001-oidc-deployment-identity-blocked.md.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Error @'
Deploys the Bicep infrastructure for one environment.

This is a MODULE 2 placeholder. MODULE 4 configuration is required before it can
run. Nothing was built, deployed or published.

See docs/decisions/0001-oidc-deployment-identity-blocked.md.
'@
exit 1

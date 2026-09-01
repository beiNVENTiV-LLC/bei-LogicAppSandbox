#Requires -Version 7.0
<#
.SYNOPSIS
    Builds the immutable Logic App Standard deployment artifact.

.DESCRIPTION
    STATUS: PLACEHOLDER. MODULE 4 IS NOT IMPLEMENTED.

    This script deliberately fails if it is run. It contains no Azure login, no
    deployment call, no artifact publication and no Azure identifier.

    Future responsibility:
    - Read VERSION and the short commit SHA.
    - Produce bei-logicappsandbox_<version>_<short-sha>.zip containing the CONTENTS of src/logic-app/shopify-order-simulation/ at the ZIP ROOT.
    - Exclude local.settings.json, the designtime folder and every file listed in .funcignore.
    - Emit the artifact path and a checksum so the same artifact can be promoted from UAT to PROD without rebuilding.

    Blocked on:
    - A MODULE 4 decision on where artifacts are retained and for how long.

    See docs/decisions/0001-oidc-deployment-identity-blocked.md.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Error @'
Builds the immutable Logic App Standard deployment artifact.

This is a MODULE 2 placeholder. MODULE 4 configuration is required before it can
run. Nothing was built, deployed or published.

See docs/decisions/0001-oidc-deployment-identity-blocked.md.
'@
exit 1

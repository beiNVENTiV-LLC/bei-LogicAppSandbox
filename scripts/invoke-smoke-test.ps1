#Requires -Version 7.0
<#
.SYNOPSIS
    Runs the post-deployment smoke test against a deployed environment.

.DESCRIPTION
    STATUS: PLACEHOLDER. MODULE 4 IS NOT IMPLEMENTED.

    This script deliberately fails if it is run. It contains no Azure login, no
    deployment call, no artifact publication and no Azure identifier.

    Future responsibility:
    - Send a synthetic, non-production order payload from tests/payloads/valid/ to the deployed ingest endpoint.
    - Assert the expected response and the expected Application Insights telemetry.
    - Never use a real customer payload and never print a callback URL or signature.

    Blocked on:
    - A deployed environment to test against.
    - A MODULE 4 decision on how the endpoint address is supplied without exposing a signature.

    See docs/decisions/0001-oidc-deployment-identity-blocked.md.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Error @'
Runs the post-deployment smoke test against a deployed environment.

This is a MODULE 2 placeholder. MODULE 4 configuration is required before it can
run. Nothing was built, deployed or published.

See docs/decisions/0001-oidc-deployment-identity-blocked.md.
'@
exit 1

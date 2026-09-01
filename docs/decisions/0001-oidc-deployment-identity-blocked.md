# ADR 0001 — GitHub-to-Azure authentication uses OIDC, and no identity exists yet

* **Status:** **BLOCKED — AZURE IDENTITY REQUIRED**
* **Date:** 2026-08-31
* **Module:** raised in MODULE 2; must be resolved before MODULE 3 completes and MODULE 4 begins
* **Deciders:** beiNVENTiV LLC — Azure subscription owner and `azure-integration-maintainers`

## Context

MODULE 4 will deploy this repository's artifact to UAT and then promote it to PROD from GitHub
Actions. That requires GitHub to authenticate to Azure.

Two options exist. Storing a long-lived Azure client secret as a GitHub secret is rejected: it is
a standing credential, it must be rotated manually, it is usable from anywhere, and its exposure
is unrecoverable without an outage. GitHub OIDC / workload identity federation instead issues a
short-lived token per workflow run, scoped by a trust policy that names the repository and, where
appropriate, the GitHub Environment. No Azure credential is stored in GitHub at all. GitHub also
recommends that environments used in OIDC subject policies are themselves protected, so the trust
cannot be claimed from an unprotected branch or an unreviewed run.

## Decision

1. GitHub Actions authenticates to Azure **only** through OIDC / workload identity federation.
2. **No Azure client secret is ever created for GitHub Actions**, and no long-lived Azure
   credential is stored as a GitHub secret.
3. UAT and PROD use **separate** deployment identities with **separately scoped, least-privilege**
   Azure access. Neither may hold Owner or Contributor at subscription scope.
4. Federated credential trust is restricted to the `bei-LogicAppSandbox` repository, and PROD
   trust is further restricted by GitHub Environment subject.
5. The UAT and PROD GitHub Environments are protected, and PROD carries a required reviewer.
6. Only nonsecret identifiers — `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` —
   are stored in GitHub, preferably as environment **variables** rather than secrets.

## Current state — why this is blocked

As of MODULE 2, none of the following could be confirmed, and this repository has no ability to
inspect or create them:

| Item | Status |
| --- | --- |
| UAT deployment identity (Entra application or user-assigned Managed Identity) | **Not confirmed** |
| PROD deployment identity | **Not confirmed** |
| Federated credential for UAT scoped to this repository | **Not confirmed** |
| Federated credential for PROD scoped to this repository and the PROD environment | **Not confirmed** |
| Azure RBAC role assignments and their scope | **Not confirmed** |
| `AZURE_CLIENT_ID` / `AZURE_TENANT_ID` / `AZURE_SUBSCRIPTION_ID` values | **Not available** |

In line with the MODULE 2 rules, **no Entra application and no Managed Identity was created**,
because neither was approved and neither may be guessed.

## Required configuration (for whoever unblocks this)

The following must be decided and recorded by an authorised beiNVENTiV owner before MODULE 4:

| Input | Value |
| --- | --- |
| GitHub owner / organization slug | `[PLACEHOLDER — not confirmed]` |
| GitHub repository | `bei-LogicAppSandbox` |
| GitHub environments used as OIDC subjects | `UAT`, `PROD` |
| Azure tenant | `beinventiv.com` (tenant GUID `[PLACEHOLDER]`) |
| Azure subscription | Microsoft Azure Sponsorship 4000 (subscription GUID `[PLACEHOLDER]`) |
| UAT target scope | `[PLACEHOLDER — resource group `rg-bei-<workload>-uat-<region>-001` recommended, not subscription]` |
| PROD target scope | `[PLACEHOLDER — resource group `rg-bei-<workload>-prod-<region>-001` recommended, not subscription]` |
| UAT identity name | `[PLACEHOLDER]` |
| PROD identity name | `[PLACEHOLDER]` |
| Least-privilege role(s) | `[PLACEHOLDER — Contributor at resource-group scope plus a narrowly scoped role assignment permission, to be reviewed]` |

Federated credential subjects will take the form
`repo:<org>/bei-LogicAppSandbox:environment:UAT` and
`repo:<org>/bei-LogicAppSandbox:environment:PROD`.

## Consequences

* `deploy-uat.yml`, `promote-prod.yml` and `release.yml` remain deliberately failing placeholders,
  and `pr-validation` enforces that none of them contains an Azure login or deployment step.
* `scripts/deploy-infrastructure.ps1`, `scripts/build-logic-app.ps1` and
  `scripts/invoke-smoke-test.ps1` remain deliberately failing placeholders.
* No environment variable or secret carrying an Azure identifier has been created, because no real
  value exists and a guessed value would be worse than an empty one.
* MODULE 4 cannot start until this ADR moves to `Accepted` with the table above filled in.

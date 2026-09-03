# ADR 0001 - GitHub-to-Azure authentication uses OIDC

* **Status:** **Accepted**
* **Date raised:** 31 August 2026 (as BLOCKED - AZURE IDENTITY REQUIRED)
* **Date accepted:** 3 September 2026
* **Module:** raised in MODULE 2; resolved before MODULE 3
* **Deciders:** beiNVENTiV LLC - Azure subscription owner and `azure-integration-maintainers`

## Context

MODULE 4 deploys this repository's artifact to UAT and then promotes it to PROD from
GitHub Actions. That requires GitHub to authenticate to Azure.

Storing a long-lived Azure client secret as a GitHub secret was rejected: it is a standing
credential, it must be rotated manually, it is usable from anywhere, and its exposure is
unrecoverable without an outage. GitHub OIDC / workload identity federation instead issues
a short-lived token per workflow run, scoped by a trust policy naming the repository and
the GitHub environment. No Azure credential is stored in GitHub at all.

## Decision

1. GitHub Actions authenticates to Azure **only** through OIDC / workload identity federation.
2. **No Azure client secret is ever created for GitHub Actions.** No long-lived Azure
   credential is stored as a GitHub secret.
3. UAT and PROD use **separate** deployment identities with **separately scoped,
   least-privilege** access. Neither holds any role at subscription scope.
4. Federated credential trust is restricted to the `bei-LogicAppSandbox` repository and further
   restricted by GitHub environment subject.
5. The UAT and PROD GitHub environments are protected.
6. Only nonsecret identifiers - `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`,
   `AZURE_SUBSCRIPTION_ID` - are stored in GitHub, as environment **variables**.

## Implemented configuration

Verified live on 3 September 2026. All values below are **nonsecret identifiers**.

| Item | Value |
| --- | --- |
| Azure tenant | `beiNVENTiV` (beinventiv.com) |
| Azure subscription | Microsoft Azure Sponsorship 4000 |
| Subscription id | `70da76a9-6162-4818-b6c9-081d89168353` |
| GitHub owner | `beiNVENTiV-LLC` |
| GitHub repository | `bei-LogicAppSandbox` |
| GitHub environments used as OIDC subjects | `UAT`, `PROD` |

### UAT

| Item | Value |
| --- | --- |
| Identity | `bei-logicappsandbox-uat-deploy` |
| Client id | `ed60c6e3-1eea-4008-95de-78be53053959` |
| Federated subject | `repo:beiNVENTiV-LLC/bei-LogicAppSandbox:environment:UAT` |
| Issuer | `https://token.actions.githubusercontent.com` |
| Audience | `api://AzureADTokenExchange` |
| Target scope | resource group `rg-bei-shopify-uat-wcus-001` |
| Roles | Contributor, User Access Administrator |
| Client secrets | **none** |

### PROD

| Item | Value |
| --- | --- |
| Identity | `bei-logicappsandbox-prod-deploy` |
| Client id | `9c82fbab-efe2-4f1d-ba7e-fdd97e129ac5` |
| Federated subject | `repo:beiNVENTiV-LLC/bei-LogicAppSandbox:environment:PROD` |
| Issuer | `https://token.actions.githubusercontent.com` |
| Audience | `api://AzureADTokenExchange` |
| Target scope | resource group `rg-bei-shopify-prod-wcus-001` |
| Roles | Contributor, User Access Administrator |
| Client secrets | **none** |

### Why User Access Administrator

`infra/modules/role-assignments.bicep` grants the Logic App's managed identity access to
Key Vault, Storage and Application Insights. Creating a role assignment requires
role-assignment-write rights, which Contributor alone does not confer. The role is scoped
to the environment resource group only - never to the subscription.

## Operational notes

**Federated subjects are case-sensitive.** Entra matches the subject string exactly against
the token claim from GitHub. A casing mismatch fails as `AADSTS70021: No matching federated
identity record found`, which presents as a permissions fault and misdirects diagnosis. The
confirmed organisation casing is `beiNVENTiV-LLC`.

**Never run `az ad app credential reset`.** Creating a client secret on either application
breaks the OIDC model and violates `SECURITY.md`.

Verify the configuration at any time with `verify-azure-oidc.ps1`, which confirms subject
casing, role scope, and the absence of client secrets.

## Consequences

* MODULE 4 can implement `deploy-uat.yml` and `promote-prod.yml` against real identities.
* Each workflow run receives a short-lived token; there is nothing to rotate and nothing to leak.
* A compromised repository cannot yield a reusable Azure credential.
* Deployment blast radius is bounded by resource group. Neither identity can affect the other
  environment or anything else in the subscription.
* `deploy-uat.yml`, `promote-prod.yml` and `release.yml` remain deliberately failing
  placeholders until MODULE 4 implements them. `pr-validation` still enforces that none of
  them contains an Azure login or deployment step.

## Supersedes

The BLOCKED - AZURE IDENTITY REQUIRED status recorded on 31 August 2026, when no Azure access
was available and, per the MODULE 2 rules, no identity was created or guessed.

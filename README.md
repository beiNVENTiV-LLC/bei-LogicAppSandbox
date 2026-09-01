# bei-LogicAppSandbox

> **NOT DEPLOYABLE YET.** This repository currently contains the MODULE 2 repository and
> governance foundation only. There is no working Azure deployment, no Azure identity, and no
> production integration behaviour. Every deployment workflow in `.github/workflows/` is an
> intentionally failing placeholder until MODULE 4 is completed. Do **not** attempt to deploy
> from this repository.

beiNVENTiV Azure Logic App Standard ALM accelerator and simulated Shopify integration learning
repository.

---

## 1. Project purpose

`bei-LogicAppSandbox` is the authoritative source of truth for a beiNVENTiV Azure Integration
Application Lifecycle Management (ALM) reference implementation. It exists to prove out a
repeatable, reviewable, secure path from a developer's workstation to UAT and then to PROD for
Azure Logic App Standard workloads — using GitHub as the system of record and Azure as a
deployment target only.

**The Git repository is authoritative. Azure portal state is not.** Any change made directly in
the Azure portal is a deviation and must be reconciled back into this repository (see
[CONTRIBUTING.md](CONTRIBUTING.md), "Emergency-change reconciliation").

## 2. Learning objective

By the end of the module series a beiNVENTiV consultant should be able to:

1. Stand up a governed integration repository with protected branches, code ownership and
   required validation (MODULE 2 — this module).
2. Express all Azure infrastructure as reviewable Bicep (MODULE 3).
3. Deploy the same immutable application artifact to UAT and then promote it to PROD through
   GitHub Environments and OIDC/workload identity federation, with no long-lived Azure
   credential stored in GitHub (MODULE 4).
4. Operate the workload — telemetry, alerting, runbooks and failed-message triage (later
   modules).

## 3. Technology stack

| Area | Technology |
| --- | --- |
| Integration runtime | Azure Logic App Standard (single-tenant, Workflow Service Plan) |
| Infrastructure as code | Bicep + `.bicepparam` parameter files |
| CI/CD | GitHub Actions |
| Secret storage | Azure Key Vault |
| Telemetry | Application Insights |
| Azure authentication (runtime) | Managed Identity wherever the connector supports it |
| Azure authentication (CI/CD) | GitHub OIDC / workload identity federation — no client secret |
| Scripting | PowerShell 7 |

**Azure context**

| Item | Value |
| --- | --- |
| Organization | beiNVENTiV LLC |
| Azure tenant | `beinventiv.com` |
| Azure subscription | Microsoft Azure Sponsorship 4000 |
| Environments | UAT, PROD |

## 4. Environment model

Two environments only, both fed from `main`:

```
feature branch --PR--> main --(deploy-uat)--> UAT --(promote-prod, gated)--> PROD
```

* **UAT** — deploys automatically from `main` once MODULE 4 is live. No routine manual approval.
* **PROD** — requires an authorized reviewer, is restricted to protected branches and approved
  release tags, and records deployment history.

Rules that follow from this model:

* **One artifact, promoted.** The exact ZIP validated in UAT is the ZIP promoted to PROD. It is
  never rebuilt for PROD.
* **One set of Bicep templates.** Environment difference is expressed only through
  `infra/environments/main.uat.bicepparam` and `main.prod.bicepparam` — never through duplicated
  templates.
* **No long-lived environment branches.** There is no `develop`, `uat`, `prod` or `release`
  branch, ever.

## 5. Repository map

```
bei-LogicAppSandbox/
├── .github/
│   ├── workflows/
│   │   ├── pr-validation.yml          # ACTIVE - required status check for main
│   │   ├── deploy-uat.yml             # PLACEHOLDER - fails by design until MODULE 4
│   │   ├── promote-prod.yml           # PLACEHOLDER - fails by design until MODULE 4
│   │   └── release.yml                # PLACEHOLDER - fails by design until MODULE 4
│   ├── ISSUE_TEMPLATE/
│   │   ├── feature.yml
│   │   └── defect.yml
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── CODEOWNERS
│   └── dependabot.yml
├── src/logic-app/shopify-order-simulation/   # Logic App Standard project root
│   ├── wf-shopify-order-ingest/workflow.json
│   ├── connections.json
│   ├── host.json
│   ├── parameters.json
│   ├── local.settings.example.json
│   └── .funcignore
├── infra/                              # MODULE 3 placeholders - deploy nothing today
│   ├── main.bicep
│   ├── bicepconfig.json
│   ├── modules/
│   └── environments/
│       ├── main.uat.bicepparam
│       └── main.prod.bicepparam
├── tests/
│   ├── payloads/{valid,invalid,edge-cases}/
│   ├── contracts/
│   ├── integration/
│   └── smoke/
├── scripts/
│   ├── build-logic-app.ps1
│   ├── validate-repository.ps1
│   ├── deploy-infrastructure.ps1
│   ├── invoke-smoke-test.ps1
│   └── configure-github-governance.ps1   # one-time governance bootstrap (gh CLI)
├── docs/{architecture,decisions,onboarding,runbooks}/
├── ops/{alerts,dashboards,queries,support}/
├── .editorconfig
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── README.md
├── SECURITY.md
└── VERSION
```

## 6. Local prerequisites

| Tool | Minimum | Notes |
| --- | --- | --- |
| Git | 2.40+ | |
| Visual Studio Code | current | |
| Azure Logic Apps (Standard) VS Code extension | current | Provides the workflow designer |
| Azure Functions Core Tools | v4 | Required by the Logic Apps Standard local runtime |
| .NET SDK | 6.0+ | Required by Core Tools / the designer host |
| Node.js | LTS | Required by the Logic Apps Standard designer |
| Azurite | current | Local storage emulator for local runs |
| Azure CLI | current | With the `bicep` extension (`az bicep install`) |
| Bicep CLI | current | `az bicep version` |
| PowerShell | 7.4+ | All repository scripts target PowerShell 7 |
| GitHub CLI (`gh`) | current | Only needed for the one-time governance bootstrap |

## 7. Logic App project root

The Logic App Standard project root is:

```
src/logic-app/shopify-order-simulation/
```

Open **that folder** in Visual Studio Code — not the repository root — when you want the Logic
Apps Standard extension to recognise the project. The project root is the folder that directly
contains `host.json`, `connections.json`, `parameters.json` and one folder per workflow, where
each workflow folder contains a `workflow.json`. `local.settings.json` also lives at this root at
runtime; it is never committed.

The only workflow today is `wf-shopify-order-ingest`, and it is a **valid placeholder**. It calls
nothing — no Shopify, no Azure Storage, no email, no Key Vault, no production endpoint.

## 8. Packaging boundary

This is the single most commonly broken rule, so it is stated explicitly.

The deployable ZIP must contain the **contents** of `src/logic-app/shopify-order-simulation/` at
the **ZIP root**. It must not contain the repository wrapper folders `src/`, `logic-app/` or
`shopify-order-simulation/`.

Correct ZIP root:

```
host.json
connections.json
parameters.json
wf-shopify-order-ingest/workflow.json
```

Incorrect ZIP root:

```
src/logic-app/shopify-order-simulation/host.json      <-- WRONG
```

`local.settings.json` is never packaged. Application settings are supplied by the Azure resource,
not by the ZIP.

## 9. Branch and pull-request workflow

Short-lived branches and pull requests only. Full rules in [CONTRIBUTING.md](CONTRIBUTING.md).

```
feature/<issue>-<description>
fix/<issue>-<description>
docs/<issue>-<description>
chore/<issue>-<description>
spike/<issue>-<description>
dependabot/*
```

Every change to `main` requires a pull request, one approval from someone other than the author,
a code-owner review, a passing `pr-validation` check, a branch that is current with `main`, and
all conversations resolved. Merges are **squash only**; the source branch is deleted on merge.

## 10. Configuration and secret handling

| Value type | Where it belongs |
| --- | --- |
| Nonsecret, environment-specific infrastructure values | `infra/environments/main.<env>.bicepparam` |
| Nonsecret Azure identifiers for CI/CD (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`) | GitHub **Environment variables** on UAT / PROD |
| Any secret, key, password, connection string or certificate | **Azure Key Vault**, referenced at runtime by Managed Identity |
| Local developer-only settings | `local.settings.json` — git-ignored, never committed |

`.bicepparam` values are stored and transmitted **in plain text**. Only nonsecret values may go
there; sensitive values must be sourced from Key Vault or another approved secure source.

Never create an Azure client secret for GitHub Actions. GitHub-to-Azure authentication uses OIDC
/ workload identity federation so that no long-lived Azure credential is stored in GitHub.

See [SECURITY.md](SECURITY.md) for the full prohibition list and the exposure-response procedure.

## 11. Release and versioning model

Semantic Versioning — `MAJOR.MINOR.PATCH`:

* **MAJOR** — an incompatible interface, security-model or operational-contract change.
* **MINOR** — a backward-compatible capability.
* **PATCH** — a backward-compatible correction.

The current version is in [VERSION](VERSION) and the history is in [CHANGELOG.md](CHANGELOG.md),
which follows a Keep-a-Changelog structure with an `Unreleased` section.

Releases are **annotated** tags: `v0.1.0`, `v0.2.0`, `v1.0.0`. A published tag is never moved and
never reused. Artifacts are named:

```
bei-logicappsandbox_<version>_<short-sha>.zip
```

## 12. Naming standards

Summarised here; the authoritative copy is
[docs/architecture/naming-standards.md](docs/architecture/naming-standards.md).

| Component | Pattern | Example |
| --- | --- | --- |
| Repository | `bei-LogicAppSandbox` | `bei-LogicAppSandbox` |
| Resource group | `rg-bei-<workload>-<env>-<region>-<instance>` | `rg-bei-shopifylab-uat-eus2-001` |
| Logic App Standard | `logic-bei-<workload>-<env>-<region>-<instance>` | `logic-bei-shopifylab-uat-eus2-001` |
| Workflow Service Plan | `asp-bei-<workload>-<env>-<region>-<instance>` | `asp-bei-shopifylab-uat-eus2-001` |
| Application Insights | `appi-bei-<workload>-<env>-<region>-<instance>` | `appi-bei-shopifylab-uat-eus2-001` |
| Key Vault | `kv-beishop-<env>-<unique-suffix>` | `kv-beishop-uat-a1b2c3` |
| Workflow folder | `wf-<business-purpose>` | `wf-shopify-order-ingest` |
| Storage account | lowercase alphanumeric, approved shortened pattern | `stbeishopuateus2001` |
| Artifact | `bei-logicappsandbox_<version>_<short-sha>.zip` | `bei-logicappsandbox_0.1.0_a1b2c3d.zip` |

Workflow folder names never contain an environment name, because the same workflow artifact is
promoted between environments.

## 13. Target application (future modules)

A simulated Shopify order integration:

```
Fake Shopify order -> HTTP endpoint -> Logic App Standard -> validation -> transformation
                   -> storage -> notification -> telemetry
```

None of this behaviour is implemented yet.

## 14. Further reading

* [CONTRIBUTING.md](CONTRIBUTING.md) — branching, review, merge and validation rules
* [SECURITY.md](SECURITY.md) — secret handling and exposure response
* [docs/architecture/](docs/architecture/) — naming standards and design notes
* [docs/decisions/](docs/decisions/) — architecture decision records, including the open OIDC blocker
* [docs/runbooks/](docs/runbooks/) — operational procedures
* [docs/onboarding/](docs/onboarding/) — developer setup

## 15. Current status

| Module | Scope | Status |
| --- | --- | --- |
| MODULE 2 | Repository and governance foundation | Implemented in this repository |
| MODULE 3 | Bicep infrastructure | Placeholders only |
| MODULE 4 | Deployment and promotion pipelines, Azure OIDC identities | Not started — **BLOCKED, AZURE IDENTITY REQUIRED** |

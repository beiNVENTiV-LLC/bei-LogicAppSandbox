# beiNVENTiV naming standards — bei-LogicAppSandbox

Authoritative naming standard for this repository and the Azure resources it will create.
Summarised in [README.md](../../README.md) section 12.

## Tokens

| Token | Meaning | Allowed values / form |
| --- | --- | --- |
| `<workload>` | Short workload identifier | lowercase alphanumeric, 3–12 chars, e.g. `shopifylab` |
| `<env>` | Environment | `uat` or `prod` only |
| `<region>` | Short Azure region code | e.g. `eus2` (East US 2), `wus3` (West US 3) |
| `<instance>` | Instance number | three digits, e.g. `001` |
| `<unique-suffix>` | Globally unique suffix | lowercase alphanumeric, generated, e.g. `a1b2c3` |
| `<business-purpose>` | What the workflow does | lowercase, hyphen-separated |
| `<version>` | Semantic version | `MAJOR.MINOR.PATCH` |
| `<short-sha>` | Abbreviated commit SHA | 7 hex characters |

## Patterns

| Component | Pattern | UAT example | PROD example |
| --- | --- | --- | --- |
| Repository | `bei-LogicAppSandbox` | `bei-LogicAppSandbox` | (same repository) |
| Resource group | `rg-bei-<workload>-<env>-<region>-<instance>` | `rg-bei-shopifylab-uat-eus2-001` | `rg-bei-shopifylab-prod-eus2-001` |
| Logic App Standard | `logic-bei-<workload>-<env>-<region>-<instance>` | `logic-bei-shopifylab-uat-eus2-001` | `logic-bei-shopifylab-prod-eus2-001` |
| Workflow Service Plan | `asp-bei-<workload>-<env>-<region>-<instance>` | `asp-bei-shopifylab-uat-eus2-001` | `asp-bei-shopifylab-prod-eus2-001` |
| Application Insights | `appi-bei-<workload>-<env>-<region>-<instance>` | `appi-bei-shopifylab-uat-eus2-001` | `appi-bei-shopifylab-prod-eus2-001` |
| Key Vault | `kv-beishop-<env>-<unique-suffix>` | `kv-beishop-uat-a1b2c3` | `kv-beishop-prod-d4e5f6` |
| Storage account | lowercase alphanumeric only, approved shortened pattern, ≤ 24 characters | `stbeishopuateus2001` | `stbeishopprodeus2001` |
| Workflow folder | `wf-<business-purpose>` | `wf-shopify-order-ingest` | (identical — promoted) |
| Artifact | `bei-logicappsandbox_<version>_<short-sha>.zip` | `bei-logicappsandbox_0.1.0_a1b2c3d.zip` | (identical — promoted) |

## Rules

1. **No environment name in a workflow folder name.** The same workflow artifact is promoted from
   UAT to PROD unchanged. `wf-shopify-order-ingest-uat` would make promotion impossible and is
   rejected by `pr-validation`.
2. **No environment name in the artifact name.** One artifact, two environments.
3. **Key Vault and storage account names are globally unique.** Their unique suffix is generated
   in MODULE 3 and recorded in the environment parameter file — it is never invented by hand and
   never reused across environments.
4. **Storage account names** allow lowercase letters and digits only, 3–24 characters. Hyphens are
   removed, not substituted.
5. **Resource names are derived in Bicep**, from the parameters in
   `infra/environments/main.<env>.bicepparam`. A name is never typed twice.
6. **Region codes are short and consistent.** Record any new region code in this table before
   using it.

## Branch names

```
feature/<issue>-<description>
fix/<issue>-<description>
docs/<issue>-<description>
chore/<issue>-<description>
spike/<issue>-<description>
dependabot/*
```

`develop`, `uat`, `prod`, `production` and permanent release branches are prohibited.

## Tags

Annotated tags only: `v<MAJOR>.<MINOR>.<PATCH>` — `v0.1.0`, `v0.2.0`, `v1.0.0`. A published tag is
never moved and never reused.

## Open items

| Item | Status |
| --- | --- |
| Confirmed `<workload>` value | **CONFIRMED: `shopify` |
| Confirmed Azure region and region code | **CONFIRMED: `southcentralus` / `scus` |
| Cost centre tag value | **PLACEHOLDER — beiNVENTiV confirmation required** |

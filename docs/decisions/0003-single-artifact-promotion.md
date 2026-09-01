# ADR 0003 — One artifact and one Bicep template, promoted across environments

* **Status:** Accepted
* **Date:** 2026-08-31
* **Module:** MODULE 2 (establishes the rule); realised in MODULE 3 and MODULE 4

## Context

The purpose of UAT is to give evidence about what will run in PROD. That evidence is only valid if
PROD runs the same thing UAT ran. Rebuilding for PROD, or maintaining a separate PROD template,
quietly invalidates every UAT test.

## Decision

1. **One application artifact.** `bei-logicappsandbox_<version>_<short-sha>.zip` is built once,
   deployed to UAT, and the **same file** is promoted to PROD. It is never rebuilt for PROD.
2. **One Bicep template.** `infra/main.bicep` and the modules under `infra/modules/` serve both
   environments. Duplicating a template per environment is prohibited.
3. **Environment difference lives only in parameter files** —
   `infra/environments/main.uat.bicepparam` and `main.prod.bicepparam` — and in environment-scoped
   nonsecret variables. Parameter files hold **nonsecret values only**, because their values are
   stored as plain text; sensitive values come from Key Vault.
4. **No environment name appears in a workflow folder name or an artifact name.**
5. The artifact contains the **contents** of `src/logic-app/shopify-order-simulation/` at the ZIP
   root, and never the repository wrapper folders or `local.settings.json`.

## Consequences

* A PROD deployment is a promotion, not a build. `promote-prod.yml` will consume an existing
  artifact rather than producing one.
* Any environment-specific need must be expressible as a parameter or an app setting. If it cannot
  be, that is a design problem to solve, not a reason to fork the template.
* `pr-validation` enforces the naming half of this rule today by rejecting an environment name in
  a `wf-*` folder.

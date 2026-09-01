# Contributing to bei-LogicAppSandbox

This repository is the authoritative source of truth for the beiNVENTiV Azure Integration ALM
reference implementation. These rules are mandatory for every contributor.

---

## 1. Branch naming

All work happens on a short-lived branch cut from an up-to-date `main`:

```
feature/<issue>-<description>
fix/<issue>-<description>
docs/<issue>-<description>
chore/<issue>-<description>
spike/<issue>-<description>
dependabot/*
```

Examples:

```
feature/123-order-validation
fix/145-null-shipping-address
docs/150-production-support-runbook
chore/155-bicep-linter-rules
spike/160-managed-identity-connector
```

`<issue>` is the GitHub issue number. `<description>` is lowercase, hyphen-separated and short.

**Prohibited branches.** Do not create `develop`, `uat`, `prod`, `production`, or any permanent
release branch. Environments are represented by GitHub Environments and Bicep parameter files,
never by branches. Long-lived branches drift, and drift breaks the "one artifact, promoted"
guarantee.

Branches are deleted automatically when the pull request is merged. Do not reuse a branch.

## 2. Pull-request process

1. Open (or claim) a GitHub issue using the feature or defect form.
2. Cut a branch from current `main` using the naming rules above.
3. Commit small, reviewable changes.
4. Rebase or update your branch so it is current with `main` before requesting review.
5. Open a pull request against `main` and complete the pull-request template in full.
6. Wait for `pr-validation` to pass.
7. Obtain the required approvals, including a code-owner approval.
8. Resolve every review conversation.
9. Squash-merge.

A pull request may not merge until **all** of the following are true:

* `pr-validation` has passed.
* At least one approval exists from someone **other than the author**.
* A member of the code-owning team has approved.
* The branch is current with `main`.
* Every conversation is resolved.
* History remains linear.

Stale approvals are dismissed when new reviewable commits are pushed. Re-request review after any
substantive change.

## 3. Review responsibilities

**Author**

* Keep the pull request small and single-purpose.
* Complete the template honestly, including UAT impact, PROD impact, security impact and
  rollback considerations.
* Confirm no secret, credential, token, certificate, connection string or production payload is
  included.
* Respond to every comment; do not resolve another reviewer's conversation.

**Reviewer**

* Verify correctness, security, and that the change is expressed as code rather than as a portal
  change.
* Verify naming standards and the packaging boundary are respected.
* Verify that `local.settings.json` and other prohibited files are not added.
* Verify that any infrastructure change is accompanied by the matching parameter-file change for
  **both** UAT and PROD.
* Block the pull request if the validation evidence is missing.

**Code owners** (`azure-integration-maintainers`) own `.github/`, `.github/CODEOWNERS`,
`.github/workflows/`, `infra/`, `src/logic-app/`, `ops/` and, as a catch-all, all repository
content. Their review is required by branch protection and cannot be bypassed.

## 4. Required validation

Before requesting review, run locally:

```powershell
pwsh ./scripts/validate-repository.ps1
```

This checks the required tree, JSON syntax, ignore rules, prohibited tracked files and obvious
committed-secret patterns. The `pr-validation` workflow runs the same class of checks in CI and
publishes a single stable status check named **`pr-validation`**, which is the required check on
`main`.

Additional validation depending on what you touched:

| Change | Required validation |
| --- | --- |
| Any Bicep file | `az bicep build --file infra/main.bicep` (or `bicep lint`) with no errors |
| Any workflow JSON | JSON parses; the Logic Apps Standard extension opens the project without error |
| Any GitHub Actions YAML | YAML parses; the workflow appears correctly in the Actions tab |
| Any documentation | Links resolve |

## 5. Merge strategy

* **Squash merge only.** Merge commits and rebase merges are disabled at the repository level.
* Linear history is enforced on `main`.
* Force pushes to `main` are blocked. Deletion of `main` is blocked.
* Rules apply to administrators. There is no routine bypass.
* The head branch is deleted automatically on merge.

The squash commit message must follow the commit/PR title convention below, and its body should
reference the issue (`Closes #123`).

## 6. Commit and pull-request title conventions

Conventional-commit style:

```
<type>(<scope>): <imperative summary>
```

Allowed types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`, `build`, `ci`, `revert`.

Common scopes: `workflow`, `infra`, `ops`, `repo`, `docs`, `tests`, `ci`.

Examples:

```
feat(workflow): validate required Shopify order fields
fix(infra): correct role assignment scope
docs(ops): add failed-order triage procedure
chore(repo): update repository validation
```

Rules: imperative mood, no trailing period, summary under 72 characters. A breaking change is
marked with `!` after the scope (`feat(workflow)!: ...`) and explained in the pull-request body.

## 7. Portal-change prohibition

**Do not make changes in the Azure portal.** The repository — not Azure — is the source of truth.
Portal edits to Logic App workflows, application settings, connections, role assignments, alerts
or any other resource are prohibited for normal work, because they are invisible to review, are
silently overwritten by the next deployment, and cause UAT and PROD to diverge.

Any required change must be made in `infra/`, `src/logic-app/` or `ops/`, reviewed, merged and
deployed.

## 8. Secret handling

Never commit, paste or log:

secrets, credentials, tokens, SAS tokens, API/subscription keys, certificates, private keys,
connection strings, publish profiles, production payloads, or real customer data.

* `local.settings.json` is **never** committed. Use `local.settings.example.json`, which contains
  placeholders only.
* Real values live in Azure Key Vault; runtime access uses Managed Identity wherever the
  connector supports it.
* Nonsecret CI/CD identifiers live in GitHub Environment variables.
* Never create an Azure client secret for GitHub Actions — CI/CD authenticates with OIDC.
* Never put a secret value in an issue, pull request, commit message, workflow log, screenshot or
  test payload.

If you believe a secret has been exposed, stop and follow [SECURITY.md](SECURITY.md) immediately.

## 9. Emergency-change reconciliation

A production emergency may — with explicit beiNVENTiV approval — require a change made outside
the normal pull-request path. That is an exception, not a workflow. When it happens:

1. Record who authorised the change, what was changed, when, and why.
2. Open a defect issue immediately, labelled `emergency-change`, with the full detail.
3. Within **one business day**, open a pull request that brings the repository back into
   agreement with reality — the code change, the parameter change, and the documentation.
4. Have that pull request reviewed by a code owner exactly like any other change.
5. Add a runbook entry under `docs/runbooks/` if the emergency revealed a gap.
6. Add a CHANGELOG entry.
7. Rotate any credential that was exposed or used out-of-band.

An emergency change is not complete until the repository is authoritative again.

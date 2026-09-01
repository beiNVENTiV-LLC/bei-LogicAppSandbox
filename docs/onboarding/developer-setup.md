# Developer setup — bei-LogicAppSandbox

> This repository is **not deployable**. It contains the MODULE 2 repository and governance
> foundation only. You can open it, validate it and contribute to it. You cannot deploy from it.

## 1. Install prerequisites

| Tool | Minimum | Notes |
| --- | --- | --- |
| Git | 2.40+ | |
| Visual Studio Code | current | |
| Azure Logic Apps (Standard) extension | current | Workflow designer |
| Azure Functions Core Tools | v4 | Local Logic Apps Standard runtime |
| .NET SDK | 6.0+ | Required by Core Tools |
| Node.js | LTS | Required by the designer |
| Azurite | current | Local storage emulator |
| Azure CLI + Bicep | current | `az bicep install` |
| PowerShell | 7.4+ | All scripts target PowerShell 7 |
| GitHub CLI | current | Only for the one-time governance bootstrap |

## 2. Clone

```bash
git clone https://github.com/<org-slug>/bei-LogicAppSandbox.git
cd bei-LogicAppSandbox
```

## 3. Validate your clone

```powershell
pwsh ./scripts/validate-repository.ps1
```

This is the same class of check that `pr-validation` runs in CI. Run it before every pull request.

## 4. Open the Logic App project

Open **`src/logic-app/shopify-order-simulation/`** in Visual Studio Code — not the repository
root. The Logic Apps (Standard) extension identifies a project by the folder that directly
contains `host.json`, `connections.json` and one `wf-*/workflow.json` per workflow.

Then:

1. Copy `local.settings.example.json` to `local.settings.json` **in that same folder**.
2. Replace every `<REPLACE-LOCALLY-DO-NOT-COMMIT>` placeholder with your own local values.
3. Start Azurite.
4. Open `wf-shopify-order-ingest/workflow.json` with the designer.

`local.settings.json` is git-ignored. Never commit it, and never put a real secret in
`local.settings.example.json`.

## 5. Make a change

```bash
git switch -c feature/<issue>-<short-description>
# ... edit ...
git commit -m "feat(workflow): <imperative summary>"
git push -u origin feature/<issue>-<short-description>
gh pr create --base main
```

Complete the pull-request template in full, wait for `pr-validation`, get a code-owner approval
and an independent approval, resolve every conversation, then squash-merge. Your branch is deleted
automatically.

Full rules: [CONTRIBUTING.md](../../CONTRIBUTING.md). Secret rules:
[SECURITY.md](../../SECURITY.md).

## 6. What you cannot do yet

| Action | Status |
| --- | --- |
| Deploy to UAT or PROD | Blocked — MODULE 4 not implemented, no Azure identity |
| Run `deploy-infrastructure.ps1`, `build-logic-app.ps1`, `invoke-smoke-test.ps1` | Deliberately fail — MODULE 4 placeholders |
| Run `deploy-uat`, `promote-prod` or `release` workflows | Deliberately fail — MODULE 4 placeholders |
| Change anything in the Azure portal | Prohibited — the repository is the source of truth |

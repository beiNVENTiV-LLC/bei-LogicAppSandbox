# Runbook — repository governance

Applying, verifying and repairing the MODULE 2 governance controls on `bei-LogicAppSandbox`.

## When to use this

* Standing the repository up for the first time
* After someone reports that a pull request merged without review
* After a CODEOWNERS change
* During a periodic governance review

## Prerequisites

* GitHub CLI authenticated as a user with **admin** rights on the repository
* The confirmed organization slug and the confirmed `azure-integration-maintainers` team slug —
  neither may be guessed

## Apply

```powershell
# Plan first - changes nothing
pwsh ./scripts/configure-github-governance.ps1 `
     -OrgSlug <org-slug> -TeamSlug <team-slug> -ProdReviewer <reviewer>

# Then apply
pwsh ./scripts/configure-github-governance.ps1 `
     -OrgSlug <org-slug> -TeamSlug <team-slug> -ProdReviewer <reviewer> -Apply
```

The script refuses to run if the organization or team slug does not resolve.

## Verify

| Control | Command | Expected |
| --- | --- | --- |
| Default branch | `gh api /repos/<org>/bei-LogicAppSandbox --jq .default_branch` | `main` |
| Squash-only merges | `gh api /repos/<org>/bei-LogicAppSandbox --jq '{squash:.allow_squash_merge,merge:.allow_merge_commit,rebase:.allow_rebase_merge,del:.delete_branch_on_merge}'` | `true,false,false,true` |
| Ruleset active | `gh api /repos/<org>/bei-LogicAppSandbox/rulesets --jq '.[].name'` | includes `protect-main` |
| Team has access | `gh api /repos/<org>/bei-LogicAppSandbox/teams --jq '.[].slug'` | includes the code-owning team |
| Environments | `gh api /repos/<org>/bei-LogicAppSandbox/environments --jq '.environments[].name'` | `UAT`, `PROD` |
| PROD reviewer gate | `gh api /repos/<org>/bei-LogicAppSandbox/environments/PROD --jq '.protection_rules'` | a `required_reviewers` rule |
| No secret stored | `gh api /repos/<org>/bei-LogicAppSandbox/actions/secrets --jq '.secrets[].name'` | no Azure credential (names only, never values) |

Behavioural checks, which matter more than the settings:

1. A direct push of a normal change to `main` is rejected.
2. A pull request touching `infra/`, `src/logic-app/`, `.github/workflows/` or `.github/CODEOWNERS`
   automatically requests the code-owning team.
3. A pull request cannot merge before `pr-validation` passes and an independent approval exists.
4. A force push to `main` is rejected.
5. Only **Squash and merge** is offered in the merge dropdown.
6. The head branch is deleted after merge.

## Common failures

| Symptom | Cause | Fix |
| --- | --- | --- |
| No code-owner review is requested | The team is not granted repository access, or the slug in `.github/CODEOWNERS` is wrong | Grant the team push access, correct the slug through a pull request |
| `CODEOWNERS` shows a syntax warning in GitHub | A placeholder slug is still present | Replace `ORG-SLUG-PLACEHOLDER` with the real organization slug |
| `pr-validation` is not offered as a required check | The check has never run on the default branch | Run the workflow once via `workflow_dispatch`, then add the check |
| Merge dropdown still offers merge commits | Repository settings were not applied | Re-run the bootstrap script with `-Apply` |

## Never do this

* Never disable a rule to make a pull request merge. Fix the pull request.
* Never grant a routine bypass. The exception path is an approved, documented emergency change
  reconciled within one business day.
* Never move or reuse a published tag.

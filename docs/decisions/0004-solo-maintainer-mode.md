# ADR 0004 - Solo maintainer mode: no second-approver requirement

* **Status:** Accepted (temporary - see Revert trigger)
* **Date:** 2 September 2026
* **Module:** raised after MODULE 2 completion, in force for MODULE 3 and MODULE 4
* **Deciders:** beiNVENTiV LLC - repository admin and Azure subscription owner

## Context

MODULE 2 delivered a protected `main` requiring one approving review from someone other
than the author, plus a code-owner review. Both were verified working: pull requests #2,
#3 and #5 each required and received an independent approval.

That posture assumes at least two active maintainers. In practice this repository has
one. The blueprint anticipated "a small technical team of 2-5 developers"; the actual
working team is a single consultant who is also the Azure subscription owner.

GitHub does not permit an author to approve their own pull request under any setting or
permission level. The requirement was therefore not merely inconvenient - it could not be
satisfied without interrupting a Partner for every change, including documentation edits
and Dependabot dependency bumps. A control that routinely requires escalation to clear
trivial changes trains people to route around governance rather than through it.

## Decision

The **human** review gate is removed. The **automated** gate is retained in full.

Removed:

| Control | From | To |
| --- | --- | --- |
| `required_approving_review_count` | 1 | 0 |
| `require_code_owner_review` | true | false |
| `require_last_push_approval` | true | false |
| `dismiss_stale_reviews_on_push` | true | false |
| PROD `prevent_self_review` | true | false |

Retained, unchanged:

* A pull request is still required. There is no direct push path to `main`.
* `pr-validation` remains a required status check and must pass before merge.
* The branch must still be current with `main` before merge.
* All review conversations must still be resolved.
* Linear history is still enforced.
* Force pushes to `main` are still blocked.
* Deletion of `main` is still blocked.
* **`bypass_actors` remains empty.** The rules still apply to administrators. No person,
  team or app holds a bypass permission.
* Squash merge remains the only permitted merge method.

## Alternatives rejected

**Add the maintainer as a bypass actor.** Rejected. A bypass switches off every rule at
once, including CI validation, and does so invisibly - the repository configuration would
still claim controls that are not being enforced. Lowering the approval count leaves an
honest, auditable configuration where what is written is what is enforced.

**Leave the requirement and escalate every change.** Rejected. It makes a Partner a
required participant in documentation typos and dependency bumps, and predictably ends in
someone using `--admin` to bypass the ruleset under time pressure.

**Disable branch protection entirely.** Rejected outright. The automated gate is the part
that catches real defects. During MODULE 2 it caught a committed-secret false positive and
two PowerShell defects before they reached `main`.

## Consequences

* The maintainer can open a pull request and merge it once `pr-validation` passes,
  without waiting for a second person.
* Every change is still recorded as a reviewable pull request with a diff and a revert path.
* No broken Bicep, invalid JSON or YAML, prohibited file, or obvious committed secret can
  reach `main` - CI still blocks all of it.
* PROD deployments in MODULE 4 can be approved by the maintainer. **The PROD environment
  gate still exists and still records deployment history**; it is no longer a
  separation-of-duties control.
* CODEOWNERS remains accurate and still requests reviews automatically. It informs rather
  than blocks. It must be kept correct so that restoring team mode is a single change.
* **This posture is not suitable for customer production work.** The patterns in this
  repository are intended for reuse; anyone reusing them for a customer engagement must
  restore team mode first.

## Revert trigger

Restore the MODULE 2 posture immediately when **any** of the following becomes true:

1. A second maintainer joins the repository.
2. This repository or its patterns are reused for customer or production work.
3. The repository begins handling real data, real credentials, or a live Azure workload
   beyond the learning subscription.
4. A beiNVENTiV owner requests it.

To restore:

```powershell
pwsh ./apply-solo-mode.ps1 -Mode Team -Apply
```

Then update this ADR's status to `Superseded` and record the date and reason.

## Verification

Confirm the current posture at any time:

```powershell
gh api /repos/beiNVENTiV-LLC/bei-LogicAppSandbox/rulesets --jq '.[] | select(.name=="protect-main") | .id'
gh api /repos/beiNVENTiV-LLC/bei-LogicAppSandbox/rulesets/<id> --jq '.rules[] | select(.type=="pull_request") | .parameters'
gh api /repos/beiNVENTiV-LLC/bei-LogicAppSandbox/rulesets/<id> --jq '{bypass: .bypass_actors | length, enforcement}'
```

`bypass` must be `0` and `enforcement` must be `active` in **both** modes. If either is
ever otherwise, the repository is less protected than any document claims.

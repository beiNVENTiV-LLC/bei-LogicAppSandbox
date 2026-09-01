<!--
  bei-LogicAppSandbox pull request

  Title must follow: <type>(<scope>): <imperative summary>
    feat(workflow): validate required Shopify order fields
    fix(infra): correct role assignment scope
    docs(ops): add failed-order triage procedure
    chore(repo): update repository validation

  Do not paste secrets, tokens, connection strings, keys or production payloads
  anywhere in this pull request. See SECURITY.md.
-->

## Summary

<!-- What changes and why. One paragraph. -->

## Work item / issue

Closes #

## Change type

<!-- Tick all that apply. -->

- [ ] `feat` — new capability (MINOR)
- [ ] `fix` — correction (PATCH)
- [ ] `docs` — documentation only
- [ ] `chore` — repository maintenance
- [ ] `refactor` — no behaviour change
- [ ] `test` — tests only
- [ ] `ci` — pipeline or workflow change
- [ ] Breaking change (MAJOR) — explain below

## Files / components affected

- [ ] `src/logic-app/` (workflow definition)
- [ ] `infra/` (Bicep templates or modules)
- [ ] `infra/environments/` (parameter files)
- [ ] `.github/workflows/` (CI/CD)
- [ ] `.github/CODEOWNERS` or repository governance
- [ ] `ops/` (alerts, dashboards, queries, support)
- [ ] `scripts/`
- [ ] `tests/`
- [ ] `docs/`

<!-- List the specific files or components. -->

## UAT impact

<!-- What changes in UAT? Any manual step, reconfiguration, data effect or downtime? Write "None" if none. -->

## PROD impact

<!-- What changes in PROD? Downtime, message loss risk, contract change, consumer impact? Write "None" if none. -->

## Security impact

<!-- Identity, role assignments, network exposure, Key Vault access, new endpoint, new dependency. Write "None" if none. -->

- [ ] No new secret, credential or key is introduced
- [ ] Managed Identity is used wherever the connector supports it
- [ ] Any new access is least privilege

## Infrastructure impact

<!-- Resources added, changed or removed. Naming standard applied. Is the change idempotent? -->

- [ ] `az bicep build` / lint passes with no errors
- [ ] UAT and PROD parameter files were both updated (or neither needed changing)
- [ ] No duplicate template was created for a single environment

## Configuration changes

<!-- New or changed app settings, Bicep parameters, GitHub Environment variables, Key Vault secret NAMES (never values). -->

| Setting name | Environment(s) | Nonsecret / Key Vault reference | Added / changed / removed |
| --- | --- | --- | --- |
|  |  |  |  |

## Validation performed

<!-- Evidence, not intent. What did you actually run, and what was the result? -->

- [ ] `pwsh ./scripts/validate-repository.ps1` passes locally
- [ ] `pr-validation` passes in CI
- [ ] JSON files parse
- [ ] YAML files parse
- [ ] Bicep builds/lints cleanly
- [ ] Logic App project opens in the Logic Apps Standard tooling (if `src/` changed)
- [ ] Tests or payload fixtures updated (if applicable)

<!-- Paste the relevant output or link the check run. -->

## Rollback considerations

<!-- How is this reverted? Is revert safe? Is it forward-only? Any data or state that a revert cannot undo? -->

## Documentation updated

- [ ] `README.md`
- [ ] `CONTRIBUTING.md`
- [ ] `SECURITY.md`
- [ ] `CHANGELOG.md` (`Unreleased` section)
- [ ] `docs/architecture/`, `docs/decisions/`, `docs/runbooks/` or `docs/onboarding/`
- [ ] Not applicable

## Secret scan confirmation

- [ ] I have reviewed the complete diff and it contains **no** secret, credential, token, SAS
      token, API or subscription key, certificate, private key, connection string, publish
      profile, production payload or real customer data.
- [ ] `local.settings.json` is **not** included in this change.
- [ ] No secret value appears in this pull request description, in a commit message, or in any
      workflow log this change produces.

---

## Reviewer checklist

- [ ] Title follows the commit convention and the scope is accurate
- [ ] The change is single-purpose and small enough to review properly
- [ ] The change is expressed as code — no portal change is being documented after the fact
- [ ] Naming standards are followed
- [ ] The packaging boundary is respected (ZIP root = contents of the Logic App project root)
- [ ] No environment name has leaked into a workflow folder name
- [ ] UAT and PROD impact statements are credible
- [ ] Security impact has been considered; least privilege holds
- [ ] No prohibited file is added; `.gitignore` still protects `local.settings.json`
- [ ] Validation evidence is present and convincing
- [ ] Rollback is understood
- [ ] Documentation and `CHANGELOG.md` are updated
- [ ] I confirm the diff contains no secret values

# Security Policy — bei-LogicAppSandbox

This repository is a beiNVENTiV LLC learning and accelerator repository for Azure Logic App
Standard ALM. It is nevertheless treated as a production-grade repository, because the patterns
it establishes are intended to be reused for real customer workloads.

---

## 1. Prohibited content — never commit

The following must never be committed, pushed, pasted into an issue or pull request, printed to a
workflow log, or included in a screenshot:

* Passwords, passphrases, PINs
* Client secrets, application secrets, service-principal credentials
* Access tokens, refresh tokens, bearer tokens, personal access tokens
* Shared Access Signature (SAS) tokens and storage account keys
* API keys, subscription keys, function keys, workflow callback URLs containing a signature
* Connection strings of any kind (Storage, Service Bus, SQL, Application Insights, Event Hub)
* Certificates and private keys (`.pfx`, `.pem`, `.key`, `.p12`, `.cer`)
* Azure publish profiles (`.PublishSettings`, `.azurePubxml`)
* `local.settings.json` — it is designed to hold local secrets and is git-ignored
* Production payloads, real customer data, real Shopify order data, or any personal data
* Internal endpoint URLs that themselves act as a credential

`.gitignore` is the mechanical backstop for several of these, and `pr-validation` scans for
obvious committed-secret patterns without printing any matched value. Neither replaces the
contributor's own responsibility.

## 2. Key Vault requirement

All secrets used by this workload live in **Azure Key Vault**.

* Every environment has its own Key Vault: `kv-beishop-<env>-<unique-suffix>`.
* UAT and PROD secrets are never shared and never copied between environments.
* Applications read secrets at runtime from Key Vault; secrets are not baked into an artifact,
  an app setting value, a Bicep parameter file, or a repository file.
* Bicep parameter files (`.bicepparam`) are appropriate for environment-specific **nonsecret**
  values only. Their values are stored as plain text, so any sensitive value must instead be
  sourced from Key Vault or another approved secure source.
* Key Vault access is granted by least-privilege role assignment to a Managed Identity — not by a
  shared access policy handed to a person.

## 3. Managed Identity preference

Managed Identity is the default authentication mechanism for the workload:

* The Logic App Standard resource uses a Managed Identity to reach Key Vault, Storage,
  Application Insights and any other Azure resource that supports it.
* Where a connector supports Managed Identity, Managed Identity **must** be used in preference to
  a connection string, access key or shared credential.
* Where a connector does not support Managed Identity, the credential is stored in Key Vault, the
  exception is recorded as an architecture decision under `docs/decisions/`, and it is reviewed
  at each module boundary.
* Role assignments are least privilege, scoped as narrowly as the workload allows, and expressed
  in Bicep — never assigned by hand in the portal.

## 4. OIDC requirement for CI/CD

GitHub Actions authenticates to Azure using **OIDC / workload identity federation**.

* **No Azure client secret may ever be created for GitHub Actions**, and no long-lived Azure
  credential may be stored as a GitHub secret.
* UAT and PROD use separate deployment identities with separately scoped, least-privilege access.
* Federated credential trust is restricted to this repository (`bei-LogicAppSandbox`) and, where
  appropriate, to a specific GitHub Environment subject.
* GitHub Environments used in OIDC subject policies are themselves protected, so that the trust
  cannot be claimed from an unprotected branch or an unreviewed workflow run.
* Only nonsecret identifiers — `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` —
  are stored, and preferably as GitHub Environment **variables** rather than secrets.

**Current status: BLOCKED — AZURE IDENTITY REQUIRED.** No UAT or PROD deployment identity or
federated credential has been confirmed for this repository. See
`docs/decisions/0001-oidc-deployment-identity-blocked.md`.

## 5. Reporting a suspected secret exposure

Do **not** open a public issue, and do **not** include the secret value in your report.

1. Stop what you are doing. Do not push further commits to the affected branch.
2. Notify the beiNVENTiV security contact and the `azure-integration-maintainers` team
   immediately through a private channel (email or a private Teams message).
   *Security contact: `erika@beinventiv.com and John@beinventiv.com`.*
3. Report: what type of credential, which environment it grants access to, where it was exposed
   (branch, commit, pull request, log, screenshot), when it was first exposed, and whether the
   repository or log is public. **Never the value itself.**
4. Await instructions. Rotation is coordinated, because rotating in the wrong order can cause an
   outage.

Target acknowledgement: same business day.

## 6. Credential rotation after exposure

Any credential that has been exposed is considered compromised, permanently — even if the
exposure was brief, even if the repository is private, and even if the commit was deleted. Git
history, forks, clones, caches and logs all retain it.

Required response, in order:

1. **Rotate or revoke first.** Generate a new credential and invalidate the old one before doing
   any repository cleanup.
2. Update the stored value in Key Vault (or the GitHub Environment variable, if the value was a
   nonsecret identifier).
3. Verify the workload still functions in UAT, then PROD.
4. Purge the value from the repository — remove the file, and where policy requires it, rewrite
   history. Rewriting history on `main` requires explicit beiNVENTiV approval and a documented
   one-time exception to branch protection.
5. Review Azure sign-in and activity logs for use of the exposed credential.
6. Record the incident, the rotation and the follow-up actions.
7. Add or strengthen a control so the same exposure cannot recur — an ignore rule, a validation
   check, or a documentation change.

Deleting the commit is not rotation. Making the repository private is not rotation. Only issuing
a new credential and invalidating the old one is rotation.

## 7. Prohibition on posting secret values

Secret values must never appear in:

* GitHub issues, pull requests, comments or review threads
* Commit messages
* GitHub Actions logs or step summaries (mask, or do not print)
* Screenshots or screen recordings
* Test payloads under `tests/`
* Documentation, runbooks or architecture decision records
* Teams messages, email or chat

When evidence is needed, reference the credential by **name and location** (for example,
"the `shopify-webhook-key` secret in `kv-beishop-uat-a1b2c3`") — never by value.

## 8. Scope

This policy covers the `bei-LogicAppSandbox` repository and the Azure resources it will deploy in
the beiNVENTiV `beinventiv.com` tenant, subscription "Microsoft Azure Sponsorship 4000". This
repository contains no production integration today.

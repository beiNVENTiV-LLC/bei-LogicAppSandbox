# Changelog

All notable changes to `bei-LogicAppSandbox` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- MODULE 3 infrastructure. `infra/main.bicep` is now resource-group scoped and
  declares the workload: storage account, Log Analytics workspace, workspace-based
  Application Insights, RBAC-enabled Key Vault, Workflow Standard plan, Logic App
  Standard with a system-assigned managed identity, a least-privilege Key Vault
  Secrets User role assignment, and diagnostic settings routed to Log Analytics.
- Environment sizing expressed only through the `.bicepparam` files: UAT uses
  locally redundant storage with 30-day retention; PROD uses geo-redundant storage
  with 90-day retention and Key Vault purge protection.


### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.1.0] - 2026-08-31

MODULE 2 — Repository Blueprint. This release establishes repository governance only. It is
**not** a deployable Azure integration.

### Added

- Repository folder structure for source, infrastructure, tests, scripts, documentation and
  operations.
- Logic App Standard project boundary at `src/logic-app/shopify-order-simulation/` with a valid
  placeholder workflow `wf-shopify-order-ingest` that calls no external service.
- Bicep MODULE 3 placeholders: `infra/main.bicep`, `infra/bicepconfig.json`, eight module
  placeholders under `infra/modules/`, and UAT/PROD `.bicepparam` files. None deploy resources.
- Active `pr-validation` GitHub Actions workflow publishing a single stable status check.
- Fail-safe, manual-only placeholders for `deploy-uat`, `promote-prod` and `release` that
  deliberately fail and state that MODULE 4 configuration is required.
- `.github/CODEOWNERS`, pull-request template, feature and defect issue forms, and
  `dependabot.yml`.
- `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CHANGELOG.md` and `VERSION`.
- `.gitignore` and `.editorconfig` enforcing secret exclusion and consistent formatting.
- Naming standards at `docs/architecture/naming-standards.md`.
- Architecture decision records covering the OIDC identity blocker, the trunk-based branching
  model and the single-artifact promotion model.
- Repository validation, build, deployment and smoke-test script placeholders under `scripts/`,
  plus a one-time GitHub governance bootstrap script.

### Security

- `local.settings.json`, certificates, keys, publish profiles and environment files are excluded
  from source control.
- No secret, credential, token, certificate, connection string or publish profile is committed.
- OIDC is documented as the only permitted GitHub-to-Azure authentication mechanism; no Azure
  client secret is created.

[Unreleased]: https://github.com/[PLACEHOLDER-ORG-SLUG]/bei-LogicAppSandbox/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/[PLACEHOLDER-ORG-SLUG]/bei-LogicAppSandbox/releases/tag/v0.1.0

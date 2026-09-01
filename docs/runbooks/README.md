# Runbooks

Operational procedures for the bei-LogicAppSandbox workload.

| Runbook | Purpose | Status |
| --- | --- | --- |
| [repository-governance.md](repository-governance.md) | Applying and verifying repository governance controls | Available |
| Failed-order triage | Diagnosing and replaying a failed order | **Not written — depends on MODULE 4 and a deployed workload** |
| Deployment rollback | Rolling back a UAT or PROD deployment | **Not written — depends on MODULE 4** |
| Secret rotation | Rotating a Key Vault secret without an outage | **Not written — depends on MODULE 3** |
| Alert response | Responding to an Application Insights alert | **Not written — depends on `ops/alerts/`** |

A runbook is written when the capability it covers exists. Writing a runbook for a workload that
does not exist produces confident, wrong instructions.

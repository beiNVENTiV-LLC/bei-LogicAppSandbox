// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - role assignments module
//
// STATUS: MODULE 3 PLACEHOLDER. THIS MODULE DEPLOYS NOTHING.
//
// Future responsibility of this module:
//   - Grant the Logic App Standard Managed Identity least-privilege access to Key Vault (Key Vault Secrets User), Storage and Application Insights.
//   - Grant nothing broader than the workload needs, and never Owner or Contributor at subscription scope.
//   - Be the single reviewable place where access is expressed, so that no access is granted by hand in the portal.
//
// Consumed by infra/main.bicep. One module serves BOTH environments; the
// difference is supplied by infra/environments/main.<env>.bicepparam.
// No secret value may ever be declared, defaulted or output here.
// ---------------------------------------------------------------------------

// Intentionally empty. Parameters, resources and outputs arrive in MODULE 3.

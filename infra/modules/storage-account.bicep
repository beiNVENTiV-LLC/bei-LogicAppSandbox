// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - storage account module
//
// STATUS: MODULE 3 PLACEHOLDER. THIS MODULE DEPLOYS NOTHING.
//
// Future responsibility of this module:
//   - Create the storage account required by the Logic App Standard runtime (lowercase alphanumeric name, approved shortened pattern).
//   - Disable shared key access where the runtime supports it, and require TLS 1.2 minimum.
//   - Disable public blob access and restrict network access.
//   - Expose the account resource id so role-assignments.bicep can grant the Logic App Managed Identity least-privilege data access - never an account key.
//
// Consumed by infra/main.bicep. One module serves BOTH environments; the
// difference is supplied by infra/environments/main.<env>.bicepparam.
// No secret value may ever be declared, defaulted or output here.
// ---------------------------------------------------------------------------

// Intentionally empty. Parameters, resources and outputs arrive in MODULE 3.

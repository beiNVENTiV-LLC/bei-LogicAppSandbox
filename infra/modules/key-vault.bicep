// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Key Vault module
//
// STATUS: MODULE 3 PLACEHOLDER. THIS MODULE DEPLOYS NOTHING.
//
// Future responsibility of this module:
//   - Create kv-beishop-<env>-<unique-suffix> with RBAC authorisation enabled.
//   - Enable soft delete and purge protection for PROD.
//   - Hold every secret this workload needs. No secret is ever stored in a parameter file, an app setting literal, or the repository.
//   - Expose the vault resource id so role-assignments.bicep can grant the Logic App Managed Identity the Key Vault Secrets User role.
//
// Consumed by infra/main.bicep. One module serves BOTH environments; the
// difference is supplied by infra/environments/main.<env>.bicepparam.
// No secret value may ever be declared, defaulted or output here.
// ---------------------------------------------------------------------------

// Intentionally empty. Parameters, resources and outputs arrive in MODULE 3.

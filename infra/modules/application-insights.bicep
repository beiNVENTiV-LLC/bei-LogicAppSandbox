// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Application Insights module
//
// STATUS: MODULE 3 PLACEHOLDER. THIS MODULE DEPLOYS NOTHING.
//
// Future responsibility of this module:
//   - Create the Log Analytics workspace and the workspace-based Application Insights resource appi-bei-<workload>-<env>-<region>-<instance>.
//   - Set an appropriate retention period per environment via parameters.
//   - Expose the connection string as a Key Vault reference target - never as a template output value.
//
// Consumed by infra/main.bicep. One module serves BOTH environments; the
// difference is supplied by infra/environments/main.<env>.bicepparam.
// No secret value may ever be declared, defaulted or output here.
// ---------------------------------------------------------------------------

// Intentionally empty. Parameters, resources and outputs arrive in MODULE 3.

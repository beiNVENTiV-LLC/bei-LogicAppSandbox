// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Workflow Service Plan module
//
// STATUS: MODULE 3 PLACEHOLDER. THIS MODULE DEPLOYS NOTHING.
//
// Future responsibility of this module:
//   - Create the Workflow Standard plan asp-bei-<workload>-<env>-<region>-<instance>.
//   - Size the plan per environment through parameters only - one template, two parameter files.
//   - Expose the plan resource id to logic-app-standard.bicep.
//
// Consumed by infra/main.bicep. One module serves BOTH environments; the
// difference is supplied by infra/environments/main.<env>.bicepparam.
// No secret value may ever be declared, defaulted or output here.
// ---------------------------------------------------------------------------

// Intentionally empty. Parameters, resources and outputs arrive in MODULE 3.

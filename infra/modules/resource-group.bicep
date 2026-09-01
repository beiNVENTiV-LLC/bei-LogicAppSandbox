// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - resource group module
//
// STATUS: MODULE 3 PLACEHOLDER. THIS MODULE DEPLOYS NOTHING.
//
// Future responsibility of this module:
//   - Create the environment resource group rg-bei-<workload>-<env>-<region>-<instance>.
//   - Apply the standard beiNVENTiV tag set.
//   - Be the only place a resource group is created, so UAT and PROD stay symmetrical.
//
// Consumed by infra/main.bicep. One module serves BOTH environments; the
// difference is supplied by infra/environments/main.<env>.bicepparam.
// No secret value may ever be declared, defaulted or output here.
// ---------------------------------------------------------------------------

targetScope = 'subscription'

// Intentionally empty. Parameters, resources and outputs arrive in MODULE 3.

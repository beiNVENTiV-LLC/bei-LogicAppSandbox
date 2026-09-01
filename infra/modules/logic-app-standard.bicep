// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Logic App Standard module
//
// STATUS: MODULE 3 PLACEHOLDER. THIS MODULE DEPLOYS NOTHING.
//
// Future responsibility of this module:
//   - Create logic-bei-<workload>-<env>-<region>-<instance> on the Workflow Standard plan.
//   - Enable a system-assigned Managed Identity.
//   - Wire application settings to Key Vault references and to Application Insights - never to literal secrets.
//   - Require HTTPS only and a minimum TLS version.
//   - Leave workflow content to the deployed artifact; the ZIP is the source of the workflow definition, not this template.
//
// Consumed by infra/main.bicep. One module serves BOTH environments; the
// difference is supplied by infra/environments/main.<env>.bicepparam.
// No secret value may ever be declared, defaulted or output here.
// ---------------------------------------------------------------------------

// Intentionally empty. Parameters, resources and outputs arrive in MODULE 3.

// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - infrastructure entry point
//
// STATUS: MODULE 3 PLACEHOLDER. THIS TEMPLATE DEPLOYS NOTHING.
//
// Future responsibility of this file:
//   - Own the subscription-scoped deployment for one environment (UAT or PROD).
//   - Create the resource group, then orchestrate the modules in ./modules:
//       resource-group, storage-account, application-insights, key-vault,
//       workflow-plan, logic-app-standard, role-assignments, diagnostics.
//   - Derive every resource name from the beiNVENTiV naming standard using the
//     parameters below, so that UAT and PROD differ ONLY by parameter file.
//   - Enable a system-assigned Managed Identity on the Logic App Standard
//     resource and grant it least-privilege access to Key Vault, Storage and
//     Application Insights via ./modules/role-assignments.bicep.
//
// There is ONE template for BOTH environments. Never duplicate this file per
// environment. Environment difference is expressed only through:
//   infra/environments/main.uat.bicepparam
//   infra/environments/main.prod.bicepparam
//
// Secrets never appear here or in a .bicepparam file. Parameter file values are
// stored as plain text; sensitive values must come from Azure Key Vault or
// another approved secure source.
// ---------------------------------------------------------------------------

targetScope = 'subscription'

@description('Short workload identifier used in every resource name, for example shopifylab.')
@minLength(3)
@maxLength(12)
param workload string

@description('Target environment. Drives naming and, in MODULE 3, environment-specific sizing.')
@allowed([
  'uat'
  'prod'
])
param environmentName string

@description('Azure region for all resources, for example eastus2.')
param location string

@description('Short region code used in resource names, for example eus2.')
@minLength(3)
@maxLength(5)
param locationShortCode string

@description('Three-digit instance number used in resource names, for example 001.')
@minLength(3)
@maxLength(3)
param instance string = '001'

@description('Tags applied to every resource created by MODULE 3.')
param tags object = {}

// Naming standard: rg-bei-<workload>-<env>-<region>-<instance> and siblings.
var namePrefix = 'bei-${workload}-${environmentName}-${locationShortCode}-${instance}'

var resourceNames = {
  resourceGroup: 'rg-${namePrefix}'
  logicApp: 'logic-${namePrefix}'
  workflowPlan: 'asp-${namePrefix}'
  applicationInsights: 'appi-${namePrefix}'
  logAnalytics: 'log-${namePrefix}'
  // Storage account names are lowercase alphanumeric only and capped at 24 characters.
  storageAccount: take(toLower(replace('stbei${workload}${environmentName}${locationShortCode}${instance}', '-', '')), 24)
  // The Key Vault unique suffix is supplied in MODULE 3; it is not guessed here.
  keyVaultPrefix: 'kv-beishop-${environmentName}-'
}

// ---------------------------------------------------------------------------
// MODULE 3 will add the resource group and the module orchestration here.
// Intentionally commented out so that this template deploys nothing today.
//
// resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
//   name: resourceNames.resourceGroup
//   location: location
//   tags: tags
// }
//
// module storage './modules/storage-account.bicep' = { ... }
// module insights './modules/application-insights.bicep' = { ... }
// module vault './modules/key-vault.bicep' = { ... }
// module plan './modules/workflow-plan.bicep' = { ... }
// module logicApp './modules/logic-app-standard.bicep' = { ... }
// module roles './modules/role-assignments.bicep' = { ... }
// module diagnostics './modules/diagnostics.bicep' = { ... }
// ---------------------------------------------------------------------------

@description('Resource names this template will create in MODULE 3. Nothing is deployed today.')
output plannedResourceNames object = resourceNames

@description('Environment this parameter set targets.')
output targetEnvironment string = environmentName

@description('Region this parameter set targets.')
output targetLocation string = location

@description('Tags that will be applied in MODULE 3.')
output plannedTags object = tags

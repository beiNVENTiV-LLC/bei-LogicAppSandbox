// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - infrastructure entry point
//
// MODULE 3. This template declares the real workload infrastructure.
//
// SCOPE: resourceGroup.
// The resource group itself is NOT created here. It is created once, out of
// band, because the GitHub deployment identity holds Contributor and User
// Access Administrator at RESOURCE GROUP scope only and has no permission at
// subscription scope. That is deliberate least privilege - see ADR 0001.
//
//   UAT  : rg-bei-<workload>-uat-<region>-<instance>
//   PROD : rg-bei-<workload>-prod-<region>-<instance>
//
// ONE template serves BOTH environments. Never duplicate this file per
// environment. Environment difference is expressed only through:
//   infra/environments/main.uat.bicepparam
//   infra/environments/main.prod.bicepparam
//
// No secret value appears in this template or in a parameter file. The storage
// connection string is resolved at deployment time with listKeys() and is never
// written to source control. Application secrets belong in Key Vault and are
// read at runtime by the Logic App managed identity.
// ---------------------------------------------------------------------------

targetScope = 'resourceGroup'

@description('Short workload identifier used in every resource name, for example shopify.')
@minLength(3)
@maxLength(12)
param workload string

@description('Target environment. Drives naming and environment-specific sizing.')
@allowed([
  'uat'
  'prod'
])
param environmentName string

@description('Azure region for all resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Short region code used in resource names, for example wcus.')
@minLength(3)
@maxLength(5)
param locationShortCode string

@description('Three-digit instance number used in resource names, for example 001.')
@minLength(3)
@maxLength(3)
param instance string = '001'

@description('Tags applied to every resource created by this template.')
param tags object = {}

@description('Workflow Standard plan SKU. WS1 is the smallest tier.')
@allowed([
  'WS1'
  'WS2'
  'WS3'
])
param workflowPlanSku string = 'WS1'

@description('Storage account redundancy. PROD should use a geo-redundant tier.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
])
param storageSkuName string = 'Standard_LRS'

@description('Log Analytics and Application Insights retention, in days.')
@minValue(30)
@maxValue(730)
param logRetentionInDays int = 30

@description('Enable Key Vault purge protection. Required for PROD; irreversible once enabled.')
param enablePurgeProtection bool = false

// ---------------------------------------------------------------------------
// Naming - derived once, never typed twice.
// See docs/architecture/naming-standards.md.
// ---------------------------------------------------------------------------

var namePrefix = 'bei-${workload}-${environmentName}-${locationShortCode}-${instance}'

// Globally unique suffix derived from the resource group, so it is stable across
// redeployments of the same environment and different between environments.
var uniqueSuffix = take(uniqueString(resourceGroup().id), 6)

var resourceNames = {
  logicApp: 'logic-${namePrefix}'
  workflowPlan: 'asp-${namePrefix}'
  applicationInsights: 'appi-${namePrefix}'
  logAnalytics: 'log-${namePrefix}'
  // Storage account names allow lowercase letters and digits only, max 24 chars.
  storageAccount: take(toLower(replace('stbei${workload}${environmentName}${locationShortCode}${instance}', '-', '')), 24)
  // Key Vault names are globally unique and capped at 24 characters.
  keyVault: take('kv-beishop-${environmentName}-${uniqueSuffix}', 24)
}

// ---------------------------------------------------------------------------
// Modules
// ---------------------------------------------------------------------------

module storage './modules/storage-account.bicep' = {
  name: 'storage-account'
  params: {
    name: resourceNames.storageAccount
    location: location
    tags: tags
    skuName: storageSkuName
  }
}

module monitoring './modules/application-insights.bicep' = {
  name: 'application-insights'
  params: {
    applicationInsightsName: resourceNames.applicationInsights
    logAnalyticsName: resourceNames.logAnalytics
    location: location
    tags: tags
    retentionInDays: logRetentionInDays
  }
}

module vault './modules/key-vault.bicep' = {
  name: 'key-vault'
  params: {
    name: resourceNames.keyVault
    location: location
    tags: tags
    enablePurgeProtection: enablePurgeProtection
  }
}

module plan './modules/workflow-plan.bicep' = {
  name: 'workflow-plan'
  params: {
    name: resourceNames.workflowPlan
    location: location
    tags: tags
    skuName: workflowPlanSku
  }
}

module logicApp './modules/logic-app-standard.bicep' = {
  name: 'logic-app-standard'
  params: {
    name: resourceNames.logicApp
    location: location
    tags: tags
    workflowPlanId: plan.outputs.id
    storageAccountName: storage.outputs.name
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    keyVaultName: vault.outputs.name
  }
}

module roles './modules/role-assignments.bicep' = {
  name: 'role-assignments'
  params: {
    keyVaultName: vault.outputs.name
    principalId: logicApp.outputs.principalId
  }
}

module diagnostics './modules/diagnostics.bicep' = {
  name: 'diagnostics'
  params: {
    logicAppName: logicApp.outputs.name
    keyVaultName: vault.outputs.name
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsId
  }
}

// ---------------------------------------------------------------------------
// Outputs - names and ids only. Never a secret (enforced by bicepconfig.json).
// ---------------------------------------------------------------------------

@description('Name of the deployed Logic App Standard resource.')
output logicAppName string = logicApp.outputs.name

@description('Default hostname of the deployed Logic App Standard resource.')
output logicAppHostName string = logicApp.outputs.defaultHostName

@description('Managed identity principal id of the Logic App.')
output logicAppPrincipalId string = logicApp.outputs.principalId

@description('Name of the Key Vault holding this workload of secrets.')
output keyVaultName string = vault.outputs.name

@description('Name of the storage account used by the Logic App runtime.')
output storageAccountName string = storage.outputs.name

@description('Name of the Application Insights resource.')
output applicationInsightsName string = monitoring.outputs.applicationInsightsName

@description('Environment this deployment targets.')
output targetEnvironment string = environmentName

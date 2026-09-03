// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - PROD parameters
//
// NONSECRET VALUES ONLY. Bicep parameter file values are stored and transmitted
// as PLAIN TEXT. Any sensitive value must come from Azure Key Vault or another
// approved secure source - never from this file.
//
// This is the ONLY place PROD differs from UAT. Do not create a second copy of
// main.bicep for this environment.
//
// PROD is durable: geo-redundant storage, longer retention, and purge
// protection enabled so a deleted Key Vault cannot be purged before its
// soft-delete window expires.
//
// WARNING: enablePurgeProtection is IRREVERSIBLE once a deployment applies it.
// ---------------------------------------------------------------------------

using '../main.bicep'

param workload = 'shopify'
param environmentName = 'prod'
param location = 'westcentralus'
param locationShortCode = 'wcus'
param instance = '001'

param workflowPlanSku = 'WS1'
param storageSkuName = 'Standard_GRS'
param logRetentionInDays = 90
param enablePurgeProtection = true

param tags = {
  environment: 'PROD'
  workload: 'shopify'
  owner: 'beiNVENTiV LLC'
  repository: 'bei-LogicAppSandbox'
  managedBy: 'bicep'
  costCenter: 'PLACEHOLDER-COST-CENTER'
}

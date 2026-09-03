// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - UAT parameters
//
// NONSECRET VALUES ONLY. Bicep parameter file values are stored and transmitted
// as PLAIN TEXT. Any sensitive value must come from Azure Key Vault or another
// approved secure source - never from this file.
//
// This is the ONLY place UAT differs from PROD. Do not create a second copy of
// main.bicep for this environment.
//
// UAT is disposable: locally redundant storage, short retention, no purge
// protection, so the environment can be torn down and rebuilt freely.
// ---------------------------------------------------------------------------

using '../main.bicep'

param workload = 'shopify'
param environmentName = 'uat'
param location = 'westcentralus'
param locationShortCode = 'wcus'
param instance = '001'

param workflowPlanSku = 'WS1'
param storageSkuName = 'Standard_LRS'
param logRetentionInDays = 30
param enablePurgeProtection = false

param tags = {
  environment: 'UAT'
  workload: 'shopify'
  owner: 'beiNVENTiV LLC'
  repository: 'bei-LogicAppSandbox'
  managedBy: 'bicep'
  costCenter: 'PLACEHOLDER-COST-CENTER'
}

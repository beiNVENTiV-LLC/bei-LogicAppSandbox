// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - UAT parameters
//
// STATUS: MODULE 3 PLACEHOLDER. main.bicep deploys nothing today.
//
// NONSECRET VALUES ONLY. Bicep parameter file values are stored and transmitted
// as PLAIN TEXT. Any sensitive value must come from Azure Key Vault or another
// approved secure source - never from this file.
//
// This is the ONLY place UAT differs from the other environment. Do not
// create a second copy of main.bicep for this environment.
//
// Values marked PLACEHOLDER have NOT been confirmed with beiNVENTiV and must be
// replaced in MODULE 3. Region and cost centre are unconfirmed assumptions.
// ---------------------------------------------------------------------------

using '../main.bicep'

param workload = 'shopifylab'
param environmentName = 'uat'
param location = 'eastus2'
param locationShortCode = 'eus2'
param instance = '001'
param tags = {
  environment: 'UAT'
  workload: 'shopifylab'
  owner: 'beiNVENTiV LLC'
  repository: 'bei-LogicAppSandbox'
  managedBy: 'bicep'
  costCenter: 'PLACEHOLDER-COST-CENTER'
}

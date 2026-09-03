// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Workflow Standard plan
//
// The hosting plan for Logic App Standard. Tier is WorkflowStandard; the SKU is
// parameterised so PROD can scale independently of UAT without a second
// template.
//
// The Workflow Standard hosting plan is available in all Azure regions for the
// Logic App (Standard) resource type.
// ---------------------------------------------------------------------------

@description('Workflow Standard plan name.')
param name string

@description('Azure region.')
param location string

@description('Tags applied to the resource.')
param tags object = {}

@description('Plan SKU. WS1 is the smallest Workflow Standard tier.')
@allowed([
  'WS1'
  'WS2'
  'WS3'
])
param skuName string = 'WS1'

@description('Maximum number of elastic workers the plan may scale out to.')
@minValue(1)
@maxValue(20)
param maximumElasticWorkerCount int = 3

resource workflowPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: 'WorkflowStandard'
  }
  properties: {
    maximumElasticWorkerCount: maximumElasticWorkerCount
    isSpot: false
    // Windows hosting. Linux would require reserved: true.
    reserved: false
    targetWorkerCount: 1
  }
}

@description('Resource id of the Workflow Standard plan.')
output id string = workflowPlan.id

@description('Name of the Workflow Standard plan.')
output name string = workflowPlan.name

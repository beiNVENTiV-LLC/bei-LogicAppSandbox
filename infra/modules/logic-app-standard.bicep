// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Logic App Standard
//
// The workload host. Workflow CONTENT is not declared here: the deployed ZIP is
// the source of the workflow definition, built from the contents of
// src/logic-app/shopify-order-simulation/ at the ZIP root. This template owns
// the resource, its identity, and its configuration only.
//
// IDENTITY
// A system-assigned managed identity is enabled and granted Key Vault Secrets
// User by role-assignments.bicep. Application secrets are read from Key Vault at
// runtime using that identity - never from an app setting literal.
//
// STORAGE CONNECTION STRING - a deliberate, documented exception
// The Logic Apps Standard runtime still requires a storage connection string for
// its content share. The key is resolved at DEPLOYMENT time with listKeys(): it
// is never committed, never placed in a parameter file, and never emitted as an
// output. It does land in the resource's application settings, which is visible
// to anyone holding reader access on the resource.
//
// FUTURE HARDENING (not in MODULE 3): move the runtime to managed-identity
// storage access and remove these two settings entirely. That requires
// Storage Blob, Queue and Table data role assignments and a runtime that
// supports identity-based content storage. Raise as an ADR before attempting.
// ---------------------------------------------------------------------------

@description('Logic App Standard resource name.')
param name string

@description('Azure region.')
param location string

@description('Tags applied to the resource.')
param tags object = {}

@description('Resource id of the Workflow Standard plan.')
param workflowPlanId string

@description('Name of the storage account used by the runtime.')
param storageAccountName string

@description('Name of the Application Insights resource.')
param applicationInsightsName string

@description('Name of the Key Vault this workload reads secrets from.')
param keyVaultName string

@description('Node.js runtime version for the workflow host.')
param nodeVersion string = '~20'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// Resolved at deployment time. Never committed, never output.
var storageConnectionString = join([
  'DefaultEndpointsProtocol=https'
  'AccountName=${storageAccount.name}'
  'AccountKey=${storageAccount.listKeys().keys[0].value}'
  'EndpointSuffix=${environment().suffixes.storage}'
], ';')

resource logicApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  // Order matters. Azure rejects 'workflowapp,functionapp'.
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: workflowPlanId
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
      functionsRuntimeScaleMonitoringEnabled: false
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: nodeVersion
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(name)
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'WORKFLOWS_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WORKFLOWS_RESOURCE_GROUP_NAME'
          value: resourceGroup().name
        }
        {
          name: 'WORKFLOWS_LOCATION_NAME'
          value: location
        }
        {
          name: 'KEY_VAULT_NAME'
          value: keyVaultName
        }
      ]
    }
  }
}

@description('Resource id of the Logic App.')
output id string = logicApp.id

@description('Name of the Logic App.')
output name string = logicApp.name

@description('Default hostname of the Logic App.')
output defaultHostName string = logicApp.properties.defaultHostName

@description('Managed identity principal id, for role assignments.')
output principalId string = logicApp.identity.principalId

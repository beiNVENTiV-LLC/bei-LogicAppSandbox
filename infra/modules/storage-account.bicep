// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - storage account
//
// The Logic App Standard runtime requires a storage account for workflow state,
// run history, the content share and internal queues.
//
// Shared key access is left ENABLED because the Logic Apps Standard runtime
// still requires a connection string for WEBSITE_CONTENTAZUREFILECONNECTIONSTRING.
// The key is never written to source control: it is resolved at deployment time
// with listKeys(). Moving the runtime to managed identity is tracked as future
// hardening - see the note in logic-app-standard.bicep.
// ---------------------------------------------------------------------------

@description('Storage account name. Lowercase alphanumeric only, 3-24 characters.')
@minLength(3)
@maxLength(24)
param name string

@description('Azure region.')
param location string

@description('Tags applied to the resource.')
param tags object = {}

@description('Redundancy tier. PROD should use a geo-redundant option.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
])
param skuName string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

@description('Resource id of the storage account.')
output id string = storageAccount.id

@description('Name of the storage account.')
output name string = storageAccount.name

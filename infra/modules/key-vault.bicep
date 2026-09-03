// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Key Vault
//
// Every secret this workload needs lives here. Nothing is stored in a parameter
// file, an app setting literal, or the repository.
//
// RBAC authorisation is enabled, so access is granted by role assignment to a
// managed identity - never by a shared access policy handed to a person.
// role-assignments.bicep grants the Logic App identity Key Vault Secrets User.
//
// Purge protection is IRREVERSIBLE once enabled. It is parameterised so PROD can
// enable it while UAT stays disposable.
// ---------------------------------------------------------------------------

@description('Key Vault name. Globally unique, 3-24 characters.')
@minLength(3)
@maxLength(24)
param name string

@description('Azure region.')
param location string

@description('Tags applied to the resource.')
param tags object = {}

@description('Soft delete retention in days.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Enable purge protection. Irreversible once enabled. Required for PROD.')
param enablePurgeProtection bool = false

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    // Only set the flag when true - Azure rejects an explicit false once enabled.
    enablePurgeProtection: enablePurgeProtection ? true : null
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

@description('Resource id of the Key Vault.')
output id string = keyVault.id

@description('Name of the Key Vault.')
output name string = keyVault.name

@description('Key Vault DNS name, for use in Key Vault references.')
output vaultUri string = keyVault.properties.vaultUri

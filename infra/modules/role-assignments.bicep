// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - role assignments
//
// The single reviewable place where workload access is expressed. No access is
// granted by hand in the portal.
//
// Least privilege: the Logic App managed identity receives Key Vault Secrets
// User - read access to secret VALUES, and nothing else. It cannot list, set,
// or delete secrets, and it holds no role over the vault itself.
//
// Creating a role assignment requires role-assignment-write rights. The GitHub
// deployment identity therefore holds User Access Administrator scoped to the
// environment resource group. Contributor alone is not sufficient. See ADR 0001.
// ---------------------------------------------------------------------------

@description('Name of the Key Vault to grant access to.')
param keyVaultName string

@description('Managed identity principal id of the Logic App.')
param principalId string

// Key Vault Secrets User - read secret contents. Built-in, stable GUID.
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  // Deterministic name so redeployment is idempotent rather than duplicating.
  name: guid(keyVault.id, principalId, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

@description('Resource id of the Key Vault Secrets User assignment.')
output keyVaultSecretsUserAssignmentId string = keyVaultSecretsUser.id

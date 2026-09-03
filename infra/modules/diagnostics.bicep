// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - diagnostic settings
//
// Routes platform logs and metrics to the Log Analytics workspace created by
// application-insights.bicep, so workflow run diagnostics, Key Vault access
// auditing and telemetry all land in one queryable place.
//
// This is the telemetry foundation the ops/ alerts, dashboards and queries will
// depend on. Retention is governed by the workspace, not by each setting.
// ---------------------------------------------------------------------------

@description('Name of the Logic App to collect diagnostics from.')
param logicAppName string

@description('Name of the Key Vault to collect diagnostics from.')
param keyVaultName string

@description('Resource id of the Log Analytics workspace to send diagnostics to.')
param logAnalyticsWorkspaceId string

resource logicApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: logicAppName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource logicAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: logicApp
  name: 'send-to-log-analytics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: 'send-to-log-analytics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('Resource id of the Logic App diagnostic setting.')
output logicAppDiagnosticsId string = logicAppDiagnostics.id

@description('Resource id of the Key Vault diagnostic setting.')
output keyVaultDiagnosticsId string = keyVaultDiagnostics.id

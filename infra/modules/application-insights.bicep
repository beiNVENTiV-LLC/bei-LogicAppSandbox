// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - Application Insights and Log Analytics
//
// Workspace-based Application Insights. The workspace is also the destination
// for the diagnostic settings configured by diagnostics.bicep, so telemetry and
// platform logs land in one place.
//
// The connection string is NOT emitted as an output. logic-app-standard.bicep
// reads it directly from the resource, so it never crosses a module boundary
// and never appears in deployment output.
// ---------------------------------------------------------------------------

@description('Application Insights resource name.')
param applicationInsightsName string

@description('Log Analytics workspace name.')
param logAnalyticsName string

@description('Azure region.')
param location string

@description('Tags applied to both resources.')
param tags object = {}

@description('Retention in days for the workspace and Application Insights.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: retentionInDays
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('Resource id of the Log Analytics workspace.')
output logAnalyticsId string = logAnalytics.id

@description('Name of the Log Analytics workspace.')
output logAnalyticsName string = logAnalytics.name

@description('Resource id of the Application Insights resource.')
output applicationInsightsId string = applicationInsights.id

@description('Name of the Application Insights resource.')
output applicationInsightsName string = applicationInsights.name

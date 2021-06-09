param logAnalyticsWorkspaceName string
param logAnalyticslocation string = 'uksouth'
param logAnalyticsWorkspaceSku string = 'pergb2018'

//Create Log Analytics Workspace
resource avdla 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: logAnalyticslocation
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
  }
}

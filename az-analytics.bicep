targetScope = 'subscription'

//Define Log Analytics parameters
param logAnalyticsWorkspaceName string
param logAnalyticslocation string = 'uksouth'
param monitoringrg string


resource monitorrg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: monitoringrg
  location: logAnalyticslocation
}


//Azure Monitor and Log Analytics
module loganalytics './modules/monitor.bicep' = {
  name: 'hubspoke'
  scope: resourceGroup(monitorrg.name)
  params: { 
    logAnalyticslocation: logAnalyticslocation
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

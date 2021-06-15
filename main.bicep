targetScope = 'tenant'

//Management Group Parameters
param orggroup string = ''
param devgroup string = ''
param testgroup string = ''
param prodgroup string = ''
param excgroup string = ''


//Policy Parameters
param listOfAllowedLocations array = [
  'uksouth'
  'ukwest'
  'northeurope'
  'westeurope'
]

param listOfAllowedSKUs array = [
  'Standard_B1ls'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B4s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
  'Standard_D2as_v3'
  'Standard_D4as_v3'
]

param SubscriptionID string
param tagname string
param tagvalue string


//VNET Parameters
param region string
param hubrgname string
param spokergname string
param hubname string
param hubspace string
param hubfwsubnet string
param spokename string
param spokespace string
param spokesnname string
param spokesnspace string
param vpnsubnet string
param vpngwpipname string
param vpngwname string
param localnetworkgwname string
param addressprefixes string
param gwipaddress string
param bgppeeringpddress string
param devicesubnet string



//LA and Montior Parameters
param logAnalyticsWorkspaceName string
param logAnalyticslocation string = 'uksouth'
param monitoringrg string


//VM Parameters
param serverrg string
param adminUserName string
@secure()
param adminPassword string
param dnsLabelPrefix string
param storageAccountName string
param vmName string
param networkSecurityGroupName string





//Create Parent Management Group

resource parentmanagement 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: orggroup 
  properties: {
    displayName: orggroup
    details: {
      }
    }
  }

  //Create Sub Groups

  resource devmanagement 'Microsoft.Management/managementGroups@2020-05-01' = {
    name: devgroup

    properties: {
      displayName: 'string'
      details: {
        parent: {
          id: parentmanagement.id
        }
      }
    }
  }

  resource testmanagement 'Microsoft.Management/managementGroups@2020-05-01' = {
    name: testgroup

    properties: {
      displayName: 'string'
      details: {
        parent: {
          id: parentmanagement.id
        }
      }
    }
  }

  resource prodmanagement 'Microsoft.Management/managementGroups@2020-05-01' = {
    name: prodgroup

    properties: {
      displayName: 'string'
      details: {
        parent: {
          id: parentmanagement.id
        }
      }
    }
  }


  //Create Exceptions Management Group

resource exceptionsmanagement 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: excgroup
  properties: {
    displayName: orggroup
    details: {
      }
    }
  }


//Create Policies
module azpolicy './az-policydef.bicep' = {
  name: 'azpolicy'
  scope: subscription(SubscriptionID)
  params: {
    listOfAllowedLocations: listOfAllowedLocations
    listOfAllowedSKUs: listOfAllowedSKUs
    tagname: tagname
    tagvalue: tagvalue
  }
}


//Create Hub-Spoke and test VM
module hubspoke './infra.bicep' = {
  name: 'infra'
  scope: subscription(SubscriptionID)
  params: {
    region: region
    hubrgname: hubrgname
    spokergname: spokergname
    hubname: hubname
    hubspace: hubspace
    hubfwsubnet: hubfwsubnet
    spokename: spokename
    spokespace: spokespace
    spokesnname: spokesnname
    spokesnspace: spokesnspace
    serverrg: serverrg
    adminUserName: adminUserName
    adminPassword: adminPassword
    dnsLabelPrefix: dnsLabelPrefix
    storageAccountName: storageAccountName
    vmName: vmName
    vpnsubnet: vpnsubnet
    networkSecurityGroupName: networkSecurityGroupName
    vpngwpipname: vpngwpipname
    vpngwname : vpngwname
    location: region
    localnetworkgwname: localnetworkgwname 
    addressprefixes: addressprefixes
    gwipaddress: gwipaddress
    bgppeeringpddress: bgppeeringpddress
    devicesubnet: devicesubnet
  }
}


//Azure Log Analytics
module loganalytics './az-analytics.bicep' = {
  name: 'loganalytics'
  scope: subscription(SubscriptionID)
  params: { 
logAnalyticslocation: logAnalyticslocation
logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
monitoringrg: monitoringrg
  }
}





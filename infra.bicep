targetScope = 'subscription'

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
param serverrg string
param adminUserName string
param vpnsubnet string
param devicesubnet string

@secure()
param adminPassword string
param dnsLabelPrefix string
param storageAccountName string
param vmName string
param networkSecurityGroupName string
param vpngwpipname string
param vpngwname string
param location string
param localnetworkgwname string
param addressprefixes string
param gwipaddress string
param bgppeeringpddress string

resource hubrg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: hubrgname
  location: region
}

resource spokerg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: spokergname
  location: region
}

resource infrarg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: serverrg
  location: region
}

module hubVNET './modules/vnet.bicep' = {
  name: hubname
  scope: hubrg
  params: {
    prefix: hubname
    addressSpaces: [
      hubspace
    ]
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: hubfwsubnet
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: vpnsubnet
        }
      }
      {
        name: 'DeviceSubnet'
        properties: {
          addressPrefix: devicesubnet
        }
      }
    ]
  }
}

module spokeVNET './modules/vnetspoke.bicep' = {
  name: spokename
  scope: spokerg
  params: {
    prefix: spokename
    snname: spokesnname
    addressSpaces: [
      spokespace
    ]
    subnets: [
      {
        name: spokesnname
        properties: {
          addressPrefix: spokesnspace
        }
      }
    ]
  }
}

module Hubfwl './modules/fwl.bicep' = {
  name: 'hub-fwl'
  scope: hubrg
  params: {
    prefix: 'hub'
    hubId: hubVNET.outputs.id
  }
}

module HubToSpokePeering './modules/peering.bicep' = {
  name: 'hub-to-spoke-peering'
  scope: hubrg
  dependsOn: [
    hubVNET
    spokeVNET
  ]
  params: {
    localVnetName: hubVNET.outputs.name
    remoteVnetName: spokename
    remoteVnetId: spokeVNET.outputs.id
  }
}

module SpokeToHubPeering './modules/peering.bicep' = {
  name: 'spoke-to-hub-peering'
  scope: spokerg
  dependsOn: [
    hubVNET
    spokeVNET
  ]
  params: {
    localVnetName: spokeVNET.outputs.name
    remoteVnetName: hubname
    remoteVnetId: hubVNET.outputs.id
  }
}



module vpn './modules/vpngw.bicep' = {
  name: 'vpn'
  scope: hubrg
  params: {
    vpngwpipname: vpngwpipname
    vpngwname : vpngwname
    location: location
    localnetworkgwname: localnetworkgwname 
    addressprefixes: addressprefixes
    gwipaddress: gwipaddress
    bgppeeringpddress: bgppeeringpddress
    subnetref: hubVNET.outputs.subnet2
  }
}



output spokevnet string = spokeVNET.outputs.name
output serverrg object = infrarg




//VM

module infra './modules/az-vm.bicep' = {
  name: 'infra'
  scope: infrarg
  dependsOn: [
    hubVNET
    spokeVNET
  ]
  params: {
    adminUserName: adminUserName
    adminPassword: adminPassword
    dnsLabelPrefix: dnsLabelPrefix
    storageAccountName: storageAccountName
    vmName: vmName
    subnetName: spokesnname
    networkSecurityGroupName: networkSecurityGroupName
    vn: spokeVNET.outputs.subnetId
  }
}




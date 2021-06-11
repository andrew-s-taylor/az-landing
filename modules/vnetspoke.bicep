param prefix string
param addressSpaces array
param subnets array
param snname string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: prefix
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpaces
    }
    subnets: subnets
  }
}

output name string = vnet.name
output id string = vnet.id

output subnetId string = '${vnet.id}/subnets/${snname}'
output subnetName string = snname




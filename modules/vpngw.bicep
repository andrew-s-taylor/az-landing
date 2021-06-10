param vpngwpipname string
param vpngwname string
param subnetref string
param location string
param localnetworkgwname string
param addressprefixes string
param gwipaddress string
param bgppeeringpddress string




resource vpngwpip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vpngwpipname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'    
  }
}

resource vpngw 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: vpngwname
  location: location    
  properties: {
      gatewayType: 'Vpn'
      ipConfigurations: [
          {
              name: 'default'
              properties: {
                  privateIPAllocationMethod: 'Dynamic'
                  subnet: {
                      id: subnetref
                  }
                  publicIPAddress: {
                      id: vpngwpip.id
                  }
              }
          }
      ]
      activeActive: false
      enableBgp: true
      bgpSettings: {
          asn: 65010
      }
      vpnType: 'RouteBased'
      vpnGatewayGeneration: 'Generation1'
      sku: {
          name: 'VpnGw1AZ'
          tier: 'VpnGw1AZ'
      }
  }
}

output id string = vpngw.id
output ip string = vpngwpip.properties.ipAddress
output bgpaddress string = vpngw.properties.bgpSettings.bgpPeeringAddress

resource localnetworkgw 'Microsoft.Network/localNetworkGateways@2020-06-01' = {
  name: localnetworkgwname
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: addressprefixes
    }
    gatewayIpAddress: gwipaddress
    bgpSettings: {
      asn:  64512
      bgpPeeringAddress: bgppeeringpddress
    }
  }
}

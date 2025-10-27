param vnetName string
param location string
param addressPrefix string
param subnetPrefix string
param routeTableId string = ''  

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: [
      {
        name: 'subnet1'
        properties: empty(routeTableId)
          ? { addressPrefix: subnetPrefix }
          : {
              addressPrefix: subnetPrefix
              routeTable: {
                id: routeTableId
              }
            }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
output vnetId string = vnet.id

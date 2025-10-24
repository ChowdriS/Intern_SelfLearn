param routeTableName string
param location string
param hubPrivateIp string
param peerSpokeAddressPrefix string

resource routeTable 'Microsoft.Network/routeTables@2022-07-01' = {
  name: routeTableName
  location: location
  properties: {
    routes: [
      {
        name: 'to-peer-spoke'
        properties: {
          addressPrefix: peerSpokeAddressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: hubPrivateIp
        }
      }
    ]
  }
}

output routeTableId string = routeTable.id

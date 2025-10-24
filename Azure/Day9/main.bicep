param location string = resourceGroup().location
param prefix string = 'chow3'
param adminUsername string = 'azureuser'

// VNets and CIDRs
var vnetNames = [
  '${prefix}-hub-vnet1'
  '${prefix}-spoke-vnet2'
  '${prefix}-spoke-vnet3'
]

var addressPrefixes = [
  '10.1.0.0/16'  // Hub
  '10.2.0.0/16'  // Spoke 1
  '10.3.0.0/16'  // Spoke 2
]

var subnetPrefixes = [
  '10.1.0.0/24'
  '10.2.0.0/24'
  '10.3.0.0/24'
]

// Create Hub VNet and VM first (index 0)
module hubVnet 'modules/vnet.bicep' = {
  name: 'hubVnet'
  params: {
    vnetName: vnetNames[0]
    location: location
    addressPrefix: addressPrefixes[0]
    subnetPrefix: subnetPrefixes[0]
    routeTableId: ''  // No route table for hub subnet
  }
}

module hubVm 'modules/vm.bicep' = {
  name: 'hubVm'
  params: {
    vmName: '${prefix}-vm-1'
    location: location
    vnetName: vnetNames[0]
    subnetName: 'subnet1'
    adminUsername: adminUsername
    enableIpForwarding: true
    assignPublicIp: true
    customData: base64(loadTextContent('script/cloud-init-hub.txt'))
  }
  dependsOn: [
    hubVnet
  ]
}

// Create Route Tables for Spokes (indices 1 and 2)
module routeTables 'modules/route_table.bicep' = [for i in range(1, 2): {
  name: 'routetable-${i+1}'
  params: {
    routeTableName: '${prefix}-rt-${i+1}'
    location: location
    hubPrivateIp: hubVm.outputs.privateIp
    peerSpokeAddressPrefix: subnetPrefixes[i == 1 ? 2 : 1]
  }
}]

// Create Spoke VNets with Route Table Association, wait on route tables
module spokeVnets 'modules/vnet.bicep' = [for i in range(1, 2): {
  name: 'spokeVnet-${i+1}'
  params: {
    vnetName: vnetNames[i]
    location: location
    addressPrefix: addressPrefixes[i]
    subnetPrefix: subnetPrefixes[i]
    routeTableId: routeTables[i - 1].outputs.routeTableId
  }
  dependsOn: [
    routeTables[i - 1]
  ]
}]

// Create Spoke VMs after respective VNets
module spokeVms 'modules/vm.bicep' = [for i in range(1, 2): {
  name: 'spokeVm-${i+1}'
  params: {
    vmName: '${prefix}-vm-${i+1}'
    location: location
    vnetName: vnetNames[i]
    subnetName: 'subnet1'
    adminUsername: adminUsername
    enableIpForwarding: false
    assignPublicIp: false
    customData: base64(loadTextContent('script/cloud-init.txt'))
  }
  dependsOn: [
    spokeVnets[i - 1]
  ]
}]

// Create VNet Peerings - Hub to Spokes
module peeringHubSpoke2 'modules/peer.bicep' = {
  name: 'peering-hub-spoke2'
  params: {
    vnet1Name: vnetNames[0]
    vnet2Name: vnetNames[1]
    vnet1Id: hubVnet.outputs.vnetId
    vnet2Id: spokeVnets[0].outputs.vnetId
  }
  dependsOn: [
    spokeVnets[0]
  ]
}

module peeringHubSpoke3 'modules/peer.bicep' = {
  name: 'peering-hub-spoke3'
  params: {
    vnet1Name: vnetNames[0]
    vnet2Name: vnetNames[2]
    vnet1Id: hubVnet.outputs.vnetId
    vnet2Id: spokeVnets[1].outputs.vnetId
  }
  dependsOn: [
    spokeVnets[1]
  ]
}

output hubPublicIp string = hubVm.outputs.privateIp

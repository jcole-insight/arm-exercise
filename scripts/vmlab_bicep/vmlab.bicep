param location string
param vmName array
param nsgName string
param vnetName string
param networkSecurityGroupRules array
param subnetName string
param subnetAddressPrefix string
param publicIpAddressType string
param DiskType string
param virtualMachineSize string
param adminUsername string

@description('Password for local admin account.')
@secure()
param adminPassword string
param patchMode string
param enableHotpatching bool

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', nsgName)
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', vnetName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource nsgName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsgId
          }
        }
      }
    ]
  }
  dependsOn: [
    nsgName_resource
  ]
}

resource vmName_name_pip 'Microsoft.Network/publicIpAddresses@2020-08-01' = [for item in vmName: {
  name: '${item.name}-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}]

resource vmName_name_nic 'Microsoft.Network/networkInterfaces@2020-11-01' = [for item in vmName: {
  name: '${item.name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: item.privateIPAddress
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', '${item.name}-pip')
          }
        }
      }
    ]
  }
  dependsOn: [
    vnetName_resource
  ]
}]

resource vmName_name_datadisk 'Microsoft.Compute/disks@2018-06-01' = [for item in vmName: {
  name: '${item.name}-datadisk'
  location: location
  sku: {
    name: 'StandardSSD_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 100
  }
}]

resource vmName_name 'Microsoft.Compute/virtualMachines@2020-12-01' = [for item in vmName: {
  name: item.name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: DiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      dataDisks: [
        {
          name: '${item.name}-datadisk'
          lun: 0
          createOption: 'Attach'
          managedDisk: {
            id: resourceId('Microsoft.Compute/disks/', '${item.name}-datadisk')
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${item.name}-nic')
        }
      ]
    }
    osProfile: {
      computerName: item.name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  dependsOn: [
    vmName_name_nic
    vmName_name_datadisk
  ]
}]

output adminUsername string = adminUsername

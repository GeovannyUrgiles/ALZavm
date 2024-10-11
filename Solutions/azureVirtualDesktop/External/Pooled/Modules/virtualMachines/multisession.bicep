param artifactsLocation string
param marketplaceImage object

param AVDnumberOfInstances int

param hostPoolName string
@description('Location for all standard resources to be deployed into.')
param location string
param domainToJoin string

@description('OU Path were new AVD Session Hosts will be placed in Active Directory')
param ouPath string
param domainJoinOptions int

param virtualMachinePrefix string
param subnetID string
param token string

param virtualMachineDiskType string
param virtualMachineSKU string
@secure()
param administratorAccountUserName string
@secure()
param administratorAccountPassword string

var avSetSKU = 'Aligned'
var existingDomainUserName = first(split(administratorAccountUserName, '@'))
var networkAdapterPostfix = '-nic'

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${virtualMachinePrefix}-${i}${networkAdapterPostfix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID
          }
        }
      }
    ]
  }
}]

// Availability Group

resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: '${virtualMachinePrefix}av1'
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 10
  }
  sku: {
    name: avSetSKU
  }
}

// Create Virtual Machines

resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${virtualMachinePrefix}-${i}'
  location: location
  properties: {
    licenseType: 'Windows_Client'
    hardwareProfile: {
      vmSize: virtualMachineSKU
    }
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets', '${virtualMachinePrefix}av1')
    }
    osProfile: {
      computerName: '${virtualMachinePrefix}-${i}'
      adminUsername: existingDomainUserName
      adminPassword: administratorAccountPassword
      windowsConfiguration: {
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
    }
    storageProfile: {
      osDisk: {
        name: '${virtualMachinePrefix}-${i}-os'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: virtualMachineDiskType
        }
        osType: 'Windows'
        createOption: 'FromImage'
      }
      imageReference: marketplaceImage
      dataDisks: [

      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${virtualMachinePrefix}-${i}${networkAdapterPostfix}')
        }
      ]
    }
  }
  dependsOn: [
    availabilitySet
    nic[i]
  ]
}]

// Active Directory Domain Join Extension

resource adDomainExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for i in range(0, AVDnumberOfInstances): {
  parent: virtualMachine[i]
  name: 'joindomain'
  //name: 'joindomain${i}'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: ouPath
      user: administratorAccountUserName
      restart: true
      options: domainJoinOptions
      NumberOfRetries: '4'
      RetryIntervalInMilliseconds: '30000'
    }
    protectedSettings: {
      password: administratorAccountPassword
    }
  }
  dependsOn: [
    virtualMachine[i]
  ]
}]

// Desired State Configuration Extension

resource dscextension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for i in range(0, AVDnumberOfInstances): {
  parent: virtualMachine[i]
  name: 'dscextension'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: artifactsLocation
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolName
        registrationInfoToken: token
      }
    }
  }
  dependsOn: [
    virtualMachine[i]
    adDomainExtension[i]
    availabilitySet
    nic[i]
  ]
}]

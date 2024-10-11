param artifactsLocation string
param marketplaceImage object

param AADJoin bool = true

param AVDnumberOfInstances int

param hostPoolName string
@description('Location for all standard resources to be deployed into.')
param location string
param domainToJoin string

@description('OU Path were new AVD Session Hosts will be placed in Active Directory')
param ouPath string
// param domainJoinOptions int

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

param intune bool = true

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
  identity: AADJoin ? {
    type: 'SystemAssigned'
  } : null
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

// Azure Active Directory Domain Join Extension

resource domainJoinExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${virtualMachinePrefix}-${i}/joindomain'
  location: location
  properties: AADJoin ? {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    // settings: intune ? {
    //  mdmId: '0000000a-0000-0000-c000-000000000000'
    // } : null
  } : {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: ouPath
      user: administratorAccountUserName
      restart: 'true'
      options: '3'
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
  
  name: '${virtualMachinePrefix}-${i}/dscextension'
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
    domainJoinExtension[i]
    availabilitySet
    nic[i]
  ]
}]


  

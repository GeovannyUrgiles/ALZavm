param location string
param subnetId string
param virtualMachineName string = '${CAFPrefix}dc'
param CAFPrefix string
param numberOfDCInstances int
param OSVersion string
// Virtual Machine Disks
param vmDiskType string
param vmSize string
// Network Interface
param avSetSKU string = 'Aligned'
param networkAdapterPostfix string = 'nic'
// Active Directory / Domain Join Credentials in KeyVault
param domainToJoin string
param ouPath string

//@secure()
//param adminName string
//@secure()
//param adminPassword string
//@secure()
// param domainAdminName string = first(split(domainAdminName, '@'))
//@secure()
//param domainAdminPassword string

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0, numberOfDCInstances): {
  name: '${virtualMachineName}0${i}${networkAdapterPostfix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
  dependsOn: [
  ]
}]

// Availability Set
resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = [for i in range(0, numberOfDCInstances) : {
  name: '${virtualMachineName}0${i}av'
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 10
  }
  sku: {
    name: avSetSKU
  }
  dependsOn: [
  ]
}]

// Virtual Machine / Windows

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, numberOfDCInstances): {
  name: '${virtualMachineName}0${i}'
  location: location
  properties: {
    licenseType: 'Windows_Server'
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets', '${virtualMachineName}0${i}av')
    }
    osProfile: {
      computerName: '${virtualMachineName}0${i}'
      adminUsername: 'tffadmin'       //  adminLoginName
      adminPassword: 'ThievingCat10!' //  adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
    }
    storageProfile: {
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        name: '${virtualMachineName}0${i}_OsDisk'
        managedDisk: {
          storageAccountType: vmDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${virtualMachineName}0${i}${networkAdapterPostfix}')
        }
      ]
    }
  }
  dependsOn: [
    availabilitySet
    networkInterface[i]
  ]
}]

// Extensions / Join Active Directory


resource joinDomain 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for i in range(0, numberOfDCInstances): {
  name: '${virtualMachineName}0${i}/joinDomain'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: ouPath
      user: domainAdminName
      restart: 'true'
      options: '3'
      NumberOfRetries: '4'
      RetryIntervalInMilliseconds: '30000'
    }
    protectedSettings: {
      password: domainAdminPassword
    }
  }
  dependsOn: [
    virtualMachine[i]
  ]
}]


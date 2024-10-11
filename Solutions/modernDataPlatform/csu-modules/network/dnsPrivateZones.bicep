param privateDnsZoneNames array
param tags object

resource privatednszones 'Microsoft.Network/privateDnsZones@2018-09-01' = [for privateDnsZoneName in privateDnsZoneNames: {
  name: '${privateDnsZoneName}'
  location: 'global'
  tags: tags
  properties: {
  }
  dependsOn: [
  ]
}]

// output privateDnsZoneId_azuresynapse string = privatednszones[14].id // 14

output privateDnsZoneId_azure_automation string = privatednszones[0].id // 15
output privateDnsZoneId_vaultcore string = privatednszones[1].id // 53
output privateDnsZoneId_file_core string = privatednszones[2].id // 28
output privateDnsZoneId_blob_core string = privatednszones[3].id // 17
output privateDnsZoneId_table_core string = privatednszones[4].id // 50
output privateDnsZoneId_queue_core string = privatednszones[5].id // 43
output privateDnsZoneId_dfs_core string = privatednszones[6].id // 24
output privateDnsZoneId_database string = privatednszones[7].id // 20
output privateDnsZoneId_azurewebsites string = privatednszones[8].id // 07
output privateDnsZoneId_datafactory string = privatednszones[9].id // 21

// output privateDnsZoneId_adf_azure string = privatednszones[5].id // 05
// output privateDnsZoneId_dev_azuresynapse string = privatednszones[22].id // 22


// output privateDnsZoneId_ods_opinsights string = privatednszones[37].id // 37
// output privateDnsZoneId_oms_opinsights string = privatednszones[38].id // 38


// output privateDnsZoneId_web_core string = privatednszones[54].id // 54


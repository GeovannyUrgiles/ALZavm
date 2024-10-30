
$Region = 'westus'
$MasterServers = '10.70.3.4'
$ComputerName = 'nbbcorwusdc01'

$DNSZones = @(

# 'azure-automation.net',
# 'azurecr.io',
'azurewebsites.net',
'blob.core.windows.net',
'database.windows.net',
'dfs.core.windows.net',
# 'datafactory.azure.net',
# 'documents.azure.com',
'file.core.windows.net',
'monitor.azure.com',
'ods.opinsights.azure.com',
'oms.opinsights.azure.com',
'queue.core.windows.net',
# 'redis.cache.windows.net',
# 'servicebus.windows.net',
# 'azuresynapse.net',
# 'sql.azuresynapse.net',
# 'dev.azuresynapse.net',
'table.core.windows.net',
'vaultcore.azure.net',
'web.core.windows.net'

# $Region + '.azmk8s.io'

)

foreach ($DNSZone in $DNSZones) {

add-dnsserverconditionalforwarderzone -name $DNSZone -masterservers $MasterServers -computername $ComputerName -passthru

}

# add-dnsserverconditionalforwarderzone -name 'azure-automation.net' -masterservers 10.1.1.4,10.7.1.4 -computername xxxxxxx -passthru

param location string
param virtualNetworkName string
param servicePrincipalAppId string
@secure()
param secret string
param tenantId string
param subscriptionId string

resource dynamicSubnetsSpoke 'Microsoft.Resources/deploymentScripts@2020-10-01' = {

  name: 'subDynamicSubnetIds.bicep.dynamicSubnetsSpoke'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.2.4'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    arguments: '-virtualNetworkName ${virtualNetworkName} -servicePrincipalAppId ${servicePrincipalAppId} -secret ${secret} -tenantId ${tenant().tenantId} -subscriptionId ${subscription().subscriptionId}'
    scriptContent: '''
    param(
    [Parameter(Mandatory=$true)][string] $virtualNetworkName,
    [Parameter(Mandatory=$true)][string] $servicePrincipalAppId,
    [Parameter(Mandatory=$true)][string] $tenantId,
    [parameter(Mandatory=$true)][string] $subscriptionId,
    [parameter(Mandatory=$true)][string] $secret
    )

    $password = ConvertTo-SecureString -String $secret -AsPlainText -Force
    $credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $servicePrincipalAppId, $password
    Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantId
    Set-AzContext -Subscription $subscriptionId

    $azurePrivateEndpointSubnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -like "AzurePrivateEndpointSubnet"}
    $azurePrivateEndpointSubnet.id

    $DeploymentScriptOutputs = @{
      azurePrivateEndpointSubnetId = $azurePrivateEndpointSubnet.id
    }

    '''
  }
  dependsOn: []
} 

output azurePrivateEndpointSubnetId string = dynamicSubnetsSpoke.properties.outputs.azurePrivateEndpointSubnetId


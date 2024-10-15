
param location string
param virtualNetworkName string
param servicePrincipalAppId string
param subscriptionId string

resource dynamicSubnetsSpoke 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  
  name: 'subDynamicSubnetIds.bicep.dynamicSubnetsSpoke'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.2.4'
    arguments: '-virtualNetworkName ${virtualNetworkName} -servicePrincipalAppId ${servicePrincipalAppId} -tenantid ${tenant().tenantId} -subscriptionId ${subscription().subscriptionId}'
    scriptContent: '''

# Required Variables

    param([Parameter(Mandatory=$true)][string] $virtualNetworkName,
    [Parameter(Mandatory=$true)][string] $servicePrincipalId,
    [Parameter(Mandatory=$true)][string] $tenantId,
    [Parameter(Mandatory=$true)][string] $secret,
    [parameter(Mandatory=$true)][string] $subscriptionId,
    [parameter(Mandatory=$true)][string] $keyVaultName
    )

# Connect to Azure

    $password = ConvertTo-SecureString -String $secret -AsPlainText -Force
    $credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $servicePrincipalAppId, $password
    Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantId
    Set-AzContext -Subscription $subscriptionId

    # Azure Subnets

    $azurePrivateEndpointSubnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "AzurePrivateEndpointSubnet"}
    $azureAKS1Subnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "AzureAKS1Subnet"}
    $azureAKS2Subnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "AzureAKS2Subnet"}
    $azureDatabricks1PublicSubnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureDatabricks1PublicSubnet"}
    $azureDatabricks1PrivateSubnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureDatabricks1PrivateSubnet"}
    $azureDatabricks2PublicSubnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureDatabricks2PublicSubnet"}
    $azureDatabricks2PrivateSubnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureDatabricks2PrivateSubnet"}
    $azureISE1Subnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureISE1Subnet"}
    $azureISE2Subnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureISE2Subnet"}
    $azureISE3Subnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureISE3Subnet"}
    $azureISE4Subnet = (Get-AzVirtualNetwork -name $virtualNetworkName).Subnets | where {$_.Name -match "azureISE4Subnet"}

    # Deployment Script Outputs

    $DeploymentScriptOutputs = @{
      
      azurePrivateEndpointSubnetId = $azurePrivateEndpointSubnet.id; 
      azureAKS1SubnetId = $azureAKS1Subnet.id;
      azureAKS2SubnetId = $azureAKS2Subnet.id;
      azureDatabricks1PublicSubnetId = $azureDatabricks1PublicSubnet.id;
      azureDatabricks1PrivateSubnetId = $azureDatabricks1PrivateSubnet.id;
      azureDatabricks2PublicSubnetId = $azureDatabricks2PublicSubnet.id;
      azureDatabricks2PrivateSubnetId = $azureDatabricks2PrivateSubnet.id;
      azureISE1SubnetId = $azureISE1Subnet.id;
      azureISE2SubnetId = $azureISE2Subnet.id;
      azureISE1SubnetId = $azureISE1Subnet.id;
      azureISE4SubnetId = $azureISE4Subnet.id;

      }

    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [

  ]
}

output azurePrivateEndpointSubnetId string = dynamicSubnetsSpoke.properties.outputs.azurePrivateEndpointSubnetId
output azureAKS1SubnetId string = dynamicSubnetsSpoke.properties.outputs.azureAKS1SubnetId
output azureAKS2SubnetId string = dynamicSubnetsSpoke.properties.outputs.azureAKS1SubnetId
output azureDatabricks1PublicSubnetId string = dynamicSubnetsSpoke.properties.outputs.azureDatabricks1PublicSubnetId
output azureDatabricks1PrivateSubnetId string = dynamicSubnetsSpoke.properties.outputs.azureDatabricks1PrivateSubnet
output azureDatabricks2PublicSubnetId string = dynamicSubnetsSpoke.properties.outputs.azureDatabricks2PublicSubnetId
output azureDatabricks2PrivateSubnet string = dynamicSubnetsSpoke.properties.outputs.azureDatabricks1PrivateSubnetId
output azureISE1SubnetId string = dynamicSubnetsSpoke.properties.outputs.azureISE1SubnetId
output azureISE2SubnetId string = dynamicSubnetsSpoke.properties.outputs.azureISE2SubnetId
output azureISE3SubnetId string = dynamicSubnetsSpoke.properties.outputs.azureISE3SubnetId
output azureISE4SubnetId string = dynamicSubnetsSpoke.properties.outputs.azureISE4SubnetId

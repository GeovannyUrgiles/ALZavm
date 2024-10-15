
param keyVaultName string
param location string
param virtualNetworkName string
param servicePrincipalAppId string
param secret string
param subscriptionId string

resource dynamicSubnetsSpoke 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  
  name: 'AddSecrets'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.2.4'
    arguments: '-vaultName ${keyVaultName} -VnetName ${virtualNetworkName} -SPappid ${servicePrincipalAppId} -tenantid ${tenant().tenantId} -secret ${secret} -subid ${subscription().subscriptionId}'
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
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $servicePrincipalAppId, $password
    Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $tenantId
    Set-AzContext -Subscription $subid


    # Azure Virtual Machine Subnet and Key Vault Operations

    $virtualNetworksubnet = (Get-AzVirtualNetwork -name $VnetName).Subnets | where {$_.Name -like "*vmsn"}
    $subnet.id
    $virtualMachineSubnet.id
    $charlist = [char]94..[char]126 + [char]65..[char]90 +  [char]47..[char]57
    $pwLength = (1..10 | Get-Random) + 24  
    $pwdList = @()
    For ($i = 0; $i -lt $pwlength; $i++) {
        $pwdList += $charList | Get-Random
        }
    $pass = -join $pwdList
    $SecurePass = $pass | ConvertTo-SecureString -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $vaultName -Name 'SQLAdminPass' -SecretValue $SecurePass

    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [

  ]
}

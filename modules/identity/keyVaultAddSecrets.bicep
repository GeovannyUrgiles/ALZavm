param location string
@secure()
param secret string 
param SPappid string 
param vaultName string
/* param storagekey string
param storagename string */

resource appidscript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
    name: 'AddSecret'
    location: location
    kind: 'AzurePowerShell'
    properties: {
      azPowerShellVersion: '7.2.4'
      arguments: '-vaultName ${vaultName} -SPappid ${SPappid} -tenantid ${tenant().tenantId} -secret ${secret} -subid ${subscription().subscriptionId}'
      scriptContent: '''

      param([Parameter(Mandatory=$true)][string] $SPappid,
      [Parameter(Mandatory=$true)][string] $tenantid,
      [Parameter(Mandatory=$true)][string] $secret,
      [parameter(Mandatory=$true)][string] $subid,
      [parameter(Mandatory=$true)][string] $vaultName
      )
      $password = ConvertTo-SecureString -String $secret -AsPlainText -Force
      $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $SPappid, $password
      Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $tenantid 
      Set-AzContext -Subscription $subid

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
/*       storageAccountSettings: {
        storageAccountKey: storagekey
        storageAccountName: storagename
      } */
    }
    dependsOn: []
  }



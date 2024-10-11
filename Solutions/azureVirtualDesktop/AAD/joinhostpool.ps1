param (
    [string]$rgname,
    [string]$hostpool,
    [string]$vm
)

$token = (Get-AzWvdRegistrationInfo -ResourceGroupName $rgname -HostPoolName $hostpool).Token

if(!$token)
    {
    echo "getting new token"
    $token = (New-AzWvdRegistrationInfo -ResourceGroupName $rgname  -HostPoolName $hostpool -ExpirationTime $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))).Token
    }

$scriptContent = @'
         param ($token)
         Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDInfraAgent\" -Name IsRegistered -Value 0
         Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDInfraAgent\" -Name RegistrationToken -Value $token
         Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" -Name DirtyShutdown -Value 0
         Set-TimeZone "Mountain Standard Time"
'@
    
$execScriptName = 'Invoke-TempScript.ps1'
$execScriptPath = New-Item -Path $execScriptName -ItemType File -Force -Value $scriptContent | select -Expand FullName
  
$invokeParams = @{
     ResourceGroupName = $rgname
     VMName = $vm
     CommandId  = 'RunPowerShellScript'
     ScriptPath = $execScriptPath
     Parameter = @{token = $token}
}
echo "Installing hostpool configurations for $vm"
$results = Invoke-AzVMRunCommand @invokeParams
$results
echo "Restarting"
$vm
Restart-AzVM -Name $vm -ResourceGroupName $rgname
     
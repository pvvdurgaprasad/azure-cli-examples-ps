Get-Content .\siteparams-createADGroup.config | Invoke-Expression

$ADGroup
$ADGroupDesc

Connect-AzAccount
Write-Output "Connected to Azure."

New-AzADGroup -DisplayName $ADGroup -MailNickname $ADGroup -Description $ADGroupDesc -Verbose

Disconnect-AzAccount -Scope Process -ErrorAction Stop | Out-Null
Write-Output "Disconnected."
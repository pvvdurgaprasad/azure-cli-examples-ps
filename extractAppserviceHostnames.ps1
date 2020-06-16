Get-Content .\siteparams-extractAppserviceHostnames.config | Invoke-Expression

$ResourceGroup
$OutputFilename

Connect-AzAccount
Write-Output "Connected to Azure."

Get-AzResource -ResourceGroupName $ResourceGroup -ResourceType Microsoft.Web/sites |Get-AzResource -ResourceId {$PSItem.ResourceId} | select @{n = "WebAppName"; e = {$PSItem.Name}}, @{n = "AppServicePlan"; e = {$PSItem.properties.serverFarmId.split('/')[-1]}}, kind, location, @{n = "status"; e = {$PSItem.properties.state}}, @{n = "HostNames"; e = {$PSItem.properties.hostnames}}, @{n = "Tier"; e = {$PSItem.properties.sku}}, @{n = "possibleOutboundIpAddresses"; e = {$PSItem.properties.possibleOutboundIpAddresses}},@{n="possibleInboundIpAddresses";e={$PSItem.properties.possibleInboundIpAddresses}} |Export-Csv $OutputFilename -NoTypeInformation

Disconnect-AzAccount -Scope Process -ErrorAction Stop | Out-Null
Write-Output "Disconnected."
Get-Content .\site-params.config | Invoke-Expression

$appService
$resourceGroup
$slot
$slotDomain
$waitTimeInSeconds
$retriesBeforeTimeout

Connect-AzAccount
Write-Output "Connected to Azure."

# Get the last Sucessful BackupID of the backup you want to restore
$backupID = Get-AzWebAppBackupList -ResourceGroupName $resourceGroup -Name $appService|Where-Object BackupStatus -EQ "Succeeded" |Select-Object BackupId -Last 1 
# Get the backup object that you want to restore by specifying the BackupID
$backup = (Get-AzWebAppBackupList -ResourceGroupName $resourceGroup -Name $appService |Where-Object {$PSItem.BackupId -eq $backupID.BackupId}) 
# Restore the app by overwriting it with the backup data in the slot
$backup |Restore-AzWebAppBackup -Slot $slot -IgnoreConflictingHostNames -Overwrite
Write-Output "Restore initiated."
#Wait for 15 minutes for restore to complete - NEED TO IMPROVE THIS
$success = $false
$count = 0
do{
    try{
	    Set-AzWebAppSlot -Name $appService -Slot $slot -ResourceGroupName $resourceGroup -HostNames @($slotDomain,"$appService-$slot.azurewebsites.net")
	    $thumbprint=(Get-AzWebAppSSLBinding -ResourceGroupName $resourceGroup -WebAppName $appService).Thumbprint
	    New-AzWebAppSSLBinding -ResourceGroupName $resourceGroup -WebAppName $appService -Slot $slot -Name $slotDomain -SslState SniEnabled -Thumbprint $thumbprint -Verbose
      	$success = $true
    }
    catch{
        Write-Verbose "Next attempt in $waitTimeInSeconds seconds"
        Start-sleep -Seconds $waitTimeInSeconds
    }
    $count++
}until($count -eq $retriesBeforeTimeout -or $success)
Write-Output "Restore operation completed. If it failed, please retry DNS mapping in Azure Portal"

Disconnect-AzAccount -Scope Process -ErrorAction Stop | Out-Null
Write-Output "Disconnected."
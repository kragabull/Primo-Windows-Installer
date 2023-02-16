$path = $MyInvocation.MyCommand.Path | split-path -parent
$log = "$path\log.txt"
echo ======================== >> $log
echo "Starting copying" >> $log
Get-Date >> $log
#---extract archives in destination folder---  
Expand-Archive -LiteralPath "$path\WebApi-IIS.zip" -DestinationPath "C:\Primo\WebApi1" -Force 2>&1 >> $log
Expand-Archive -LiteralPath "$path\UI.zip" -DestinationPath "C:\Primo\UI1" -Force 2>&1 >> $log
echo "Copying complete" >> $log
Get-Date >> $log
echo ======================== >> $log
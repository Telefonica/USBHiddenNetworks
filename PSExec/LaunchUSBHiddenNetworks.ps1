# HiddenNetwork SMB / PSexec
# Don´t forget change paths to files

$computers = gc "C:\scripts\HiddenNetworks\PSExec\USBHiddenNetworks_for_SMB\servers.txt"
$url = "http://TypeYourIPHere/RecollectUSBData.ps1"
$sincro = 40

foreach ($computer in $computers) {
    $Process = [Diagnostics.Process]::Start("cmd.exe","/c psexec.exe \\$computer powershell.exe -C IEX (New-Object Net.Webclient).Downloadstring('$url') >> C:\scripts\HiddenNetworks\PSExec\USBHiddenNetworks_for_SMB\usbdata.csv")  
    $id = $Process.Id       
    sleep $sincro   
    Write-Host "Process created. Process id is $id" 
    taskkill.exe /PID $id
}


# HiddenNetworks
# SMB PSExec version
# Output USB data from local computer to CSV file

$USBDevices = @()
$USBContainerID = @()
$USBComputerName = @()
$USBComputerIP = @()
$SubKeys2        = @()
$USBSTORSubKeys1 = @()

$Hive   = "LocalMachine"
$Key    = "SYSTEM\CurrentControlSet\Enum\USBSTOR"

$ComputerName = $Env:COMPUTERNAME
$ComputerIP = $localIpAddress=((ipconfig | findstr [0-9].\.)[0]).Split()[-1]

$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$Computer)
$USBSTORKey = $Reg.OpenSubKey($Key)
$nop=$false

Try {
    $USBSTORSubKeys1  = $USBSTORKey.GetSubKeyNames() 
}
Catch
{
    Write-Host "Computer: ",$ComputerName -foregroundcolor "white" -backgroundcolor "red"
    Write-Host "No USB data found"
    $nop=$true
}

# USB searching for devices connected
if(-Not $nop)
{
    ForEach($SubKey1 in $USBSTORSubKeys1)
    {          
        $Key2 = "SYSTEM\CurrentControlSet\Enum\USBSTOR\$SubKey1"
        $RegSubKey2 = $Reg.OpenSubKey($Key2)
        $SubkeyName2 = $RegSubKey2.GetSubKeyNames()      
        $Subkeys2  += "$Key2\$SubKeyName2"
        $RegSubKey2.Close()    
            
    }


    ForEach($Subkey2 in $Subkeys2)
    {	
        $USBKey = $Reg.OpenSubKey($Subkey2)
        $USBDevice = $USBKey.GetValue('FriendlyName')
        $USBContainerID = $USBKey.GetValue('ContainerID')
    
        If($USBDevice)
        {	
            $USBDevices += New-Object -TypeName PSObject -Property @{
            USBDevice = $USBDevice
            USBContainerID = $USBContainerID
            USBComputerName= $ComputerName
            ComputerIP = $ComputerIP
            }   
        }
  
        $USBKey.Close()     		      					
    }
    
    # Output data to screen	

    for ($i=0; $i -lt $USBDevices.length; $i++) {
        $IDUnico=$USBDevices[$i] | Select -ExpandProperty "USBContainerID"
        $USBNombre=$USBDevices[$i] | Select -ExpandProperty "USBDevice"  
        Write-Host "$ComputerName,$ComputerIP,$USBNombre,$IDUnico"       
    }
}



# Informacion Registro USB
# Crea fichero de salida CSV con la información USB del equipo remoto
# Prueba para invoke_command

$USBDevices = @()
$USBContainerID = @()
$USBComputerName = @()
$USBComputerIP = @()
$Hive   = "LocalMachine"
$Key    = "SYSTEM\CurrentControlSet\Enum\USBSTOR"
$ComputerName = $Env:COMPUTERNAME
$ComputerIP = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress 
$SubKeys2        = @()
$USBSTORSubKeys1 = @()
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

#Detectamos los USB que han sido instalados en la máquina
if(-Not $nop)
{
    ForEach($SubKey1 in $USBSTORSubKeys1)
    {          
        $Key2 = "SYSTEM\CurrentControlSet\Enum\USBSTOR\$SubKey1"
        $RegSubKey2 = $Reg.OpenSubKey($Key2)
        $SubkeyName2 = $RegSubKey2.GetSubKeyNames()      
        $Subkeys2  += "$Key2\$SubKeyName2"
        $RegSubKey2.Close()    
            
    }#end foreach SubKey1


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
    
    #Salida en pantalla y fichero de los datos		

    for ($i=0; $i -lt $USBDevices.length; $i++) {
        $IDUnico=$USBDevices[$i] | Select -ExpandProperty "USBContainerID"
        $USBNombre=$USBDevices[$i] | Select -ExpandProperty "USBDevice"  
        Write-Host "Computer: ",$ComputerName -foregroundcolor "black" -backgroundcolor "green"
        Write-Host "USB found: ",$USBNombre
        Write-Host "USB ID: ",$IDUnico 
        Echo "$ComputerName,$ComputerIP,$USBNombre,$IDUnico"       
    }
}



$IPAdressCIDR = $($args[0])

function IP-toINT64($ip) { 
  $octets = $ip.split(".") 
  return [int64]([int64]$octets[0]*16777216 +[int64]$octets[1]*65536 +[int64]$octets[2]*256 +[int64]$octets[3]) 
} 
 
function INT64-toIP($int) { 
  return (([math]::truncate($int/16777216)).tostring()+"."+([math]::truncate(($int%16777216)/65536)).tostring()+"."+([math]::truncate(($int%65536)/256)).tostring()+"."+([math]::truncate($int%256)).tostring() )
} 

if ($IPAdressCIDR -like "*/*") {
    $IPAdress = [Net.IPAddress]::Parse($IPAdressCIDR.Split('/')[0])
    $Mask = [convert]::ToInt32($IPAdressCIDR.Split("/")[1])
    if ($Mask -le 32 -and $Mask -ne 0) {
        $MaskAddress = [Net.IPAddress]::Parse((INT64-toIP(([convert]::ToInt64(("1"*$Mask+"0"*(32-$Mask)),2)))))
        $NetworkAddr = new-object net.ipaddress ($MaskAddress.address -band $IPAdress.address)
        $BroadcastAddr = new-object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $MaskAddress.address -bor $NetworkAddr.address))
        $beginaddr = IP-toINT64($NetworkAddr.ipaddresstostring)
        $endaddr = IP-toINT64($BroadcastAddr.ipaddresstostring)
    }
    else {
        Write-Host "Mask invalid"
        Exit
    }
}
else {
    Write-Host "Usage : jajookup.ps1 192.168.0.0/24"
    Exit
}

$pathfile = $PSScriptRoot+"\result.txt"

$stream = [System.IO.StreamWriter] $pathfile

for ($i = $beginaddr; $i -le $endaddr; $i++) 
{ 
  $ipcurrent = INT64-toIP($i)
  try {
    $nslookupoutput = nslookup.exe $ipcurrent 2>$null | Out-String
    if ($nslookupoutput -match 'Nom') {
        Write-Host $ipcurrent " =======> " $nslookupoutput.Split([Environment]::NewLine)[6].Split("Nom")[3].Replace(':', '').Replace(' ', '')
        $stream.WriteLine($ipcurrent+" =======> "+$nslookupoutput.Split([Environment]::NewLine)[6].Split("Nom")[3].Replace(':', '').Replace(' ', ''))
    }
  }catch{

  }
}

$stream.Close()

Write-Host "Result in "$pathfile
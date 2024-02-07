param (
	[boolean]$test = $false,
	[string]$user,
    [string]$pass
)
# Read XML configuration file
$path = $PSScriptRoot
Write-Host "ohjelma suoritetaan kansiossa $path"

# Jos config.xml ei ole olemassa, kopioidaan esimerkkitiedosto
if (!(Test-Path "$path\config.xml")) {
	# kopioi esimerkkitiedosto config.xml
	Copy-Item "$path\example.config.xml" "$path\config.xml"
	throw "Määritä asetukset config.xml-tiedostoon."
}

[xml]$config = Get-Content "$path\config.xml"
$pport = $config.Configuration.primusquery.port
$phost = $config.Configuration.primusquery.host
$pu = $config.Configuration.primusquery.user
$pp = $config.Configuration.primusquery.pass
$pq_error = "$path\$($config.Configuration.primusquery.errorfile)"
$pq =$config.Configuration.primusquery.exe
$log = "$path\$($config.Configuration.logfile)"
$outFile = "$path\$($config.Configuration.filename)"

# Jos parametri $phost puuttuu, lopetetetaan suoritus
if (!$phost) {throw "Primusquery host ei ole määritelty config.xml:ssä"}
# Jos sfpt host puuttuu, lopetetetaan suoritus
if (!$config.Configuration.sftp.host) {throw "SFTP host ei ole määritelty config.xml:ssä"}

# Jos käyttäjätunnus tai salasana ei ole määritelty config.xml:ssä, kysytään ne
if (!$pu){
	if($user){
		$pu = $user
	} else {
		$pu = Read-Host -Prompt "Primuksen käyttäjätunnus"
	}
}
if (!$pp) {
	if($pass) {
		$pp = $pass
	} else {
		$password = Read-Host -Prompt "Primuksen salasana" -AsSecureString
		$pp = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
				[Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
	}
}

Start-Transcript $log
Write-Host "###  Primus --> Traderia siirto  ###"

if (Test-Path $outFile) {Remove-item $outFile}

&"$pq" -v
&"$pq" $phost $pport $pu $pp -queryfile "$path\TraderiaOpiskelijatunnisteet.pq" -o $outFile -e +$pq_error

if (Test-Path $outFile) {
	Write-Host "Siirtotiedostossa mukana $((Get-Content $outFile).Length) riviä."
} else {
	throw "Siirretävää tiedostoa ei muodostunut. Tarkasta Primusquery määritykset ja primus tunnukset."
}

<#
# Lataa tiedosto palvelimelle 
# Huomioi, jos parametrina annettu -test $true --> lähettää testipalvelimelle
#>
try
{
	# Load WinSCP .NET assembly
	Add-Type -Path "$path\winscp\WinSCPnet.dll"
	
	# Set up session options
	# Note -test $true parameter
	if ($test)
	{
		Write-Host "Siirretään TESTIYMPÄRISTÖÖN"
		$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
			Protocol = [WinSCP.Protocol]::Sftp
			HostName = $config.Configuration.test.sftp.host
			PortNumber = $config.Configuration.test.sftp.port
			UserName = $config.Configuration.test.sftp.UserName
			Password = $config.Configuration.test.sftp.Password
			SshHostKeyFingerprint = $config.Configuration.test.sftp.sshHostKeyFingerprint
			#SshPrivateKeyPath = $config.Configuration.test.sftp.SshPrivateKeyPath
		}
	} else 
	{
		Write-Host "Siirretään TUOTANTOYMPÄRISTÖÖN"
		$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
			Protocol = [WinSCP.Protocol]::Sftp
			HostName = $config.Configuration.sftp.host
			PortNumber = $config.Configuration.sftp.port
			UserName = $config.Configuration.sftp.UserName
			Password = $config.Configuration.sftp.Password
			SshHostKeyFingerprint = $config.Configuration.sftp.sshHostKeyFingerprint
			#SshPrivateKeyPath = $config.Configuration.sftp.SshPrivateKeyPath
		}
	}
	
	$session = New-Object WinSCP.Session
	
	try
	{
	    # Connect
		Write-Host "Avataan sFTP..."
	    $session.Open($sessionOptions)
	
	    # Transfer files
		Write-Host "Lahetetaan..."
		$transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
		$TransferOptions.PreserveTimestamp = $False
		
	    $transferResult =
			$session.PutFiles($outFile, "/", $False, $transferOptions)
		# Throw on any error
		$transferResult.Check()
		# Print results
		foreach ($transfer in $transferResult.Transfers)
		{
			Write-Host "Upload of $($transfer.FileName) succeeded"
	    } 
		
	} catch	{
	    Write-Host "Error: $($_.Exception.Message)"
	}
	finally
	{
	    $session.Dispose()
	}
} 
catch
{
	Write-Host "Error: $($_.Exception.Message)"
}

Stop-Transcript


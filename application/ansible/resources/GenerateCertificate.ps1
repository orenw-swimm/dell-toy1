param(
	[string] $adHostName,
	[string] $dsHostName
)

# Generate and install IIS Websites Certificate

$smhostName = hostname
$commonName = "/CN=$smhostName"
$sanString = "DNS:$smhostName,DNS:$adHostName,DNS:$dsHostName"
$opensslConfig = @"
[req]
distinguished_name=req
req_extensions=v3_req

[v3_req]

[SAN]
subjectAltName=$sanString
keyUsage=digitalSignature,keyEncipherment,dataEncipherment,keyAgreement,keyCertSign
extendedKeyUsage=serverAuth,clientAuth
"@

$opensslConfigPath = New-TemporaryFile
$opensslConfig | Out-File -FilePath $opensslConfigPath.FullName -Encoding ASCII

$vmKey = & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" req `
	-new `
	-newkey `
	rsa:2048 `
	-days 1825 `
	-x509 `
	-nodes `
	-subj "$commonName" `
	-keyout "XMProCertificate.pem" `
	-out "XMProCertificate.cert" `
	-config $opensslConfigPath.FullName `
	-extensions SAN > $null 2>&1
$vmCert = & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" pkcs12 `
	-export `
	-out "XMProCertificate.pfx" `
	-inkey "XMProCertificate.pem" `
	-in "XMProCertificate.cert" `
	-name $smhostName `
	-passout pass:
Remove-Item -Path $opensslConfigPath.FullName

param (
    [string]$jsonFilePath = "streamhosts.json",
    [string]$sourcePath = "SHTemplate",
    [string]$templatePath = "$sourcePath\appsettings.template"
)

$jsonFilePath = Resolve-Path $jsonFilePath -ErrorAction Stop
Write-Host "JSON config file path: $jsonFilePath"
$sourcePath = Resolve-Path $sourcePath -ErrorAction Stop
Write-Host "Source Stream Host folder: $sourcePath"
#$sourcePath = Join-Path -Path $sourcePath -ChildPath "*"
$templatePath = Resolve-Path $templatePath -ErrorAction Stop
Write-Host "Source appsettings.template: $templatePath"
Write-Host ""

# Read the JSON content from the file
$jsonContent = Get-Content -Path $jsonFilePath | ConvertFrom-Json

$serverUrl = $jsonContent.serverUrl
$encryptionKey = $jsonContent.encryptionKey

Write-Host "Deploying Stream Hosts for..."
Write-Host "serverUrl: $serverUrl ..."
Write-Host "encryptionKey: $encryptionKey ..."
Write-Host ""

# Iterate through each item and write out the key and value
foreach ($collection in $jsonContent.collections) {

    $collectionId = $collection.id
    $collectionSecret = $collection.secret
    Write-Host "Collection: id: $collectionId, secret: $collectionSecret ..."
    Write-Host ""

    foreach ($gateway in $collection.gateways) {

        $deviceName = $gateway.deviceName
        #Copy SH
        Write-Host "Deploying Stream Host: $deviceName ..."
        $destinationFolder = Join-Path -Path ".\" -ChildPath $gateway.folderName
        $destinationPath = Resolve-Path $destinationFolder -ErrorAction SilentlyContinue
        if ($null -eq $destinationPath) {
            Write-Host "Destination folder '$destinationFolder' does not exist. Creating it ..."
            $destinationPath = New-Item -Path ".\" -Name $destinationFolder -ItemType Directory -Force
        }
        Write-Host "Copying to '$destinationFolder' ..."
        #Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force
        Robocopy.exe $sourcePath $destinationPath /E /COPYALL /NFL /NDL /NJH /NJS

        # Read the JSON content from the template file
        Write-Host "Loading appsettings.template ..."
        $template = Get-Content $templatePath | ConvertFrom-Json

        Write-Host "Populating appsettings ..."
        $template.xmpro.gateway.id = (New-Guid).Guid
        $template.xmpro.gateway.name = $deviceName
        $template.xmpro.gateway.collectionid = $collection.id
        $template.xmpro.gateway.secret = $collection.secret
        $template.xmpro.gateway.rank = $gateway.rank
        $template.xmpro.gateway.serverurl = $serverUrl
        $template.xmpro.xmcryptography.tripleDES.key = $encryptionKey

        $destinationPath = Join-Path -Path $destinationFolder -ChildPath "appsettings.json"
        # Convert the modified JSON back to a string
        $appsettingsjson = ConvertTo-Json -InputObject $template -Depth 10
        Set-Content -Path $destinationPath -Value $appsettingsjson

        Write-Host "Saving appsettings to $destinationPath ..."

        #Create Service
        Write-Host "Creating Stream Host service: XMPro Stream Host - $deviceName ..."
        $binarypath = Join-Path -Path $destinationFolder -ChildPath "XMIoT.Gateway.Host.Service.dll"
        $binarypath = Resolve-Path $binarypath -ErrorAction Stop
        $dotnetpath = "C:\Program Files\dotnet\dotnet.exe"

        $params = @{
            Name = "XMPro Stream Host - $deviceName"
            BinaryPathName = "$dotnetpath ""$binarypath"" action:run"
            DisplayName = "XMPro Stream Host - $deviceName"
            StartupType = "Automatic"
            Description = "XMPro Stream Host"
          }
        New-Service @params -ErrorAction SilentlyContinue
        Restart-Service -Name $params.Name

        Write-Host "End - Deploying Stream Host: $deviceName"
        Write-Host ""
    }
}

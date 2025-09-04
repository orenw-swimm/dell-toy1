﻿##
## This script runs via an ARM Microsoft.Resources/deploymentScripts called "UpdateDatabase"
##
## Script execution runs within a Container Instance running Linux
##
## The Container Instance environment is created by the ARM deployment script and attaches
## a dedicated Storage Account for the purpose of the running the script.
##

param(
	[string] $targetServerName,
	[string] $targetUser,
	[string] $targetPassword,
	[string] $DSUrl,
	[string] $ADUrl,
	[string] $AIUrl,
	[string] $NBUrl,
	[string] $CompanyName,
	[string] $FirstName,
	[string] $LastName,
	# [string] $UserName,
	[string] $Email,
	[string] $CompanyAdminPassword,
	[string] $SiteAdminPassword,
	[string] $EnableAi,
	[string] $smDbMigrationsExeFilePath = ".\XMIdentity.Database.Console.exe",
	[string] $dsDbMigrationsExeFilePath = ".\XMIoT.Database.Console.exe",
	[string] $adDbMigrationsExeFilePath = ".\AppDesigner.Database.Console.exe",
	[string] $aiDbMigrationsExeFilePath = ".\AIDesigner.Database.Console.exe"
)

###############################################################
# Install required powershell modules
###############################################################
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name SqlServer -RequiredVersion 21.1.18256 -AllowClobber

###############################################################
# Perform database migrations
###############################################################
$smConnectionString = "Data Source=tcp:{0};Initial Catalog=SM;User ID={1};Password={2}" -f $targetServerName, $targetUser, $targetPassword
& $smDbMigrationsExeFilePath `
	--dbConnectionString $smConnectionString `
	--companyName $CompanyName `
	--companyAdminFirstName $FirstName `
	--companyAdminSurname $LastName `
	--companyAdminEmailAddress $Email `
	--adProductUrl $ADUrl `
	--dsProductUrl $DSUrl `
	--aiProductUrl $AIUrl `
	--xmproNotebookProductUrl $NBUrl `
	--companyAdminPassword $CompanyAdminPassword `
	--siteAdminPassword $SiteAdminPassword `
	--enableAiProduct $enableAI = [System.Convert]::ToBoolean($EnableAi)


$dsConnectionString = "Data Source=tcp:{0};Initial Catalog=DS;User ID={1};Password={2}" -f $targetServerName, $targetUser, $targetPassword
& $dsDbMigrationsExeFilePath `
	--dbConnectionString $dsConnectionString


$adConnectionString = "Data Source=tcp:{0};Initial Catalog=AD;User ID={1};Password={2}" -f $targetServerName, $targetUser, $targetPassword
& $adDbMigrationsExeFilePath `
	--dbConnectionString $adConnectionString `
	--dataStreamDesignerUrl $DSUrl

if([System.Convert]::ToBoolean($EnableAi)) {
	$aiConnectionString = "Data Source=tcp:{0};Initial Catalog=AI;User ID={1};Password={2}" -f $targetServerName, $targetUser, $targetPassword
	& $aiDbMigrationsExeFilePath `
		--dbConnectionString $aiConnectionString `
}

###############################################################
# Output vars to the ARM template to use in subsequent steps
###############################################################

$DeploymentScriptOutputs = @{}

# Get the Stream Host connection profile
$sql = "SELECT [Id] FROM Company WHERE Name = '{0}'"
$company = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f $CompanyName)
$companyId = $company.Id
$DeploymentScriptOutputs['CompanyId'] = $company.Id

Write-Output "Company"
Write-Output $company  | Format-Table

$sql = "SELECT TOP 1
			[Id],
			[Secret],
			[Value] as [EncryptionKey]
		FROM [dbo].[EdgeContainer]
			INNER JOIN [dbo].[XMCompanySetting] ON [Company] = [CompanyId]
		WHERE
			[CompanyId] = '{0}'
			AND [Name] = 'Default'
			AND [SettingId] = (SELECT [Id] FROM [dbo].[XMSetting] WHERE [Name] = 'EncryptionKey')"
$dsConnectionProfile = Invoke-Sqlcmd -ConnectionString $dsConnectionString -Query ($sql -f $companyId)

Write-Output "DS Connection Profile"
Write-Output $dsConnectionProfile  | Format-Table

$DeploymentScriptOutputs['CollectionId'] = $dsConnectionProfile.Id
$DeploymentScriptOutputs['CollectionSecret'] = $dsConnectionProfile.Secret
$DeploymentScriptOutputs['DSEncryptionKey'] = $dsConnectionProfile.EncryptionKey

# Get the products ids and keys
$sql = "SELECT
			LOWER(convert(nvarchar(50), Product.[Id])) as [Id],
			[Key]
		FROM Product
			INNER JOIN ProductKey on [ProductId] = Product.[Id]
		WHERE
			Name = '{0}'"
$smProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'XMPro')
$dsProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'Data Stream Designer')
$adProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'App Designer')
$aiProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'AI')

Write-Output "SM"
Write-Output $smProduct | Format-Table
Write-Output "DS"
Write-Output $dsProduct | Format-Table
Write-Output "AD"
Write-Output $adProduct | Format-Table
# Write-Output "AI"
# Write-Output $aiProduct | Format-Table

$DeploymentScriptOutputs['SMProductId'] = $smProduct.Id
$DeploymentScriptOutputs['SMProductKey'] = $smProduct.Key
$DeploymentScriptOutputs['DSProductId'] = $dsProduct.Id
$DeploymentScriptOutputs['DSProductKey'] = $dsProduct.Key
$DeploymentScriptOutputs['ADProductId'] = $adProduct.Id
$DeploymentScriptOutputs['ADProductKey'] = $adProduct.Key
# $DeploymentScriptOutputs['AIProductId'] = $aiProduct.Id
# $DeploymentScriptOutputs['AIProductKey'] = $aiProduct.Key

if ([System.Convert]::ToBoolean($EnableAi)) {
	$nbProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'XMPro Notebook')

	Write-Output "NB"
	Write-Output $nbProduct | Format-Table

	$DeploymentScriptOutputs['NBProductId'] = $nbProduct.Id
	$DeploymentScriptOutputs['NBProductKey'] = $nbProduct.Key
}

# Write Deployment Script Outputs to an output file
$DeploymentScriptOutputs | ConvertTo-Json | Set-Content -Path "deployment_script_outputs.txt"

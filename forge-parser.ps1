$WindowsModuleList = ("registry", "dsc")

# Create a pwsh object from the forge api call to registry module
$WebModuleResponse = Invoke-WebRequest "https://forgeapi.puppet.com/v3/releases?module=puppetlabs-" + $WindowsModuleList[0]

$WebModuleObject = ConvertFrom-Json -InputObject $WebModuleResponse.Content

# Get the name of the module
$ModuleName = $WebModuleObject.results."metadata"."name"[0]

# Date first version was created
$WebModuleObject.results."created_at"[-1]

# Days registry module has been on forge
#$DateCreated = $WebModuleObject.results."created_at"[-1].subString(0, 19)
$DateFirstOnForge = [datetime]::ParseExact($WebModuleObject.results."created_at"[-1].subString(0, 19),'yyyy-MM-dd HH:mm:ss',$null)

$TimeOnForge = NEW-TIMESPAN -End $DateFirstOnForge 
$DaysOnForge = $TimeOnForge.days

# Get a list of version numbers for the registry module
$VersionList = $WebModuleObject.results.version

# Get a list of downloads for the registry module in order from highest version to lowest version
$DownloadList = $WebModuleObject.results.downloads

# Number of total downloads of registry module over all versions
$TotalDownloads = ($WebModuleObject.results."downloads" | Measure-Object -Sum).sum

#String of downloads per version
[string]::Format($ModuleName + "`n")
for($i = 0;  $i -le $VersionList.length; $i++) {
  [string]::Format($VersionList[$i] + " " + $DownloadList[$i] + "`n")
}
[string]::Format("Total Downloads for puppetlabs-" + $ModuleName + " " + $TotalDownloads)

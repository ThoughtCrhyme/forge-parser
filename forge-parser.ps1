$WindowsModuleList = ("acl", "chocolatey", "dsc", "dsc_lite", "iis", "powershell", "reboot", "registry", "scheduled_task", "sqlserver", "wsus_client")

$FileContent = "Module Name,Latest Version(LV),Downloads of LV,Total Downloads,Days on Forge,LV Days on Forge,Total DL/Day,LV DL/Day`n"

foreach ($module in $WindowsModuleList) {
  # Create a pwsh object from the forge api call to registry module
  $WebModuleResponse = Invoke-WebRequest ("https://forgeapi.puppet.com/v3/releases?module=puppetlabs-" + $module)

  $WebModuleObject = ConvertFrom-Json -InputObject $WebModuleResponse.Content

  # Get the name of the module
  $ModuleName = $WebModuleObject.results."metadata"."name"[0]

  # Days registry module has been on forge
  $DateCreated = $WebModuleObject.results."created_at"[-1].subString(0, 19)
  $LVDateCreated = $WebModuleObject.results."created_at"[0].subString(0, 19)
  $DateFirstOnForge = [datetime]::ParseExact($DateCreated,'yyyy-MM-dd HH:mm:ss',$null)
  $LVDateFirstOnForge = [datetime]::ParseExact($LVDateCreated,'yyyy-MM-dd HH:mm:ss',$null)

  $TimeOnForge = NEW-TIMESPAN -Start $DateFirstOnForge 
  $LVTimeOnForge = NEW-TIMESPAN -Start $LVDateFirstOnForge 
  $DaysOnForge = $TimeOnForge.days
  $LVDaysOnForge = $LVTimeOnForge.days

  # Get a list of version numbers for the registry module
  $VersionList = $WebModuleObject.results.version
  $LatestVersion = $VersionList[0]

  # Get a list of downloads for the registry module in order from highest version to lowest version
  $DownloadList = $WebModuleObject.results.downloads
  $LVDownloads = $DownloadList[0]

  # Number of total downloads of registry module over all versions
  $TotalDownloads = ($WebModuleObject.results."downloads" | Measure-Object -Sum).sum

  $DownloadsPerDay =  [math]::Round($TotalDownloads / $DaysOnForge)
  $LVDownloadsPerDay =  [math]::Round($LVDownloads / $LVDaysOnForge)

  $FileContent += ($ModuleName + "," + $LatestVersion + "," + $LVDownloads + "," + $TotalDownloads + "," + $DaysOnForge + "," + $LVDaysOnForge + "," + $DownloadsPerDay + "," + $LVDownloadsPerDay + "`n")
}
$FileContent | Out-File -FilePath .\Report.csv

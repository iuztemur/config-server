#region Set Parameters
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"
        
$env:PodePort ??= 8085
$env:ThreadCount ??= 10
$config = Get-Content -Path .\config.json | ConvertFrom-Json
#endregion

#region Uninstall/Install Required Modules
$config.requiredModules | ForEach-Object {
    Uninstall-Module -Name $_.Name -Force -AllVersions -ErrorAction SilentlyContinue
    Install-Module -Name $_.Name -RequiredVersion $_.Version -Force -AllowClobber -Repository $_.Repository
}
#endregion

Start-PodeServer -Threads $env:ThreadCount {
    Import-PodeModule -Name "powershell-yaml"
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging
    Restore-PodeState -Path './state.json'
    Add-PodeEndpoint -Address * -Port $env:PodePort -Protocol Http
    
    Add-PodeSchedule -Name 'get-repo' -Cron '@minutely'  -FilePath ./schedules/get-repo.ps1
    Add-PodeSchedule -Name 'get-configs' -Cron '@minutely' -FilePath ./schedules/get-configs.ps1
    Add-PodeSchedule -Name 'get-routes' -Cron '@minutely'  -FilePath ./schedules/get-routes.ps1
    Add-PodeSchedule -Name 'new-routes' -Cron '@minutely' -FilePath ./schedules/new-routes.ps1
    Add-PodeSchedule -Name 'remove-routes' -Cron '@minutely' -FilePath ./schedules/remove-routes.ps1
    
}

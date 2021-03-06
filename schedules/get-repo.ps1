{
    param($Event)
    try {
        
        $ProgressPreference = "SilentlyContinue"
        $VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"
        
        $fileName = "get-repo"
        $env:repo ??= "https://github.com/haidouks/configs.git"
        $configPath = Join-Path -Path (Get-PodeServerPath) -ChildPath "configs"
        (Test-Path -Path $configPath) ? "" : (New-Item -Path $configPath -ItemType Directory)
        $repoPath = Join-Path -Path $configPath -ChildPath "repo"
        

        if(Test-Path $repoPath) {
            Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Starting to pull changes from $env:repo to: $repoPath"
            git -C $repoPath pull --quiet
            $exitCode = $LASTEXITCODE
            if ($exitCode) {
                Throw "$(Get-Date -Format "yyyyMMddHHmmssfff") Unable to pull repo: $($env:repo), exit code: $exitCode" 
            }
        }
        else {
            Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Starting to clone $env:repo to: $repoPath"
            git clone $env:repo $repoPath --quiet
            $exitCode = $LASTEXITCODE
            if ($exitCode) { 
                Throw "$(Get-Date -Format "yyyyMMddHHmmssfff") Unable to clone repo: $($env:repo), exit code: $exitCode" 
            }

        }
        Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Saved repo to $configPath"   
    }
    catch {
        $exception = $($PSItem | select-object * | Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$fileName __ $exception"
    }
    finally {
        Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Invoking get configs" 
        Invoke-PodeSchedule -Name 'get-configs'
    }
}

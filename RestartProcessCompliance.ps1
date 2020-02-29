$ServiceName         = "ProcessCompliance"
$ProcessName         = "tomcat8"
$WaitAfterTerminate  = 30 # 30 seconds
$ShutdownTimeout     = 180 # 180 seconds 

function Stop-ServiceWithTimeout ([string] $name, [int] $timeoutSeconds) {
    $timespan = New-Object -TypeName System.Timespan -ArgumentList 0,0,$timeoutSeconds
    
    $ServiceNeedsToBeStopped = $true

    $svc = Get-Service -Name $name
    
    if ($svc -eq $null) 
    { 
        Write-Error "The Service Name is not $($name)"
        return $false 
    }

    if ($svc.Status -eq [ServiceProcess.ServiceControllerStatus]::Stopped) 
    { 
        Write-Host "Service is already stopped"
        $ServiceNeedsToBeStopped = $false 
    }

    if ($ServiceNeedsToBeStopped) {
        $svc.Stop()
        try {
            $svc.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Stopped, $timespan)
        }
        catch [ServiceProcess.TimeoutException] {
            Write-Warning "Timeout stopping service $($svc.Name)"
            Write-Warning "Terminating process $($ProcessName)"
            Stop-Process -Name $ProcessName -Force

            sleep -Seconds 30    
        }
    }

    Write-Output "Starting Service: $($name)"
    $svc.Start();
}

Stop-ServiceWithTimeout $ServiceName $ShutdownTimeout
<#
.SYNOPSIS
Invoke given $block in given amount of threads, $loop containing given $arguments

.EXAMPLE

Invoke-parallel -threads 3 -loop "jack","jane" -block { param($name) Write-Output "hello, $name" }

hello, jack
hello, jane

.EXAMPLE


Invoke-parallel -threads 3 -loop "jack","jane" -arguments 10,11 -block { param($name, $arguments) Write-Output ("hello, {0} {1}" -f $name, $arguments[0]) }

hello, jack 10
hello, jane 10

#>
param(
    [int]$threads = 3,
    $block,
    $loop,
    $arguments,
    $message = "Running"
    )


function Invoke-ParallelOperation($threads,$block,$loop,$arguments, $message = "Running threads") {
    $path = $script:MyInvocation.MyCommand.Path
    
    $dir = Split-Path $path
    $initial = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    Get-Module | Select -ExpandProperty Path | % {
        $initial.ImportPSModule($_)
    }

    $pool = [RunspaceFactory]::CreateRunspacePool(1,$threads,$initial,$Host)
    $pool.ApartmentState = "STA"
    $pool.Open()
    $jobs = @()
    $fail = $null
    $loop | % {
        $pipeline = [Powershell]::create().AddScript($block)
        $pipeline = $pipeline.AddArgument($_)
        $pipeline = $pipeline.AddArgument($arguments)
        $pipeline.RunspacePool = $pool
        $jobs += New-Object PSObject -property @{
            Pipe = $pipeline
            Result = $pipeline.BeginInvoke() 
            Running = $true
        }        
    }
    $count = 0
    do {
        $jobs | ? { $_.Result.IsCompleted -eq $true -and $_.Running} | % {
            try {
                Write-Output $_.Pipe.EndInvoke($_.Result)
            }  catch [exception] {
                if (!($_ -match "runspace pool")) {
                    $fail = $_
                    Write-Host -ForegroundColor Red $_
                }
                $fail = $true
                $pool.Close()
                $pipeline.Stop()
            } finally {
                $count += 1
            }

            $_.Running = $false
        }
        $allCount = $loop.Count
        if (!$loop.Count) {
            $allCount = 1
        }
        $comp = [int](($count/[float]$allCount)*100)

        Write-Progress -Activity $message -PercentComplete $comp -Status ("Executing {0}%.." -f $comp)    

    } while (!$fail -and $count -ne $allCount)
    Write-Progress -Activity $message -Completed -Status "Done"
    if ($fail) {
        throw $fail
    }
}


Invoke-ParallelOperation -threads:$threads -block:$block -arguments:$arguments -message:$message -loop:$loop
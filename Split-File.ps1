<#
.SYNOPSIS

Split a large file into subparts

.PARAMETER chunks

How many parts

.PARAMETER out

output directory

.PARAMETER file

File

#>
param(
    [parameter(Mandatory=$true)]
    [int]$chunks,
    [parameter(Mandatory=$false)]
    [string]$out,
    [parameter(Mandatory=$true)]
    $file    
)
$writer = $null
$data = $null
try {
    if (!(Test-Path $file)) {
        throw "File $file required"
    }
    $ext = Get-ChildItem $file|select -expand extension
    $base = Get-ChildItem $file|select -expand Basename
    $currPath = pwd|select -expand path
    if ($out -and (Test-Path $out)) {
        $currPath = $out
    }

    $len = Get-Childitem $file | Select -Expand Length

    $lineCount = 0
    gc $file -ReadCount 3000|%{$lineCount += $_.Length}

    $chunkSize = [Math]::ceiling($lineCount/$chunks)


    $counter = 0
    $chunk = 0
    $chunkFile = "$currPath\{0}_part_{1:D2}_{2}{3}" -f $base,($chunk+1),$chunks,$ext
    $chunkFile
    $writer = New-Object IO.StreamWriter ($chunkFile)

    [System.IO.FileStream] $dataStream = new-object System.IO.FileStream ((gci $file),[IO.FileMode]::Open, [System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite)
    [System.IO.StreamReader] $logFileReader = new-object System.IO.StreamReader ($dataStream)
    while (!($logFileReader.EndOfStream)) {
        $counter += 1
        $writer.WriteLine($logFileReader.ReadLine())
        if ($counter -ge $chunkSize) {
            $chunk += 1
            $chunkFile = "$currPath\{0}_part_{1:D2}_{2}{3}" -f $base,($chunk+1),$chunks,$ext
            $writer.Close()
            $writer = New-Object IO.StreamWriter ($chunkFile)
            $chunkFile        
            $counter = 0
        }

    }
    $count 
} finally {
    if ($writer) { $writer.Close()}
    if ($data) {$data.Close() }
}


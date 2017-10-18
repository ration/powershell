<#
.SYNOPSIS

Find text from files and hilight findings

.PARAMETER pattern

Text to search

.PARAMETER filter

Include only  files with given pattern

.PARAMETER not

Exclude files that match given pattern

.PARAMETER caseSensitive

Case sensitivity in search

.PARAMETER vgrep

Exclude match if the matching line contains this pattern

.PARAMETER grep 

Further limit findings 

.PARAMETER open

Open findings in editor

.PARAMETER l

List filenames only

.PARAMETER p

List first level directories only

.PARAMETER pipe

Pipe output (dont use Write-Host)

.EXAMPLE

Find 'Jack' from the current directory (and all subdirectories) and hilight the matches

Find-String -pattern Jack

.EXAMPLE

Find 'Jack' but exclude files that have zip in the name

Find-String -pattern Jack -not zip

.EXAMPLE

Find 'Jack' but exclude if the matching line has 'Jim'

Find-String -pattern Jack -vgrep Jim

.EXAMPLE

Find 'Jack' and only list matching files

Find-String -pattern Jack -l

.EXAMPLE

Find 'Jack' but also need 'Jim'

Find-String -pattern Jack -grep Jim

#>

param ( 
    [Parameter(Mandatory=$true)]
    [string[]] $pattern,
    [string] $filter = "*.*",
    [switch] $recurse = $true,
    [switch] $caseSensitive = $false,
    [string] $not = $null,
    [string[]] $vgrep = @(),
    [string[]] $grep = @(),
    [switch] $o = $false,
    [switch] $l = $false,
    [switch] $open,
    [switch] $p = $false,
    [switch] $pipe
)

$editor = "emacsclient.exe";
$params = "-n";



function Skip([string]$inputText,$include,$exclude) {
    $exclude | foreach {
        if ($inputText.ToLower().Contains($_.ToLower())) {
            return $true;
        }
    }
    $include | foreach {
        if (!$inputText.ToLower().Contains($_.ToLower())) {
            return $true;
        }
    }
    return $false;
}


function Get-Match([string]$inputText, [System.Text.RegularExpressions.Regex]$regex) {
    $index = 0;
    $output = ""
    while ($index -lt $inputText.length) {
        $match = $regex.Match($inputText,$index);
        if ($match.Success -and $match.Length -gt 0) {
            $output += $inputText.SubString($index,$match.Index - $index) 
            $output +=  $match.Value.ToString()
            $index = $match.Index + $match.Length
        } else {
            $output += $inputText.SubString($index)
            $index = $inputText.Length
        }
    }
    return $output
}

function Write-HostAndHiglightPattern([string]$inputText, [System.Text.RegularExpressions.Regex]$regex) {
    $index = 0;
    while ($index -lt $inputText.length) {
        $match = $regex.Match($inputText,$index);
        if ($match.Success -and $match.Length -gt 0) {
            Write-Host $inputText.SubString($index,$match.Index - $index) -nonewline
            Write-Host $match.Value.ToString() -ForegroundColor Red -nonewline
            $index = $match.Index + $match.Length
        } else {
            Write-Host $inputText.SubString($index) -nonewline
            $index = $inputText.Length
        }
    }
}



$regexPattern = $pattern;
if (!$caseSensitive) { 
    $regexPattern = "(?i)$regexPattern";
}
$regex = New-Object System.Text.RegularExpressions.Regex $regexPattern;

$last = ""

$rootpattern = "("+[Regex]::Escape($pwd.Path)+"\\.*?(?=\\))"
$roots = New-Object System.Collections.Generic.HashSet[String]

Get-ChildItem -recurse:$recurse -filter:$filter | Where-Object { !($not -and $_.Name.Contains($not)) } | 
    Select-String -caseSensitive:$caseSensitive -pattern:$pattern |
    foreach {
        if (!(Skip -include $grep -exclude $vgrep -inputText $_)) {
            if ($last -ne $_.Path) {
                $last = $_.Path
                if (!$l -and !$p) {
                    if ($pipe) {
                        Write-Output "`n"
                    } else {
                        Write-Host
                    }   
                }
                if ($p) {
                    # This could be optimized by handling first level directories separately and terminate on match
                    if ($_.Path -match $rootpattern) {
                        $key = $Matches[1]
                        if ($roots.Add($key)) {
                            if ($pipe) {
                                Write-Output $_.Path
                            } else {
                                Write-Host -ForeGroundColor Green $Matches[1]
                            }   
                        }
                    }
                } else {
                    if ($pipe) {
                        Write-Output  $_.Path
                    } else {
                        Write-Host -ForeGroundColor Green $_.Path
                    }   
                }
            }
            elseif (!$l -and !$p) {
                if ($pipe) {
                    Get-Match -inputText $_.Line -regex $regex | Write-Output
                } else {
                    Write-Host "($($_.LineNumber)): " -nonewline
                    Write-HostAndHiglightPattern -inputText $_.Line -regex $regex
                    Write-Host
                }   
            }
            if ($open) {
                <# Might be very emacs specific so.. #>
                . $editor $params +$($_.LineNumber) $_.Path
            }
        }
    }



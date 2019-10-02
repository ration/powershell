<#
.SYNOPSIS

Conveniance script for Find-String - finds in java files

.EXAMPLE

jack someinterface -grep implements

Find someinterface implementations (assuming on same line)

#> 
param (
    [parameter(Mandatory=$true)]
    [string] $pattern ="",
    [string] $filter = "*.*",
    [switch] $recure = $true,
    [switch] $caseSensitive = $false,
    [string] $not = "<___________^^________>",
    [string[]] $vgrep = @(),
    [string[]] $grep = @(),
    [switch] $o = $false,
    [switch] $l = $false,    
    [switch] $open,
    [switch] $p = $false,
    [switch] $pipe = $false
)

Find-String -filter $filter -pattern $pattern -not:$not -o:$o -open:$open -vgrep $vgrep -grep $grep -l:$l -p:$p -pipe:$pipe


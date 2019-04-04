<#
.SYNOPSIS

Find files with given pattern

.EXAMPLE

Find all filenames that contain "jack"

f jack

#>

param (      
    [switch] $open = $false, 
    [switch]$goto
)

$editor = "C:\ProgramData\chocolatey\bin\emacsclient.exe"

[string] $exclude = "(\.hg)"

if ($open) {
    $files = Get-ChildItem -ErrorAction SilentlyContinue -path . -recurse -filter "*$args*" | ? { $_.FullName -notmatch $exclude } | Select-Object -Property FullName -Expand FullName
    . $editor -n $files
} elseif ($goto) {
    Get-ChildItem -ErrorAction SilentlyContinue -path . -recurse -filter "*$args*" |  ? { $_.FullName -notmatch $exclude } | Select -First 1 -ExpandProperty DirectoryName | cd

} else {
    Get-ChildItem -ErrorAction SilentlyContinue -path . -recurse -filter "*$args*" |  ? { $_.FullName -notmatch $exclude } | Select-Object -Property FullName | Format-List *
}

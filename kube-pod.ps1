<#
.SYNOPSIS

Start a shell to running kube container

.PARAMETER pattern

Matching pattern for selecting pod, e.g. nginx
#>
param (
    [Parameter(Mandatory=$true)]
    [string] $pattern,
    [string] $opts = "--namespace pipeline1"
)

$kube_cmd = "kubectl"
$kube_params="kubectl $opts get pods --no-headers -o custom-columns=':metadata.name'"
(Invoke-Expression -Command $kube_params  -OutVariable $str | Select-String -Pattern $pattern |out-string).Trim()

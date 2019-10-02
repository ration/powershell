<#
.SYNOPSIS

Start a shell to running kube container

.PARAMETER pattern

Matching pattern for selecting pod, e.g. nginx
#>
param ( 
    [Parameter(Mandatory=$true)]
    [string] $pattern,
    [switch] $f
)

$pod = kube-pod $pattern
$follow = ""
if ($f) {
    $follow = "-f"
}
. kubectl logs --tail=10000 $follow $pod


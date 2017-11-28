<#
.SYNOPSIS

Copy current path into clipboard

#>
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$pwd.Path | % { [Windows.Forms.Clipboard]::SetText($_)  }
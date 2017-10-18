<#
.SYNOPSIS

Copy current path into clipboard

#>
$pwd.Path | % { [Windows.Forms.Clipboard]::SetText($_)  }

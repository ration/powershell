<#
.SYNOPSIS 

Quick hack to jump through dirs 

.EXAMPLE

g dl

Goes to Downloads

.EXAMPLE

g jack

Goes to directory that contains jack, or gives a list of options

#>


<# Add whatever shortcuts you want here #>
$gotos = @{
    "temp" = "C:\temp";
    "hg" = "C:\tatu\hg";
    "pf" = "C:\Program Files (x86)";
    "pf64" = "C:\Program Files";
    "dl" = "$HOME\Downloads";
    "log" = "$HOME\log\";
	"git" = "c:\tatu\git";
}

if ($args.length -ge 1) {
   <# Allow tabbing #>
   $pattern = $args[0] -replace "\.\\",""
   if ($pattern -eq "l") {
       cd (Get-ChildItem | ? { $_.PSIsContainer } | Sort-Object -Property LastWriteTime|select -last 1)
       exit
   }

   <# Quick gotos #>
   if ($gotos.Contains($pattern)) {
        cd $gotos.Get_Item($pattern); exit;
   }
   

   <# Pattern lookup in current dir #>
   
   $dirs = dir "*$pattern*" | ?{$_.PSIsContainer}
   if ($dirs.length -gt 1) {
      for ($i = 0; $i -lt $dirs.length; $i++) {
      	  write-host "(" $i ")" $dirs[$i] 
      }
      $sel = read-host "?"
      if ($sel|select-string -pattern "\d+" -quiet) {
          cd $dirs[$sel]
      }
      exit
   } 

   $cur = pwd
   dir "*$pattern*" | select -First 1| select-object -exp name | cd
  
}


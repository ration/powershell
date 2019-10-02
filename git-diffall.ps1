

git diff --name-only "$args" | % {
    $cmd = "git"
    $arguments = "difftool --no-prompt $_"
    if ($args) {
        $arguments = "difftool '$args' --no-prompt $_"
    }
    write-host $arguments
    Start-Process -NoNewWindow $cmd $arguments
}
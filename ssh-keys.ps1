# Import-Module 'C:\tatu\Apps\posh-git\src\posh-git.psd1'
$already = ps ssh-agent -ErrorAction SilentlyContinue
if (!$already) {
    $a = . ssh-agent | Out-String
    $a | Out-File $env:TEMP\ssh_agent.pid
    $agent = $a | Select-String -Pattern "SSH_AGENT_PID=(\d+);"
    $agent = $a | Select-String -Pattern "SSH_AGENT_PID=(\d+);"
    if ($agent) {
        Write-Host "Loading ssh agent"
        $socket = $a | Select-String -Pattern "SSH_AUTH_SOCK=(.*?);" 
        $SSH_AGENT_PID = $agent.Matches.Groups[1].Value
        $SSH_AGENT_SOCKET = $socket.Matches.Groups[1].Value
        
        $env:SSH_AUTH_SOCK=$SSH_AGENT_SOCKET
        $env:SSH_AGENT_PID=$SSH_AGENT_PID
        ssh-add 
    }

} else {
    $a = Get-Content $env:TEMP\ssh_agent.pid
    $agent = $a | Select-String -Pattern "SSH_AGENT_PID=(\d+);"
    $agent = $a | Select-String -Pattern "SSH_AGENT_PID=(\d+);"
    if ($agent) {
        Write-Host "Loading ssh agent"
        $socket = $a | Select-String -Pattern "SSH_AUTH_SOCK=(.*?);" 
        $SSH_AGENT_PID = $agent.Matches.Groups[1].Value
        $SSH_AGENT_SOCKET = $socket.Matches.Groups[1].Value
        
        $env:SSH_AUTH_SOCK=$SSH_AGENT_SOCKET
        $env:SSH_AGENT_PID=$SSH_AGENT_PID
    }
}

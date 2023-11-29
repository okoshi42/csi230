#Login to a remote ssh server
$address = Read-Host -Prompt "please enter an IP address to connect to"
$cred = Read-Host -Prompt "please enter credentials"
New-SSHSession -ComputerName $address -Credential (Get-Credential $cred)
$the_cmd = read-host -Prompt "Please enter a command"
(Invoke-SSHCommand -index 0 $the_cmd).Output

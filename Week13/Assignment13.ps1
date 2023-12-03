$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules','https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

foreach ($u in $drop_urls) {

$temp = $u.split("/")
$file_name = $temp[-1]

if(Test-Path $file_name) {
    continue
    }
else {
    Invoke-WebRequest -Uri $u -OutFile $file_name
    }
}



$input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
Select-String -Path $input_paths -Pattern $regex_drop |
ForEach-Object {$_.Matches} |
ForEach-Object {$_.Value } | Sort-Object | Get-Unique |
Out-File -FilePath "ips-bad.tmp"
create-Ruleset
Function create-Ruleset{
$ruleset = Read-Host -Prompt "Enter [I] for iptables, [W] for windows firewall, or [E] to Exit."
switch($ruleset){
    I{(Get-Content -Path ".\ips-bad.tmp") | % {$_ -replace "^","iptables -A INPUT -s" -replace "$", " -j DROP"} |
    Out-File -FilePath "iptables.bash"
    create-Ruleset}
    
    W{
    $message=(Get-Content -Path ".\ips-bad.tmp") | % {$_ -replace "^","netsh advfirewall firewall add rule name=`"BLOCK IP ADDRESS - " -replace "$", "`" dir=in action=block remoteip= $_"} |
    Out-File -FilePath "netsh.bash"
    create-Ruleset}
    E{}
    default{ create-Ruleset
    }
}
}

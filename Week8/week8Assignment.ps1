#storyline: reveiw the security event log

#directory to save files
$myDir= "C:\Users\jokos\csi230\Week8"
#list all the avvailable windows event logs
Get-EventLog -list 

#create a prompt to allow user to select the log to use
$readLog = Read-host -Prompt "Please select a log to review from the list above"
$msgSearch = Read-Host -Prompt "Please choose a word or phrase to search for"

#print the results for the log
Get-EventLog -LogName $readLog -Newest 40 | where {$_.Message -ilike "*$msgSearch*"} | export-csv -NoTypeInformation -Path "C:\Users\jokos\csi230\Week8\securityLogs.csv"

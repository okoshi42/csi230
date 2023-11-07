#storyline: view the event log, check for valid log, print result

function select_log(){
    cls
    #list all event log
    $theLogs= Get-EventLog -list | select Log
    $theLogs|Out-Host

    #initialize array to store the logs
    $arrLog= @()
    foreach ($tempLog in $theLogs){
    $arrLog += $tempLog
    }
    $readLog = Read-Host -Prompt "Please enter a log from the list above or 'q' to quit the program"
    if($readLog -match "^[qQ]$"){
        break
    }
    log_check -logToSearch $readLog
}

function log_check(){
    Param([string]$logToSearch)
    $theLog = "^@{Log="+$logToSearch+"}$"
    if($arrLog -match $theLog){
        Write-Host -BackgroundColor Green -ForegroundColor White "Please wait, it may take a few moments to retrieve the log entries."
        sleep 2
        view_log -logToSearch $logToSearch
    }
    else {
        Write-Host -BackgroundColor Red -ForegroundColor White "The log specified doesn't exist"
        sleep 2
        select_log
    }
}
function view_log(){
    cls
    Get-EventLog -LogName $logToSearch -Newest 10 -After "1/18/2020"
    Read-Host -Prompt "press enter when you are done"
    select_log
}

select_log

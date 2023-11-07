#storyline: view the event log, check for valid log, print result

function select_service(){
    cls
     $readService = Read-Host -Prompt "Please specify [R]unning, [S]topped, or [A]ll services, or 'q' to quit the program"
    if($readService -match "^[qQ]$"){
        break
    }
    if($readService -match "^[rR]$"){
     $theServices= Get-Service | Where { $_.Status -eq "Running"}
    }
    elseif($readService -match "^[sS]$"){
    
     $theServices= Get-Service | Where { $_.Status -eq "Stopped"}
    }
    elseif($readService -match "^[aA]$"){
      $theServices= Get-Service 
    }
    else{
        Write-Host -BackgroundColor Red -ForegroundColor White "invalid response"
        sleep 2
        select_service
    }
    #list all event log
   
    $theServices|Out-Host
     Read-Host -Prompt "press enter when you are done"
    select_service

   }
   select_service
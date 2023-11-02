Start-Process C:\Windows\System32\calc.exe 
Wait-Event -SourceIdentifier "ProcessStarted" -Timeout 3
Stop-Process -Name "CalculatorApp"
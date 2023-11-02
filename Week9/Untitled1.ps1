#use the get-WMI cmdlet to find network adapter information
Get-WmiObject -Class win32_NetworkAdapterConfiguration | select ServiceName, IPAddress, DefaultIPGateway, DNSDomain, DHCPServer
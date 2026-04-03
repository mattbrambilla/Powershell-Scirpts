#Connect to Exchange Online
Connect-ExchangeOnline

#Get All Rooms and Their Auto Release Status
$rooms = Get-Mailbox -ResultSize unlimited | ?{$_.ResourceType -eq "Room"} | Sort-Object -Property name

foreach($room in $rooms){
    
    $enableAutoRelease = Get-CalendarProcessing $room.Name

    if($enableAutoRelease.EnableAutoRelease){
        Write-Host ("$($room.Name): $($enableAutoRelease.EnableAutoRelease)") -ForegroundColor Green
    }
    else{
        Write-Host ("$($room.Name): $($enableAutoRelease.EnableAutoRelease)")
    }

}

#Enable Auto Release For a Room
Set-CalendarProcessing `
    -Identity "youremail@provider.com" `
    -EnableAutoRelease $true `
    -AutomateProcessing AutoAccept

#Disable Auto Release For a Room
Set-CalendarProcessing `
    -Identity "youremail@provider.com" `
    -EnableAutoRelease $false `
    -AutomateProcessing AutoAccept

#Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
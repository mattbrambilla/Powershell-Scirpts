#Mi connetto a Exchange
Connect-ExchangeOnline
#Cerco tutte le shared mailbox che non hanno nessun utente in Read and manage (Full Access)
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | ? { (Get-MailboxPermission $_.UserPrincipalName | ? {$_.User -ne "NT AUTHORITY\SELF"}).Count -eq 0 }
#Mantengo aperta la sessione powershell
Pause
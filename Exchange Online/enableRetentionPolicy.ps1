#This script can help you enable the Retention Policy option for a specific email address in Exchange Online.
#Feel free to enhance the script and redistribute it in accordance with the GNU Public License.

#First of all connect to exchange online
Connect-ExchangeOnline

#Select your mailbox and retriew info
Get-mailbox [Your Mailbox adress here] |fl

#Enable the Retention Policy
Set-Mailbox [Your Mailbox adress here] -RetentionHoldEnabled $true
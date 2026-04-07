# Inizializzo le variabili
$SharePointURL = " https://yoursite.sharepoint.com/" ;

# Mi connetto a SharePoint Online
Connect-SPOService -url $SharePointURL

# Recupero tutti i siti
$sites = Get-SPOSite -Limit All

# Specifica il nome del gruppo di sicurezza che vuoi impostare come amministratore del sito
$securityGroup = "nome-del-tuo-gruppo@dominio.onmicrosoft.com" # oppure l'object ID del gruppo

# Assegna il gruppo come amministratore a ogni sito
foreach ($site in $sites) {
    Write-Host "Assegnazione amministratore a: $($site.Url)"
    Set-SPOUser -Site $site.Url -LoginName $securityGroup -IsSiteCollectionAdmin $true
}

# Mi disconnetto da SharePoint Online
Disconnect-SPOService
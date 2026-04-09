# Initialize variables

$AdminURL = "https://contoso.sharepoint.com/"
$Admin1 = "admin1contoso@example.com"
$Admin2 = "admin2contoso@example.com"
$Admin3 = "admin3contoso@example.com"
  
# Connect to SharePoint Online
Connect-SPOService -Url $AdminURL
 
# Get all tenant sites
$Sites = Get-SPOSite -Limit All

# For each site, display the URL being processed and add the users as site collection administrators
foreach ($Site in $Sites) {
    Write-Host "Processing site: $($Site.Url)"
    Set-SPOUser -Site $Site.Url -LoginName $Admin1 -IsSiteCollectionAdmin $True
    Set-SPOUser -Site $Site.Url -LoginName $Admin2 -IsSiteCollectionAdmin $True
    Set-SPOUser -Site $Site.Url -LoginName $Admin3 -IsSiteCollectionAdmin $True
}

# Disconnect from SharePoint Online
Disconnect-SPOService
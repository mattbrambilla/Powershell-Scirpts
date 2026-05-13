<#
.SYNOPSIS
Bulk-add Site Collection Administrators to SharePoint Online team and communication sites.

.DESCRIPTION
Connects to SharePoint Online, retrieves all team and communication sites
(excluding system sites and OneDrive for Business), and adds one or more
accounts as Site Collection Administrators with optional logging to CSV.

.PARAMETER AdminUrl
SharePoint Admin Center URL (e.g. https://contoso-admin.sharepoint.com).

.PARAMETER AdminAccounts
One or more UPNs to add as Site Collection Administrators
(e.g. @("admin1@contoso.com", "admin2@contoso.com")).

.PARAMETER LogPath
Path for the results CSV log. Defaults to Desktop\SPO_AdminAdd_<timestamp>.csv.

.PARAMETER WhatIf
Show what would happen without making any changes.

.EXAMPLE
.\Bulk-Add-TenantSiteAdmins.ps1 -AdminUrl "https://contoso-admin.sharepoint.com" `
    -AdminAccounts @("admin@contoso.com")

.EXAMPLE
.\Bulk-Add-TenantSiteAdmins.ps1 -AdminUrl "https://contoso-admin.sharepoint.com" `
    -AdminAccounts @("admin1@contoso.com", "admin2@contoso.com") -WhatIf

.NOTES
Author        : Mattia Brambilla
Requires      : SharePoint Online Management Shell (Connect-SPOService)
Module        : Microsoft.Online.SharePoint.PowerShell
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$AdminUrl,

    [Parameter(Mandatory)]
    [string[]]$AdminAccounts,

    [string]$LogPath = (Join-Path $env:USERPROFILE "Desktop\SPO_AdminAdd_$(Get-Date -Format yyyyMMdd_HHmmss).csv"),

    [switch]$WhatIf
)

# Only process these site templates (team sites + communication sites)
$AllowedTemplates = @(
    "GROUP#0",                # Microsoft 365 Group-connected team site
    "STS#3",                  # Modern team site (no group)
    "SITEPAGEPUBLISHING#0"    # Communication site
)

$Results = [System.Collections.Generic.List[PSObject]]::new()

try {
    Write-Host "Connecting to SharePoint Online: $AdminUrl" -ForegroundColor Cyan
    Connect-SPOService -Url $AdminUrl

    Write-Host "Retrieving sites..." -ForegroundColor Cyan
    $AllSites = Get-SPOSite -Limit All -IncludePersonalSite $false
    $Sites = $AllSites | Where-Object { $_.Template -in $AllowedTemplates }

    Write-Host "Found $($AllSites.Count) total sites, $($Sites.Count) eligible (team/communication)." -ForegroundColor Yellow

    if ($Sites.Count -eq 0) {
        Write-Host "No eligible sites found. Exiting." -ForegroundColor Red
        return
    }

    $confirmed = $true
    if (-not $WhatFi) {
        $title = "Confirm bulk operation"
        $message = "Add $($AdminAccounts.Count) admin(s) to $($Sites.Count) sites?`nThis action cannot be undone."
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Proceed"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Cancel"
        $choice = $Host.UI.PromptForChoice($title, $message, @($yes, $no), 1)
        $confirmed = ($choice -eq 0)
    }

    if (-not $confirmed) {
        Write-Host "Operation cancelled by user." -ForegroundColor Yellow
        return
    }

    $totalOps = $Sites.Count * $AdminAccounts.Count
    $currentOp = 0

    foreach ($Site in $Sites) {
        Write-Progress -Activity "Adding Site Collection Administrators" `
            -Status "Processing: $($Site.Url)" `
            -PercentComplete (($currentOp / $totalOps) * 100)

        foreach ($Admin in $AdminAccounts) {
            $currentOp++
            Write-Progress -Activity "Adding Site Collection Administrators" `
                -Status "$Admin -> $($Site.Url)" `
                -PercentComplete (($currentOp / $totalOps) * 100)

            try {
                if ($PSCmdlet.ShouldProcess($Site.Url, "Add $Admin as Site Collection Admin")) {
                    Set-SPOUser -Site $Site.Url -LoginName $Admin -IsSiteCollectionAdmin $True
                    $Results.Add([PSCustomObject]@{
                        Site   = $Site.Url
                        Admin  = $Admin
                        Status = "OK"
                        Error  = ""
                    })
                }
            } catch {
                Write-Warning "Failed to add $Admin to $($Site.Url): $($_.Exception.Message)"
                $Results.Add([PSCustomObject]@{
                    Site   = $Site.Url
                    Admin  = $Admin
                    Status = "FAIL"
                    Error  = $_.Exception.Message
                })
            }
        }
    }

    Write-Progress -Activity "Adding Site Collection Administrators" -Completed

    if ($Results.Count -gt 0) {
        $Results | Export-Csv -Path $LogPath -NoTypeInformation -Encoding UTF8
        Write-Host "Results exported to: $LogPath" -ForegroundColor Green
    }

    $okCount = ($Results | Where-Object Status -eq "OK").Count
    $failCount = ($Results | Where-Object Status -eq "FAIL").Count
    Write-Host "Done. Succeeded: $okCount, Failed: $failCount" -ForegroundColor Green
}
catch {
    Write-Host "Fatal error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    if ((Get-PSSession | Where-Object { $_.ComputerName -like "*sharepoint*" })) {
        Disconnect-SPOService -Confirm:$false
        Write-Host "Disconnected from SharePoint Online." -ForegroundColor Cyan
    }
}

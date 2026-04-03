param (
    [string]$DomainName = "example.com",
    [array]$ExampleUsers = @(
        "user1@example.com",
        "user2@example.com",
        "user3@example.com",
        "user4@example.com",
        "user5@example.com"
    )
)

# Function to install and import modules if not present
function Ensure-Module {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Install-Module -Name $ModuleName -Force -AllowClobber
    }
    Import-Module $ModuleName -ErrorAction Stop
}

# Ensure that the modules are present and imported
Ensure-Module -ModuleName "MSOnline"
Ensure-Module -ModuleName "MicrosoftTeams"
Ensure-Module -ModuleName "AzureADPreview"

# Connections to various services
Write-Output "Logging in to Azure AD..."
Connect-AzureAD

Write-Output "Logging in to Microsoft Teams..."
Connect-MicrosoftTeams

Write-Output "Logging in to SharePoint Online..."
try {
    Connect-SPOService -Url https://example-admin.sharepoint.com
    Write-Output "Successfully connected to SharePoint Online."
} catch {
    Write-Output "Error connecting to SharePoint Online: $_"
    return
}

Write-Output "Logging in to MSOnline..."
Connect-MsolService

# Get the list of users for the specified domain
$users = Get-MsolUser -DomainName $DomainName -All

# Filter users based on the Example users list
$filteredUsers = $users | Where-Object { $ExampleUsers -contains $_.UserPrincipalName }

# Create an object to store the results
$teamResults = @()

# Get all teams
$teams = Get-Team

foreach ($team in $teams) {
    if ($null -eq $team.GroupId) {
        Write-Output "The team '$($team.DisplayName)' does not have a valid GroupId. Ignored."
        continue
    }

    $teamId = $team.GroupId
    $teamName = $team.DisplayName

    # Get members and owners of the team
    $teamUsers = Get-TeamUser -GroupId $teamId | Where-Object { $_.Role -in @('Member', 'Owner') } | Where-Object { $ExampleUsers -contains $_.User }

    foreach ($user in $teamUsers) {
        $teamResults += [PSCustomObject]@{
            TeamName = $teamName
            Member   = $user.User
            Role     = $user.Role
        }
    }
}

# Export results to a CSV file
if ($teamResults.Count -gt 0) {
    $outputPath = "TeamsAndMembers.csv"
    $teamResults | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8
    Write-Output "Script completed. Results have been exported to '$outputPath'."
} else {
    Write-Output "No data to export."
}

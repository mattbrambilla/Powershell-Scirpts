# Set your authentication credentials
$clientId = "TuoClientID"
$clientSecret = "TuoClientSecret"
$tenantId = "TuoTenantID"

# Get an access token using your credentials
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$body = @{
    client_id     = $clientId
    client_secret = $clientSecret
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
}
$token = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body

# Set the authorization header
$authorization = "Bearer $($token.access_token)"
$headers = @{
    Authorization = $authorization
}

# Get the list of files shared via OneDrive
$sharedFilesEndpoint = "https://graph.microsoft.com/v1.0/drive/shared"
$sharedFiles = Invoke-RestMethod -Uri $sharedFilesEndpoint -Headers $headers

# View details of shared files
$sharedFiles.value | ForEach-Object {
    Write-Output "File condiviso: $($_.name) - URL: $($_.webUrl)"
}

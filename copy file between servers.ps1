$source_dir = "C:\Users\..."
$destination_dir = "C:\Users\..."

if (Test-Path $source_dir) {
    Get-ChildItem $source_dir -Filter "filename*" -File | Copy-Item -Destination $destination_dir
    Write-Host "Files copied successfully."
} else {
    Write-Host "Source directory does not exist."
}

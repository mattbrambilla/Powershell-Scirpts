$source_dir = #Insert the source directory path here "C:\Users\...""
$destination_dir = #Insert the destination directory path here "C:\Users\...""

# Check if the source directory exists
# If the source directory does not exist, you can create it or handle the error as needed
if (Test-Path $source_dir) {
 # Get all files matching the pattern "filename*"
 $files = Get-ChildItem -Path $source_dir -Filter #"filename*" -File

 # Check if any files were found
 foreach ($file in $files) {
 Copy-Item -Path $file.FullName -Destination $destination_dir
 }

 # Output a message indicating success
 Write-Host "Files copied successfully."
} else {
 Write-Host "Source directory does not exist."
}

# Optional: Wait for a few seconds before exiting
# This can be useful for debugging or to see the output before the script ends
Start-Sleep -Seconds 5
Exit

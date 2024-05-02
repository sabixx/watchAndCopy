# Define the path to monitor
$folderToWatch = "C:\Users\jens\AppData\Local\Temp\2"  # Update this path to the folder you want to monitor
$destinationFolder = "C:\temp"  # Update this path to where you want copies saved

# Create a FileSystemWatcher object
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folderToWatch
$watcher.Filter = "*.*"  # Monitor all files, update this if you want to filter by specific file types
$watcher.IncludeSubdirectories = $false  # Set to $true if you want to monitor subdirectories
$watcher.EnableRaisingEvents = $true

# Define actions on a created file
$action = {
    param($source, $eventArgs)
    $fileName = [System.IO.Path]::GetFileName($eventArgs.FullPath)
    Write-Host "File created: $fileName"
    $destination = [System.IO.Path]::Combine($destinationFolder, $fileName)
    Write-Host "Copying file to: $destination"
    try {
        Copy-Item -Path $eventArgs.FullPath -Destination $destination -Force
        Write-Host "File copied successfully."
    } catch {
        Write-Host "Error copying file: $_"
    }
}


# Decide what to do when a file is created
$eventName = "FileCreatedEvent"
Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action -MessageData $destinationFolder -SourceIdentifier $eventName

# Write a message to console
Write-Host "Watching for changes to files in '$folderToWatch'. Press any key to exit..."

# Wait for a key press to terminate
while ($true) {
    if ($host.UI.RawUI.KeyAvailable) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        break
    }
}

# Unregister the event and dispose the watcher
Unregister-Event -SourceIdentifier $eventName
$watcher.Dispose()
Write-Host "Watcher stopped."

# remove the handler, when no longer needed
# Unregister-Event -SourceIdentifier $eventName -ErrorAction SilentlyContinue

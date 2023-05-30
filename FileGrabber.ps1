$sourceDirectories = @(
    [Environment]::GetFolderPath('MyDocuments')
    [Environment]::GetFolderPath('MyPictures')
)

$desktopDirectory = [Environment]::GetFolderPath('Desktop')
$destinationDirectory = "D:\data"

# Get the username of the currently logged-in user
$currentUsername = [Environment]::UserName
$thumbDrivePath = Join-Path $destinationDirectory $currentUsername

# Verify if the destination directory exists
if (-not (Test-Path $destinationDirectory)) {
    Write-Host "Destination directory '$destinationDirectory' does not exist."
    Exit
}

# Verify if the thumb drive data directory exists, otherwise create it
if (-not (Test-Path $thumbDrivePath)) {
    New-Item -ItemType Directory -Path $thumbDrivePath | Out-Null
}

foreach ($sourceDir in $sourceDirectories) {
    # Verify if the source directory exists
    if (-not (Test-Path $sourceDir)) {
        Write-Host "Source directory '$sourceDir' does not exist."
        Continue
    }
    
    # Determine the destination subdirectory based on the source directory name
    $sourceDirectoryName = (Get-Item -Path $sourceDir).Name
    $destinationSubdirectory = Join-Path $thumbDrivePath "$sourceDirectoryName"
    if (-not (Test-Path $destinationSubdirectory)) {
        New-Item -ItemType Directory -Path $destinationSubdirectory | Out-Null
    }
    
    Get-ChildItem -Path $sourceDir -Recurse -File | ForEach-Object {
        $filePath = $_.FullName
        
        # Create the corresponding destination path
        $relativePath = $filePath.Replace($sourceDir, "")
        $destinationPath = Join-Path -Path $destinationSubdirectory -ChildPath $relativePath
        
        # Copy the file to the thumb drive
        Copy-Item -Path $filePath -Destination $destinationPath -Force -ErrorAction SilentlyContinue
        
        Write-Host "Copied '$($_.Name)' to '$destinationPath'"
    }
}

# Copy specific file types from the Desktop
$fileTypes = @("*.pdf", "*.docx", "*.pptx", "*.xlsx", "*.txt")
foreach ($fileType in $fileTypes) {
    $desktopFiles = Get-ChildItem -Path $desktopDirectory -Filter $fileType -Recurse -File
    foreach ($file in $desktopFiles) {
        $destinationPath = Join-Path -Path $thumbDrivePath -ChildPath $file.Name
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction SilentlyContinue
        
        Write-Host "Copied '$($file.Name)' to '$destinationPath'"
    }
}

# Configuration
$BranchName = "main"
$ScriptName = $MyInvocation.MyCommand.Name

Write-Host "Step 1: Preparing the repository"
Set-Location -Path $PSScriptRoot

Write-Host "Step 2: Acquiring GitHub repository URL"
$RepoUrl = git config --get remote.origin.url
if (-not $RepoUrl) {
    Write-Host "Error: Could not acquire GitHub repository URL."
    Write-Host "Please ensure this is a Git repository and has a remote named 'origin'."
    Write-Host "Verify by running 'git remote -v' in the repository directory."
    exit 1
}
Write-Host "Repository URL: $RepoUrl"

Write-Host "Step 3: Backing up important files"
if (-not (Test-Path "temp_backup")) {
    New-Item -ItemType Directory -Path "temp_backup" | Out-Null
}
Copy-Item $ScriptName "temp_backup\"

Write-Host "Step 4: Resetting the repository"
if (Test-Path ".git") {
    Get-ChildItem .git -Recurse | Set-ItemProperty -Name Attributes -Value Normal
    Remove-Item -Recurse -Force .git
}

Write-Host "Step 5: Initializing a new repository"
git init -b main

Write-Host "Step 6: Copying new build files"
# Add your copy commands here

Write-Host "Step 7: Restoring backed-up files"
Copy-Item "temp_backup\*" . -Force
Remove-Item -Recurse -Force "temp_backup"

Write-Host "Step 8: Committing changes"
git add -A
$commitResult = git commit -m "Reset build $(Get-Date -Format 'yyyy-MM-dd')" 2>&1
if ($commitResult -match "nothing to commit") {
    Write-Host "No changes to commit. Exiting."
    exit 0
}

Write-Host "Step 9: Pushing to GitHub"
git remote add origin $RepoUrl
git push -f origin $BranchName

Write-Host "Process completed. Repository has been reset and updated."

# Step 10: Open GitHub repository URL in default browser
Write-Host "Opening GitHub repository in default browser..."
if ($RepoUrl -match "^git@github\.com:(.+)\.git$") {
    $BrowserUrl = "https://github.com/$($Matches[1])"
} elseif ($RepoUrl -match "^https://github\.com/(.+)\.git$") {
    $BrowserUrl = "https://github.com/$($Matches[1])"
} else {
    Write-Host "Unable to determine GitHub URL format. Please open the repository manually."
    exit 0
}

Start-Process $BrowserUrl
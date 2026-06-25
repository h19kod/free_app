# Flutter Setup Script - Run after flutter.zip download completes
# Usage: .\setup_flutter.ps1

Write-Host "Setting up Flutter..." -ForegroundColor Cyan

$zipPath = "$env:USERPROFILE\Downloads\flutter.zip"
$installPath = "C:\src"

# Check if zip exists
if (-not (Test-Path $zipPath)) {
    Write-Host "flutter.zip not found at $zipPath" -ForegroundColor Red
    exit 1
}

# Create destination
New-Item -ItemType Directory -Force -Path $installPath | Out-Null
Write-Host "Extracting Flutter to $installPath..." -ForegroundColor Yellow

# Extract
Expand-Archive -Path $zipPath -DestinationPath $installPath -Force
Write-Host "Extraction complete!" -ForegroundColor Green

# Add to PATH (current session)
$flutterBin = "$installPath\flutter\bin"
$env:PATH = "$env:PATH;$flutterBin"

# Add to PATH (permanent - user level)
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*flutter\bin*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$flutterBin", "User")
    Write-Host "Flutter added to PATH permanently!" -ForegroundColor Green
}

Write-Host "`nFlutter version:" -ForegroundColor Cyan
& "$flutterBin\flutter.bat" --version

Write-Host "`nRunning flutter doctor..." -ForegroundColor Cyan
& "$flutterBin\flutter.bat" doctor

Write-Host "`nInstalling project dependencies..." -ForegroundColor Cyan
Set-Location "$PSScriptRoot"
& "$flutterBin\flutter.bat" pub get

Write-Host "`nSetup complete! Run 'flutter run' to start the app." -ForegroundColor Green

$ErrorActionPreference = "Stop"

# Set this to an HTTPS image URL or a local JPG/PNG file path.
$WallpaperPath = ""

if ([string]::IsNullOrWhiteSpace($WallpaperPath)) {
    throw "WallpaperPath is blank. Set it to the company wallpaper URL or local file path before running this script."
}

$DestinationDirectory = Join-Path $env:ProgramData "Company\Branding"
$DestinationPath = Join-Path $DestinationDirectory "company-wallpaper.jpg"

New-Item -Path $DestinationDirectory -ItemType Directory -Force | Out-Null

if ($WallpaperPath -match '^https://') {
    Invoke-WebRequest -Uri $WallpaperPath -OutFile $DestinationPath -UseBasicParsing
} elseif (Test-Path -LiteralPath $WallpaperPath -PathType Leaf) {
    Copy-Item -LiteralPath $WallpaperPath -Destination $DestinationPath -Force
} else {
    throw "WallpaperPath must be an HTTPS URL or an existing local file."
}

$PersonalizationKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
New-Item -Path $PersonalizationKey -Force | Out-Null
New-ItemProperty -Path $PersonalizationKey -Name "DesktopImagePath" -Value $DestinationPath -PropertyType String -Force | Out-Null
New-ItemProperty -Path $PersonalizationKey -Name "DesktopImageUrl" -Value $DestinationPath -PropertyType String -Force | Out-Null
New-ItemProperty -Path $PersonalizationKey -Name "DesktopImageStatus" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Output "Company wallpaper configured at $DestinationPath."

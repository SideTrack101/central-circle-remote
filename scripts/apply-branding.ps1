param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [string]$BrandingPath = (Join-Path $PSScriptRoot "..\branding")
)

$ErrorActionPreference = "Stop"

function Replace-Literal {
    param([string]$Path, [string]$Old, [string]$New)

    if (-not (Test-Path $Path)) {
        throw "Required source file not found: $Path"
    }

    $content = [System.IO.File]::ReadAllText($Path)
    if (-not $content.Contains($Old)) {
        throw "Expected text '$Old' was not found in $Path"
    }

    [System.IO.File]::WriteAllText($Path, $content.Replace($Old, $New))
}

$source = (Resolve-Path $SourcePath).Path
$branding = (Resolve-Path $BrandingPath).Path

$iconSource = Join-Path $branding "windows\app.ico"
$logoSource = Join-Path $branding "windows\central-circle-remote.png"
$iconTarget = Join-Path $source "flutter\windows\runner\resources\app_icon.ico"
$flutterAssets = Join-Path $source "flutter\assets"

if (-not (Test-Path $iconSource)) { throw "Windows icon is missing: $iconSource" }
if (-not (Test-Path $logoSource)) { throw "Flutter logo is missing: $logoSource" }

New-Item -ItemType Directory -Force -Path $flutterAssets | Out-Null
Copy-Item $iconSource $iconTarget -Force
Copy-Item $logoSource (Join-Path $flutterAssets "logo.png") -Force
Copy-Item $logoSource (Join-Path $flutterAssets "logo_light.png") -Force
Copy-Item $logoSource (Join-Path $flutterAssets "logo_dark.png") -Force
Copy-Item $logoSource (Join-Path $flutterAssets "icon.png") -Force

$runnerResource = Join-Path $source "flutter\windows\runner\Runner.rc"
Replace-Literal $runnerResource 'VALUE "CompanyName", "Purslane Tech Pte. Ltd."' 'VALUE "CompanyName", "Central Circle"'
Replace-Literal $runnerResource 'VALUE "FileDescription", "RustDesk Remote Desktop"' 'VALUE "FileDescription", "Central Circle Remote Support"'
Replace-Literal $runnerResource 'VALUE "ProductName", "RustDesk"' 'VALUE "ProductName", "Central Circle Remote"'
Replace-Literal $runnerResource 'Copyright © 2026 Purslane Tech Pte. Ltd. All rights reserved.' 'Copyright © 2026 Central Circle. Open-source components retain their original licences.'

$cargoManifest = Join-Path $source "Cargo.toml"
Replace-Literal $cargoManifest 'ProductName = "RustDesk"' 'ProductName = "Central Circle Remote"'
Replace-Literal $cargoManifest 'FileDescription = "RustDesk Remote Desktop"' 'FileDescription = "Central Circle Remote Support"'

$portableManifest = Join-Path $source "libs\portable\Cargo.toml"
Replace-Literal $portableManifest 'ProductName = "RustDesk"' 'ProductName = "Central Circle Remote"'
Replace-Literal $portableManifest 'FileDescription = "RustDesk Remote Desktop"' 'FileDescription = "Central Circle Remote Support"'

$sharedConfig = Join-Path $source "libs\hbb_common\src\config.rs"
Replace-Literal $sharedConfig 'pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());' 'pub static ref APP_NAME: RwLock<String> = RwLock::new("Central Circle Remote".to_owned());'

Write-Host "Central Circle UI logo, application name, icon and Windows metadata applied successfully."

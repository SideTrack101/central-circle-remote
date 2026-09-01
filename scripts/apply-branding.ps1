param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [string]$BrandingPath = (Join-Path $PSScriptRoot "..\branding")
)

$ErrorActionPreference = "Stop"

function Replace-Literal {
    param(
        [string]$Path,
        [string]$Old,
        [string]$New
    )

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
$iconTarget = Join-Path $source "flutter\windows\runner\resources\app_icon.ico"
Copy-Item $iconSource $iconTarget -Force

$runnerResource = Join-Path $source "flutter\windows\runner\Runner.rc"
Replace-Literal $runnerResource 'VALUE "ProductName", "RustDesk"' 'VALUE "ProductName", "Central Circle Remote"'
Replace-Literal $runnerResource 'VALUE "FileDescription", "RustDesk"' 'VALUE "FileDescription", "Central Circle Remote"'
Replace-Literal $runnerResource 'Copyright © 2026 Purslane Tech Pte. Ltd. All rights reserved.' 'Copyright © 2026 Central Circle. Open-source components retain their original licences.'

$cargoManifest = Join-Path $source "Cargo.toml"
Replace-Literal $cargoManifest 'ProductName = "RustDesk"' 'ProductName = "Central Circle Remote"'
Replace-Literal $cargoManifest 'FileDescription = "RustDesk Remote Desktop"' 'FileDescription = "Central Circle Remote Support"'

$portableManifest = Join-Path $source "libs\portable\Cargo.toml"
Replace-Literal $portableManifest 'ProductName = "RustDesk"' 'ProductName = "Central Circle Remote"'
Replace-Literal $portableManifest 'FileDescription = "RustDesk Remote Desktop"' 'FileDescription = "Central Circle Remote Support"'

Write-Host "Central Circle branding applied successfully."

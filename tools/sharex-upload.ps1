[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$File,

    [ValidateSet('backgrounds', 'avatars', 'icons', 'illustrations', 'stickers')]
    [string]$Folder = 'illustrations'
)

$ErrorActionPreference = 'Stop'
$uploader = Join-Path $PSScriptRoot 'github-upload.ps1'
$output = & $uploader -File $File -Folder $Folder
$exitCode = $LASTEXITCODE

try {
    $result = $output | ConvertFrom-Json
} catch {
    [Console]::Error.WriteLine('Uploader returned invalid JSON.')
    exit 1
}

if ($exitCode -ne 0 -or -not $result.ok) {
    [Console]::Error.WriteLine($result.error)
    exit 1
}

$result.url

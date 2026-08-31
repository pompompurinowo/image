[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$File,

    [ValidateSet('backgrounds', 'avatars', 'icons', 'illustrations', 'stickers')]
    [string]$Folder = 'illustrations',

    [string]$Name,

    [switch]$Overwrite,

    [string]$Owner = 'pompompurinowo',

    [string]$Repository = 'image',

    [string]$Branch = 'main'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$MaximumFileBytes = 20MB

function Write-UploadError {
    param([System.Management.Automation.ErrorRecord]$Record)

    $message = $Record.Exception.Message
    if ($Record.ErrorDetails -and $Record.ErrorDetails.Message) {
        try {
            $details = $Record.ErrorDetails.Message | ConvertFrom-Json
            if ($details.message) { $message = $details.message }
        } catch {
            # Keep the original PowerShell error when GitHub did not return JSON.
        }
    }

    [pscustomobject]@{
        ok = $false
        error = $message
    } | ConvertTo-Json -Compress
}

function ConvertTo-UrlPath {
    param([string]$Path)

    $segments = ($Path -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }
    [string]::Join('/', $segments)
}

function Get-SafeStem {
    param([string]$Value)

    $stem = [IO.Path]::GetFileNameWithoutExtension($Value).ToLowerInvariant()
    $stem = [regex]::Replace($stem, '[^a-z0-9_-]+', '-')
    $stem = [regex]::Replace($stem, '-+', '-').Trim('-', '_', '.')
    if ([string]::IsNullOrWhiteSpace($stem)) { return 'image' }
    return $stem
}

function Get-UniqueName {
    param([IO.FileInfo]$InputFile)

    $stem = Get-SafeStem $InputFile.Name
    $stamp = [DateTime]::UtcNow.ToString('yyyyMMddHHmmss')
    $suffix = [guid]::NewGuid().ToString('N').Substring(0, 6)
    return "$stamp-$stem-$suffix$($InputFile.Extension.ToLowerInvariant())"
}

function Assert-ValidName {
    param([string]$Value)

    $characters = $Value.ToCharArray()
    if ($Value -ne [IO.Path]::GetFileName($Value) -or $Value.Contains('..') -or ($characters | Where-Object { [char]::IsControl($_) } | Select-Object -First 1)) {
        throw 'Name must be a plain file name without path separators, .., or control characters.'
    }
    if ([string]::IsNullOrWhiteSpace([IO.Path]::GetExtension($Value))) {
        throw 'Name must include an image file extension.'
    }
}

function Invoke-GitHubRequest {
    param(
        [ValidateSet('Get', 'Put')]
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers,
        [string]$Body
    )

    $parameters = @{
        Method = $Method
        Uri = $Uri
        Headers = $Headers
        ContentType = 'application/json'
    }
    if ($PSBoundParameters.ContainsKey('Body')) { $parameters.Body = $Body }
    Invoke-RestMethod @parameters
}

try {
    $inputFile = Get-Item -LiteralPath $File
    if ($inputFile.PSIsContainer) { throw 'File must point to an image file, not a directory.' }
    if ($inputFile.Length -gt $MaximumFileBytes) { throw "Files larger than $([math]::Round($MaximumFileBytes / 1MB)) MB are not supported." }

    $allowedExtensions = '.jpg', '.jpeg', '.png', '.webp', '.gif', '.avif'
    if ($allowedExtensions -notcontains $inputFile.Extension.ToLowerInvariant()) {
        throw "Unsupported image extension: $($inputFile.Extension)"
    }

    $targetName = if ($Name) { $Name } else { Get-UniqueName $inputFile }
    Assert-ValidName $targetName

    $token = $env:GITHUB_TOKEN
    if ([string]::IsNullOrWhiteSpace($token)) { throw 'Set the GITHUB_TOKEN environment variable before uploading.' }

    $repoPath = "$Folder/$targetName"
    $encodedPath = ConvertTo-UrlPath $repoPath
    $apiBase = "https://api.github.com/repos/$Owner/$Repository"
    $contentUri = "$apiBase/contents/$encodedPath"
    $headers = @{
        Accept = 'application/vnd.github+json'
        Authorization = "Bearer $token"
        'X-GitHub-Api-Version' = '2022-11-28'
        'User-Agent' = 'github-image-uploader'
    }

    $existingSha = $null
    try {
        $existing = Invoke-GitHubRequest -Method Get -Uri "$contentUri`?ref=$([uri]::EscapeDataString($Branch))" -Headers $headers
        $existingSha = $existing.sha
        if (-not $Overwrite) {
            throw "The destination already exists: $repoPath. Use -Overwrite or omit -Name to create a unique name."
        }
    } catch {
        if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 404) {
            $existingSha = $null
        } elseif ($_.Exception.Message -like 'The destination already exists:*') {
            throw
        } else {
            throw
        }
    }

    $base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($inputFile.FullName))
    $result = $null
    for ($attempt = 0; $attempt -lt 2; $attempt++) {
        $payload = @{
            message = "upload: $repoPath"
            content = $base64
            branch = $Branch
        }
        if ($existingSha) { $payload.sha = $existingSha }

        try {
            $body = $payload | ConvertTo-Json -Compress
            $result = Invoke-GitHubRequest -Method Put -Uri $contentUri -Headers $headers -Body $body
            break
        } catch {
            if ($attempt -eq 0 -and $_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 409) {
                $existing = Invoke-GitHubRequest -Method Get -Uri "$contentUri`?ref=$([uri]::EscapeDataString($Branch))" -Headers $headers
                $existingSha = $existing.sha
                continue
            }
            throw
        }
    }

    if (-not $result) { throw 'GitHub did not return an upload result.' }

    $actualPath = if ($result.content.path) { $result.content.path } else { $repoPath }
    $actualEncodedPath = ConvertTo-UrlPath $actualPath
    $commit = $result.commit.sha
    $mainUrl = "https://cdn.jsdelivr.net/gh/$Owner/$Repository@$Branch/$actualEncodedPath"
    $stableUrl = "https://cdn.jsdelivr.net/gh/$Owner/$Repository@$commit/$actualEncodedPath"
    $rawUrl = "https://raw.githubusercontent.com/$Owner/$Repository/$Branch/$actualEncodedPath"
    $pagesUrl = "https://$Owner.github.io/$Repository/$actualEncodedPath"
    $alt = [IO.Path]::GetFileNameWithoutExtension($actualPath)

    [pscustomobject]@{
        ok = $true
        path = $actualPath
        commit = $commit
        url = $mainUrl
        stableUrl = $stableUrl
        rawUrl = $rawUrl
        pagesUrl = $pagesUrl
        markdown = "![$alt]($mainUrl)"
        html = "<img src=`"$mainUrl`" alt=`"$alt`">"
    } | ConvertTo-Json -Compress
} catch {
    Write-UploadError $_
    exit 1
}

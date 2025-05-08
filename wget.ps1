param (
    [Alias("u")][Parameter(Mandatory = $true)][string]$url,
    [Alias("o")][string]$output
)

try {
    if (-not $output -or $output.Trim() -eq "") {
        # Try to get filename from URL
        $uri = [System.Uri]$url
        $output = [System.IO.Path]::GetFileName($uri.AbsolutePath)

        if (-not $output -or $output -eq "") {
            throw "Could not find a valid filename in the URL. Specify -o manually."
        }
    }

    Write-Host "Downloading from: $url"
    Write-Host "Saving as: $output"

    if (Test-Path $output) {
        $choice = Read-Host "'$output' Already exists. Do you want to overwrite it? (y/n)"
        if ($choice -ne 'y') {
            Write-Host "Aborting."
            exit 0
        }
    }

    $maxRetries = 3
    $attempt = 0
    while ($attempt -lt $maxRetries) {
        try {
            $attempt++
            Invoke-WebRequest -Uri $url -Outfile $output -ErrorAction stop -Headers @{ "User-Agent" = "Mozilla/5.0 (PowerShell-Wget)"}
            Write-Host "Downloading complete: $output"
            break
        } catch {
            if ($attempt -lt $maxRetries) {
                Write-Warning "Error during download, retrying ($attempt)"
                Start-Sleep -Seconds 2
            } else {
                throw
            }
        }
    }

}
catch {
    Write-Error "Download failed: $($_.Exception.Message)"
    exit 1
}

exit 0

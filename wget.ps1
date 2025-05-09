param (
    [Alias("u")][Parameter(Mandatory = $true)][string]$url,
    [Alias("o")][string]$output,
    [Alias("q")][switch]$Quiet,
    [Alias("f")][switch]$Force
)

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "Info"
    )

    if (-not $Quiet) {
        switch ($Level) {
            "Info" { Write-Host $Message }
            "Warning" { Write-Warning $Message }
            "Error" { Write-Error $Message }
        }
    }
}

try {
    try {
            $uri = [System.Uri]$url
        } catch {
            Write-Log "Invalid URL: $url" "Error"
            exit 2
        }
        
    if (-not $output -or $output.Trim() -eq "") {
        # Try to get filename from URL
        $output = [System.IO.Path]::GetFileName($uri.AbsolutePath)

        if (-not $output -or $output -eq "") {
            throw "Could not find a valid filename in the URL. Specify -o manually."
        }
    }

    Write-Log "Downloading from: $url"
    Write-Log "Saving as: $output"

    if ((Test-Path $output) -and -not $Force) {
        $choice = Read-Host "'$output' Already exists. Do you want to overwrite it? (y/n)"
        if ($choice -ne 'y') {
            Write-Log "Aborting."
            exit 0
        }
    }

    $maxRetries = 3
    $attempt = 0
    while ($attempt -lt $maxRetries) {
        try {
            $attempt++
            Invoke-WebRequest -Uri $url -Outfile $output -ErrorAction stop -Headers @{ "User-Agent" = "Mozilla/5.0 (PowerShell-Wget)"}
            Write-Log "Downloading complete: $output"
            break
        } catch {
            if ($attempt -lt $maxRetries) {
                Write-Log "Error during download, retrying ($attempt)" "Warning"
                Start-Sleep -Seconds 2
            } else {
                throw
            }
        }
    }

}
catch {
    Write-Log "Download failed: $($_.Exception.Message)" "Error"
    exit 1
}

exit 0

<#
.SYNOPSIS
    Downloads and installs 7-Zip.

.DESCRIPTION
    This script downloads the 7-Zip installer from the specified URL and installs it silently
    to the specified directory. It supports logging of operations.
    Compatible with PowerShell 2.0.

.PARAMETER DownloadUrl
    The URL to download the 7-Zip installer from.
    Default: "https://www.7-zip.org/a/7z2409-x64.exe"

.PARAMETER InstallPath
    The directory where 7-Zip should be installed.
    Default: "$env:ProgramFiles\7-Zip"

.PARAMETER LogFile
    The full path to the log file.
    Default: "$env:TEMP\7zip_install.log"

.EXAMPLE
    .\7z.ps1
    Downloads and installs 7-Zip with default settings.

.EXAMPLE
    .\7z.ps1 -DownloadUrl "https://www.7-zip.org/a/7z2409-x64.exe" -InstallPath "C:\Tools\7-Zip" -LogFile "C:\logs\7zip.log"
    Downloads and installs 7-Zip with custom settings.

.NOTES
    Author: GitHub Copilot
    Date: 2025-05-23
#>
param(
    [string]$DownloadUrl = "https://www.7-zip.org/a/7z2409-x64.exe",
    [string]$InstallPath = "$env:ProgramFiles\7-Zip",
    [string]$LogFile = "$env:TEMP\7zip_install.log"
)

#Requires -Version 2

# Function to write log messages
function Write-Log {
    param(
        [string]$Message,
        [switch]$IsError
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    
    Write-Host $LogEntry
    try {
        Add-Content -Path $LogFile -Value $LogEntry -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to write to log file ${LogFile}: $($_.Exception.Message)"
    }

    if ($IsError) {
        Write-Error $Message # This will also go to the error stream
    }
}

Write-Log -Message "Starting 7-Zip installation script."

# Validate parameters
if (-not ($DownloadUrl -match "^https?://.+")) {
    Write-Log -Message "Error: DownloadUrl '$DownloadUrl' is not a valid HTTP/HTTPS URL." -IsError
    exit 1
}

# Ensure the parent directory for the log file exists
try {
    $LogDir = Split-Path -Path $LogFile -Parent
    if (-not (Test-Path -Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force -ErrorAction Stop | Out-Null
        Write-Log -Message "Created log directory: $LogDir"
    }
}
catch {
    Write-Warning "Could not create log directory '$LogDir'. Log file may not be written. Error: $($_.Exception.Message)"
}


Write-Log -Message "Parameters:"
Write-Log -Message "  DownloadUrl: $DownloadUrl"
Write-Log -Message "  InstallPath: $InstallPath"
Write-Log -Message "  LogFile:     $LogFile"

# Path for the downloaded installer
$InstallerName = $DownloadUrl.Split('/')[-1]
$InstallerPath = Join-Path -Path $env:TEMP -ChildPath $InstallerName

# Download 7-Zip
Write-Log -Message "Downloading 7-Zip from $DownloadUrl to $InstallerPath..."
try {
    $WebClient = New-Object System.Net.WebClient
    # Set User-Agent to avoid potential blocking by some servers
    $WebClient.Headers.Add("User-Agent", "PowerShell Script")
    $WebClient.DownloadFile($DownloadUrl, $InstallerPath)
    Write-Log -Message "Download completed successfully."
}
catch {
    Write-Log -Message "Error downloading 7-Zip: $($_.Exception.Message)" -IsError
    exit 1
}

# Install 7-Zip
Write-Log -Message "Installing 7-Zip to $InstallPath..."
# 7-Zip installer silent switch is /S
# /D specifies the installation directory
$InstallArguments = "/S /D=`"$InstallPath`"" 

Write-Log -Message "Running installer: $InstallerPath $InstallArguments"
try {
    # Start-Process in PowerShell 2.0
    $Process = Start-Process -FilePath $InstallerPath -ArgumentList $InstallArguments -Wait -PassThru -ErrorAction Stop
    
    if ($Process.ExitCode -eq 0) {
        Write-Log -Message "7-Zip installation completed successfully. Exit code: $($Process.ExitCode)"
    }
    else {
        # Some installers might return non-zero for success in specific scenarios,
        # but for 7-Zip, 0 is typically success.
        Write-Log -Message "7-Zip installation finished with exit code: $($Process.ExitCode). This might indicate an issue." -IsError
        # Depending on requirements, you might choose to exit here or just log.
    }
}
catch {
    Write-Log -Message "Error during 7-Zip installation: $($_.Exception.Message)" -IsError
    # Clean up downloaded file if installation fails
    if (Test-Path -Path $InstallerPath) {
        Write-Log -Message "Cleaning up downloaded installer: $InstallerPath"
        Remove-Item -Path $InstallerPath -Force -ErrorAction SilentlyContinue
    }
    exit 1
}

# Clean up downloaded installer
if (Test-Path -Path $InstallerPath) {
    Write-Log -Message "Cleaning up downloaded installer: $InstallerPath"
    Remove-Item -Path $InstallerPath -Force -ErrorAction SilentlyContinue
}

Write-Log -Message "7-Zip installation script finished."

# Optional: Add to Path (requires admin rights and new session for changes to take effect)
# Consider making this a separate function or parameter-driven
# $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
# if ($CurrentPath -notlike "*$InstallPath*") {
#     Write-Log -Message "Adding $InstallPath to system PATH. Administrator rights required."
#     try {
#         [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$InstallPath", "Machine")
#         Write-Log -Message "$InstallPath added to system PATH. A new session/reboot may be required for changes to take effect."
#     }
#     catch {
#         Write-Log -Message "Failed to add $InstallPath to system PATH. Error: $($_.Exception.Message)" -IsError
#     }
# }
# else {
#     Write-Log -Message "$InstallPath is already in the system PATH."
# }


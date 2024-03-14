$ErrorActionPreference = "Stop";
Set-StrictMode -Version "Latest";

$thisScript = $MyInvocation.MyCommand.Path;
$thisFolder = [System.IO.Path]::GetDirectoryName($thisScript);
$rootFolder = [System.IO.Path]::GetDirectoryName($thisFolder);
$testFolder = [System.IO.Path]::Combine($thisFolder, "scripts");

$testableScripts = @(
    "windows-scheduled-task-create.ScriptBody.ps1",
    "sql-backup-database.ScriptBody.ps1"
);
foreach( $script in $testableScripts )
{
    $filename = [System.IO.Path]::Combine($rootFolder, $script);
    if( -not [System.IO.File]::Exists($filename) )
    {
        throw new-object System.IO.FileNotFoundException("Testable script not found.", $filename);
    }
    . $filename;
}

# Define the path to the local Pester module
$packagesFolder = $thisFolder
$packagesFolder = [System.IO.Path]::GetDirectoryName($packagesFolder)
$packagesFolder = [System.IO.Path]::GetDirectoryName($packagesFolder)
$localPesterPath = [System.IO.Path]::Combine($packagesFolder, "packages/Pester.3.4.3/tools/Pester")

try {
    # Try to import the global Pester module
    Import-Module -Name Pester -ErrorAction Stop
} catch {
    # If the global module isn't found, fallback to the local one
    Write-Host "Global Pester module not found. Attempting to load local Pester module at '$localPesterPath'."
    Import-Module -Name $localPesterPath -ErrorAction Stop
}

Invoke-Pester;

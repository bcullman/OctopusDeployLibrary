$ErrorActionPreference = "Stop"
Set-StrictMode -Version "Latest"

# Attempt to load SMO assemblies


# Define the full paths to the assemblies
$smoPath = "C:\Users\brad.ullman\.nuget\packages\microsoft.sqlserver.sqlmanagementobjects\170.23.0\lib\net462\Microsoft.SqlServer.Smo.dll"
$sdkSfcPath = "C:\Users\brad.ullman\.nuget\packages\microsoft.sqlserver.sqlmanagementobjects\170.23.0\lib\net462\Microsoft.SqlServer.Management.Sdk.Sfc.dll"
$connectionInfoPath = "C:\Users\brad.ullman\.nuget\packages\microsoft.sqlserver.sqlmanagementobjects\170.23.0\lib\net462\Microsoft.SqlServer.ConnectionInfo.dll"
$sqlEnumPath = "C:\Users\brad.ullman\.nuget\packages\microsoft.sqlserver.sqlmanagementobjects\170.23.0\lib\net462\Microsoft.SqlServer.SqlEnum.dll"

# Load the assemblies
[Reflection.Assembly]::LoadFrom($smoPath)
[Reflection.Assembly]::LoadFrom($sdkSfcPath)
[Reflection.Assembly]::LoadFrom($connectionInfoPath)
[Reflection.Assembly]::LoadFrom($sqlEnumPath)

# $smoAssemblyPaths = @(
#     "Microsoft.SqlServer.Smo",
#     "Microsoft.SqlServer.Management.Sdk.Sfc",
#     "Microsoft.SqlServer.ConnectionInfo",
#     "Microsoft.SqlServer.SqlEnum"
# ) | ForEach-Object {
#     [System.Reflection.Assembly]::LoadWithPartialName($_)
# }

Describe "BackupDatabase Function Tests" {

    BeforeAll {
        # Mock the dependent functions and cmdlets
        Mock CreateDevices { return @("MockDevicePath") }
        Mock AddPercentHandler { } # No return value needed, just avoid executing its body
        Mock New-Object {
            param($Type)
            if ($Type -match 'Backup') {
                # Return a mocked version or minimal implementation of the Microsoft.SqlServer.Management.Smo.Backup class
                return New-MockObject -Type Microsoft.SqlServer.Management.Smo.Backup
            }
        }

        # Define $OctopusParameters for testing purposes
        $script:OctopusParameters = @{
            "Server" = "MockServer"
            "Database" = "MockDB"
            "BackupDirectory" = "C:\MockPath"
            "Devices" = 1
            "Compression" = 0
            "Incremental" = $false
            "CopyOnly" = $false
            "RetentionPolicyEnabled" = $false
            "RetentionPolicyCount" = 0
            "SqlLogin" = "MockLogin"
            "SqlPassword" = "MockPassword"
            "ConnectionTimeout" = 30
        }
    }

    # Assuming assemblies are loaded as in your script
    #$server = New-Object Microsoft.SqlServer.Management.Smo.Server(".")
    #Write-Host "Server object created: $server"


    #$smoBackup = New-Object Microsoft.SqlServer.Management.Smo.Backup
    #Write-Host "SMO Backup object type: $($smoBackup.GetType().FullName)"

    It "Performs successful database backup" {
      # Directly test the BackupDatabase function without mocking it
      # Ensure to catch and handle exceptions if the function is supposed to throw under certain conditions
      { BackupDatabase -ServerName $script:OctopusParameters['Server'] -DatabaseName $script:OctopusParameters['Database'] -BackupDirectory $script:OctopusParameters['BackupDirectory'] -Devices $script:OctopusParameters['Devices'] -CompressionOption $script:OctopusParameters['Compression'] -Incremental $script:OctopusParameters['Incremental'] -CopyOnly $script:OctopusParameters['CopyOnly'] -RetentionPolicyEnabled $script:OctopusParameters['RetentionPolicyEnabled'] -RetentionPolicyCount $script:OctopusParameters['RetentionPolicyCount'] -server (New-Object Object) -timestamp "MockTimestamp" } | Should Not Throw
    }

    # Add more tests to cover various scenarios and edge cases of the BackupDatabase function
}

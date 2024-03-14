$ErrorActionPreference = "Stop"
Set-StrictMode -Version "Latest"

Describe "BackupDatabase Function Tests" {

    BeforeAll {
        # Define a simplified mock version of ConnectToDatabase that doesn't rely on SMO types
        Mock ConnectToDatabase {
            return $true
        }

        # Mock New-Object calls specifically for SMO types to return simplified mock objects
        Mock New-Object {
            param([string]$TypeName)
            if ($TypeName -match 'Microsoft.SqlServer.Management.Smo.Server') {
                # Return a dummy object for SMO.Server
                return New-Object PSObject -Property @{
                    Databases = New-Object PSObject
                    ConnectionContext = New-Object PSObject -Property @{
                        Connect = { }
                        StatementTimeout = 0
                        LoginSecure = $false
                        Login = ""
                        Password = ""
                    }
                }
            } elseif ($TypeName -match 'SomeOtherSMOType') {
                # Mock other SMO types as needed
            }
            # Fall back to the default behavior for non-SMO types
            return Invoke-Expression "New-Object $TypeName"
        }

        # Mock any other functions called within BackupDatabase that interact with SMO types or perform actions that should not be executed during tests
        # Example: Mocking AddPercentHandler and CreateDevices which might interact with SMO objects or filesystem
        Mock AddPercentHandler { }
        Mock CreateDevices { return @('MockDevicePath') }

        # Assuming your script uses $OctopusParameters
        # This setup is already assumed to be in place from your description
    }

    It "Performs successful database backup" {
        # Assuming BackupDatabase is defined in a script you're testing, and that script has been sourced before running this test
        # This call directly tests the BackupDatabase function with mocked dependencies
        { BackupDatabase -ServerName "MockServer" -DatabaseName "MockDB" -BackupDirectory "C:\MockPath" -Devices 1 -CompressionOption 0 -Incremental $false -CopyOnly $false -RetentionPolicyEnabled $false -RetentionPolicyCount 0 -server (New-Object Object) -timestamp "MockTimestamp" } | Should -Not -Throw
    }

    # Add additional It blocks to cover more test cases as needed
}

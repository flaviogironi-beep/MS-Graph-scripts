# Connect to Microsoft Graph with permissions to read device management data
Connect-Graph -Scopes "DeviceManagementManagedDevices.Read.All"

Write-Host "Fetching managed devices from Intune..." -ForegroundColor Cyan

# Fetch all managed devices (handles pagination automatically if you have thousands of devices)
\$managedDevices = Get-MgDeviceManagementManagedDevice -All

# Define output path for the report
\$reportPath = "./Intune_Device_Compliance_Report.csv"
\$reportData = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($device in$managedDevices) {
    # Filter only for Windows devices (optional, you can remove this `if` if you want macOS/iOS too)
    if (\$device.OperatingSystem -eq "Windows") {
        
        # Check BitLocker key presence status if available in properties
        # Note: Detailed recovery keys require separate calls, but we can capture compliance and encryption flags
        \$reportData.Add([PSCustomObject]@{
            DeviceName          = \$device.DeviceName
            UserPrincipalName   = \$device.UserPrincipalName
            OperatingSystem     = \$device.OperatingSystem
            OSVersion           = \$device.OSVersion
            ComplianceState     = \$device.ComplianceState
            LastSyncDateTime    = \$device.LastSyncDateTime
            IsEncrypted         = \$device.IsEncrypted
            SerialNumber        = \$device.SerialNumber
            Model               = \$device.Model
        })
    }
}

# Export collected data to CSV
$reportData \vert{} Export-Csv -Path$reportPath -NoTypeInformation -Encoding utf8

Write-Host "Report successfully exported to: \$reportPath" -ForegroundColor Green
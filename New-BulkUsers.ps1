# Ensure Microsoft.Graph module is installed
# Run: Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph with required administrative permissions
Connect-Graph -Scopes "User.ReadWrite.All"

# Path to the CSV file containing user data
$csvPath = "./users.csv"

# Import user list from the CSV file
$users = Import-Csv -Path $csvPath

foreach ($row in $users) {
    try {
        # Define user parameters matching Graph API schema
        $params = @{
            AccountEnabled      = $true
            DisplayName         = $row.DisplayName
            MailNickname        = $row.MailNickname
            UserPrincipalName   = $row.UserPrincipalName
            GivenName           = $row.GivenName
            Surname             = $row.Surname
            PasswordProfile     = @{
                ForceChangePasswordNextSignIn = $true
                Password                      = $row.Password
            }
        }

        # Create the user in Entra ID / Microsoft 365
        $newUser = New-MgUser @params
        Write-Host "Successfully created user: $($newUser.UserPrincipalName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating user $($row.UserPrincipalName): $_" -ForegroundColor Red
    }
}
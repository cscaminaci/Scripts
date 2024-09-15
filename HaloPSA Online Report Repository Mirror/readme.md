# HaloPSA Online Repo Report Extractor

This PowerShell script extracts SQL reports from the HaloPSA online reporting repository system and saves them as individual SQL files locally. This is useful in using the queries as context in AI applications or to train schema models.

## Features

- Retrieves all reports from the HaloPSA Online Repository reporting API endpoint
- Handles pagination to fetch all available reports
- Extracts the SQL content for each report
- Saves each report's SQL as a separate file
- Provides progress feedback during execution

## Prerequisites

- PowerShell 7 or later
- Access to HaloPSA API (Client ID, Client Secret, Tenant Name, and API URL)
- Appropriate API scopes for accessing reports

## Setup

1. Clone this repository or download the `HaloPSA-Report-Extractor.ps1` script.
2. Open the script in a text editor.
3. Modify the following line with your Halo PSA API credentials:

```powershell
#Connect-HaloAPI -ClientID "YOUR_CLIENT_ID" -Tenant "YOUR_TENANT_NAME" -URL "https://YOURINSTANCE.halopsa.com" -ClientSecret "YOUR_CLIENT_SECRET" -Scopes "YOUR_SCOPES"
```
4. Update the `$clientName` variable with your MSP name as it appears in the Halo PSA URL:

```powershell
$clientName = "Your%20MSP%20Name"
```

## Usage

1. Open PowerShell.
2. Navigate to the directory containing the script.
3. Run the script:

```powershell
.\HaloPSA-Report-Extractor.ps1
```
The script will create a `HaloReports` directory in the same location and save all extracted SQL reports as individual files within this directory.

## Output

- SQL files will be saved in the `HaloReports` directory.
- File names will be in the format: `{ReportID}_{ReportName}.sql`
- Special characters in report names will be replaced with underscores.

## Error Handling

- The script includes error handling for API requests and file operations.
- Warnings will be displayed for reports without SQL content.
- Errors will be logged for any issues encountered during processing.

## Notes

- Ensure you have the necessary permissions to access the Halo PSA API and retrieve reports.
- The script uses the `Invoke-HaloRequest` function, which should be available in your Halo PSA PowerShell module.
- Adjust the `$PageSize` parameter in the `Get-Reports` function if needed (default is 50).

## Contributing

Contributions to improve the script are welcome. Please fork the repository and submit a pull request with your changes.


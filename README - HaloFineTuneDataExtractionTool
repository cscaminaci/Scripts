# HaloPSAFineTuneDataExtractionTool

This is a PowerShell script that helps in extracting and structuring data from Halo PSA (Professional Services Automation) for machine learning purposes, specifically for fine-tuning an AI model. The script interacts with the Halo PSA API to extract ticket data, including all actions taken on a ticket. The extracted data is then structured and formatted for fine-tuning an AI model.

## Getting Started

To get started with the script, you need to set your Halo client ID and client secret in the `Get-HaloPSAToken` function. You also need to replace `YOURHALOPSAURL` with the actual URL of your Halo PSA.

$HaloClientID = "<CLIENT ID>"
$HaloClientSecret = "<CLIENT SECRET>"
$uri = "https://YOURHALOPSAURL.HALOPSA.COM/auth/token"

## Functions

The script contains two main functions:

1. `Get-HaloPSAToken`: This function authenticates with the Halo PSA and retrieves the access token.
2. `Get-HaloTicketActions`: This function gets all actions related to a ticket from the Halo PSA.

## Importing Data

The script imports a list of closed ticket numbers from a CSV file for training the AI model. Make sure to replace `path_to_closed_tickets.csv` with the actual path to your CSV file.


$Global:ImportList = Import-Csv -Path "C:\Users\username\path_to_closed_tickets.csv"


## Filtering

The script includes a filter to exclude certain tickets based on specific conditions, such as tickets with no clearance note or tickets that have been closed via merge.


$Global:TicketsToScan = $ImportList | Where-Object { $_.ClearanceNote -ne "$null" -and $_.ClearanceNote -notmatch "Closed via Merge" -and $_.ClearanceNote -notmatch "Automated Closure Sent" -and $_.ClearanceNote -notmatch "#NAME?"} | Sort-Object -Property RequestID -Descending


## Output

The script outputs the structured data into a CSV file. Replace `export.csv` with the path and name of the file you wish to output the structured data to.


$PromptToAdd | Export-Csv -Path "C:\Users\username\export.csv" -NoTypeInformation -Append


## Progress Tracking

The script also provides progress tracking on the console, letting you know the number of tickets processed so far and the total number of tickets to be processed.

## Author

The script is written by Ceej Scaminaci - The MSP Automator.

Website: [mspautomator.com](http://mspautomator.com)

Copyright 2023

Please contact the author if you have any questions or issues with the script.

# Function to get reports from the API
function Get-Reports {
    param (
        [int]$PageNo = 1,
        [int]$PageSize = 50
    )
    
    $webRequestParams = @{
        Uri                = "https://halo.haloservicedesk.com/api/ReportRepository?pageinate=true&page_size=50&page_no=$($Pageno)&columns_id=24&includecolumns=false&order=name&orderdesc=false&clientname=$($ClientName)"
        Method             = "GET"
        Headers            = @{
            "Content-Type" = "application/json"
        }
        Body               = $null
        UseBasicParsing    = $true
        ErrorAction        = "Continue"
        TimeoutSec         = 30
        DisableKeepAlive   = $true
        MaximumRedirection = 5
    }

    Write-Verbose "Invoking Halo action to get reports for page $PageNo"
    try {
        $Reports = Invoke-HaloRequest -WebRequestParams $webRequestParams 
        Write-Verbose "Halo action completed successfully for page $PageNo"
        return $Reports
    }
    catch {
        Write-Error "Failed to get reports for page $PageNo : $_"
        return $null
    }
}

# Function to get a single report by ID
function Get-HaloRepositoryReport {
    param (
        [int]$ReportId
    )
    $webRequestParams = @{
        Uri                = "https://halo.haloservicedesk.com/api/ReportRepository/$($ReportId)?includedetails=true&loadreport=true&dontloadsystemreport=false&clientname=$($ClientName)"
        Method             = "GET"
        Headers            = @{
            "Content-Type" = "application/json"
        }
        Body               = $null
        UseBasicParsing    = $true
        ErrorAction        = "Continue"
        TimeoutSec         = 30
        DisableKeepAlive   = $true
        MaximumRedirection = 5
    }
    Write-Verbose "Invoking Halo action to get report $ReportId"
    try {
        $Report = Invoke-HaloRequest -WebRequestParams $webRequestParams 
        Write-Verbose "Halo action completed successfully for report $ReportId"
        return $Report
    }
    catch {
        Write-Error "Failed to get report $ReportId : $_"
        return $null
    }
}

#Change these values to match your Halo API configuration - alternatively you can connect first in the console and then comment this line out
Connect-HaloAPI -ClientID "YOUR_CLIENT_ID" -Tenant "YOUR_TENANT_NAME" -URL "https://YOURINSTANCE.halopsa.com" -ClientSecret "YOUR_CLIENT_SECRET" -Scopes "YOUR_SCOPES"
# Initialize an empty array to store all report IDs
$allReportIds = @()

#Define your client name for the reporting endpoint - retrieve this from the report repository URL bar in Halo or the browser console request headers
$clientName = "Your%20MSP%20Name"

# Get the first page of reports
$currentPage = 1
$reports = Get-Reports -PageNo $currentPage

# Loop through all pages
while ($reports -and $reports.reports.Count -gt 0) {
    # Add report IDs from the current page to the array
    $allReportIds += $reports.reports | Select-Object -ExpandProperty id
    
    # Move to the next page
    $currentPage++
    $reports = Get-Reports -PageNo $currentPage
}

# Create a directory to store the SQL files
$outputDir = ".\HaloReports"
if (-not (Test-Path -Path $outputDir)) {
    try {
        New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
        Write-Verbose "Created output directory: $outputDir"
    }
    catch {
        Write-Error "Failed to create output directory: $_"
        exit 1
    }
}

# Loop through all report IDs and save SQL to files
$totalReports = $allReportIds.Count
for ($i = 0; $i -lt $totalReports; $i++) {
    $reportId = $allReportIds[$i]
    Write-Progress -Activity "Processing Reports" -Status "Report $($i+1) of $totalReports" -PercentComplete (($i+1) / $totalReports * 100)
    
    try {
        $report = Get-HaloRepositoryReport -ReportId $reportId
        
        if ($report -and $report.sql) {
            $fileName = "{0}_{1}.sql" -f $report.id, ($report.name -replace '[^\w\-\.]', '_')
            $filePath = Join-Path -Path $outputDir -ChildPath $fileName
            $report.sql | Out-File -FilePath $filePath -Encoding utf8
            Write-Verbose "Saved SQL for report $($report.id) to $fileName"
        }
        else {
            Write-Warning "No SQL found for report $reportId"
        }
    }
    catch {
        Write-Error "Error processing report $reportId - $_"
    }
}

Write-Progress -Activity "Processing Reports" -Completed
Write-Host "All reports processed. SQL files saved in $outputDir"
# Scripts Repository

Welcome to the Scripts repository! This repository is a curated collection of scripts (mostly revolving around HaloPSA) designed to automate tasks, streamline processes, and enhance efficiency across various operations. The repository includes PowerShell scripts, Bash scripts, and other types of scripts catering to system administration, automation needs, and more.

## Contents

### Halo Reports

- A collection of text files and images providing templates and examples for generating various reports related to agent billable time, monthly hours, project profitability, and more in HaloPSA.

### HaloPSA Billing Scripts

- **Unreview-Actions.ps1 & Unreview-Actions-Parameterized.ps1**: Scripts for managing billing actions within HaloPSA, including a parameterized version for more flexible usage. These scripts can bulk unreview actions to fix labor entries.

### HaloPSA CSP License Scavenge Runbook

- **LicenseInquiry.ps1**: A PowerShell script designed to manage and report on Microsoft licenses using CSP graph API, returning the data to HaloPSA for decision support.

### HaloPSA English US Language Pack

- Files for implementing the unofficial English (United States) language pack in HaloPSA, including a CSV and an INI file. This language pack has been modified to remove all UK english spelling and terminology.

### HaloPSA Fine Tune Data Extraction Tool

- **HaloFineTuneDataExtractionTool.ps1**: A PowerShell script accompanied by a README, designed to extract data from HaloPSA tickets to create an AI model fine-tune.

### HaloPSA RepairShoppr Ticket Import

- **Sync-RepairShoprToHaloPSA.ps1**: A script for synchronizing open tickets from RepairShoppr to HaloPSA.

### HaloPSA SMS Identity Verification

- **VerifyUser.ps1**: A script intended for verifying user identity via SMS from inside of HaloPSA using Graph and Twilio.

### HaloPSA User Scripts

- **Unset-HaloServiceUsers.ps1**: A script for managing user settings within HaloPSA, specifically for unsetting service users in bulk.

### SentinelOne Installer Scripts

- Scripts for installing SentinelOne on various platforms, including a Bash script for Mac installations and a PowerShell script for other systems, along with a README for guidance.

### Whisper Speech to Text

- **WhisperSTT.ps1**: A PowerShell script that utilizes the Whisper model for speech-to-text conversion, accompanied by a detailed README.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Please feel free to fork the repository and submit pull requests. You can also open issues for bugs, suggestions, or any discussion related to the scripts.

## Usage

To use the scripts in this repository, you may need to adjust permissions or settings according to your environment and the specific requirements of each script. Please refer to the comments within each script or accompanying README files for detailed instructions on usage and prerequisites.

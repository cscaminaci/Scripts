# WhisperSTT

This repository contains a PowerShell script, `WhisperSTT.ps1`, for transcribing audio files using OpenAI's Whisper Automatic Speech Recognition (ASR) system. The script is designed to sanitize and process multiple files in a directory and output the transcriptions in JSON format.

## Prerequisites

* PowerShell 5.1 or higher
* Audio files in WAV format
* An OpenAI API key

## Installation

No installation is necessary. You can clone this repository and run the script locally on your system.

## Usage

There are two main functions in the script: `Invoke-WhisperASR` and `Sanitize-FileNames`.

### Sanitize-FileNames

This function sanitizes the filenames in a given directory. Only alphanumeric characters, underscores, hyphens, and periods are allowed in the filenames.

```powershell
Sanitize-FileNames -DirectoryPath "<path to folder>"
```

### Invoke-WhisperASR

This function transcribes all WAV files in a given directory using the Whisper ASR API.

```powershell
Invoke-WhisperASR -DirectoryPath "<path to folder>" -OutputDirectoryPath "<output folder>" -APIKey "<your open API key>"
```

## Parameters

* `DirectoryPath` - The folder containing the audio files you want transcribed.
* `OutputDirectoryPath` - The output folder for the transcription files.
* `APIKey` - Your OpenAI API key.
* `Model` - Currently only `whisper-1` is available.
* `Prompt` - If you want to add a prompt to tell the model to do something with this data, you can include it here.
* `Temperature` - 0 returns a deterministic response, the farther away from 0-0.2 range you get, the more random and...creative the transcribes get.
* `Language` - ISO language code. Including this always makes responses faster.

## Output

The transcriptions will be stored in the specified output directory in verbose JSON format, with one file per transcription.

## Progress Tracking

The script provides a progress bar to indicate the status of the transcriptions.

## Author

The script is written by Ceej Scaminaci - The MSP Automator.

Website: [mspautomator.com](http://mspautomator.com)

Copyright 2023

Please contact the author if you have any questions or issues with the script.
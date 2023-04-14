<#
.----------------. .----------------. .----------------.   .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. 
| .--------------. | .--------------. | .--------------. | | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. |
| | ____    ____ | | |    _______   | | |   ______     | | | |      __      | | | _____  _____ | | |  _________   | | |     ____     | | | ____    ____ | | |      __      | | |  _________   | | |     ____     | | |  _______     | |
| ||_   \  /   _|| | |   /  ___  |  | | |  |_   __ \   | | | |     /  \     | | ||_   _||_   _|| | | |  _   _  |  | | |   .'    `.   | | ||_   \  /   _|| | |     /  \     | | | |  _   _  |  | | |   .'    `.   | | | |_   __ \    | |
| |  |   \/   |  | | |  |  (__ \_|  | | |    | |__) |  | | | |    / /\ \    | | |  | |    | |  | | | |_/ | | \_|  | | |  /  .--.  \  | | |  |   \/   |  | | |    / /\ \    | | | |_/ | | \_|  | | |  /  .--.  \  | | |   | |__) |   | |
| |  | |\  /| |  | | |   '.___`-.   | | |    |  ___/   | | | |   / ____ \   | | |  | '    ' |  | | |     | |      | | |  | |    | |  | | |  | |\  /| |  | | |   / ____ \   | | |     | |      | | |  | |    | |  | | |   |  __ /    | |
| | _| |_\/_| |_ | | |  |`\____) |  | | |   _| |_      | | | | _/ /    \ \_ | | |   \ `--' /   | | |    _| |_     | | |  \  `--'  /  | | | _| |_\/_| |_ | | | _/ /    \ \_ | | |    _| |_     | | |  \  `--'  /  | | |  _| |  \ \_  | |
| ||_____||_____|| | |  |_______.'  | | |  |_____|     | | | ||____|  |____|| | |    `.__.'    | | |   |_____|    | | |   `.____.'   | | ||_____||_____|| | ||____|  |____|| | |   |_____|    | | |   `.____.'   | | | |____| |___| | |
| |              | | |              | | |              | | | |              | | |              | | |              | | |              | | |              | | |              | | |              | | |              | | |              | |
| '--------------' | '--------------' | '--------------' | | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' |
 '----------------' '----------------' '----------------'   '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' 
 WhisperSTT.ps1                                      
 Author: Ceej Scaminaci - The MSP Automator                                   
 Website: mspautomator.com                                                  
 Copyright 2023       
#>


<#
	.SYNOPSIS
		These functions help you sanitize files and transcribe them using the Whisper API from OpenAI.
	
	.DESCRIPTION
		Invoke-WhisperASR will upload a file under 25MB to the Whisper API, await the transcription against model large-v2, and return the transcription in a verbose JSON file.
	
	.PARAMETER DirectoryPath
		A folder containing the audio files you want transcribed
	
	.PARAMETER OutputDirectoryPath
		The output folder for the transcription files.
	
	.PARAMETER APIKey
		Your OpenAI API key.
	
	.PARAMETER Model
		Currently only whisper-1 is available.
	
	.PARAMETER Prompt
		If you want to add a prompt to tell the model to do something with this data, you can include it here.
	
	.PARAMETER Temperature
		0 returns a deterministic response, the farther away from 0-0.2 range you get, the more random and....creative the transcribes get.
	
	.PARAMETER Language
		ISO language code. Including this always makes responses faster.
	
	.EXAMPLE
		Prior to transcribing, it's wise to sanitize the file names in the directory to ensure they won't cause JSON parsing issues.

		Sanitize-FileNames -DirectoryPath "<path to folder>"
		
		When ready to transcribe all files in a folder, invoke the transcribe engine.

		Invoke-WhisperASR -DirectoryPath "<path to folder>" -OutputDirectoryPath "<output folder>" -APIKey "<your open API key>"
	
	.NOTES
		Provided free for community use by Ceej the MSP Automator - mspautomator.com - Please attribute this work to me where appropriate. Stealing isn't cool, you dicks.
#>


function Invoke-WhisperASR
{
	param (
		[string]$DirectoryPath,
		[string]$OutputDirectoryPath,
		[string]$APIKey,
		[string]$Model = "whisper-1",
		[string]$Prompt = $null,
		[double]$Temperature = 0,
		[string]$Language = "en"
	)
	
	$APIUrl = "https://api.openai.com/v1/audio/transcriptions"
	$ResponseFormat = "verbose_json"
	
	$files = Get-ChildItem -Path $DirectoryPath -Filter "*.wav"
	$totalFiles = $files.Count
	$currentFileIndex = 0
	
	$files | ForEach-Object {
		$currentFileIndex++
		$wavFilePath = $_.FullName
		$outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($wavFilePath) + ".json"
		$outputFilePath = Join-Path -Path $OutputDirectoryPath -ChildPath $outputFileName
		
		$headers = @{
			"Authorization" = "Bearer $APIKey"
		}
		
		# Construct form data
		$formData = @{
			"file" = (Get-Item -Path $wavFilePath)
			"model" = $Model
			"response_format" = $ResponseFormat
			"temperature" = $Temperature
		}
		
		if ($Prompt)
		{
			$formData["prompt"] = $Prompt
		}
		
		if ($Language)
		{
			$formData["language"] = $Language
		}
		
		Write-Output "Processing file: $($wavFilePath)"
		$response = Invoke-WebRequest -Uri $APIUrl -Method Post -Headers $headers -Form $formData
		
		# Save the response to a file
		Set-Content -Path $outputFilePath -Value $response.Content
		Write-Output "Finished processing file: $($wavFilePath)"
		
		# Update the progress bar
		Write-Progress -Activity "Transcribing audio files" -Status "Processing file $($currentFileIndex) of $($totalFiles)" -PercentComplete (($currentFileIndex / $totalFiles) * 100)
	}
	
	Write-Output "All files have been processed."
}


function Sanitize-FileNames
{
	param (
		[string]$DirectoryPath,
		[string]$AllowedCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.'
	)
	
	Get-ChildItem -Path $DirectoryPath -File | ForEach-Object {
		$oldFileName = $_.Name
		$sanitizedFileName = ($oldFileName.ToCharArray() | Where-Object { $AllowedCharacters.Contains($_) }) -join ''
		
		# If the sanitized file name is empty or unchanged, skip renaming
		if (-not [string]::IsNullOrWhiteSpace($sanitizedFileName) -and $sanitizedFileName -ne $oldFileName)
		{
			$newFilePath = Join-Path -Path $DirectoryPath -ChildPath $sanitizedFileName
			Rename-Item -Path $_.FullName -NewName $newFilePath
		}
	}
}

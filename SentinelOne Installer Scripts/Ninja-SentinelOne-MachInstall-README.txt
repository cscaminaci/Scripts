README - Ninja SentinelOne Installer

Prerequisites:

1. A public repo to upload registration tokens and installers to for download
2. A SentinelOne registration token file - to make this file, copy the SITE_TOKEN from the SentinelOne Portal and paste it into a blank text file, saving it as com.sentinelone.registration-token
3. Ninja installed with proper permissions granted on a MacOS device

Instructions:

1. Upload your SentinelOne .pkg file to your repo along with your registration-token file for that client
2. Alter the script URLs and file names to reflect the names of the files you uploaded
3. Add this script to NinjaRMM as a type ShellScript and assign to the client policy as a scheduled script to "Run Once Immediately" as root
4. You should see the endpoints start to populate in the SentinelOne portal if install is successful. Ninja will echo the script output to the console.
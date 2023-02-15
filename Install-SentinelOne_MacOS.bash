#!/bin/bash

#Make Temp Directory
mkdir -p /Volumes/Macintosh\ HD/Users/Shared/temp

#Go to temp
cd /Volumes/Macintosh\ HD/Users/Shared/temp

#download
curl -LO https://URL.TO.SENTINELONE/Sentinel_Release_macos_v22_2_3_6268.pkg
curl -LO https://URL.TO.SENTINELONE/com.sentinelone.registration-token
chmod -R 755 com.sentinelone.registration-token

#Run
sudo installer -pkg /Volumes/Macintosh\ HD/Users/Shared/temp/Sentinel_Release_macos_v22_2_3_6268.pkg -target /

exit 0
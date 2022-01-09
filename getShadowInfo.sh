#! /bin/bash

echo "Gathering Hostname and Public IP information..."
HOST=$(hostname)
IP=$(curl -4 icanhazip.com)
SHADOWCHECK=${HOST:0:6}
REGION=${HOST:7:2}
echo "Downloading additional files..."
wget https://github.com/ChaoticWeg/discord.sh/archive/refs/tags/v1.6.tar.gz > /dev/null 2>&1
tar -xvf v1.6.tar.gz > /dev/null 2>&1
cd discord.sh-1.6
echo -n "Please enter the webhook found in the shadow operators channel now: "
read -e WEBHOOK
while [[ $SHADOWCHECK != 'shadow' ]]; do
    echo "The shadow check has failed, please ensure your hostname is in the correct format." 
    exit

done
while  [[ $REGION != 'na' ]] && [[ $REGION != 'eu' ]] && [[ $REGION != 'ap' ]]; do
    echo "The region check has failed, please ensure your hostname is in the correct format." 
    exit

done
./discord.sh --webhook-url=$WEBHOOK --text "New Shadow Host has been added to Region - [$REGION] - [$HOST] - [$IP]"
echo "Cleaning up files..."
cd ..
rm -rf discord*
rm -rf v1.6*

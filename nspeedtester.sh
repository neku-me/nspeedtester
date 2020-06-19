#! /bin/bash
{
cd ~/
rm ./x-speedtest-summary ./x-speedtest-status ./x-speedtest-tempRaw
mv ./speedtest-summary ./x-speedtest-summary
mv ./speedtest-status ./x-speedtest-status
mv ./speedtest-tempRaw ./x-speedtest-tempRaw
# mv ./speedtest-share ./x-speedtest-share
} &> /dev/null

while true
do
    varDate=$(date) && varShortDate=$(date +%m-%d-%Y)
    varTime=$(echo $varDate | awk '{print $4}' | sed 's/\:/\-/g')
    echo $varDate >> ./speedtest-summary
    cat & speedtest --share | tee ./speedtest-tempRaw |  grep -e 'Download:\|Upload:\|results:' >> ./speedtest-summary
    printf "\n\r" >> ./speedtest-summary
    varDSum=$(cat ./speedtest-summary | grep 'Download:' | awk '{print $2}' | awk '{x+=$1}END{print $1}')
    varDLines=$(cat ./speedtest-summary | awk 'END{print NR}')
    varUSum=$(cat ./speedtest-summary | grep 'Download:' | awk '{print $2}' | awk '{x+=$1}END{print $1}')
    varULines=$(cat ./speedtest-summary | awk 'END{print NR}')
    varShare=$(cat ./speedtest-tempRaw | grep 'results:' | awk '{print $3}')
    varShareSerial=${varShare##*/}
    varShareSerial=${varShareSerial%.png}
    varDSpeed=$(echo "scale=2; $varDSum / $varDLines" | bc -l)
    varUSpeed=$(echo "scale=2; $varUSum / $varULines" | bc -l)
    echo $varDate 'Average DOWNLOAD:' $varDSpeed 'Mbps Average UPLOAD:' $varUSpeed 'Mbps' 'SHARE:' $varShare | tee  -a ./speedtest-status
{
    # Download the URL in a separate folder
    if [ ! -d "./speedtest-share" ]; then
        mkdir ./speedtest-share
    fi
    if [ ! -d "./speedtest-share/$varDate" ]; then
	mkdir ./speedtest-share/$varShortDate
    fi
    wget -O ./speedtest-share/$varShortDate/$varTime-$varShareSerial.png $varShare
} &> /dev/null
    sleep 15m
done

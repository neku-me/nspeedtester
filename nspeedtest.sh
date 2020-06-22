#! /bin/bash
{
cd ~/
# make folders
if [ ! -d "./nspeedtester" ]; then
    mkdir ./nspeedtester
fi
if [ ! -d "./nspeedtester/raw" ]; then
    mkdir ./nspeedtester/raw
fi
if [ ! -d "./nspeedtester/summary" ]; then
    mkdir ./nspeedtester/summary
fi
if [ ! -d "./nspeedtester/terminal-display" ]; then
    mkdir ./nspeedtester/terminal-display
fi
if [ ! -d "./nspeedtester/share" ]; then
    mkdir ./nspeedtester/share
fi

} &> /dev/null

while true
do
    varDate=$(date)
    varShortDate=$(date +%m-%d-%Y)
    varTime=$(echo $varDate | awk '{print $4}' | sed 's/\:/\-/g')

    echo $varDate >> ./nspeedtester/summary/summary-$varShortDate.txt
    cat & speedtest --share | tee ./nspeedtester/raw/tempRaw-$varShortDate.txt |  grep -e 'Download:\|Upload:\|results:' >> ./nspeedtester/summary/summary-$varShortDate.txt
    printf "\n\r" >> ./nspeedtester/summary/summary-$varShortDate.txt
    varDSum=$(cat ./nspeedtester/summary/summary-$varShortDate.txt | grep 'Download:' | awk '{print $2}' | awk '{x+=$1}END{print x}')
    varDLines=$(cat ./nspeedtester/summary/summary-$varShortDate.txt | grep 'Download:' | awk 'END{print NR}')
    varUSum=$(cat ./nspeedtester/summary/summary-$varShortDate.txt | grep 'Upload:' | awk '{print $2}' | awk '{x+=$1}END{print x}')
    varULines=$(cat ./nspeedtester/summary/summary-$varShortDate.txt | grep 'Upload:' | awk 'END{print NR}')
    varShare=$(cat ./nspeedtester/raw/tempRaw-$varShortDate.txt | grep 'results:' | awk '{print $3}')
    varShareSerial=${varShare##*/}
    varShareSerial=${varShareSerial%.png}
    varDSpeed=$(echo "scale=2; $varDSum / $varDLines" | bc -l)
    varUSpeed=$(echo "scale=2; $varUSum / $varULines" | bc -l)
    echo $varDate 'Average DOWNLOAD:' $varDSpeed 'Mbps Average UPLOAD:' $varUSpeed 'Mbps' 'SHARE:' $varShare | tee  -a ./nspeedtester/terminal-display/terminal-display-$varShortDate.txt
    {
    if [ ! -d "./nspeedtester/share/$varShortDate" ]; then
    mkdir ./nspeedtester/share/$varShortDate
    fi
    wget -O ./nspeedtester/share/$varShortDate/$varTime-$varShareSerial.png $varShare
    } &> /dev/null
    sleep 60m
done

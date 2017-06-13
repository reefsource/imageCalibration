#!/bin/bash

set -e

inputFileName=$1
long=$2
lat=$3
album_date=$4 #iso 8601

FILE_PATH=$(dirname $inputFileName)
FILE_NAME=$(echo "${inputFileName##*/}")
FILE_NAME=$(echo "${FILE_NAME%.*}")

echo "Analyzing file: $inputFileName"
echo "Path: $FILE_PATH"
echo "File name: $FILE_NAME"


# This is necessary to run Matlab Runtime Environment
# But causes some conflicts with awscli
# This is why we delete the LD_LIBRARY_PATH after the call
export LD_LIBRARY_PATH="/opt/mcr/v901/runtime/glnxa64:/opt/mcr/v901/bin/glnxa64:/opt/mcr/v901/sys/os/glnxa64"
/analyzeImage $FILE_PATH/$FILE_NAME".GPR" "path" "/external" "currentPixelCmRatio" "12"
export LD_LIBRARY_PATH=""


#If the .json file does not have geo-data, replace it
hasLatitude=$(jq '.GPSLatitude' $FILE_PATH/$FILE_NAME".json")
hasLongitude=$(jq '.GPSLongitude' $FILE_PATH/$FILE_NAME".json")

if [[ -z $hasLatitude || -n $hasLatitude || -z $hasLongitude || -n $hasLongitude ]]
  then
      echo "Updating GPS coordinates"
      jq --arg lat $lat --arg long $long --arg dateTime $album_date '.GPSLatitude=$lat | .GPSLongitude=$long | .GPSDateTime=$dateTime' $FILE_PATH/$FILE_NAME".json" > $FILE_PATH/$FILE_NAME".json.tmp"
      mv $FILE_PATH/$FILE_NAME".json.tmp" $FILE_PATH/$FILE_NAME".json"
  else
      echo "GPS coordinates are present in the json file"
fi


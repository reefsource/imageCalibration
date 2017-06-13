#!/bin/bash

inputFileName=$1
upload_id=$2
long=$3
lat=$4
album_date=$5 #iso 8601

FILE_PATH=$(dirname $inputFileName)
FILE_NAME=$(echo "${inputFileName##*/}")
FILE_NAME=$(echo "${FILE_NAME%.*}")

echo "Analyzing file: $inputFileName"
echo "Path: $FILE_PATH"
echo "File name: $FILE_NAME"


jsonFileName=$FILE_PATH/$FILE_NAME'.json'
exiftool -json $FILE_PATH/$FILE_NAME.GPR > $jsonFileName

jq '.[0]' $jsonFileName > $jsonFileName.tmp
mv $jsonFileName.tmp $jsonFileName

hasLatitude=$(jq '.GPSLatitude' $jsonFileName)
hasLongitude=$(jq '.GPSLongitude' $jsonFileName)

#If the .json file does not have geo-data, replace it
if [[ -z $hasLatitude || -n $hasLatitude || -z $hasLongitude || -n $hasLongitude ]]
  then
      echo $lat $long
      jq --arg lat $lat --arg long $long --arg dateTime $album_date '.GPSLatitude=$lat | .GPSLongitude=$long | .GPSDateTime=$dateTime' $jsonFileName > $jsonFileName.tmp
      mv $jsonFileName.tmp $jsonFileName
  else
      echo "GPS coordinates are present in the json file"
fi




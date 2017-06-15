#!/bin/bash

set -e

inputFileName=$1
upload_id=$2
long=$3
lat=$4
album_date=$5 #iso 8601

AWS_PATH=$(dirname $inputFileName)
FILE_NAME=$(echo "${inputFileName##*/}")
FILE_NAME=$(echo "${FILE_NAME%.*}")

echo "Analyzing file: $inputFileName"
echo "AWS path: $AWS_PATH"
echo "File name: $FILE_NAME"

function submitResult {
    jq -n --arg upload_id "$upload_id" --arg stage "stage_2" --arg result "$1" '{uploaded_file_id: $upload_id, stage: $stage, json: $result}' | curl -v \
        -H "Content-Type: application/json" \
        -H "Authorization: Token ${AUTH_TOKEN}" \
        -X POST -d@- http://coralreefsource.org/api/v1/results/submit/
}

function submitError {
   submitResult "{\"error\": \"$1\"}"
   exit -1
}

aws s3 cp $inputFileName /$FILE_NAME.GPR
aws s3 cp $AWS_PATH/${FILE_NAME}_stage1.json /$FILE_NAME.json

if ! LD_LIBRARY_PATH="/opt/mcr/v901/runtime/glnxa64:/opt/mcr/v901/bin/glnxa64:/opt/mcr/v901/sys/os/glnxa64" /analyzeImage /$FILE_NAME".GPR" "path" "/external" "currentPixelCmRatio" "12"; then submitError "analyzeImage failed" ; fi


#If the .json file does not have geo-data, replace it
hasLatitude=$(jq '.GPSLatitude' /$FILE_NAME.json)
hasLongitude=$(jq '.GPSLongitude' /$FILE_NAME.json)

if [[ -z $hasLatitude || -n $hasLatitude || -z $hasLongitude || -n $hasLongitude ]]
  then
      echo "Updating GPS coordinates $lat $long $album_date"
      jq --arg lat "$lat" --arg long "$long" '.GPSLatitude=$lat | .GPSLongitude=$long' ${FILE_NAME}".json" > /${FILE_NAME}".json.tmp"
      mv /$FILE_NAME".json.tmp" /$FILE_NAME".json"
  else
      echo "GPS coordinates are present in the json file"
fi

echo "Copying files to S3"
aws s3 cp $FILE_NAME"_labels.png" $AWS_PATH/$FILE_NAME"_labels.png" --acl 'public-read'
aws s3 cp $FILE_NAME.json $AWS_PATH/${FILE_NAME}_stage2.json

echo "Done"
jq -n --arg upload_id "$upload_id" --arg stage "stage_2" '{uploaded_file_id: $upload_id, stage: $stage}' | curl -v \
    -H "Content-Type: application/json" \
    -H "Authorization: Token ${AUTH_TOKEN}" \
    -X POST -d@- http://coralreefsource.org/api/v1/results/stage2complete/

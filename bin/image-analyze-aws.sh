#!/bin/bash

inputFileName=$1
upload_id=$2

AWS_PATH=$(dirname $inputFileName)
FILE_NAME=$(echo "${inputFileName##*/}")
FILE_NAME=$(echo "${FILE_NAME%.*}")

echo "Analyzing file: $inputFileName"
echo "AWS path: $AWS_PATH"
echo "File name: $FILE_NAME"

aws s3 cp $inputFileName /$FILE_NAME.GPR
aws s3 cp $AWS_PATH/${FILE_NAME}_stage1.json /$FILE_NAME.json

# This is necessary to run Matlab Runtime Environment
# But causes some conflicts with awscli
# This is why we delete the LD_LIBRARY_PATH after the call
export LD_LIBRARY_PATH="/opt/mcr/v901/runtime/glnxa64:/opt/mcr/v901/bin/glnxa64:/opt/mcr/v901/sys/os/glnxa64"
/analyzeImage /$FILE_NAME.GPR "path" "/data"
export LD_LIBRARY_PATH=""

aws s3 cp $FILE_NAME"_labels.png" $AWS_PATH/$FILE_NAME"_labels.png" --acl 'public-read'
aws s3 cp $FILE_NAME.json $AWS_PATH/${FILE_NAME}_stage2.json

jq -n --arg upload_id "$upload_id" '{uploaded_file_id: $upload_id}' | curl \
    -H "Content-Type: application/json" \
    -H "Authorization: Token ${AUTH_TOKEN}" \
    -X POST -d@- http://coralreefsource.org/api/v1/results/stage2complete/

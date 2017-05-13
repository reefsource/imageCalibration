#!/bin/bash

cp ../analyzeImage/for_redistribution_files_only/analyzeImage ./analyzeImage
cp ../../coralClassification/devkit/meta.mat ./devkit/meta.mat
mkdir ./devkit/descriptors
cp ../../coralClassification/descriptors/normalizer.mat ./devkit/descriptors/normalizer.mat
cp ../../coralClassification/descriptors/model.dat ./devkit/descriptors/model.dat
cp ../svmLinearData.mat ./svmLinearData.mat

cp -r ../../coralClassification/libsvm ./devkit/

docker build -t hblasins/image-analyze --build-arg http_proxy="http://10.102.1.10:8000" --build-arg https_proxy="http://10.102.1.10:8000" --rm=false .

docker push hblasins/image-analyze
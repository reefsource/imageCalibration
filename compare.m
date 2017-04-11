close all;
clear all;
clc;

dbPath = fullfile('/','Users','hblasinski','Documents','MATLAB',...
    'reefsource','imageCalibration','SamplesWithTarget');



files = dir(fullfile(dbPath,'*.GPR'));

%%

for f=10:length(files)
    
    imagePath = fullfile(dbPath,files(f).name);
    
    % Normalize image
    I = readRawImage(imagePath);
    I = double(I);
    
    [~, keypointFile] = fileparts(imagePath);
    load(fullfile(dbPath,sprintf('%s.mat',keypointFile)));
    
    mask = [];
    
    I = imageExpose(I,0.99,mask);
    Igm = I.^(1/2.2);
    
    [hLin, mapLin] = computeHistogramML(I);
    [hGam, mapGam] = computeHistogramML(Igm,'linear',false);
    [hLinV2, ~, mapLinV2] = computeHistogramV2(I,[],mask);
    [hGamV2, ~, mapGamV2] = computeHistogramV2(Igm,[],mask);
    [hLinGT, mapLinGT] = computeHistogramGT(I,keypoints,'intensityDelta',0.15);
    [hGamGT, mapGamGT] = computeHistogramGT(Igm,keypoints,'intensityDelta',0.15);
    
    figure;
    subplot(1,2,1);
    imshow(Igm);
    subplot(1,2,2);
    bar([hLin hGam hLinV2 hGamV2 hLinGT hGamGT]);
    legend('ML-Linear','ML-Gamma','Prop-Lin','Prop-Gamma','GT-Lin','GT-gamma');
    drawnow;
    
    figure;
    subplot(2,3,1);
    imagesc(mapLin);
    subplot(2,3,4);
    imagesc(mapGam);
    subplot(2,3,2);
    imagesc(mapLinV2);
    subplot(2,3,5);
    imagesc(mapGamV2);
    subplot(2,3,3);
    imagesc(mapLinGT);
    subplot(2,3,6);
    imagesc(mapGamGT);
    
    
    
end
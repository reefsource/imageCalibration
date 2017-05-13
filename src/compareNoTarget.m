close all;
clear all;
clc;

dbPath = fullfile('/','Users','hblasinski','Documents','MATLAB',...
    'reefsource','imageCalibration','SampleImages');



files = dir(fullfile(dbPath,'*.GPR'));

%%

for f=1:length(files)
    
    imagePath = fullfile(dbPath,files(f).name);
    
    % Normalize image
    I = readRawImage(imagePath);
    I = double(I);
    
    mask = [];
    
    I = imageExpose(I,0.99,mask);
    Igm = I.^(1/2.2);
    
    [hLin, mapLin] = computeHistogramML(I);
    [hGam, mapGam] = computeHistogramML(Igm,'linear',false);
    [hLinV2, ~, mapLinV2] = computeHistogramV2(I,[],mask);
    [hGamV2, ~, mapGamV2] = computeHistogramV2(Igm,[],mask);
    
    figure;
    subplot(1,2,1);
    imshow(Igm);
    subplot(1,2,2);
    bar([hLin hGam hLinV2 hGamV2 ]);
    legend('ML-Linear','ML-Gamma','Prop-Lin','Prop-Gamma');
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

      
end
close all;
clear all;
clc;

dbPath = fullfile('/','Users','hblasinski','Documents','MATLAB',...
    'reefsource','imageCalibration','SampleImagesWithTarget');


classLabelStr = '1; 2; 3; 4; 5; 6;';


results = fopen('ImageHistograms.csv','w');
fprintf(results,'; %s','Whole image'); for i=1:11, fprintf(results,'; '); end; 
fprintf(results,'; %s','Automatic segmentation'); for i=1:11, fprintf(results,'; '); end; 
fprintf(results,'; %s','Manual ROI'); for i=1:11, fprintf(results,'; '); end; fprintf(results,'\n');

for i=1:3, fprintf(results,'; Proposed; ; ; ; ; ; Chart based ; ; ; ; ;'); end; fprintf(results,'\n');
fprintf(results,'Image name; ');
for i=1:6, fprintf(results,'%s',classLabelStr); end; fprintf(results,'\n');
  

%%
files = dir(fullfile(dbPath,'*.GPR'));

delta = 0.1;

for f=1:length(files)
    
    imagePath = fullfile(dbPath,files(f).name);
    [~, imageFileName] = fileparts(imagePath);
    
    % Normalize image
    I = readRawImage(imagePath);
    I = double(I);
    
    [~, keypointFile] = fileparts(imagePath);
    load(fullfile(dbPath,sprintf('%s.mat',keypointFile)));
    

    I = imageExpose(I,0.99,[]);
    

    % Whole image
    [hLin, mapLin] = computeHistogramML(I);
    [hLinGT, mapLinGT] = computeHistogramGT(I,keypoints,'intensityDelta',delta);
    
    % Automatic segmentation
    prevI = imread(fullfile(dbPath,sprintf('%s_preview.jpg',imageFileName)));
    mask = segmentImage(prevI,'path','/Users/hblasinski/Documents/MATLAB/reefsource/coralClassification');

    mask = imresize(mask,[size(I,1) size(I,2)],'nearest');
    
    [hLinAut, mapLinAut] = computeHistogramML(I,'mask',mask);
    [hLinGTAut, mapLinGTAut] = computeHistogramGT(I,keypoints,'intensityDelta',delta,'mask',mask);
    
    
    % ROI
    bBox = round(boundingBox);
    mask = false(size(I,1),size(I,2));
    mask(bBox(2):bBox(2)+bBox(4),bBox(1):bBox(1)+bBox(3)) = true;
    
    [hLinROI, mapLinROI] = computeHistogramML(I,'mask',mask);
    [hLinGTROI, mapLinGTROI] = computeHistogramGT(I,keypoints,'intensityDelta',delta,'mask',mask);
    
    figure;
    
    subplot(2,3,1);
    imagesc(mapLin);
    subplot(2,3,4);
    imagesc(mapLinGT);
    
    subplot(2,3,2);
    imagesc(mapLinAut);
    subplot(2,3,5);
    imagesc(mapLinGTAut);
    
    subplot(2,3,3);
    imagesc(mapLinROI);
    subplot(2,3,6);
    imagesc(mapLinGTROI);
    
    figure;
    subplot(1,3,1);
    bar([hLin hLinGT]);
    
    subplot(1,3,2);
    bar([hLinAut hLinGTAut]);
    
    subplot(1,3,3);
    bar([hLinROI hLinGTROI]);

    
    fprintf(results,'%s; ',files(f).name);
    for j=1:6, fprintf(results,'%f; ',hLin(j)); end
    for j=1:6, fprintf(results,'%f; ',hLinGT(j)); end
    for j=1:6, fprintf(results,'%f; ',hLinAut(j)); end
    for j=1:6, fprintf(results,'%f; ',hLinGTAut(j)); end
    for j=1:6, fprintf(results,'%f; ',hLinROI(j)); end
    for j=1:6, fprintf(results,'%f; ',hLinGTROI(j)); end
    fprintf(results,'\n');
    
    %{
    [~, fN] = fileparts(files(f).name);
    imwrite(Igm,fullfile(dbPath,sprintf('%s.jpg',fN)));
    %}
    
    
    
end

fclose(results);
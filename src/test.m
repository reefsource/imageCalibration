close all;
clear all;
clc;


% dataDirectory = fullfile('/','Users','hblasinski','Documents','MATLAB',...
%                          'reefsource','imageCalibration','SampleImages');

%dataDirectory = fullfile('/','Users','hblasinski','Google Drive','Magic Grant 2016-17',...
%                         'Florida Photos','RAW Files');

dataDirectory = fullfile('/','Users','hblasinski','Desktop','subset');

files = dir(fullfile(dataDirectory,'*.GPR'));
for f=5:length(files)
    
    cmd = sprintf('docker run -ti --rm -v ''%s'':''/Input'' hblasins/image-preprocess "/Input/%s"',dataDirectory,files(f).name);
    system(cmd);
    
    
    analyzeImage(fullfile(dataDirectory,files(f).name),...
        'path',fullfile('/','Users','hblasinski','Documents','MATLAB','reefsource','imageCalibration','external'),...
        'DEBUG',true,...
        'currentPixelCmRatio',12);
    
    drawnow;
end

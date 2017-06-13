close all;
clear all;
clc;


% dataDirectory = fullfile('/','Users','hblasinski','Documents','MATLAB',...
%                          'reefsource','imageCalibration','SampleImages');

%dataDirectory = fullfile('/','Users','hblasinski','Google Drive','Magic Grant 2016-17',...
%                         'Florida Photos','RAW Files');

dataDirectory = fullfile('/','Users','hblasinski','Desktop','subset');

files = dir(fullfile(dataDirectory,'*.GPR'));
for f=1:length(files)
    
    
    
    
    analyzeImage(fullfile(dataDirectory,files(f).name),...
        'path',fullfile('/','Users','hblasinski','Documents','MATLAB','reefsource','external'),...
        'DEBUG',true,...
        'currentPixelCmRatio',5);
    
    drawnow;
end

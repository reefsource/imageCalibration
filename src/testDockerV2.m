close all;
clear all;
clc;


% dataDirectory = fullfile('/','Users','hblasinski','Documents','MATLAB',...
%                          'reefsource','SampleImagesWithTarget');
                     
dataDirectory = fullfile('/','Users','hblasinski','Desktop','subset');                     
files = dir(fullfile(dataDirectory,'*.GPR'));
for f=1:length(files)
   
    cmd = sprintf('docker run -ti --rm -v ''%s'':''/Input'' hblasins/image-preprocess "/Input/%s"',dataDirectory,files(f).name);
    system(cmd);
    
    fileName = fullfile(dataDirectory,files(f).name);
    analyzeImage(fileName,...
        'path',fullfile('/','Users','hblasinski','Documents','MATLAB','reefsource','external'),...
        'DEBUG',true,...
        'currentPixelCmRatio',12);
    
    drawnow;
    
end


close all;
clear all;
clc;


% dataDirectory = fullfile('/','Users','hblasinski','Documents','MATLAB',...
%                          'reefsource','imageCalibration','SampleImages');
  
dataDirectory = fullfile('/','Users','hblasinski','Desktop','sample2'); 


files = dir(fullfile(dataDirectory,'*.GPR'));
for f=1:length(files)
   
    cmd = sprintf('docker run -ti --rm -v ''%s'':''/Input'' hblasins/image-preprocess "/Input/%s"',dataDirectory,files(f).name);
    system(cmd);
    
    
    cmd = sprintf('docker run --rm -ti -v''%s'':''/Input'' hblasins/image-analyze /Input/%s -123 +10 666',dataDirectory,files(f).name);
    system(cmd);
    
end

fclose(results);
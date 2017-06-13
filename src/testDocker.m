close all;
clear all;
clc;


% dataDirectory = fullfile('/','Users','hblasinski','Documents','MATLAB',...
%                          'reefsource','imageCalibration','SampleImages');
  
dataDirectory = fullfile('/','Users','hblasinski','Google Drive','Magic Grant 2016-17',...
                         'Florida Photos','RAW Files');


files = dir(fullfile(dataDirectory,'*.GPR'));
for f=1:length(files)
   
    cmd = sprintf('docker run --rm -ti -v''%s'':''/data'' hblasins/image-analyze /analyzeImage /data/%s',dataDirectory,files(f).name);
    system(cmd);
    
    [~, fileName] = fileparts(files(f).name);
    
    jsonData = loadjson(fullfile(dataDirectory,sprintf('%s.json',fileName)));
    
    fprintf(results,'%s; ',files(f).name);
    for j=1:6
        fprintf(results,'%f; ',jsonData.coral.histogram.values(j));
    end
    fprintf(results,'\n');
    
end

fclose(results);
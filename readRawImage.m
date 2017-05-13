function [ I ] = readRawImage( imageFilePath )

[imagePath, imageName, imageExt] = fileparts(imageFilePath);


% dngPath = fullfile('/','Applications','Adobe DNG Converter.app','Contents','MacOS');

%% Docker implementation
cmd = sprintf('wine /AdobeDNGConverter.exe -l -u %s',imageFilePath);
system(cmd);


dngImage = fullfile(imagePath,sprintf('%s.%s',imageName,'dng'));
cmd = sprintf('/usr/bin/dcraw -v -r 1 1 1 1 -H 0 -o 0 -d -j -4 %s',dngImage);
system(cmd);

%%

ppmImage = fullfile(imagePath,sprintf('%s.%s',imageName,'ppm'));
I = imread(ppmImage);

% Remove temporary files.
system(sprintf('rm %s',ppmImage));
system(sprintf('rm %s',dngImage));

end

 
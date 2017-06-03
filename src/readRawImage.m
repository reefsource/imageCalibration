function [ I ] = readRawImage( imageFilePath )

[imagePath, imageName, imageExt] = fileparts(imageFilePath);


% dngPath = fullfile('/','Applications','Adobe DNG Converter.app','Contents','MacOS');

%% Docker implementation
try
    cmd = sprintf('wine /AdobeDNGConverter.exe -l -u %s',imageFilePath);
    [status, res] = system(cmd);
    
    if status == 0
        dngImage = fullfile(imagePath,sprintf('%s.%s',imageName,'dng'));
        cmd = sprintf('/usr/bin/dcraw -v -r 1 1 1 1 -H 0 -o 0 -d -j -4 %s',dngImage);
        system(cmd);
    end
catch
    fprintf('Docker commands failed\n');
end

%% OSX implementation
try
    cmd = sprintf('/Applications/Adobe\\ DNG\\ Converter.app/Contents/MacOS/Adobe\\ DNG\\ Converter -l -u "%s"',imageFilePath);
    [status, res] = system(cmd);
    
    if status == 0
        dngImage = fullfile(imagePath,sprintf('%s.%s',imageName,'dng'));
        cmd = sprintf('/usr/local/bin/dcraw -v -r 1 1 1 1 -H 0 -o 0 -d -j -4 "%s"',dngImage);
        system(cmd);
    end
catch
    fprintf('OSX commands failed\n');
end

%%

ppmImage = fullfile(imagePath,sprintf('%s.%s',imageName,'ppm'));
I = imread(ppmImage);

% Remove temporary files.
system(sprintf('rm "%s"',ppmImage));
system(sprintf('rm "%s"',dngImage));

end

 
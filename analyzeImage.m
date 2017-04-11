function analyzeImage( fileName, varargin )

p = inputParser;
p.addOptional('previewHeight',768);
p.addOptional('previewWidth',1024);
p.parse(varargin{:});
inputs = p.Results;


[path, imageFileName] = fileparts(fileName);

% Read json data
jsonFileName = fullfile(path,sprintf('%s.json',imageFileName));

if exist(jsonFileName,'file')
    jsonData = loadjson(jsonFileName);
else
    jsonData = struct();
end

% Read preview image
try
    prevI = imread(fullfile(path,sprintf('%s_preview.jpg',imageFileName)));
    previewHeight = size(prevI,1);
    previewWidth = size(prevI,2);
catch
    previewHeight = inputs.previewHeight;
    previewWidth = inputs.previewWidth;
end


% Read raw image
I = readRawImage(fileName);
I = double(I);

% Pre-process the image
mask = [];
I = imageExpose(I,0.99,mask);

% Compute the histogram
[histogram, map] = computeHistogramML(I);

map = imresize(map,[previewHeight, previewWidth],'nearest');
colorMap = jet(6);
colorMap = flipud(colorMap); % 6 is good, 1 is bad(red)
mapRGB = ind2rgb(map,colorMap);
imwrite(mapRGB,fullfile(path,sprintf('%s_labels.png',imageFileName)));

jsonData.coral.histogram.values = histogram;
jsonData.coral.histogram.bins = 1:6;

% Mean
jsonData.coral.mean = jsonData.coral.histogram.bins*jsonData.coral.histogram.values;

% Mode
[~, id] = max(histogram);
jsonData.coral.mode = jsonData.coral.histogram.bins(id);

% Percentiles
jsonData.coral.percentiles.bins = [5 15 25 50 75 85 95];
jsonData.coral.percentiles.values = prctile(map(:),jsonData.coral.percentiles.bins);

savejson('',jsonData,jsonFileName);

end


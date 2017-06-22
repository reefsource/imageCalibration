function analyzeImage( fileName, varargin )

p = inputParser;
p.KeepUnmatched = true;
p.addOptional('previewHeight',768);
p.addOptional('previewWidth',1024);
p.addOptional('DEBUG',false);
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
    prevI = [];
end


% Read raw image
I = readRawImage(fileName);
I = double(I);

IatDepth = imageExpose(I,0.99,[]);
I = deDepthImage(IatDepth);
I = imageExpose(I,0.99,[]);


if isempty(prevI)
    prevI = imresize(IatDepth,[previewHeight previewWidth],'nearest');
end

% Pre-process the image

mask = segmentImage(prevI,varargin{:});
% mask = segmentImage(I.^(1/2.2),varargin{:});

if sum(mask(:)==1) == 0, mask = []; end

% Compute the histogram
[histogram, map] = computeHistogramML(I, 'mask', mask, varargin{:});

map = imresize(map,[previewHeight, previewWidth],'nearest');
colorMap = jet(6);
colorMap = flipud(colorMap); % 6 is good, 1 is bad(red)
mapRGB = ind2rgb(map,colorMap);

mapRGBvec = reshape(mapRGB,[previewHeight*previewWidth,3]);
prevIvec = reshape(im2double(prevI),[previewHeight*previewWidth,3]);

mapRGBvec(~mask(:),:) = prevIvec(~mask(:),:);
mapRGB = reshape(mapRGBvec,[previewHeight, previewWidth, 3]);

imwrite(mapRGB,fullfile(path,sprintf('%s_labels.jpg',imageFileName)));

if inputs.DEBUG
    figure; imshow(mapRGB);
    fs = 20;
    figure; bar(histogram);
    xlabel('Coral health','FontSize',fs);
    % print('-dpng','Histogram.png');
end

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

% Final score
% (At this point it is the same as the mean score)
jsonData.coral.score = round(jsonData.coral.mean*10)/10;

savejson('',jsonData,jsonFileName);

end


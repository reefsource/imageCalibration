function [ histogram, map ] = computeHistogramML( I, varargin )

p = inputParser;
p.addOptional('linear',true);
p.addOptional('scale',0.25);
p.addOptional('mask',[]);
p.addOptional('path','./data/');
p.parse(varargin{:});
inputs = p.Results;



I = imresize(I,inputs.scale,'nearest');

h = size(I,1);
w = size(I,2);
c = size(I,3);

if isempty(inputs.mask)
    mask = true(h,w);
else
    mask = imresize(inputs.mask,[h, w],'nearest');
end


Ivec = reshape(I,[h*w,c]);
Ivec = Ivec(mask(:),2:3);

if inputs.linear
    load(fullfile(inputs.path,'svmLinearData.mat'));
else
    load(fullfile(inputs.path,'svmGammaData.mat'));
end

%# function ClassificationECOC

predictions = predict(model,Ivec);
map = zeros(h*w,1);
map(mask(:)) = predictions;
map = reshape(map,[h w]);

histogram = zeros(6,1);
for i=1:6
    histogram(i) = sum(predictions == i);
end

histogram = histogram/sum(histogram);



end


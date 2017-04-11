function [ histogram, map ] = computeHistogramML( I, varargin )

p = inputParser;
p.addOptional('linear',true);
p.addOptional('scale',0.25);
p.parse(varargin{:});
inputs = p.Results;



I = imresize(I,inputs.scale,'nearest');

h = size(I,1);
w = size(I,2);
c = size(I,3);


Ivec = reshape(I,[h*w,c]);
Ivec = Ivec(:,2:3);

if inputs.linear
    load('svmLinearData.mat');
else
    load('svmGammaData.mat');
end

predictions = predict(model,Ivec);
map = reshape(predictions,[h w]);

histogram = zeros(6,1);
for i=1:6
    histogram(i) = sum(predictions == i);
end

histogram = histogram/sum(histogram);



end


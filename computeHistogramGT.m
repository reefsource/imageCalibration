function [ histogram, map ] = computeHistogramGT( I, keypoints, varargin )

p = inputParser;
p.addOptional('spatialDelta',5);
p.addOptional('intensityDelta',0.05);
p.addOptional('mask',[]);
p.parse(varargin{:});
inputs = p.Results;


h = size(I,1);
w = size(I,2);
c = size(I,3);

if isempty(inputs.mask)
    inputs.mask = true(h*w,1);
end

Ivec = reshape(I,[h*w,c]);

histogram = zeros(6,1);

map = zeros(h,w);

for i=1:size(keypoints,1) 
    
        xx = keypoints(i,1)-inputs.spatialDelta:keypoints(i,1)+inputs.spatialDelta;
        yy = keypoints(i,2)-inputs.spatialDelta:keypoints(i,2)+inputs.spatialDelta;
        
        %nonSaturatedROI = nonSaturated(sub2ind([h,w],yy,xx));
        nonSaturatedROI = true(length(yy),length(xx));
        
        Ir = I(yy,xx,1);
        Ig = I(yy,xx,2);
        Ib = I(yy,xx,3);
        
        Ir = mean(Ir(nonSaturatedROI));
        Ig = mean(Ig(nonSaturatedROI));
        Ib = mean(Ib(nonSaturatedROI));
                
        
        
        ids = ((Ivec(:,1) > (Ir-inputs.intensityDelta)) & (Ivec(:,1) < (Ir + inputs.intensityDelta))) & ...
              ((Ivec(:,2) > (Ig-inputs.intensityDelta)) & (Ivec(:,2) < (Ig + inputs.intensityDelta))) & ...
              ((Ivec(:,3) > (Ib-inputs.intensityDelta)) & (Ivec(:,3) < (Ib + inputs.intensityDelta)));
        
        histogram(mod(i-1,6)+1) = histogram(mod(i-1,6)+1) + sum(ids(inputs.mask));
        
        
        map(inputs.mask(:) & ids) = (mod(i-1,6)+1);
        
end

histogram = histogram/sum(histogram);


end


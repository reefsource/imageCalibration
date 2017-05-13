function [ counts ] = getHistogram( I, x, y, delta )

nBins = length(x);
counts = zeros(nBins,1);
nChannels = size(I,3);

selMask = zeros(size(I,1),size(I,2));

for i=1:nBins
   
    reference = I(y(i),x(i),:);
    
    mask = ones(size(I,1),size(I,2));
    for c=1:nChannels
        mask = mask & (reference(c)*(1-delta) <=  I(:,:,c)) &  (I(:,:,c) <= reference(c)*(1+delta));
    end
    
    selMask = selMask | mask;
    
    figure; imagesc(mask);
    
    counts(i) = sum(mask(:));
    
    
end


figure; imagesc(selMask);


end


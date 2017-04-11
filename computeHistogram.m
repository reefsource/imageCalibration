function [ histogram, bins ] = computeHistogram( image, varargin )

p = inputParser;
p.addRequired('image',@(x) size(x,3) == 3);
p.addOptional('nBins',6,@isscalar);
p.addOptional('binScale',2,@isscalar);
p.addOptional('blueScale',0.5,@isscalar);

p.parse(varargin{:});


nBins = p.Results.nBins;
binScale = p.Results.binScale;
blueScale = p.Results.blueScale;



lineBins = linspace(0,1,nBins+1);
lineHist = zeros(nBins,1);

for i=2:nBins+1
    
    deltaG = lineBins(i) - lineBins(i-1);
    deltaB = binScale*deltaG;
    
    gRef = lineBins(i-1) + deltaG/2;
    bRef = blueScale*gRef;
    
    bLower = bRef - deltaB/2;
    bUpper = bRef + deltaB/2;
    
    gIndicator = image(:,:,2) > lineBins(i-1) & image(:,:,2) <= lineBins(i);
    bIndicator = image(:,:,3) > bLower & image(:,:,3) <= bUpper;
    
    cond = gIndicator & bIndicator;
    
    
    lineHist(i-1) = sum(cond(:));
      
end

histogram = lineHist;
bins = lineBins;


end


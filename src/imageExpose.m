function [ result ] = imageExpose( img, percent, mask )

h = size(img,1);
w = size(img,2);
c = size(img,3);

if isempty(mask)
    mask = true(h,w,c);
    mask = mask(:);
else
    mask = repmat(mask,[1 1 c]);
    mask = mask(:);
end

minVal = min(img(mask));
maxVal = max(img(mask));
imgNorm = (img - minVal)/(maxVal-minVal);

[h, bins] = hist(imgNorm(mask),256*256);
chist= cumsum(h)/sum(h);





locSat = find(chist >= percent,1,'first');
locBlack = find(chist <= 1-percent,1,'last');

newMax = bins(locSat);
newMin = bins(locBlack);

result = (imgNorm - newMin)/(newMax - newMin);
result = max(min(result,1),0);


end


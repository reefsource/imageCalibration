function [ coralHistogram, keypointVals, map2d ] = computeHistogramV2( I, keypoints, mask )

nCoralBins = 6;
nBins = 256;
satThr = 0.95;
debug = false;

h = size(I,1);
w = size(I,2);

if isempty(mask)
    mask = ones(h,w);
end

% I = imageExpose(I,satThr);
if debug
    figure; imshow(I);
    hold on;
    for i=1:size(keypoints,1)
        plot(keypoints(i,1),keypoints(i,2),'+','MarkerSize',10,'LineWidth',5);
    end
end


Ivec = reshape(I,[h*w, 3]);
nonSaturated = ((Ivec(:,2) < satThr) & (Ivec(:,3) < satThr)) & mask(:);

[hist2d, bins] = hist3(Ivec(nonSaturated,2:3),[nBins, nBins]);

params = [Ivec(nonSaturated,2), ones(sum(nonSaturated==1),1)]\Ivec(nonSaturated,3);
gain = params(1);
offset = params(2);

xx = bins{1};
yy = gain*bins{1} + offset;

if debug
    figure;
    hold on; grid on; box on;
    imagesc(bins{1},bins{2},log(hist2d)');
    plot(xx,yy,'r');
    xlabel('Green channel intensity');
    ylabel('Blue channel intensity');
end

xBd = linspace(xx(1),xx(end),nCoralBins+1);
yBd = linspace(yy(1),yy(end),nCoralBins+1);
xBd = xBd(2:end);
yBd = yBd(2:end);

if debug
    plot(xBd,yBd,'g+');
end

perpendicularLines = zeros(nCoralBins,2);
perpendicularLines(:,1) = -1/gain;
perpendicularLines(:,2) = yBd + 1/gain*xBd;

if debug
    for i=1:nCoralBins
        dd = xx*perpendicularLines(i,1) + perpendicularLines(i,2);
        plot(xx,dd,'y');
    end
    xlim([min(bins{1}) max(bins{1})]);
    ylim([min(bins{2}) max(bins{2})]);
end



delta = 4;
% Overlay keypoints
keypointVals = [];

if isempty(keypoints) == false
    cmap = lines(6);
    
    keypointVals = zeros(size(keypoints,1),3);
    
   for i=1:size(keypoints,1) 
    
        xx = keypoints(i,1)-delta:keypoints(i,1)+delta;
        yy = keypoints(i,2)-delta:keypoints(i,2)+delta;
        
        %nonSaturatedROI = nonSaturated(sub2ind([h,w],yy,xx));
        nonSaturatedROI = true(length(yy),length(xx));
        
        Ir = I(yy,xx,1);
        Ig = I(yy,xx,2);
        Ib = I(yy,xx,3);
        
        Ir = mean(Ir(nonSaturatedROI));
        Ig = mean(Ig(nonSaturatedROI));
        Ib = mean(Ib(nonSaturatedROI));
        
        keypointVals(i,:) = [Ir, Ig, Ib];
        
        fprintf('Keypoint %2i: R=%.3f, G=%.3f\n',i,Ig,Ib);
        
        if debug
            if (isnan(Ig) || isnan(Ib)) == false
                plot(Ig,Ib,'+','color',cmap(mod(i,6)+1,:),'MarkerSize',10,'LineWidth',5);
                text(Ig+0.01,Ib+0.01,sprintf('%i',(mod(i-1,6)+1)),'FontSize',20,'Color','red');
            end
        end
   end
end



[xCoord, yCoord] = meshgrid(bins{1},bins{2});
xCoordVec = xCoord(:);
yCoordVec = yCoord(:);

binMap = zeros(nBins^2,1);


condition = yCoordVec - xCoordVec*(-1/gain);
thresholds = [0; perpendicularLines(:,2)];

for i=1:nCoralBins
     indices = (condition >= thresholds(i)) & (condition < thresholds(i+1));
     binMap(indices) = i;  
end

binMap(binMap == 0) = nCoralBins;


if debug
    figure; imagesc(reshape(binMap,[256 256]));
    set(gca,'Ydir','Normal')
end

%% 2D map of histogram bins


map2d = zeros(h,w);
condition = Ivec(:,3) - Ivec(:,2)*(-1/gain);


for i=1:nCoralBins
     indices = (condition >= thresholds(i)) & (condition < thresholds(i+1));
     map2d(indices) = nCoralBins - i + 1;  
end


%% Compute the actual histogram
% Note that 1-represents 'bright' and 6 - 'dark'.

hist2dVec = hist2d(:);
coralHistogram = zeros(nCoralBins,1);

for i=1:nCoralBins
    coralHistogram(i) = sum(hist2dVec(binMap == i));
end

% In the coralWatch chart the brightest color is at index one
coralHistogram = flipud(coralHistogram);
coralHistogram = coralHistogram/(h*w);

if debug
    figure; 
    subplot(1,2,1);
    imagesc(map2d);
    subplot(1,2,2);
    bar(coralHistogram);
end


end


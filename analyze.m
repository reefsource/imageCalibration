close all;
clear all;
clc;

dbPath = fullfile('/','Users','hblasinski','Documents','MATLAB',...
    'reefsource','imageCalibration','SamplesWithTarget');

files = dir(fullfile(dbPath,'*.GPR'));

%%

for f=1:length(files)
    
    imagePath = fullfile(dbPath,files(f).name);
    
    
    % mask(1250:2600,1:1700) = 0;
    
    % Normalize image
    I = readRawImage(imagePath);
    I = double(I);
    
    % mask = true(size(I,1),size(I,2));
    mask = [];
    
    % I = (double(I)/max(double(I(:))));
    I = imageExpose(I,0.99,mask);
    % I = I.^(1/2.2);
    [~, keypointFile] = fileparts(imagePath);
    
   
    
    keypoints = [];
    try
        load(fullfile(dbPath,sprintf('%s.mat',keypointFile)));
    catch
        fg = figure; 
        imshow(I);
        [x, y] = getpts();
        keypoints = [x(:), y(:)];
        keypoints = round(keypoints);
        save(fullfile(dbPath,sprintf('%s.mat',keypointFile)),'keypoints');
        close(fg);
    end
    
    
    [h1, kV{f}] = computeHistogramV2(I,keypoints,mask);
    
    figure;
    subplot(1,2,1);
    imshow(I);
    subplot(1,2,2);
    bar(h1);

end

%%

totalKeypoints = [];
totalLabels = [];

figure;
hold on; grid on; box on;
mp = lines(6);
for f=1:length(files)
   
    for i=1:24 
       if (mod(i-1,6)+1)==2 || (mod(i-1,6)+1)==6
        plot(kV{f}(i,2),kV{f}(i,3),'+','color',mp(mod(i-1,6)+1,:));
       end
   end
   
   totalKeypoints = [totalKeypoints; kV{f}];
   totalLabels = [totalLabels; repmat((1:6)',4,1)];
end

%% Train a classifier

X = totalKeypoints(:,2:3);

validIDs = X(:,1) < 1 & X(:,2) < 1;
X = X(validIDs,:);
labels = totalLabels(validIDs);

svmTemplate = templateSVM('Standardize',0,'KernelFunction','linear');
model = fitcecoc(X,labels,'Learners',svmTemplate);
save('svmLinearData.mat','model');

%{
predLabels = predict(model,X);

accy = sum(predLabels == totalLabels)/numel(totalLabels);

figure;
imagesc(confusionmat(predLabels,totalLabels));
title(sprintf('Accuracy %.2f',accy));


xMax = max(X);
xMin = min(X);

x1Pts = linspace(xMin(1),xMax(1));
x2Pts = linspace(xMin(2),xMax(2));
[x1Grid,x2Grid] = meshgrid(x1Pts,x2Pts);
[id] = predict(model,[x1Grid(:),x2Grid(:)]);

figure;
contourf(x1Grid,x2Grid,...
        reshape(id,size(x1Grid,1),size(x1Grid,2)));
h = colorbar;
h.YLabel.String = 'Class assignment';
h.YLabel.FontSize = 15;
hold on

for f=1:length(files)
   
    for i=1:24 
        plot(kV{f}(i,2),kV{f}(i,3),'+','color',mp(mod(i-1,6)+1,:));
   end
   
end



%%
h = size(I,1);
w = size(I,2);

data = reshape(I,[h*w, 3]);

predLabels = predict(model,data(:,2:3));

hst = zeros(6,1);
for i=1:6
    hst(i) = sum(predLabels == i);
end

figure;
bar(hst/sum(hst));

%}

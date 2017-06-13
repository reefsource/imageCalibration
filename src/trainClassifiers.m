close all;
clear all;
clc;

dbPath = fullfile('/','Users','hblasinski','Documents','MATLAB',...
    'reefsource','SampleImagesWithTarget');

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
    % r = I(:,:,1); g = I(:,:,2); b=I(:,:,3);
    % figure; plot3(r(:),g(:),b(:),'.');
    
    I = deDepthImage(I);
    I = imageExpose(I,0.99,[]);
    % r = I(:,:,1); g = I(:,:,2); b=I(:,:,3);
    % figure; plot3(r(:),g(:),b(:),'.');
    % g = I(:,:,2); b=I(:,:,3);
    % figure; plot(g(:),b(:),'.');
    
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
    
    if ~exist('boundingBox','var');
        fg = figure; 
        imshow(I);
        boundingBox = getrect();
        save(fullfile(dbPath,sprintf('%s.mat',keypointFile)),'boundingBox','-append');
        close(fg);
    end

    
    
    [h1, kV{f}] = computeHistogramV2(I,keypoints,mask);
    
    
    figure;
    subplot(1,2,1);
    imshow(I);
    subplot(1,2,2);
    bar(h1);
    
    
    clear boundingBox;
end

%%

totalKeypoints = [];
totalLabels = [];

figure;
hold on; grid on; box on;
mp = lines(6);
for f=1:length(files)
   
    for i=1:24 
       %if (mod(i-1,6)+1)==2 || (mod(i-1,6)+1)==6
        plot(kV{f}(i,2),kV{f}(i,3),'+','color',mp(mod(i-1,6)+1,:));
        % plot3(kV{f}(i,1),kV{f}(i,2),kV{f}(i,3),'+','color',mp(mod(i-1,6)+1,:));
       %end
   end
   
   totalKeypoints = [totalKeypoints; kV{f}];
   totalLabels = [totalLabels; repmat((1:6)',4,1)];
end

save('linearKeypointsDeDepth.mat','totalKeypoints','totalLabels');

%% Train a classifier

X = totalKeypoints(:,2:3);

validIDs = X(:,1) <= 1 & X(:,2) <= 1;
X = X(validIDs,:);
labels = totalLabels(validIDs);

svmTemplate = templateSVM('Standardize',0,'KernelFunction','linear');
model = fitcecoc(X,labels,'Learners',svmTemplate);
save('svmLinearDataDeDepth.mat','model');


%% Decision boundaries

fs = 20;

predLabels = predict(model,X);

accy = sum(predLabels == labels)/numel(labels);

figure; 
axis image; hold on; box on;
imagesc(confusionmat(predLabels,labels));
set(gca,'FontSize',fs*0.6);
title(sprintf('Accuracy %.2f',accy));
xlabel('True class','FontSize',fs);
ylabel('Predicted class','FontSize',fs);
% print('-dpng','ConfusionMatrix.png');



xMax = max(X);
xMin = min(X);

x1Pts = linspace(xMin(1),xMax(1));
x2Pts = linspace(xMin(2),xMax(2));
[x1Grid,x2Grid] = meshgrid(x1Pts,x2Pts);
[id] = predict(model,[x1Grid(:),x2Grid(:)]);

figure;
axis image; hold on; box on;
contourf(x1Grid,x2Grid,reshape(id,size(x1Grid,1),size(x1Grid,2)));
set(gca,'FontSize',fs*0.6);
xlabel('G pixel intensity','FontSize',fs);
ylabel('B pixel intensity','FontSize',fs);
% print('-dpng','ClassBoundaries.png');


% h = colorbar;
% h.YLabel.String = 'Class assignment';
% h.YLabel.FontSize = 15;





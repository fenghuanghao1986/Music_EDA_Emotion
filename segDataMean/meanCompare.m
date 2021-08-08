%% mean value comparison for each subject

clc;
clear;
warning off

%load mat file
%compare warmup means
fileName = ...
    'E:\EDA_Process\C_Morlet_SVM\segDataMean\warm\filtermean_warm.mat';

disp('Loading File ...')

warmFile = load(fileName);
warmFile = warmFile.saveClip3;

mean(warmFile)
max(warmFile)
min(abs(warmFile))
median(abs(warmFile))

% for i = 1:length(warmFile)
%     if abs(warmFile(i)) > mean(warmFile)*10
%         warmFile(i) = median(warmFile);
%     end
%     
% end


x = reshape(warmFile, 50,8);
% x = warmFile;
plot(x(:,8))

%compare intervention means 
% fileName = ...
%     'E:\EDA_Process\C_Morlet_SVM\segDataMean\inter\filtermean_inter.mat';
% 
% disp('Loading File ...')
% 
% interFile = load(fileName);
% interFile = interFile.saveClip3;
% 
% x = reshape(interFile, 4,6);
% 
% plot(x)
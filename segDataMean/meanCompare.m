%% mean value comparison for each subject

clc;
clear;
warning off

%load mat file
%compare warmup means
fileName = ...
    'E:\EDA_Process\C_Morlet_SVM\segDataMean\warm\norm_warm.mat';

disp('Loading File ...')

warmFile = load(fileName);
warmFile = warmFile.saveClip1;

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
plot(x)

%load mat file
%compare warmup means
fileName = ...
    'E:\EDA_Process\C_Morlet_SVM\segDataMean\inter\norm_inter.mat';

disp('Loading File ...')

interFile = load(fileName);
interFile = interFile.saveClip1;

mean(interFile)
max(interFile)
min(abs(interFile))
median(abs(interFile))

% for i = 1:length(warmFile)
%     if abs(warmFile(i)) > mean(warmFile)*10
%         warmFile(i) = median(warmFile);
%     end
%     
% end


x = reshape(interFile, 48,6);
% x = warmFile;
plot(x)
% plot the last subject's intervention data means
plot(x(:, 6), '*')
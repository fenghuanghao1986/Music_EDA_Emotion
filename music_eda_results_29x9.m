clc;
clear all;
close all;

accuracy = [];
precision = [];
recall = [];
auc = [];
temp = [];
good = 0;
bad = 0;

% filePath = 'E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmLinear_001\2v3';
% filePath = 'E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn7\2v3';
% filePath = 'E:\EDA_Process\C_Morlet_SVM\results_10_12_10\1v2v3\knn3';
% filePath = 'E:\EDA_Process\C_Morlet_SVM\results_10_12_10\1v2v3\svmRBF';
% filePath = 'E:\EDA_Process\C_Morlet_SVM\results_raw\svmRBF\2v3';
% filePath = 'E:\EDA_Process\C_Morlet_SVM\results_raw\knn3\1v2';
% filePath = 'E:\EDA_Process\C_Morlet_SVM\results_raw\1v2v3\knn3';


files = dir(fullfile(filePath, '*.mat'));

for i = 1: length(files)
    
    baseName = files(i).name;
    fullName = fullfile(filePath, baseName);
    
    matFile = load(fullName);
    temp = struct2cell(matFile(1));
    accuracy(i) = temp{1};
    
    if accuracy(i) >= 0.60
        good = good + 1
    end
    
    
%     auc(i) = temp{5};
%     precision(i) = temp{3};
%     recall(i) = temp{4};
    
end

fprintf('Average accuracy: %f \n', mean(accuracy));
fprintf('Average auc: %f \n', mean(auc));
fprintf('Average precision: %f \n', mean(precision));
fprintf('Average recall: %f \n', mean(recall));
fprintf('Std of accuracy: %f \n', std(accuracy));
fprintf('Variance of accuracy: %f \n', var(accuracy));
fprintf('Median of accuracy: %f \n', median(accuracy));
fprintf('Max accuracy: %f \n', max(accuracy));
fprintf('Min accuracy: %f \n', min(accuracy));




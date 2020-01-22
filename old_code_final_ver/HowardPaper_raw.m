function HowardPaper

% HowardClassification (SVM, Just for a single qsensor)

% Fs = 32;
% scales = [1:100];
% DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/32)
% 
% fw = DesiredFrequency/2;
% scales = Fs ./ fw


clc
clear all
close all
   
%% Make Dataset

disp('Loading Data ...')
DownSamp = 100;

% C = 0.1; % for 2 events - events 2 & 3 are the best!!
% C = 10; % for 3 events

qsensor = 'q2'; % 'q1', 'q2';

event_1 = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_1\event_1_', qsensor]);
event_1 = event_1.output;
event_2 = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_2\event_2_', qsensor]);
event_2 = event_2.output; 
event_3 = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_3\event_3_', qsensor]);
event_3 = event_3.output;
event_4 = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_4\event_4_', qsensor]);
event_4 = event_4.output;
event_5 = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_5\event_5_', qsensor]);
event_5 = event_5.output; 

%%% Adjust DataSet, EventName, KernelName, TaskNumb
% tic
% disp('Dont Forget Update the Parameters :)))))) ')
% while toc < 7  
% end

event_11 = load(['D:\event_based_emotion_redo\6_features\event_1_', qsensor, '_6_features.mat']);
event_11 = event_11.StatSave;
event_22 = load(['D:\event_based_emotion_redo\6_features\event_2_', qsensor, '_6_features.mat']);
event_22 = event_22.StatSave;
event_33 = load(['D:\event_based_emotion_redo\6_features\event_3_', qsensor, '_6_features.mat']);
event_33 = event_33.StatSave;
event_55 = load(['D:\event_based_emotion_redo\6_features\event_5_', qsensor, '_6_features.mat']);
event_55 = event_55.StatSave;

DataSet = {%downsample(event_1', DownSamp)', ...
%            [downsample(event_1', DownSamp)', event_11]...
           [downsample(event_1', DownSamp)', event_11], ...
           [downsample(event_3', DownSamp)', event_33] ...
           [downsample(event_5', DownSamp)', event_55]};

% DataSet = {%downsample(event_1', DownSamp)', ...
% %            downsample(event_1', DownSamp)',...
%             downsample(event_2', DownSamp)', ...
%            downsample(event_3', DownSamp)', ...
%            downsample(event_5', DownSamp)'};
       
EventName = { 'event_1', 'event_5', 'event_3'};     
% EventName = { 'event_3', 'event_5'};       

% KernelName = 'Linear'; 
% KernelName = 'Polynomial';
KernelName = 'RBF';

TaskNumb = 3;
% TaskNumb = 2;

SampNumb = 64;
%% Kfold & PCA & Classification

disp('Kfold & PCA & Classification ...')

SVMLabels_M = zeros(TaskNumb,SampNumb);
deciSVM = [];

KNNLabels_M = zeros(TaskNumb,SampNumb);
deciKNN = [];
SaveTestLabel = [];


for k = 1 : SampNumb         
    
     TrSaLe = [];
     TeSaLe = [];
    
     for i = 1 : numel(DataSet)
    
         TempMemLe = DataSet{i};
        
         if isempty(TempMemLe)
             continue
         else
            
            [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
    
            TrSaLe = [TrSaLe; TrainLe];
            TeSaLe = [TeSaLe; TestLe]; 
            
         end
          
     end    
    
     TrLa = [];
     TeLa = [];
    
     for z = 1 : TaskNumb        
            
          TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
          TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
        
     end
     
     SaveTestLabel = [SaveTestLabel, TeLa];
     
%%  PCA
    
     % Normalize the Dataset (Left) and PCA
     minLe = min(TrSaLe(:));
     maxLe = max(TrSaLe(:));
     
     TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
     TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
     PCAratio = 0.05;
     [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
    
%%  SVM
    
     TrFeCo = TrFeLe;    
     TeFeCo = TeFeLe; 
     if strcmp(KernelName, 'Linear') 
         [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.01 -t 0 ');
     elseif strcmp(KernelName, 'Polynomial')
         [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
     else
         [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 100 -t 2 -g 0.0001');    % RBF
     end
     
     [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
     deciSVM = [deciSVM, DecEst * model.Label(1)];
     SVMLabels_M(:,k) = SVMLabels(:);
     
%% KNN 
     K = 5;  % K = 1, 3, 5, ...
     KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
     [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
     deciKNN = [deciKNN, score(:,2)];
     KNNLabels_M(:,k) = KNNLabels(:);
     
     
end

%% Quantitative Assessments

SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);

deciSVM = deciSVM'; deciSVM = deciSVM(:);
deciKNN = deciKNN'; deciKNN = deciKNN(:);

    
if TaskNumb ~= 2
    
    AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
    [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
    save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\SVM_', KernelName, '_', EventName{1}, ' & ', ...
          EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
    disp(['SVM Accuracy: ', num2str(AccuracySVM)])
    disp('SVM ConfMat: ');
    disp(num2str(ProbConfMatSVM))
    
    AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
    [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
    save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
          EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
    disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
    disp('KNN ConfMat: ');
    disp(num2str(ProbConfMatKNN))   
    
else 
    [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, stack_xSVM, stack_ySVM] = PRA(SaveTestLabel, ...
                                                                                               SVMLabels_M, ...
                                                                                                   deciSVM, ...
                                                                                        ['SVM-', KernelName]);
    save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\SVM_', KernelName, '_', EventName{1}, ' & ', ...
          EventName{2}],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM', 'stack_xSVM', 'stack_ySVM') 
    disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
          '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM)])
    disp('SVM ConfMat: ')
    disp(num2str(ConfMatSVM))
    
    
    [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, stack_xKNN, stack_yKNN] = PRA(SaveTestLabel, ...
                                                                                               KNNLabels_M, ...
                                                                                                   deciKNN, ...
                                                                                         ['KNN-K', num2str(K)]); 
    save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
          EventName{2}],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN', 'stack_xKNN', 'stack_yKNN') 
    disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
          '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN)])
    disp('KNN ConfMat: ')
    disp(num2str(ConfMatKNN))
    
end                                                                                           
                                                                                               
                                                                                            

function [ProbConfMat, Percision, Recall, Accuracy, auc, stack_x, stack_y] = PRA(GroundTruth, Predicted, deci, ClassifierName)

% https://stats.stackexchange.com/questions/145566/how-to-calculate-area-under-the-curve-auc-or-the-c-statistic-by-hand
% Example

% load('mnist_all.mat')
% trsamples = 500;
% trends = trsamples * 10;
% TrainingData = [double(train1(1:10:trends, :)); double(train5(1:10:trends, :))];
% TrainingLabel = [1 * ones(1,trsamples)'; 2 * ones(1, trsamples)'];
% tssamples = 200;
% tsends = tssamples * 2;
% TestData = [double(test1(1:2:tsends, :)); double(test5(1:2:tsends, :))];
% TestLabel = [1*ones(1,tssamples)'; 2 * ones(1,tssamples)'];
% model = svmtrain(TrainingLabel, TrainingData, '-s 0 -c 0.000001 -t 0 -g 1/784');
% [predicted_label, accuracy, decision_values_prob_estimates] = svmpredict(TestLabel, TestData, model);
% deci = decision_values_prob_estimates * model.Label(1);
% 
% [ProbConfMat,Percision, Recall, Accuracy, AUC, FPR, TPR] = PRA(TestLabel, predicted_label, deci, 'SVM_Linear');


Index = unique(GroundTruth);

if numel(Index) ~= 2
    error('This dataset is not compatible with this function')
end

GroundTruth(logical(GroundTruth == Index(1))) = -1;
GroundTruth(logical(GroundTruth == Index(2))) = +1;
Predicted(logical(Predicted == Index(1))) = -1;
Predicted(logical(Predicted == Index(2))) = +1;


% GroundTruth = [-1 * ones(Ind_Neg, 1); +1 * ones(Ind_Pos, 1)];

[ConfMat, ProbConfMat] = ConfusionMatrix(GroundTruth, Predicted);

Percision = ConfMat(1,1)/(ConfMat(1,1) + ConfMat(1,2));
Recall = ConfMat(1,1)/(ConfMat(1,1) + ConfMat(2,1));
Accuracy = sum(diag(ConfMat)) / sum(ConfMat(:));

% [stack_x, stack_y, auc] =perfcurve(GroundTruth,deci,1);
[~,ind] = sort(deci,'descend');
roc_y = GroundTruth(ind);
stackX = cumsum(roc_y == -1)/sum(roc_y == -1);
stackY = cumsum(roc_y == 1)/sum(roc_y == 1);
auc = sum((stackX(2:length(roc_y),1)-stackX(1:length(roc_y)-1,1)).*stackY(2:length(roc_y),1));
if auc < 0.5
    auc = 1 - auc;
    stack_x = stackY;
    stack_y = stackX;
else
    stack_x = stackX;
    stack_y = stackY;
end

figure; plot(stack_x, stack_y);
title([ClassifierName, '>> AUC : ' num2str(auc), '; Percision: ', num2str(Percision), '; Recall: ', num2str(Recall)...
       , '; Accuracy: ', num2str(Accuracy)]); xlabel('FPR'); ylabel('TPR')


% ===========================================================
%                     Confusion Matrix
% ===========================================================

function [ConfMat, ProbConfMat] = ConfusionMatrix(GroundTruth, Predicted)

% Created by: Hosein M. Golshan, h.golshan.m@gmail.com
% CV Lab, Uni of Denver, Denver, CO, USA
% Last Update: 14 Sep. 2017

IndG = unique(GroundTruth);
numClass = numel(IndG);
ConfMat = zeros(numClass, numClass);
ProbConfMat = zeros(numClass, numClass);

for i = 1 : numClass
    
    Ind = find(GroundTruth == IndG(i));  
    for j = 1 : numClass
       ConfMat(i,j) = numel(find(Predicted(Ind) == IndG(j)));       
    end
    ProbConfMat(i, :) = ConfMat(i, :) / numel(Ind);    
end
ProbConfMat = ProbConfMat * 100;

























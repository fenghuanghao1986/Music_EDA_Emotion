function music_EDA_3in1

% Music EDA classification (SVM, MKL, single sensor)

% Fs = 32;
% scales = [1:100];
% DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/32)
% 
% fw = DesiredFrequency/2;
% scales = Fs ./ fw

%% task intro vs task listen cross validation
clc;
clear all;
close all;

%% Make Dataset

SVMAcc = [];
KNNAcc = [];
SVMMat = {};
KNNMat = {};

for s = 1: 40
    
    disp('Loading Data ...')
    downSamp = 100;

    % C = 0.1; % for 2 different tasks
    % C = 10; % for 3 different tasks


    task_1 = load(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\vec_warm_intro', num2str(s)]);
    task_1 = task_1.output;
    task_2 = load(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\vec_warm_listen', num2str(s)]);
    task_2 = task_2.output;
    task_3 = load(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\vec_warm_play', num2str(s)]);
    task_3 = task_3.output;

    DataSet = { 
                downsample(task_1', downSamp)', ...
%                 downsample(task_2', downSamp)', ...
                downsample(task_3', downSamp)', ...
                };


%     KernelName = 'Linear'; 
%     KernelName = 'Polynomial';
    KernelName = 'RBF';

    SampNumb = 10
    TaskNumb = 2;

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
    %             TrainLe = [TrainLe; TestLe];
    %             size(TrainLe)

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
         size(TrSaLe, 2)
         [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
         size(TrFeLe, 2)
    %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based

    %%  SVM

         TrFeCo = TrFeLe;    
         TeFeCo = TeFeLe; 
         if strcmp(KernelName, 'Linear') 
             [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 10 -t 0 ');
         elseif strcmp(KernelName, 'Polynomial')
             [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 1 -t 1 -d 2');       % Polynomial
         else 
             [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 1000 -t 2 -g 0.0001');    % RBF
         end

         [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
         deciSVM = [deciSVM, DecEst * model.Label(1)];
         SVMLabels_M(:,k) = SVMLabels(:);

    %% KNN

         K =3;  % K = 1, 3, 5, ...

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
        [ConfMat, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
    %             save(['E:\EDA_Process\C_Morlet_SVM\results\SVM_', KernelName, '_', EventName{1}, ' & ', ...
    %                   EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
        disp(['SVM Accuracy: ', num2str(AccuracySVM)])
        disp('SVM ConfMat: ');
        disp(num2str(ProbConfMatSVM))
        SVMAcc(s) = AccuracySVM;
        SVMMat{s} = ProbConfMatSVM;


        AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
        [ConfMat, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
    %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
    %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
        disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
        disp('KNN ConfMat: ');
        disp(num2str(ProbConfMatKNN)) 
        KNNAcc(s) = AccuracyKNN;
        KNNMat{s} = ProbConfMatKNN;


    else 
        [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
                                 PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
    %     save(['E:\EDA_Process\C_Morlet_SVM\segDataInOneTask\warmup\SVM_', KernelName, '_', 'vec_warm_intro', ' & ', ...
    %           'vec_warm_listen'],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
        disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
              '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
              num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
        disp('SVM ConfMat: ')
        disp(num2str(ConfMatSVM))
        SVMAcc(s) = AccuracySVM;
        SVMMat{s} = ConfMatSVM;



        [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
                                 PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
    %     save(['E:\EDA_Process\C_Morlet_SVM\segDataInOneTask\warmup\KNN_K', num2str(K), '_', 'vec_warm_intro', ' & ', ...
    %           'vec_warm_listen'],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN') 
        disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
              '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
              num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
        disp('KNN ConfMat: ')
        disp(num2str(ConfMatKNN))
        KNNAcc(s) = AccuracyKNN;
        KNNMat{s} = ConfMatKNN;
        

    end
    % save all acc for 3 classes accross all files
    avgSVM = mean(SVMAcc);
    avgKNN = mean(KNNAcc);
    
%     save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\SVM_', KernelName, '_', 'for_3_parts'],  'SVMAcc', 'SVMMat')
%     save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\KNN_K', num2str(K), '_', 'for_3_parts'],  'KNNAcc', 'KNNMat')
%     
%     save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\SVM_', KernelName, '_', 'for_3_parts_average'],  'avgSVM')
%     save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\KNN_K', num2str(K), '_', 'for_3_parts_average'],  'avgKNN')

    save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\SVM_', KernelName, '_', 'for_2_parts'],  'SVMAcc', 'SVMMat')
    save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\KNN_K', num2str(K), '_', 'for_2_parts'],  'KNNAcc', 'KNNMat')
    
    save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\SVM_', KernelName, '_', 'for_2_parts_average'],  'avgSVM')
    save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\warmup\KNN_K', num2str(K), '_', 'for_2_parts_average'],  'avgKNN')
    
    disp(['avgSVM: ', num2str(avgSVM)])
    disp(['avgKNN: ', num2str(avgKNN)])
end
close all;


% %% task intro vs task listen cross validation
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% % C = 0.1; % for 2 different tasks
% % C = 10; % for 3 different tasks
% 
% 
% task_1 = load('vec_warm_intro');
% task_1 = task_1.output;
% task_3 = load('vec_inter_play');
% task_3 = task_3.output;
% 
% DataSet = { 
%             downsample(task_1', downSamp)', ...
%             downsample(task_3', downSamp)', ...
%             };
% 
% 
% % KernelName = 'Linear'; 
% KernelName = 'Polynomial';
% % KernelName = 'RBF';
% 
% SampNumb = 29
% TaskNumb = 2;
% 
% %% Kfold & PCA & Classification
% 
% disp('Kfold & PCA & Classification ...')
% 
% SVMLabels_M = zeros(TaskNumb,SampNumb);
% deciSVM = [];
% 
% KNNLabels_M = zeros(TaskNumb,SampNumb);
% deciKNN = [];
% SaveTestLabel = [];
% 
% 
% for k = 1 : SampNumb         
% 
%      TrSaLe = [];
%      TeSaLe = [];
% 
%      for i = 1 : numel(DataSet)
% 
%          TempMemLe = DataSet{i};
% 
%          if isempty(TempMemLe)
%              continue
%          else
% 
%             [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
% %             TrainLe = [TrainLe; TestLe];
% %             size(TrainLe)
% 
%             TrSaLe = [TrSaLe; TrainLe];
%             TeSaLe = [TeSaLe; TestLe]; 
% 
%          end
% 
%      end    
% 
%      TrLa = [];
%      TeLa = [];
% 
%      for z = 1 : TaskNumb        
% 
%           TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%           TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%      end
% 
%      SaveTestLabel = [SaveTestLabel, TeLa];
% 
% %%  PCA
% 
%       % Normalize the Dataset (Left) and PCA
%      minLe = min(TrSaLe(:));
%      maxLe = max(TrSaLe(:));
% 
%      TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%      TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%      PCAratio = 0.05;
%      size(TrSaLe, 2)
%      [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%      size(TrFeLe, 2)
% %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
% %%  SVM
% 
%      TrFeCo = TrFeLe;    
%      TeFeCo = TeFeLe; 
%      if strcmp(KernelName, 'Linear') 
%          [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.001 -t 0 ');
%      elseif strcmp(KernelName, 'Polynomial')
%          [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%      else 
%          [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 10 -t 2 -g 0.0001');    % RBF
%      end
% 
%      [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%      deciSVM = [deciSVM, DecEst * model.Label(1)];
%      SVMLabels_M(:,k) = SVMLabels(:);
% 
% %% KNN
% 
%      K = 1;  % K = 1, 3, 5, ...
% 
%      KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%      [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%      deciKNN = [deciKNN, score(:,2)];
%      KNNLabels_M(:,k) = KNNLabels(:);
% 
% end
% 
% %% Quantitative Assessments
% 
% SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
% SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
% KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
% deciSVM = deciSVM'; deciSVM = deciSVM(:);
% deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
% if TaskNumb ~= 2
% 
%     AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%     [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
% %             save(['E:\EDA_Process\C_Morlet_SVM\results\SVM_', KernelName, '_', EventName{1}, ' & ', ...
% %                   EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%     disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%     disp('SVM ConfMat: ');
%     disp(num2str(ProbConfMatSVM))
% 
%     AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%     [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
% %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
% %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%     disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%     disp('KNN ConfMat: ');
%     disp(num2str(ProbConfMatKNN))   
% 
% else 
%     [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                              PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%     save(['E:\EDA_Process\C_Morlet_SVM\segDataInOneTask\warmup\SVM_', KernelName, '_', 'vec_warm_intro', ' & ', ...
%           'vec_warm_listen'],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%     disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%           '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%           num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%     disp('SVM ConfMat: ')
%     disp(num2str(ConfMatSVM))
% 
% 
%     [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                              PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
%     save(['E:\EDA_Process\C_Morlet_SVM\segDataInOneTask\warmup\KNN_K', num2str(K), '_', 'vec_warm_intro', ' & ', ...
%           'vec_warm_listen'],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN') 
%     disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%           '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%           num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%     disp('KNN ConfMat: ')
%     disp(num2str(ConfMatKNN))
% 
% 
% end
% 
% %% task 2 vs task 3
% 
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% for b = 1: 12
%     for c = 1: 10
% 
%         task_2 = load(['vec_inter_seg_', num2str(b)]);
%         task_2 = task_2.output;
%         task_3 = load(['vec_game_seg_', num2str(c)]);
%         task_3 = task_3.output;
% 
%         DataSet = { 
%                     downsample(task_2', downSamp)', ...
%                     downsample(task_3', downSamp)', ...
%                     };
% 
% 
%         KernelName = 'Linear'; 
% %             KernelName = 'Polynomial';
% %         KernelName = 'RBF';
% 
%         SampNumb = 29
%         TaskNumb = 2;
%         % TaskNumb = 3;
% 
%         %% Kfold & PCA & Classification
% 
%         disp('Kfold & PCA & Classification ...')
% 
%         SVMLabels_M = zeros(TaskNumb,SampNumb);
%         deciSVM = [];
% 
%         KNNLabels_M = zeros(TaskNumb,SampNumb);
%         deciKNN = [];
%         SaveTestLabel = [];
% 
% 
%         for k = 1 : SampNumb         
% 
%              TrSaLe = [];
%              TeSaLe = [];
% 
%              for i = 1 : numel(DataSet)
% 
%                  TempMemLe = DataSet{i};
% 
%                  if isempty(TempMemLe)
%                      continue
%                  else
% 
%                     [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
%         %             TrainLe = [TrainLe; TestLe];
%         %             size(TrainLe)
% 
%                     TrSaLe = [TrSaLe; TrainLe];
%                     TeSaLe = [TeSaLe; TestLe]; 
% 
%                  end
% 
%              end    
% 
%              TrLa = [];
%              TeLa = [];
% 
%              for z = 1 : TaskNumb        
% 
%                   TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%                   TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%              end
% 
%              SaveTestLabel = [SaveTestLabel, TeLa];
% 
%         %%  PCA
% 
%               % Normalize the Dataset (Left) and PCA
%              minLe = min(TrSaLe(:));
%              maxLe = max(TrSaLe(:));
% 
%              TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%              TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%              PCAratio = 0.05;
%              size(TrSaLe, 2)
%              [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%              size(TrFeLe, 2)
%         %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
%         %%  SVM
% 
%              TrFeCo = TrFeLe;    
%              TeFeCo = TeFeLe; 
%              if strcmp(KernelName, 'Linear') 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.001 -t 0 ');
%              elseif strcmp(KernelName, 'Polynomial')
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%              else
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 10 -t 2 -g 0.0001');    % RBF
%              end
% 
%              [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%              deciSVM = [deciSVM, DecEst * model.Label(1)];
%              SVMLabels_M(:,k) = SVMLabels(:);
% 
%         %% KNN
% 
%              K = 1;  % K = 1, 3, 5, ...
%              KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%              [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%              deciKNN = [deciKNN, score(:,2)];
%              KNNLabels_M(:,k) = KNNLabels(:);
% 
%         end
% 
%         %% Quantitative Assessments
% 
%         SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
%         SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
%         KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
%         deciSVM = deciSVM'; deciSVM = deciSVM(:);
%         deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
%         if TaskNumb ~= 2
% 
%             AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%             [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\SVM_', KernelName, '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%             disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%             disp('SVM ConfMat: ');
%             disp(num2str(ProbConfMatSVM))
% 
%             AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%             [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%             disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%             disp('KNN ConfMat: ');
%             disp(num2str(ProbConfMatKNN))   
% 
%         else 
%             [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                                      PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmLinear\2v3\SVM_', KernelName, '_', 'vec_inter_seg_', num2str(b), ' & ', ...
%                   'vec_game_seg_', num2str(c)],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%             disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%                   '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%                   num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%             disp('SVM ConfMat: ')
%             disp(num2str(ConfMatSVM))
% 
% 
%             [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                                      PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
% %             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn1\2v3\KNN_K', num2str(K), '_', 'vec_inter_seg_', num2str(b), ' & ', ...
% %                   'vec_game_seg_', num2str(c)],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN')
%             disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%                   '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%                   num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%             disp('KNN ConfMat: ')
%             disp(num2str(ConfMatKNN))
% 
%         end
%     end
% end

%  %% task 1 vs task 2 cross validation
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% % C = 0.1; % for 2 different tasks
% % C = 10; % for 3 different tasks
% 
% for a = 1: 10
%     for b = 1: 12
%         task_1 = load(['vec_warm_seg_', num2str(a)]);
%         task_1 = task_1.output;
%         task_2 = load(['vec_inter_seg_', num2str(b)]);
%         task_2 = task_2.output;
% 
%         DataSet = { 
%                     downsample(task_1', downSamp)', ...
%                     downsample(task_2', downSamp)', ...
%                     };
% 
% 
% %             KernelName = 'Linear'; 
%         KernelName = 'Polynomial';
% %         KernelName = 'RBF';
% 
%         SampNumb = 29
%         TaskNumb = 2;
%         % TaskNumb = 3;
% 
%         %% Kfold & PCA & Classification
% 
%         disp('Kfold & PCA & Classification ...')
% 
%         SVMLabels_M = zeros(TaskNumb,SampNumb);
%         deciSVM = [];
% 
%         KNNLabels_M = zeros(TaskNumb,SampNumb);
%         deciKNN = [];
%         SaveTestLabel = [];
% 
% 
%         for k = 1 : SampNumb         
% 
%              TrSaLe = [];
%              TeSaLe = [];
% 
%              for i = 1 : numel(DataSet)
% 
%                  TempMemLe = DataSet{i};
% 
%                  if isempty(TempMemLe)
%                      continue
%                  else
% 
%                     [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
%         %             TrainLe = [TrainLe; TestLe];
%         %             size(TrainLe)
% 
%                     TrSaLe = [TrSaLe; TrainLe];
%                     TeSaLe = [TeSaLe; TestLe]; 
% 
%                  end
% 
%              end    
% 
%              TrLa = [];
%              TeLa = [];
% 
%              for z = 1 : TaskNumb        
% 
%                   TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%                   TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%              end
% 
%              SaveTestLabel = [SaveTestLabel, TeLa];
% 
%         %%  PCA
% 
%               % Normalize the Dataset (Left) and PCA
%              minLe = min(TrSaLe(:));
%              maxLe = max(TrSaLe(:));
% 
%              TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%              TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%              PCAratio = 0.05;
%              size(TrSaLe, 2)
%              [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%              size(TrFeLe, 2)
%         %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
%         %%  SVM
% 
%              TrFeCo = TrFeLe;    
%              TeFeCo = TeFeLe; 
%              if strcmp(KernelName, 'Linear') 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.01 -t 0 ');
%              elseif strcmp(KernelName, 'Polynomial')
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%              else 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 100 -t 2 -g 0.0001');    % RBF
%              end
% 
%              [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%              deciSVM = [deciSVM, DecEst * model.Label(1)];
%              SVMLabels_M(:,k) = SVMLabels(:);
% 
%         %% KNN
% 
%              K = 3;  % K = 1, 3, 5, ...
% 
%              KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%              [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%              deciKNN = [deciKNN, score(:,2)];
%              KNNLabels_M(:,k) = KNNLabels(:);
% 
%         end
% 
%         %% Quantitative Assessments
% 
%         SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
%         SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
%         KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
%         deciSVM = deciSVM'; deciSVM = deciSVM(:);
%         deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
%         if TaskNumb ~= 2
% 
%             AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%             [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
% %             save(['E:\EDA_Process\C_Morlet_SVM\results\SVM_', KernelName, '_', EventName{1}, ' & ', ...
% %                   EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%             disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%             disp('SVM ConfMat: ');
%             disp(num2str(ProbConfMatSVM))
% 
%             AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%             [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%             disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%             disp('KNN ConfMat: ');
%             disp(num2str(ProbConfMatKNN))   
% 
%         else 
%             [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                                      PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmPoly\1v2\SVM_', KernelName, '_', 'vec_warm_seg_', num2str(a), ' & ', ...
%                   'vec_inter_seg_', num2str(b)],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%             disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%                   '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%                   num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%             disp('SVM ConfMat: ')
%             disp(num2str(ConfMatSVM))
% 
% 
%             [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                                      PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn3\1v2\KNN_K', num2str(K), '_', 'vec_warm_seg_', num2str(a), ' & ', ...
%                   'vec_inter_seg_', num2str(b)],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN') 
%             disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%                   '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%                   num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%             disp('KNN ConfMat: ')
%             disp(num2str(ConfMatKNN))
% 
%         end
%     end
% end
% 
% %% task 1 vs task 3
% 
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% for a = 1: 10
%     for c = 1: 10
%         task_1 = load(['vec_warm_seg_', num2str(a)]);
%         task_1 = task_1.output;
%         task_3 = load(['vec_game_seg_', num2str(c)]);
%         task_3 = task_3.output;
% 
%         DataSet = { 
%                     downsample(task_1', downSamp)', ...
%                     downsample(task_3', downSamp)', ...
%                     };
% 
% 
% %             KernelName = 'Linear'; 
%         KernelName = 'Polynomial';
% %         KernelName = 'RBF';
% 
%         SampNumb = 29
%         TaskNumb = 2;
%         % TaskNumb = 3;
% 
%         %% Kfold & PCA & Classification
% 
%         disp('Kfold & PCA & Classification ...')
% 
%         SVMLabels_M = zeros(TaskNumb,SampNumb);
%         deciSVM = [];
% 
%         KNNLabels_M = zeros(TaskNumb,SampNumb);
%         deciKNN = [];
%         SaveTestLabel = [];
% 
% 
%         for k = 1 : SampNumb         
% 
%              TrSaLe = [];
%              TeSaLe = [];
% 
%              for i = 1 : numel(DataSet)
% 
%                  TempMemLe = DataSet{i};
% 
%                  if isempty(TempMemLe)
%                      continue
%                  else
% 
%                     [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
%         %             TrainLe = [TrainLe; TestLe];
%         %             size(TrainLe)
% 
%                     TrSaLe = [TrSaLe; TrainLe];
%                     TeSaLe = [TeSaLe; TestLe]; 
% 
%                  end
% 
%              end    
% 
%              TrLa = [];
%              TeLa = [];
% 
%              for z = 1 : TaskNumb        
% 
%                   TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%                   TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%              end
% 
%              SaveTestLabel = [SaveTestLabel, TeLa];
% 
%         %%  PCA
% 
%               % Normalize the Dataset (Left) and PCA
%              minLe = min(TrSaLe(:));
%              maxLe = max(TrSaLe(:));
% 
%              TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%              TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%              PCAratio = 0.05;
%              size(TrSaLe, 2)
%              [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%              size(TrFeLe, 2)
%         %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
%         %%  SVM
% 
%              TrFeCo = TrFeLe;    
%              TeFeCo = TeFeLe; 
%              if strcmp(KernelName, 'Linear') 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.01 -t 0 ');
%              elseif strcmp(KernelName, 'Polynomial')
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%              else
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 100 -t 2 -g 0.0001');    % RBF
%              end
% 
%              [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%              deciSVM = [deciSVM, DecEst * model.Label(1)];
%              SVMLabels_M(:,k) = SVMLabels(:);
% 
%         %% KNN
% 
%              K = 3;  % K = 1, 3, 5, ...
%              KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%              [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%              deciKNN = [deciKNN, score(:,2)];
%              KNNLabels_M(:,k) = KNNLabels(:);
% 
%         end
% 
%         %% Quantitative Assessments
% 
%         SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
%         SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
%         KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
%         deciSVM = deciSVM'; deciSVM = deciSVM(:);
%         deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
%         if TaskNumb ~= 2
% 
%             AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%             [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\SVM_', KernelName, '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%             disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%             disp('SVM ConfMat: ');
%             disp(num2str(ProbConfMatSVM))
% 
%             AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%             [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%             disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%             disp('KNN ConfMat: ');
%             disp(num2str(ProbConfMatKNN))   
% 
%         else 
%             [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                                      PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmPoly\1v3\SVM_', KernelName, '_', 'vec_warm_seg_', num2str(a), ' & ', ...
%                   'vec_game_seg_', num2str(c)],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%             disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%                   '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%                   num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%             disp('SVM ConfMat: ')
%             disp(num2str(ConfMatSVM))
% 
% 
%             [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                                      PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn3\1v3\KNN_K', num2str(K), '_', 'vec_warm_seg_', num2str(a), ' & ', ...
%                   'vec_game_seg_', num2str(c)],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN') 
%             disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%                   '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%                   num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%             disp('KNN ConfMat: ')
%             disp(num2str(ConfMatKNN))
% 
%         end
%     end
% end
% 
% %% task 2 vs task 3
% 
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% for b = 1: 12
%     for c = 1: 10
% 
%         task_2 = load(['vec_inter_seg_', num2str(b)]);
%         task_2 = task_2.output;
%         task_3 = load(['vec_game_seg_', num2str(c)]);
%         task_3 = task_3.output;
% 
%         DataSet = { 
%                     downsample(task_2', downSamp)', ...
%                     downsample(task_3', downSamp)', ...
%                     };
% 
% 
% %             KernelName = 'Linear'; 
%         KernelName = 'Polynomial';
% %         KernelName = 'RBF';
% 
%         SampNumb = 29
%         TaskNumb = 2;
%         % TaskNumb = 3;
% 
%         %% Kfold & PCA & Classification
% 
%         disp('Kfold & PCA & Classification ...')
% 
%         SVMLabels_M = zeros(TaskNumb,SampNumb);
%         deciSVM = [];
% 
%         KNNLabels_M = zeros(TaskNumb,SampNumb);
%         deciKNN = [];
%         SaveTestLabel = [];
% 
% 
%         for k = 1 : SampNumb         
% 
%              TrSaLe = [];
%              TeSaLe = [];
% 
%              for i = 1 : numel(DataSet)
% 
%                  TempMemLe = DataSet{i};
% 
%                  if isempty(TempMemLe)
%                      continue
%                  else
% 
%                     [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
%         %             TrainLe = [TrainLe; TestLe];
%         %             size(TrainLe)
% 
%                     TrSaLe = [TrSaLe; TrainLe];
%                     TeSaLe = [TeSaLe; TestLe]; 
% 
%                  end
% 
%              end    
% 
%              TrLa = [];
%              TeLa = [];
% 
%              for z = 1 : TaskNumb        
% 
%                   TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%                   TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%              end
% 
%              SaveTestLabel = [SaveTestLabel, TeLa];
% 
%         %%  PCA
% 
%               % Normalize the Dataset (Left) and PCA
%              minLe = min(TrSaLe(:));
%              maxLe = max(TrSaLe(:));
% 
%              TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%              TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%              PCAratio = 0.05;
%              size(TrSaLe, 2)
%              [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%              size(TrFeLe, 2)
%         %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
%         %%  SVM
% 
%              TrFeCo = TrFeLe;    
%              TeFeCo = TeFeLe; 
%              if strcmp(KernelName, 'Linear') 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.01 -t 0 ');
%              elseif strcmp(KernelName, 'Polynomial')
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%              else
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 100 -t 2 -g 0.0001');    % RBF
%              end
% 
%              [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%              deciSVM = [deciSVM, DecEst * model.Label(1)];
%              SVMLabels_M(:,k) = SVMLabels(:);
% 
%         %% KNN
% 
%              K = 3;  % K = 1, 3, 5, ...
%              KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%              [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%              deciKNN = [deciKNN, score(:,2)];
%              KNNLabels_M(:,k) = KNNLabels(:);
% 
%         end
% 
%         %% Quantitative Assessments
% 
%         SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
%         SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
%         KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
%         deciSVM = deciSVM'; deciSVM = deciSVM(:);
%         deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
%         if TaskNumb ~= 2
% 
%             AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%             [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\SVM_', KernelName, '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%             disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%             disp('SVM ConfMat: ');
%             disp(num2str(ProbConfMatSVM))
% 
%             AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%             [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%             disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%             disp('KNN ConfMat: ');
%             disp(num2str(ProbConfMatKNN))   
% 
%         else 
%             [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                                      PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmPoly\2v3\SVM_', KernelName, '_', 'vec_inter_seg_', num2str(b), ' & ', ...
%                   'vec_game_seg_', num2str(c)],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%             disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%                   '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%                   num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%             disp('SVM ConfMat: ')
%             disp(num2str(ConfMatSVM))
% 
% 
%             [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                                      PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn3\2v3\KNN_K', num2str(K), '_', 'vec_inter_seg_', num2str(b), ' & ', ...
%                   'vec_game_seg_', num2str(c)],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN')
%             disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%                   '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%                   num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%             disp('KNN ConfMat: ')
%             disp(num2str(ConfMatKNN))
% 
%         end
%     end
% end
% 
% %% task 1 vs task 2 cross validation
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% % C = 0.1; % for 2 different tasks
% % C = 10; % for 3 different tasks
% 
% for a = 1: 10
%     for b = 1: 12
%         task_1 = load(['vec_warm_seg_', num2str(a)]);
%         task_1 = task_1.output;
%         task_2 = load(['vec_inter_seg_', num2str(b)]);
%         task_2 = task_2.output;
% 
%         DataSet = { 
%                     downsample(task_1', downSamp)', ...
%                     downsample(task_2', downSamp)', ...
%                     };
% 
% 
% %             KernelName = 'Linear'; 
% %         KernelName = 'Polynomial';
%         KernelName = 'RBF';
% 
%         SampNumb = 29
%         TaskNumb = 2;
%         % TaskNumb = 3;
% 
%         %% Kfold & PCA & Classification
% 
%         disp('Kfold & PCA & Classification ...')
% 
%         SVMLabels_M = zeros(TaskNumb,SampNumb);
%         deciSVM = [];
% 
%         KNNLabels_M = zeros(TaskNumb,SampNumb);
%         deciKNN = [];
%         SaveTestLabel = [];
% 
% 
%         for k = 1 : SampNumb         
% 
%              TrSaLe = [];
%              TeSaLe = [];
% 
%              for i = 1 : numel(DataSet)
% 
%                  TempMemLe = DataSet{i};
% 
%                  if isempty(TempMemLe)
%                      continue
%                  else
% 
%                     [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
%         %             TrainLe = [TrainLe; TestLe];
%         %             size(TrainLe)
% 
%                     TrSaLe = [TrSaLe; TrainLe];
%                     TeSaLe = [TeSaLe; TestLe]; 
% 
%                  end
% 
%              end    
% 
%              TrLa = [];
%              TeLa = [];
% 
%              for z = 1 : TaskNumb        
% 
%                   TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%                   TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%              end
% 
%              SaveTestLabel = [SaveTestLabel, TeLa];
% 
%         %%  PCA
% 
%               % Normalize the Dataset (Left) and PCA
%              minLe = min(TrSaLe(:));
%              maxLe = max(TrSaLe(:));
% 
%              TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%              TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%              PCAratio = 0.05;
%              size(TrSaLe, 2)
%              [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%              size(TrFeLe, 2)
%         %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
%         %%  SVM
% 
%              TrFeCo = TrFeLe;    
%              TeFeCo = TeFeLe; 
%              if strcmp(KernelName, 'Linear') 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.001 -t 0 ');
%              elseif strcmp(KernelName, 'Polynomial')
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%              else 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 10 -t 2 -g 0.0001');    % RBF
%              end
% 
%              [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%              deciSVM = [deciSVM, DecEst * model.Label(1)];
%              SVMLabels_M(:,k) = SVMLabels(:);
% 
%         %% KNN
% 
%              K = 5;  % K = 1, 3, 5, ...
% 
%              KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%              [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%              deciKNN = [deciKNN, score(:,2)];
%              KNNLabels_M(:,k) = KNNLabels(:);
% 
%         end
% 
%         %% Quantitative Assessments
% 
%         SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
%         SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
%         KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
%         deciSVM = deciSVM'; deciSVM = deciSVM(:);
%         deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
%         if TaskNumb ~= 2
% 
%             AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%             [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
% %             save(['E:\EDA_Process\C_Morlet_SVM\results\SVM_', KernelName, '_', EventName{1}, ' & ', ...
% %                   EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%             disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%             disp('SVM ConfMat: ');
%             disp(num2str(ProbConfMatSVM))
% 
%             AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%             [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%             disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%             disp('KNN ConfMat: ');
%             disp(num2str(ProbConfMatKNN))   
% 
%         else 
%             [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                                      PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmRBF\1v2\SVM_', KernelName, '_', 'vec_warm_seg_', num2str(a), ' & ', ...
%                   'vec_inter_seg_', num2str(b)],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%             disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%                   '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%                   num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%             disp('SVM ConfMat: ')
%             disp(num2str(ConfMatSVM))
% 
% 
%             [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                                      PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
% %             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn5\1v2\KNN_K', num2str(K), '_', 'vec_warm_seg_', num2str(a), ' & ', ...
% %                   'vec_inter_seg_', num2str(b)],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN') 
%             disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%                   '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%                   num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%             disp('KNN ConfMat: ')
%             disp(num2str(ConfMatKNN))
% 
%         end
%     end
% end
% 
% %% task 1 vs task 3
% 
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% for a = 1: 10
%     for c = 1: 10
%         task_1 = load(['vec_warm_seg_', num2str(a)]);
%         task_1 = task_1.output;
%         task_3 = load(['vec_game_seg_', num2str(c)]);
%         task_3 = task_3.output;
% 
%         DataSet = { 
%                     downsample(task_1', downSamp)', ...
%                     downsample(task_3', downSamp)', ...
%                     };
% 
% 
% %             KernelName = 'Linear'; 
% %             KernelName = 'Polynomial';
%         KernelName = 'RBF';
% 
%         SampNumb = 29
%         TaskNumb = 2;
%         % TaskNumb = 3;
% 
%         %% Kfold & PCA & Classification
% 
%         disp('Kfold & PCA & Classification ...')
% 
%         SVMLabels_M = zeros(TaskNumb,SampNumb);
%         deciSVM = [];
% 
%         KNNLabels_M = zeros(TaskNumb,SampNumb);
%         deciKNN = [];
%         SaveTestLabel = [];
% 
% 
%         for k = 1 : SampNumb         
% 
%              TrSaLe = [];
%              TeSaLe = [];
% 
%              for i = 1 : numel(DataSet)
% 
%                  TempMemLe = DataSet{i};
% 
%                  if isempty(TempMemLe)
%                      continue
%                  else
% 
%                     [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
%         %             TrainLe = [TrainLe; TestLe];
%         %             size(TrainLe)
% 
%                     TrSaLe = [TrSaLe; TrainLe];
%                     TeSaLe = [TeSaLe; TestLe]; 
% 
%                  end
% 
%              end    
% 
%              TrLa = [];
%              TeLa = [];
% 
%              for z = 1 : TaskNumb        
% 
%                   TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%                   TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%              end
% 
%              SaveTestLabel = [SaveTestLabel, TeLa];
% 
%         %%  PCA
% 
%               % Normalize the Dataset (Left) and PCA
%              minLe = min(TrSaLe(:));
%              maxLe = max(TrSaLe(:));
% 
%              TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%              TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%              PCAratio = 0.05;
%              size(TrSaLe, 2)
%              [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%              size(TrFeLe, 2)
%         %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
%         %%  SVM
% 
%              TrFeCo = TrFeLe;    
%              TeFeCo = TeFeLe; 
%              if strcmp(KernelName, 'Linear') 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.001 -t 0 ');
%              elseif strcmp(KernelName, 'Polynomial')
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%              else
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 10 -t 2 -g 0.0001');    % RBF
%              end
% 
%              [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%              deciSVM = [deciSVM, DecEst * model.Label(1)];
%              SVMLabels_M(:,k) = SVMLabels(:);
% 
%         %% KNN
% 
%              K = 5;  % K = 1, 3, 5, ...
%              KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%              [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%              deciKNN = [deciKNN, score(:,2)];
%              KNNLabels_M(:,k) = KNNLabels(:);
% 
%         end
% 
%         %% Quantitative Assessments
% 
%         SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
%         SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
%         KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
%         deciSVM = deciSVM'; deciSVM = deciSVM(:);
%         deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
%         if TaskNumb ~= 2
% 
%             AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%             [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\SVM_', KernelName, '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%             disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%             disp('SVM ConfMat: ');
%             disp(num2str(ProbConfMatSVM))
% 
%             AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%             [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%             disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%             disp('KNN ConfMat: ');
%             disp(num2str(ProbConfMatKNN))   
% 
%         else 
%             [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                                      PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmRBF\1v3\SVM_', KernelName, '_', 'vec_warm_seg_', num2str(a), ' & ', ...
%                   'vec_game_seg_', num2str(c)],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%             disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%                   '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%                   num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%             disp('SVM ConfMat: ')
%             disp(num2str(ConfMatSVM))
% 
% 
%             [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                                      PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
% %             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn5\1v3\KNN_K', num2str(K), '_', 'vec_warm_seg_', num2str(a), ' & ', ...
% %                   'vec_game_seg_', num2str(c)],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN') 
%             disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%                   '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%                   num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%             disp('KNN ConfMat: ')
%             disp(num2str(ConfMatKNN))
% 
%         end
%     end
% end
% 
% %% task 2 vs task 3
% 
% clc;
% clear all;
% close all;
% 
% %% Make Dataset
% 
% disp('Loading Data ...')
% downSamp = 100;
% 
% for b = 1: 12
%     for c = 1: 10
% 
%         task_2 = load(['vec_inter_seg_', num2str(b)]);
%         task_2 = task_2.output;
%         task_3 = load(['vec_game_seg_', num2str(c)]);
%         task_3 = task_3.output;
% 
%         DataSet = { 
%                     downsample(task_2', downSamp)', ...
%                     downsample(task_3', downSamp)', ...
%                     };
% 
% 
% %             KernelName = 'Linear'; 
% %             KernelName = 'Polynomial';
%         KernelName = 'RBF';
% 
%         SampNumb = 29
%         TaskNumb = 2;
%         % TaskNumb = 3;
% 
%         %% Kfold & PCA & Classification
% 
%         disp('Kfold & PCA & Classification ...')
% 
%         SVMLabels_M = zeros(TaskNumb,SampNumb);
%         deciSVM = [];
% 
%         KNNLabels_M = zeros(TaskNumb,SampNumb);
%         deciKNN = [];
%         SaveTestLabel = [];
% 
% 
%         for k = 1 : SampNumb         
% 
%              TrSaLe = [];
%              TeSaLe = [];
% 
%              for i = 1 : numel(DataSet)
% 
%                  TempMemLe = DataSet{i};
% 
%                  if isempty(TempMemLe)
%                      continue
%                  else
% 
%                     [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k);            
%         %             TrainLe = [TrainLe; TestLe];
%         %             size(TrainLe)
% 
%                     TrSaLe = [TrSaLe; TrainLe];
%                     TeSaLe = [TeSaLe; TestLe]; 
% 
%                  end
% 
%              end    
% 
%              TrLa = [];
%              TeLa = [];
% 
%              for z = 1 : TaskNumb        
% 
%                   TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
%                   TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
% 
%              end
% 
%              SaveTestLabel = [SaveTestLabel, TeLa];
% 
%         %%  PCA
% 
%               % Normalize the Dataset (Left) and PCA
%              minLe = min(TrSaLe(:));
%              maxLe = max(TrSaLe(:));
% 
%              TrSaLe = (TrSaLe - minLe)/(maxLe - minLe);
%              TeSaLe = (TeSaLe - minLe)/(maxLe - minLe); 
%              PCAratio = 0.05;
%              size(TrSaLe, 2)
%              [TrFeLe, TeFeLe] = CorrectPCA(TrSaLe, TeSaLe, PCAratio);
%              size(TrFeLe, 2)
%         %      TrFeLe = TrSaLe;  TeFeLe = TeSaLe; %%% Statistics based
% 
%         %%  SVM
% 
%              TrFeCo = TrFeLe;    
%              TeFeCo = TeFeLe; 
%              if strcmp(KernelName, 'Linear') 
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.001 -t 0 ');
%              elseif strcmp(KernelName, 'Polynomial')
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 1 -d 2');       % Polynomial
%              else
%                  [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 10 -t 2 -g 0.0001');    % RBF
%              end
% 
%              [SVMLabels, ~, DecEst] = svmpredict(TeLa, TeFeCo, model);
%              deciSVM = [deciSVM, DecEst * model.Label(1)];
%              SVMLabels_M(:,k) = SVMLabels(:);
% 
%         %% KNN
% 
%              K = 5;  % K = 1, 3, 5, ...
%              KNNClassifierObject= ClassificationKNN.fit(TrFeCo, TrLa,  'NumNeighbors', K, 'Distance', 'euclidean');
%              [KNNLabels, score, ~] = predict(KNNClassifierObject,TeFeCo);
%              deciKNN = [deciKNN, score(:,2)];
%              KNNLabels_M(:,k) = KNNLabels(:);
% 
%         end
% 
%         %% Quantitative Assessments
% 
%         SaveTestLabel = SaveTestLabel'; SaveTestLabel = SaveTestLabel(:);
%         SVMLabels_M = SVMLabels_M'; SVMLabels_M = SVMLabels_M(:);
%         KNNLabels_M = KNNLabels_M'; KNNLabels_M = KNNLabels_M(:);
% 
%         deciSVM = deciSVM'; deciSVM = deciSVM(:);
%         deciKNN = deciKNN'; deciKNN = deciKNN(:);
% 
% 
%         if TaskNumb ~= 2
% 
%             AccuracySVM = numel(find(SVMLabels_M == SaveTestLabel)) / numel(SaveTestLabel);
%             [~, ProbConfMatSVM] = ConfusionMatrix(SaveTestLabel, SVMLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\SVM_', KernelName, '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatSVM', 'AccuracySVM') 
%             disp(['SVM Accuracy: ', num2str(AccuracySVM)])
%             disp('SVM ConfMat: ');
%             disp(num2str(ProbConfMatSVM))
% 
%             AccuracyKNN = numel(find(KNNLabels_M == SaveTestLabel)) / numel(SaveTestLabel);    
%             [~, ProbConfMatKNN] = ConfusionMatrix(SaveTestLabel, KNNLabels_M);
%         %     save(['C:\Users\CV_LAB_Howard\Desktop\HCode\SaveResults\KNN_K', num2str(K), '_', EventName{1}, ' & ', ...
%         %           EventName{2}, ' & ', EventName{3}],  'ProbConfMatKNN', 'AccuracyKNN') 
%             disp(['KNN Accuracy: ', num2str(AccuracyKNN)])
%             disp('KNN ConfMat: ');
%             disp(num2str(ProbConfMatKNN))   
% 
%         else 
%             [ConfMatSVM, PercisionSVM, RecallSVM, AccuracySVM, aucSVM, ~, ~, AvePercisionSVM, AveRecallSVM] = ...
%                                      PRA(SaveTestLabel, SVMLabels_M, deciSVM,['SVM-', KernelName]);
%             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\svmRBF\2v3\SVM_', KernelName, '_', 'vec_inter_seg_', num2str(b), ' & ', ...
%                   'vec_game_seg_', num2str(c)],  'ConfMatSVM', 'PercisionSVM', 'RecallSVM', 'AccuracySVM', 'aucSVM') 
%             disp(['SVM>> Accuracy: ', num2str(AccuracySVM), '; Percision: ', num2str(PercisionSVM), ...
%                   '; Recall: ', num2str(RecallSVM), '; AUC: ', num2str(aucSVM), '; AvePercision: ', ...
%                   num2str(AvePercisionSVM), '; AveRecall: ', num2str(AveRecallSVM)])
%             disp('SVM ConfMat: ')
%             disp(num2str(ConfMatSVM))
% 
% 
%             [ConfMatKNN, PercisionKNN, RecallKNN, AccuracyKNN, aucKNN, ~, ~, AvePercisionKNN, AveRecallKNN] = ... 
%                                      PRA(SaveTestLabel, KNNLabels_M, deciKNN, ['KNN-K', num2str(K)]); 
% %             save(['E:\EDA_Process\C_Morlet_SVM\results_10_12_10\knn5\2v3\KNN_K', num2str(K), '_', 'vec_inter_seg_', num2str(b), ' & ', ...
% %                   'vec_game_seg_', num2str(c)],  'ConfMatKNN', 'PercisionKNN', 'RecallKNN', 'AccuracyKNN', 'aucKNN')
%             disp(['KNN>> Accuracy: ', num2str(AccuracyKNN), '; Percision: ', num2str(PercisionKNN), ...
%                   '; Recall: ', num2str(RecallKNN), '; AUC: ', num2str(aucKNN), '; AvePercision: ', ...
%                   num2str(AvePercisionKNN), '; AveRecall: ', num2str(AveRecallKNN)])
%             disp('KNN ConfMat: ')
%             disp(num2str(ConfMatKNN))
% 
%         end
%     end
% end
% 
% close all;

    
function [ProbConfMat, Percision, Recall, Accuracy, auc, stack_x, stack_y, AvePercision, AveRecall] = ...
               PRA(GroundTruth, Predicted, deci, ClassifierName)

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
% [ProbConfMat,Percision, Recall, Accuracy, AUC, FPR, TPR, AvePercision, AveRecall] = PRA(TestLabel, predicted_label, deci, 'SVM_Linear');


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

Percision = ConfMat(1,1)/(ConfMat(1,1) + ConfMat(2,1));
Recall = ConfMat(1,1)/(ConfMat(1,1) + ConfMat(1,2));
Accuracy = sum(diag(ConfMat)) / sum(ConfMat(:));

Percision2 = ConfMat(2,2) / (ConfMat(2,2) + ConfMat(1,2));
Recall2 = ConfMat(2,2) / (ConfMat(2,2) + ConfMat(2,1));

AvePercision = (Percision + Percision2) / 2;
AveRecall = (Recall + Recall2) / 2;

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
% stack_x = stackY;
% stack_y = stackX;

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

% ---- Predicted ----
% |    TP   FN
% G    FP   TN 
% T
% |


% ConfMat = [TP, FN;
%            FP, TN];
       
       
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
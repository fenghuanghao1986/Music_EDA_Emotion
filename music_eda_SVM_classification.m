% Music EDA classification (SVM, MKL, single sensor)

% Fs = 32;
% scales = [1:100];
% DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/32)
% 
% fw = DesiredFrequency/2;
% scales = Fs ./ fw

%% SVM - Linear Kernal
% all 33 same files results after time correction, since the video recoding
% system not sync the time properly, so move 1 min up than before, q sensor
% always sync the real time
% the following results are from Surface computer

% 1vs2
% SVMAccuracy : 51.5152
% SVMConfusionMatrix
% 52  48
% 48  52
% for c = 10
% SVMAccuracy : 66.6667
% SVMConfusionMatrix
% 64  36
% 30  70

% 1vs3
% SVMAccuracy : 53.0303
% SVMConfusionMatrix
% 55  45
% 48  52
% for c = 1
% SVMAccuracy : 54.5455
% SVMConfusionMatrix
% 58  42
% 48  52

% 2vs3
% SVMAccuracy : 57.5758
% SVMConfusionMatrix
% 76  24
% 61  39
% for c = 1
% SVMAccuracy : 59.0909
% SVMConfusionMatrix
% 73  27
% 55  45

% 1vs2vs3 c = 0.1
% SVMAccuracy : 36.3636
% SVMConfusionMatrix
% 48  33  18
% 45  33  21
% 33  39  27

% 1vs2vs3 c = 10
% SVMAccuracy : 30.303
% SVMConfusionMatrix
% 39  27  33
% 45  18  36
% 27  39  33

%% SVM - Linear Kernal
% the following results are from Lab computer

% 1vs2
% SVMAccuracy : 51.5152
% SVMConfusionMatrix
% 27  73
% 24  76
% for c = 100
% SVMAccuracy : 60.6061
% SVMConfusionMatrix
% 52  48
% 30  70

% 1vs3
% SVMAccuracy : 46.9697
% SVMConfusionMatrix
% 58  42
% 64  36

% 2vs3
% SVMAccuracy : 56.0606
% SVMConfusionMatrix
% 79  21
% 67  33
% for c = 1000
% SVMAccuracy : 71.2121
% SVMConfusionMatrix
% 79  21
% 36  64

% 1vs2vs3 c = 0.1
% SVMAccuracy : 36.3636
% SVMConfusionMatrix
% 12  67  21
% 18  64  18
%  9  58  33

% 1vs2vs3 c = 10
% SVMAccuracy : 37.3737
% SVMConfusionMatrix
% 42  36  21
% 39  42  18
% 39  33  27

%% SVM - Polynomial Kernal

% c = 0.1 1vs2
% SVMAccuracy : 57.5758
% SVMConfusionMatrix
% 21  79
%  6  94

% c = 100 1vs3
% SVMAccuracy : 60.6061
% SVMConfusionMatrix
% 58  42
% 36  64

% c = 1 2vs3
% SVMAccuracy : 60.6061
% SVMConfusionMatrix
% 94   6
% 73  27

% c = 1 1vs2vs3
% SVMAccuracy : 40.404
% SVMConfusionMatrix
% 12  76  12
% 12  85   3
%  9  67  24

%% SVM - RBF Kernal

% c = 0.1 1vs2
% SVMAccuracy : 53.0303
% SVMConfusionMatrix
% 39  61
% 33  67

% c = 100 1vs3
% SVMAccuracy : 56.0606
% SVMConfusionMatrix
% 55  45
% 42  58

% c = 0.1 2vs3
% SVMAccuracy : 60.6061
% SVMConfusionMatrix
% 61  39
% 39  61

% c = 1000 1vs2vs3
% SVMAccuracy : 39.3939
% SVMConfusionMatrix
% 33  42  24
% 39  39  21
% 36  18  45


%% Clean
clc;
clear all;
close all;

%% Make Dataset

disp('Loading Data ...')
downSamp = 1000;

% C = 0.1; % for 2 different tasks
% C = 10; % for 3 different tasks

task_1 = load('vec_warm_1000');
task_1 = task_1.output;
task_2 = load('vec_inter_1000');
task_2 = task_2.output;
task_3 = load('vec_game_1000');
task_3 = task_3.output;

% 2 tasks
% DataSet = { downsample(task_1', downSamp)', ...
%             downsample(task_2', downSamp)'};
% 3 tasks
DataSet = { downsample(task_1', downSamp)', ...
            downsample(task_2', downSamp)', ...
            downsample(task_3', downSamp)'};
       
SampNumb = 33
% TaskNumb = 2;
TaskNumb = 3;

%% Kfold & PCA & Classification

disp('Kfold & PCA & Classification ...')

SVMAccuracy = zeros(1, SampNumb);
SVMConf = cell(1,SampNumb); 

SVMLabels_M = zeros(TaskNumb,SampNumb);

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
     % C = 0.1 for 2 tasks in general 1 gives better results from surface
     [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 3 ');
     % C = 10 for 3 tasks C = 0.1 gives better result from surface
%      [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c .1 -t 0 ');

     [SVMLabels, accuracy, DecEst] = svmpredict(TeLa, TeFeCo, model);
    
     SVMLabels_M(:,k) = SVMLabels(:);
    
     SVMCoMa = zeros(TaskNumb, TaskNumb);             
     for i = 1 : TaskNumb  
         for j = 1 : TaskNumb
        
             SVMCoMa(i,j) = numel(find(SVMLabels...
                 (1 + (i - 1)*size(TeLa,1)/TaskNumb : i*size(TeLa,1)/TaskNumb) == j));
        
         end    
     end
    
     SVMAccuracy(k) = accuracy(1);
     SVMConf{k} = SVMCoMa;
    
end

%% Quantitative Assessments

SVMAcc = sum(SVMAccuracy(:))/SampNumb;
ConfMat_SVM1 = 0;
    
for w = 1 : SampNumb
    
     ConfMat_SVM1 = ConfMat_SVM1 + SVMConf{w};

end

ConfMat_SVM = round(100*(ConfMat_SVM1/SampNumb)/(numel(TeLa)/TaskNumb));

disp(['SVMAccuracy : ', num2str(SVMAcc)])
disp('SVMConfusionMatrix')
disp(num2str(ConfMat_SVM))


% Music EDA classification (SVM, MKL, single sensor)

% Fs = 32;
% scales = [1:100];
% DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/32)
% 
% fw = DesiredFrequency/2;
% scales = Fs ./ fw

%% Clean
clc;
clear all;
close all;

%% Make Dataset

disp('Loading Data ...')
downSamp = 1000;

% C = 0.1; % for 2 different tasks
% C = 10; % for 3 different tasks

asd_class = load('vec_ASD');
asd_class = asd_class.output;
td_class = load('vec_TD');
td_class = td_class.output;

% 2 tasks
DataSet = { downsample(asd_class', downSamp)', ...
            downsample(td_class', downSamp)'};
       
SampNumb = 16
TaskNumb = 2;

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


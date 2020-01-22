% Music EDA classification (SVM, MKL, single sensor, half vs half)

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

ASD0 = load('vec_ASD0');
ASD0 = ASD0.output;
TD0 = load('vec_TD0');
TD0 = TD0.output;

DataSet0 = { 
            downsample(ASD0', downSamp)', ...
            downsample(TD0', downSamp)', ...
            };
         
ASD1 = load('vec_ASD1');
ASD1 = ASD1.output;
TD1 = load('vec_TD1');
TD1 = TD1.output;

DataSet1 = { 
            downsample(ASD1', downSamp)', ...
            downsample(TD1', downSamp)', ...
            };
       
SampNumb = 8;
TaskNumb = 2; 

%% Kfold & PCA & Classification

disp('Kfold & PCA & Classification ...')

SVMAccuracy = zeros(1, SampNumb);
SVMConf = cell(1,SampNumb); 

MKLAccuracy = zeros(1, SampNumb);
MKLConf = cell(1,SampNumb);

SVMLabels_M = zeros(TaskNumb,SampNumb);
MKLLabels_M = zeros(TaskNumb,SampNumb);

for k = 1 : SampNumb         
    
     TrSaLe = [];
     TeSaLe = [];
     TrSaRi = [];
     TeSaRi = [];
    
     for i = 1 : numel(DataSet0)
    
         TempMemLe = DataSet0{i};
         TempMemRi = DataSet1{i};
        
         if isempty(TempMemLe)
             continue
         else
            
            [TrainLe, TestLe] = Kfold(TempMemLe, SampNumb, SampNumb, k); 
            [TrainRi, TestRi] = Kfold(TempMemRi, SampNumb, SampNumb, k); 
    
            TrSaLe = [TrSaLe; TrainLe];
            TeSaLe = [TeSaLe; TestLe]; 
            TrSaRi = [TrSaRi; TrainRi];
            TeSaRi = [TeSaRi; TestRi];
            
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
     
     % Normalize the Dataset (Right) and PCA
     minRi = min(TrSaRi(:));
     maxRi = max(TrSaRi(:));
     
     TrSaRi = (TrSaRi - minRi)/(maxRi - minRi);
     TeSaRi = (TeSaRi - minRi)/(maxRi - minRi); 
     PCAratio = 0.05;
     [TrFeRi, TeFeRi] = CorrectPCA(TrSaRi, TeSaRi, PCAratio);
    
%%  SVM
    
     TrFeCo = cat(2,TrFeLe, TrFeRi);    
     TeFeCo = cat(2,TeFeLe, TeFeRi);
     
%    "-t kernel_type : set type of kernel function (default 2)\n"
% 	"	0 -- linear: u'*v\n"
% 	"	1 -- polynomial: (gamma*u'*v + coef0)^degree\n"
% 	"	2 -- radial basis function: exp(-gamma*|u-v|^2)\n"
% 	"	3 -- sigmoid: tanh(gamma*u'*v + coef0)\n"
% 	"	4 -- precomputed kernel (kernel values in training_set_file)\n"
%   "-c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)\n"
     % C = 0.1 for 2 tasks in general 1 gives better results from surface
     
     if numel(DataSet1) == 2
         [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 3 ');
     else
         [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.1 -t 3 ');
     end

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
     
%% MKL
% I am using half of the sample (17 samples out of 33 total samples) as 
% left and another half for right, then use them as trainng set and test 
% set, we will see what will happen

     if numel(DataSet1) == 2
         [MKLLabels,~,~] = LpMKL_MW_2f(TrFeLe, TrFeRi, TrLa, TeFeLe, TeFeRi, 10, TaskNumb, 2); 
     else
         [MKLLabels,~,~] = LpMKL_MW_2f(TrFeLe, TrFeRi, TrLa, TeFeLe, TeFeRi, 10, TaskNumb, 2);
     end
         
     MKLLabels_M(:,k) = MKLLabels(:);
    
     MKLCoMa = zeros(TaskNumb, TaskNumb);  
     for i = 1 : TaskNumb  
         for j = 1 : TaskNumb
        
             MKLCoMa(i,j) = numel(find(MKLLabels...
                (1 + (i - 1)*size(TeLa,1)/TaskNumb : i*size(TeLa,1)/TaskNumb) == j));
        
         end    
     end
              
     MKLAccuracy(k) = 100*numel(find((MKLLabels - TeLa) == 0))/numel(TeLa);
     MKLConf{k} = MKLCoMa;
    
end

%% Quantitative Assessments

SVMAcc = sum(SVMAccuracy(:))/SampNumb;
MKLAcc = sum(MKLAccuracy(:))/SampNumb;

ConfMat_SVM1 = 0;
ConfMat_MKL1 = 0;
    
for w = 1 : SampNumb
    
     ConfMat_SVM1 = ConfMat_SVM1 + SVMConf{w};
     ConfMat_MKL1 = ConfMat_MKL1 + MKLConf{w};

end

ConfMat_SVM = round(100*(ConfMat_SVM1/SampNumb)/(numel(TeLa)/TaskNumb));
ConfMat_MKL = round(100*(ConfMat_MKL1/SampNumb)/(numel(TeLa)/TaskNumb));

disp(['SVMAccuracy : ', num2str(SVMAcc)])
disp(['MKLAccuracy : ', num2str(MKLAcc)])
disp('SVMConfusionMatrix')
disp(num2str(ConfMat_SVM))
disp('MKLConfusionMatrix')
disp(num2str(ConfMat_MKL))


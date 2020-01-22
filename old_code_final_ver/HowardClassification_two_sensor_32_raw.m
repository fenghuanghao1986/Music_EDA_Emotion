
% HowardClassification (SVM, MKL) (combining both qsensors)

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

% % C = 0.1; % for 2 events - events 2 & 3 are the best!!
% % C = 10; % for 3 events

%% 3 classes
% event_2 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\whole_data\Figures_spectrogram_range64_filter32\Event_2\event_2_', 'q1']);
% event_2 = event_2.output;
% event_3 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\whole_data\Figures_spectrogram_range64_filter32\Event_3\event_3_', 'q1']);
% event_3 = event_3.output;
% event_5 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\whole_data\Figures_spectrogram_range64_filter32\Event_5\event_5_', 'q1']);
% event_5 = event_5.output;
% 
% DataSetL = {downsample(event_2', DownSamp)', ...
%            downsample(event_3', DownSamp)', ...
%            downsample(event_5', DownSamp)'};
% 
% event_2 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\whole_data\Figures_spectrogram_range64_filter32\Event_2\event_2_', 'q2']);
% event_2 = event_2.output;
% event_3 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\whole_data\Figures_spectrogram_range64_filter32\Event_3\event_3_', 'q2']);
% event_3 = event_3.output;
% event_5 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\whole_data\Figures_spectrogram_range64_filter32\Event_5\event_5_', 'q2']);
% event_5 = event_5.output;
% 
% DataSetR = {downsample(event_2', DownSamp)', ...
%            downsample(event_3', DownSamp)', ...
%            downsample(event_5', DownSamp)'};       
% 
% SampNumb = 23;
% TaskNumb = 3;

% %% 2 classes
% 
% event_2 = load(['C:\Users\Lab User\Desktop\Figures_spectrogram_currectVersion (1)\Event_2\event_2_', 'q1']);
% event_2 = event_2.output;
% event_3 = load(['C:\Users\Lab User\Desktop\Figures_spectrogram_currectVersion (1)\Event_3\event_3_', 'q1']);
% event_3 = event_3.output;
% 
% DataSetL = {downsample(event_2', DownSamp)', ...
%            downsample(event_3', DownSamp)'};
% 
% event_2 = load(['C:\Users\Lab User\Desktop\Figures_spectrogram_currectVersion (1)\Event_2\event_2_', 'q2']);
% event_2 = event_2.output;
% event_3 = load(['C:\Users\Lab User\Desktop\Figures_spectrogram_currectVersion (1)\Event_3\event_3_', 'q2']);
% event_3 = event_3.output;
% 
% DataSetR = {downsample(event_2', DownSamp)', ...
%            downsample(event_3', DownSamp)'};
%        
% SampNumb = 32;
% TaskNumb = 2;

%% 5 classes
event_1 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_1\event_1_', 'q1']);
event_1 = event_1.output;
event_2 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_2\event_2_', 'q1']);
event_2 = event_2.output;
event_3 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_3\event_3_', 'q1']);
event_3 = event_3.output;
event_4 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_4\event_4_', 'q1']);
event_4 = event_4.output;
event_5 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_5\event_5_', 'q1']);
event_5 = event_5.output;

DataSetL = {%downsample(event_1', DownSamp)', ...
           downsample(event_5', DownSamp)', ...
           downsample(event_1', DownSamp)', ...
           downsample(event_2', DownSamp)', ...
           downsample(event_3', DownSamp)'};

event_1 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_1\event_1_', 'q2']);
event_1 = event_1.output;
event_2 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_2\event_2_', 'q2']);
event_2 = event_2.output;
event_3 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_3\event_3_', 'q2']);
event_3 = event_3.output;
event_4 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_4\event_4_', 'q2']);
event_4 = event_4.output;
event_5 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_5\event_5_', 'q2']);
event_5 = event_5.output;

DataSetR = {%downsample(event_1', DownSamp)', ...
           downsample(event_5', DownSamp)', ...
           downsample(event_1', DownSamp)', ...
           downsample(event_2', DownSamp)', ...
           downsample(event_3', DownSamp)'};     

SampNumb = 32;
TaskNumb = 4;

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
    
     for i = 1 : numel(DataSetL)
    
         TempMemLe = DataSetL{i};
         TempMemRi = DataSetR{i};
        
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
     
     if numel(DataSetL) == 2
         [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.01 -t 0 ');
     else
         [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 1 -t 0 ');
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
     
     if numel(DataSetL) == 2
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








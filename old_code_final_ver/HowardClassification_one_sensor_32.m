
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

qsensor = 'q1'; % 'q1', 'q2';

% event_2 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\refined_raw_data\Figures_spectrogram_range64_filter32\Event_2\event_2_', qsensor]);
% event_2 = event_2.output;
% % event_3 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\refined_raw_data\Figures_spectrogram_range64_filter32\Event_3\event_3_', qsensor]);
% % event_3 = event_3.output;
% event_5 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\refined_raw_data\Figures_spectrogram_range64_filter32\Event_5\event_5_', qsensor]);
% event_5 = event_5.output;
% % 
% % DataSet = {downsample(event_2', DownSamp)', ...
% %            downsample(event_3', DownSamp)', ...
% %            downsample(event_5', DownSamp)'};
% % 
% % SampNumb = 23;
% % TaskNumb = 3;
% 
% % event_2 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\refined_raw_data\Figures_spectrogram_range64_filter32\Event_2\event_2_', qsensor]);
% % event_2 = event_2.output;
% % event_3 = load(['D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\refined_raw_data\Figures_spectrogram_range64_filter32\Event_3\event_3_', qsensor]);
% % event_3 = event_3.output;
% 
% DataSet = {downsample(event_5', DownSamp)', ...
%            downsample(event_2', DownSamp)'};
% 
% SampNumb = 23;
% TaskNumb = 2;

event_1 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_1\event_1_', qsensor]);
event_1 = event_1.output;
event_2 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_2\event_2_', qsensor]);
event_2 = event_2.output;
event_3 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_3\event_3_', qsensor]);
event_3 = event_3.output;
event_4 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_4\event_4_', qsensor]);
event_4 = event_4.output;
event_5 = load(['D:\event_based_emotion_redo\Figures_spectrogram_32_raw\Event_5\event_5_', qsensor]);
event_5 = event_5.output;

DataSet = {%downsample(event_1', DownSamp)', ...
%            downsample(event_1', DownSamp)', ...
           downsample(event_2', DownSamp)', ...
           downsample(event_3', DownSamp)', ...
           downsample(event_5', DownSamp)'};     

SampNumb = 32;
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
     [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 0.01 -t 0 ');
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










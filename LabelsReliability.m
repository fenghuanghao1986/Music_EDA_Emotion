



% By Hosein M. Golshan
% Last Update: Jun. 16, 2016

% 3Labels for 3Channels and the fuse. (This approach gives the best
% results!)

clc
clear all
close all
warning off

%% Data Extraction using Raw signal

% disp('Data Extraction form Raw STN-LFPs ...')
% SubjectName = 'O14AJ_20141103';
% SubjectResponse = 'O14AJ_20141103_response';
% ECoG_OR_LFP = 'LFP';
% ExtractDataSet(SubjectName,SubjectResponse,name,InterestedTasks,1,ECoG_OR_LFP);

%% Initialization

% name = 'J15M';
% name = 'O14AJ';
name = 'O14AK';
% name = 'A15K';
InterestedTasks = {'Button','Audio','Random','Reach','Video'};
TaskNum = numel(InterestedTasks);
prompt = 'Press 1 if you want to run synchronization subroutine:';
Synchronization = input(prompt);

%% Synchronization

ECoG_OR_LFP = 'LFP';          % 'LFP' OR 'ECoG'

if Synchronization == 1
    
    disp('Set Dataset based on the synchronization of channels ...') 
    A = 0;
    Max_Synch = cell(TaskNum,1);
    Max_Val = zeros(TaskNum,1);
    Max_Ind = zeros(TaskNum,1);
    Sync_Score = zeros(3,3);
     
    RawKind = 'DownRaw';   % 'DownRaw' OR 'DownRawFiltered' 

    for i = 1:numel(InterestedTasks)
 
        for j = 1:3 
        
             DataL = load([name,'-',InterestedTasks{i},'-CH',num2str(j),'L-',ECoG_OR_LFP,'.mat'],RawKind);
        
             for k = 1:3
                
                  DataR = load([name,'-',InterestedTasks{i},'-CH',num2str(k),'R-',ECoG_OR_LFP,'.mat'],RawKind);
            
                  if strcmp(RawKind,'DownRawFiltered')
                
                      [Sync_Score(j,k)] = Extract_FFTSync_Ch(DataL.DownRawFiltered,DataR.DownRawFiltered,100);
%                       [Sync_Score(j,k)] = Extract_PLVSync_Ch(DataL.DownRawFiltered,DataR.DownRawFiltered,100);
               
                  else
                
                      [Sync_Score(j,k)] = Extract_FFTSync_Ch(DataL.DownRaw,DataR.DownRaw,100);
%                       [Sync_Score(j,k)] = Extract_PLVSync_Ch(DataL.DownRaw,DataR.DownRaw,100);
               
                  end
            
             end
        
        end
  
        A = A + Sync_Score;      
      
    end

    clear DataL DataR 
    A = A / numel(InterestedTasks);
   
    LeftCh = zeros(3,1); 
    RightCh = zeros(3,1);
   
    for num = 1:3
    
         [vv,aa] = max(A(num,:));
         [LeftCh(num),RightCh(num)] = ind2sub([1,3],aa);
    
    end

    LeftCh = LeftCh + [0; 1; 2];
    BB = [max(A(1,:)); max(A(2,:)); max(A(3,:))];   
    [va, MostLikelyCh] = max(BB(:));
    
else
    
    LeftCh = [1; 2; 3];
    RightCh = [1; 2; 3];
    
end    

%% Classification 

SVMAcc = 0;
MKLAcc = 0;
ConfMat_MKL = 0;
ConfMat_SVM = 0;

for q = 1: 3
    
    DirPoolLeft = ['CH', num2str(LeftCh(q)), 'L'];
    DirPoolRight = ['CH', num2str(RightCh(q)), 'R'];
   
%% Make Dataset

    disp('Loading Data ...')
    DataType = 'AmplLowPass';
    DownSamp = 100;
    
    [DataSet] = MakeDataSet3(name,InterestedTasks,DataType,DirPoolLeft,DirPoolRight,DownSamp,ECoG_OR_LFP,0);

%% Make  Equal the Number of Events for all Tasks

    for i = 1 : size(DataSet, 1)
    
         TempSiz(i) = size(DataSet{i,1}, 1);
    
    end

    SampNumb = min(TempSiz(find(TempSiz>0)));
    M_DataSet = cell(size(DataSet));

    if q == 1
        
       FinalLabelsSVM = zeros(3*numel(InterestedTasks),SampNumb);
       FinalLabelsMKL = zeros(3*numel(InterestedTasks),SampNumb);
        
    end
    
    for i = 1 : size(DataSet , 1)
    
        Temp1 = DataSet{i,1};
        Temp2 = DataSet{i,2};
    
        if isempty(Temp1) || isempty(Temp2)
            continue
        else
        
            M_DataSet{i,1} = Temp1(1:SampNumb,:);
            M_DataSet{i,2} = Temp2(1:SampNumb,:);
        
        end   
    
    end

    DataSet = M_DataSet;

%% Kfold & PCA & Classification

    disp('Kfold & PCA & Classification ...')

    SVMAccuracy = zeros(1, SampNumb);
    MKLAccuracy = zeros(1, SampNumb);
    SVMConf = cell(1,SampNumb); 
    MKLConf = cell(1,SampNumb);

    SVMTrainTime = zeros(1,SampNumb);
    MKLTrainTime = zeros(1,SampNumb);
    SVMTestTime = zeros(1,SampNumb);
    MKLTestTime = zeros(1,SampNumb);

    SVMLabels_M = zeros(TaskNum,SampNumb);
    MKLLabels_M = zeros(TaskNum,SampNumb);

    for k = 1 : SampNumb         
    
        TrSaLe = [];
        TeSaLe = [];
        TrSaRi = [];
        TeSaRi = [];
    
        for i = 1 : size(DataSet, 1)
    
            TempMemLe = DataSet{i,1};
            TempMemRi = DataSet{i,2};
        
            if isempty(TempMemLe) || isempty(TempMemRi)
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
    
        for z = 1 : TaskNum        
            
             TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
             TeLa = [TeLa; z*ones(size(TestLe, 1),1)];                        
        
        end
              
%%  PCA
    
        % Normalize the Dataset (Left) and PCA
        TrSaLe = (TrSaLe - min(TrSaLe(:)))/(max(TrSaLe(:)) - min(TrSaLe(:)));
        TeSaLe = (TeSaLe - min(TeSaLe(:)))/(max(TeSaLe(:)) - min(TeSaLe(:))); 
        PCAratio = 0.05;
        [TrFeLe, TeFeLe] = NewPCA2(TrSaLe, TeSaLe, PCAratio);
    
        % Normalize the Dataset (Right) and PCA
        TrSaRi = (TrSaRi - min(TrSaRi(:)))/(max(TrSaRi(:)) - min(TrSaRi(:)));
        TeSaRi = (TeSaRi - min(TeSaRi(:)))/(max(TeSaRi(:)) - min(TeSaRi(:))); 
        PCAratio = 0.05;
        [TrFeRi, TeFeRi] = NewPCA2(TrSaRi, TeSaRi, PCAratio);
    
%%  SVM
    
        TrFeCo = cat(2,TrFeLe, TrFeRi);    
        TeFeCo = cat(2,TeFeLe, TeFeRi); 
        tic
        [model] = svmtrain(TrLa, TrFeCo, '-s 0 -c 100 -t 0 ');
        SVMTrainTime(k) = toc;
        tic
        [SVMLabels, accuracy, DecEst] = svmpredict(TeLa, TeFeCo, model);
        SVMTestTime(k) = toc;
    
        SVMLabels_M(:,k) = SVMLabels(:);
    
        SVMCoMa = zeros(TaskNum, TaskNum);             
        for i = 1 : TaskNum  
            for j = 1 : TaskNum
        
                 SVMCoMa(i,j) = numel(find(SVMLabels...
                 (1 + (i - 1)*size(TeLa,1)/TaskNum : i*size(TeLa,1)/TaskNum) == j));
        
            end    
        end
    
        SVMAccuracy(k) = accuracy(1);
        SVMConf{k} = SVMCoMa;
    
%% MKL

        [MKLLabels,MKLTrainTime(k),MKLTestTime(k)] = LpMKL_MW_2f(TrFeLe, TrFeRi, TrLa, TeFeLe, TeFeRi, 100, TaskNum, 2); 
        MKLLabels_M(:,k) = MKLLabels(:);
    
        MKLCoMa = zeros(TaskNum, TaskNum);  
        for i = 1 : TaskNum  
            for j = 1 : TaskNum
        
                 MKLCoMa(i,j) = numel(find(MKLLabels...
                (1 + (i - 1)*size(TeLa,1)/TaskNum : i*size(TeLa,1)/TaskNum) == j));
        
            end    
        end
              
        MKLAccuracy(k) = 100*numel(find((MKLLabels - TeLa) == 0))/numel(TeLa);
        MKLConf{k} = MKLCoMa; 
    
    end

    for rt = 1:numel(InterestedTasks)
        
        FinalLabelsSVM(q + 3*(rt-1),:) = SVMLabels_M(rt,:);
        FinalLabelsMKL(q + 3*(rt-1),:) = MKLLabels_M(rt,:);
        
    end
 
%% Quantitative Assessments

    SVMAcc = SVMAcc + sum(SVMAccuracy(:))/SampNumb;
    MKLAcc = MKLAcc + sum(MKLAccuracy(:))/SampNumb;

    ConfMat_SVM1 = 0;
    ConfMat_MKL1 = 0;
    
    for w = 1 : SampNumb
    
        ConfMat_MKL1 = ConfMat_MKL1 + MKLConf{w};
        ConfMat_SVM1 = ConfMat_SVM1 + SVMConf{w};

    end

    ConfMat_MKL = ConfMat_MKL + round(100*(ConfMat_MKL1/SampNumb)/(numel(TeLa)/TaskNum));
    ConfMat_SVM = ConfMat_SVM + round(100*(ConfMat_SVM1/SampNumb)/(numel(TeLa)/TaskNum));
    
end

%% Old quantitative assessments

SVMAcc = SVMAcc/3;
MKLAcc = MKLAcc/3;
ConfMat_SVM = round(ConfMat_SVM/3);
ConfMat_MKL = round(ConfMat_MKL/3);

%% Reliability Calculation

MKL_ReliableMatrix = zeros(numel(InterestedTasks),SampNumb);
SVM_ReliableMatrix = zeros(numel(InterestedTasks),SampNumb);

for j = 1:SampNumb
    
    for i = 1:numel(InterestedTasks)
    
        TempLabel = FinalLabelsSVM(3*(i-1)+1:3*i, j);            
        ww = numel(find(TempLabel==i));
            
        if ww == 0
            SVM_ReliableMatrix(i,j) = 0;
        elseif ww == 1
            SVM_ReliableMatrix(i,j) = 33;
        elseif ww == 2
            SVM_ReliableMatrix(i,j) = 66;
        else
            SVM_ReliableMatrix(i,j) = 100;
        end
            
% **************************************************************************        
        
        TempLabel = FinalLabelsMKL(3*(i-1)+1:3*i, j);      
        ww = numel(find(TempLabel==i));
            
        if ww == 0
            MKL_ReliableMatrix(i,j) = 0;
        elseif ww == 1
            MKL_ReliableMatrix(i,j) = 33;
        elseif ww == 2
            MKL_ReliableMatrix(i,j) = 66;
        else
            MKL_ReliableMatrix(i,j) = 100;
        end            
        
    end
    
end

%% Fusion Phase

NewMKLLabels= zeros(3*numel(InterestedTasks),SampNumb);
NewSVMLabels= zeros(3*numel(InterestedTasks),SampNumb);

for j = 1:SampNumb
    
    for i = 1:numel(InterestedTasks)
    
        TempLabel = FinalLabelsSVM(3*(i-1)+1:3*i, j);
        
        for k = 1:numel(InterestedTasks)
            ww = numel(find(TempLabel==k));
            if ww>1
                TempLabel = k*ones(3,1);
                break
            end
        end
        
        if ww<=1
           if Synchronization==1 
               TempLabel = TempLabel(MostLikelyCh)*ones(3,1);
           else
               TempLabel = TempLabel(1)*ones(3,1);
           end
        end            
        NewSVMLabels(3*(i-1)+1:3*i, j)=TempLabel;

% **************************************************************************        
        
        TempLabel2 = FinalLabelsMKL(3*(i-1)+1:3*i, j);
        
        for k = 1:numel(InterestedTasks)
            ww2 = numel(find(TempLabel2==k));
            if ww2>1
                TempLabel2 = k*ones(3,1);
                break
            end
        end
        
        if ww2<=1
            if Synchronization==1
                TempLabel2 = TempLabel2(MostLikelyCh)*ones(3,1);
            else
                TempLabel2 = TempLabel2(1)*ones(3,1);
            end
        end
           
        NewMKLLabels(3*(i-1)+1:3*i, j) = TempLabel2;
        
    end
    
end

%% New Quantitative Assessments

TeLa2 = [];
for uu = 1:numel(InterestedTasks)
    TeLa2 = [TeLa2; uu*ones(3,1)];
end

NewLabelDif_SVM = NewSVMLabels - repmat(TeLa2,1,SampNumb);
NewLabelDif_MKL = NewMKLLabels - repmat(TeLa2,1,SampNumb);

NewSVMAccuracy = 100*numel(find(NewLabelDif_SVM==0))/(numel(NewLabelDif_SVM));
NewMKLAccuracy = 100*numel(find(NewLabelDif_MKL==0))/(numel(NewLabelDif_MKL));

% Confusion Matrix for the new implementation
NewLaSVM = zeros(numel(InterestedTasks),SampNumb);
NewLaMKL = zeros(numel(InterestedTasks),SampNumb);

for z2 = 1:SampNumb
    
    for z1 = 1:numel(InterestedTasks)
         
        NewLaSVM(z1,z2) = NewSVMLabels(3*(z1-1)+1,z2);
        NewLaMKL(z1,z2) = NewMKLLabels(3*(z1-1)+1,z2);
        
    end
    
end      

ConfMatSVM_N = zeros(numel(InterestedTasks),numel(InterestedTasks));
ConfMatMKL_N = zeros(numel(InterestedTasks),numel(InterestedTasks));

for p = 1:SampNumb
    
    TempSVMLa = NewLaSVM(:,p);
    TempMKLLa = NewLaMKL(:,p);
    
    for p1 = 1:numel(InterestedTasks)
        
        for p2 = 1:numel(InterestedTasks)
            
            ConfMatSVM_N(p1,p2) =  ConfMatSVM_N(p1,p2) + numel(find(TempSVMLa(p1)==p2));
            ConfMatMKL_N(p1,p2) =  ConfMatMKL_N(p1,p2) + numel(find(TempMKLLa(p1)==p2));
            
        end
        
    end
    
end

ConfMat_SVM_N = round(100*(ConfMatSVM_N/SampNumb)); 
ConfMat_MKL_N = round(100*(ConfMatMKL_N/SampNumb));                                   
    
%% Display the results
clc

disp('SVM Confusion Matrix:'); disp(num2str(ConfMat_SVM)); disp(' ');
disp('New SVM Confusion Matrix:'); disp(num2str(ConfMat_SVM_N)); disp(' ');
disp('MKL Confusion Matrix:'); disp(num2str(ConfMat_MKL)); disp(' ');
disp('New MKL Confusion Matrix:'); disp(num2str(ConfMat_MKL_N)); disp(' ');

disp(['SVM Accuracy: ', num2str(mean(SVMAcc(:)))]); 
disp(['New SVM Accuracy: ', num2str(NewSVMAccuracy)]); 
disp(['MKL Accuracy: ', num2str(mean(MKLAcc(:)))]); 
disp(['New MKL Accuracy: ', num2str(NewMKLAccuracy)]); 

%% Save Classification Accuracy and Confusion Matrix

save([name,'LabelsData',ECoG_OR_LFP],'FinalLabelsMKL',...
    'FinalLabelsSVM','InterestedTasks','SampNumb',...
    'MKL_ReliableMatrix', 'SVM_ReliableMatrix') 















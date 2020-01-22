
% By Hosein M. Golshan
% Last Update: May. 11, 2016

%% Initialization
clc
clear all
close all
warning off

%% Test Loop

BB={'O14AJ','O14AK','A15K'};
CC=[10,50,500,1000,2000];

for bb=1:numel(BB)
    for cc=1:numel(CC)

%% Synchronization

disp('Set Dataset based on the synchronization of channels ...')
name = BB{bb};
InterestedTasks = {'Button','Audio','Random','Reach','Video'};
Kind = 'LFP';          % 'LFP' OR 'ECoG' 
Sync_Mem = zeros(15,2);
Sync_Score = zeros(3,3);
RawKind = 'DownRaw';   % 'DownRaw' OR 'DownRawFiltered' 

for i = 1:numel(InterestedTasks)
 
    for j = 1:3 
        
        DataL = load([name,'-',InterestedTasks{i},'-CH',num2str(j),'L-',Kind,'.mat'],RawKind);
        
        for k = 1:3
                
            DataR = load([name,'-',InterestedTasks{i},'-CH',num2str(k),'R-',Kind,'.mat'],RawKind);
            
            if strcmp(RawKind,'DownRawFiltered')
                
               [Sync_Score(j,k)] = Extract_Sync_Ch(DataL.DownRawFiltered,DataR.DownRawFiltered,10);
               
            else
                
               [Sync_Score(j,k)] = Extract_Sync_Ch(DataL.DownRaw,DataR.DownRaw,10);
               
            end
            
        end
        
    end
                        
    [x1,y1] = find(max(Sync_Score(1,:))==Sync_Score(1,:),1);
    [x2,y2] = find(max(Sync_Score(2,:))==Sync_Score(2,:),1);
    [x3,y3] = find(max(Sync_Score(3,:))==Sync_Score(3,:),1);
    A = [x1,y1;x2+1,y2;x3+2,y3];
    
    if strcmp(InterestedTasks{i},'Button'); Sync_Mem(1:3,:)=A; end
    if strcmp(InterestedTasks{i},'Audio'); Sync_Mem(4:6,:)=A+3; end
    if strcmp(InterestedTasks{i},'Random'); Sync_Mem(7:9,:)=A+6; end
    if strcmp(InterestedTasks{i},'Reach'); Sync_Mem(10:12,:)=A+9; end
    if strcmp(InterestedTasks{i},'Video'); Sync_Mem(13:15,:)=A+12; end
    
end      
                            
clear DataL DataR  

%% Make Dataset

disp('Loading Data ...')
SubjectName = name;
DataType = 'AmplLowPass';
ECoG_OR_LFP = Kind;
DownSamp = CC(cc);
[DataSet] = MakeDataSet(SubjectName,InterestedTasks,DataType,DownSamp,'Each',ECoG_OR_LFP);
% DataSetTest = DataSet;
TempDataSet = cell(15,2);

for i = 1:15
            
    if Sync_Mem(i,2) == 0
       continue
    end

    TempDataSet{i,1} = DataSet{i,1};         
    TempDataSet{i,2} = DataSet{Sync_Mem(i,2),2}; 

end

DataSet = TempDataSet;
clear TempDataSet

All_OR_Each = 'All'; % ************* 

if strcmp(All_OR_Each,'All')
   
   % Set Left Side
   DataSet1L = [DataSet{1,1};DataSet{2,1};DataSet{3,1}];       
   DataSet2L = [DataSet{4,1};DataSet{5,1};DataSet{6,1}];       
   DataSet3L = [DataSet{7,1};DataSet{8,1};DataSet{9,1}];      
   DataSet4L = [DataSet{10,1};DataSet{11,1};DataSet{12,1}];    
   DataSet5L = [DataSet{13,1};DataSet{14,1};DataSet{15,1}];   

   % Set Right Side
   DataSet1R = [DataSet{1,2};DataSet{2,2};DataSet{3,2}];
   DataSet2R = [DataSet{4,2};DataSet{5,2};DataSet{6,2}];
   DataSet3R = [DataSet{7,2};DataSet{8,2};DataSet{9,2}]; 
   DataSet4R = [DataSet{10,2};DataSet{11,2};DataSet{12,2}];
   DataSet5R = [DataSet{13,2};DataSet{14,2};DataSet{15,2}]; 
   
   DataSet = {DataSet1L,DataSet1R;DataSet2L,DataSet2R;DataSet3L,DataSet3R;DataSet4L,DataSet4R;DataSet5L,DataSet5R};
   clear DataSet1L DataSet2L DataSet3L DataSet4L DataSet5L DataSet1R DataSet2R DataSet3R DataSet4R DataSet5R
   
end

%% Kfold & PCA & Classification

kfold = 10;
disp([num2str(kfold),'-fold implementation, PCA, and Classification ...'])

for i = 1 : size(DataSet, 1)
    
    TempSiz(i) = size(DataSet{i,1}, 1);
    
end

index = find(TempSiz ~= 0);
SampNumb = min(TempSiz(index));
SizOfInterest = SampNumb - mod(SampNumb, kfold);

SVMAccuracy = zeros(1, kfold);
MKLAccuracy = zeros(1, kfold);
SVMConf = cell(1,1); 
MKLConf = cell(1,1);

SVMTrainTime = zeros(1,kfold);
MKLTrainTime = zeros(1,kfold);
SVMTestTime = zeros(1,kfold);
MKLTestTime = zeros(1,kfold);

for k = 1 : kfold
          
    TrSaLe = [];
    TeSaLe = [];
    TrSaRi = [];
    TeSaRi = [];
    counter = 0;
    
    for i = 1 : size(DataSet, 1)
    
        TempMemLe = DataSet{i,1};
        TempMemRi = DataSet{i,2};
        
        if isempty(TempMemLe)
            
            counter = counter + 1;
            continue
            
        else
            
            [TrainLe, TestLe] = Kfold(TempMemLe, kfold, SizOfInterest, k);
            [TrainRi, TestRi] = Kfold(TempMemRi, kfold, SizOfInterest, k);
            
        end
    
        TrSaLe = [TrSaLe; TrainLe];
        TeSaLe = [TeSaLe; TestLe]; 
        TrSaRi = [TrSaRi; TrainRi];
        TeSaRi = [TeSaRi; TestRi];
          
    end
    
    if strcmp(All_OR_Each, 'Each')
        
        NuOfTa = (15 - counter)/3;
        
    else
        
        NuOfTa = 5 - counter;
        
    end
    
    TrLa = [];
    TeLa = [];
    
    for z = 1 : NuOfTa
        
        if strcmp(All_OR_Each, 'Each') 
            
            TrLa = [TrLa; z*ones(3*size(TrainLe, 1),1)];
            TeLa = [TeLa; z*ones(3*size(TestLe, 1),1)];
            
        else 
            
            TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
            TeLa = [TeLa; z*ones(size(TestLe, 1),1)];
            
        end                  
        
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
    
    SVMCoMa = zeros(NuOfTa, NuOfTa);             
    for i = 1 : NuOfTa  
        for j = 1 : NuOfTa
        
            SVMCoMa(i,j) = numel(find(SVMLabels...
                (1 + (i - 1)*size(TeLa,1)/NuOfTa : i*size(TeLa,1)/NuOfTa) == j));
        
        end    
    end
    
    SVMAccuracy(k) = accuracy(1);
    SVMConf{k} = SVMCoMa;
    
%% MKL

    [MKLLabels,MKLTrainTime(k),MKLTestTime(k)] = LpMKL_MW_2f(TrFeLe, TrFeRi, TrLa, TeFeLe, TeFeRi, 100, NuOfTa, 2); 
    
    MKLCoMa = zeros(NuOfTa, NuOfTa);  
    for i = 1 : NuOfTa  
        for j = 1 : NuOfTa
        
            MKLCoMa(i,j) = numel(find(MKLLabels...
                (1 + (i - 1)*size(TeLa,1)/NuOfTa : i*size(TeLa,1)/NuOfTa) == j));
        
        end    
    end
              
    MKLAccuracy(k) = 100*numel(find((MKLLabels - TeLa) == 0))/numel(TeLa);
    MKLConf{k} = MKLCoMa; 
    
end

%% Quantitative Assessments

SVMAcc = sum(SVMAccuracy(:))/kfold;
MKLAcc = sum(MKLAccuracy(:))/kfold;

ConfMat_MKL = zeros(size(MKLConf{1}));
ConfMat_SVM = zeros(size(SVMConf{1}));

for w = 1 : kfold
    
    ConfMat_MKL = ConfMat_MKL + MKLConf{w};
    ConfMat_SVM = ConfMat_SVM + SVMConf{w};

end

ConfMat_MKL = round(100*(ConfMat_MKL/kfold)/(numel(TeLa)/NuOfTa));
ConfMat_SVM = round(100*(ConfMat_SVM/kfold)/(numel(TeLa)/NuOfTa));

save(['Sync',SubjectName,num2str(DownSamp),'_',num2str(DownSamp)], 'SVMAcc', 'MKLAcc', 'ConfMat_MKL', 'ConfMat_SVM')


    end
end




%% Initialization
clc
clear all
close all
warning off

%% Make Dataset

BB={'O14AJ','O14AK','A15K'};
CC=[10,50,500,1000,2000];

for bb=1:numel(BB)
    for cc=1:numel(CC)
        
disp('Loading Data ...')
SubjectName = BB{bb};
InterestedTasks = {'Button','Audio','Random','Reach','Video'};
DataType = 'AmplLowPass';
All_OR_Each = 'All';
ECoG_OR_LFP = 'LFP';
DownSamp = CC(cc);
[DataSet] = MakeDataSet(SubjectName,InterestedTasks,DataType,DownSamp,All_OR_Each,ECoG_OR_LFP);

%% Kfold & PCA & Classification

kfold = 10;

disp([num2str(kfold),'-fold implementation, PCA, and Classification ...'])

for i = 1 : size(DataSet, 1)
    
    TempSiz(i) = size(DataSet{i,1}, 1);
    
end

index = find(TempSiz ~= 0);
SampNumb = min(TempSiz(index));
SizOfInterest = SampNumb - mod(SampNumb, kfold);

SVMAccuracy = zeros(1, kfold);
MKLAccuracy = zeros(1, kfold);
SVMConf = cell(1,1); 
MKLConf = cell(1,1);

SVMTrainTime = zeros(1,kfold);
MKLTrainTime = zeros(1,kfold);
SVMTestTime = zeros(1,kfold);
MKLTestTime = zeros(1,kfold);

for k = 1 : kfold
          
    TrSaLe = [];
    TeSaLe = [];
    TrSaRi = [];
    TeSaRi = [];
    counter = 0;
    
    for i = 1 : size(DataSet, 1)
    
        TempMemLe = DataSet{i,1};
        TempMemRi = DataSet{i,2};
        
        if isempty(TempMemLe)
            
            counter = counter + 1;
            continue
            
        else
            
            [TrainLe, TestLe] = Kfold(TempMemLe, kfold, SizOfInterest, k);
            [TrainRi, TestRi] = Kfold(TempMemRi, kfold, SizOfInterest, k);
            
        end
    
        TrSaLe = [TrSaLe; TrainLe];
        TeSaLe = [TeSaLe; TestLe]; 
        TrSaRi = [TrSaRi; TrainRi];
        TeSaRi = [TeSaRi; TestRi];
          
    end
    
    if strcmp(All_OR_Each, 'Each')
        
        NuOfTa = (15 - counter)/3;
        
    else
        
        NuOfTa = 5 - counter;
        
    end
    
    TrLa = [];
    TeLa = [];
    
    for z = 1 : NuOfTa
        
        if strcmp(All_OR_Each, 'Each') 
            
            TrLa = [TrLa; z*ones(3*size(TrainLe, 1),1)];
            TeLa = [TeLa; z*ones(3*size(TestLe, 1),1)];
            
        else 
            
            TrLa = [TrLa; z*ones(size(TrainLe, 1),1)];
            TeLa = [TeLa; z*ones(size(TestLe, 1),1)];
            
        end                  
        
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
    
    SVMCoMa = zeros(NuOfTa, NuOfTa);             
    for i = 1 : NuOfTa  
        for j = 1 : NuOfTa
        
            SVMCoMa(i,j) = numel(find(SVMLabels...
                (1 + (i - 1)*size(TeLa,1)/NuOfTa : i*size(TeLa,1)/NuOfTa) == j));
        
        end    
    end
    
    SVMAccuracy(k) = accuracy(1);
    SVMConf{k} = SVMCoMa;
    
%% MKL

    [MKLLabels,MKLTrainTime(k),MKLTestTime(k)] = LpMKL_MW_2f(TrFeLe, TrFeRi, TrLa, TeFeLe, TeFeRi, 100, NuOfTa, 2); 
    
    MKLCoMa = zeros(NuOfTa, NuOfTa);  
    for i = 1 : NuOfTa  
        for j = 1 : NuOfTa
        
            MKLCoMa(i,j) = numel(find(MKLLabels...
                (1 + (i - 1)*size(TeLa,1)/NuOfTa : i*size(TeLa,1)/NuOfTa) == j));
        
        end    
    end
              
    MKLAccuracy(k) = 100*numel(find((MKLLabels - TeLa) == 0))/numel(TeLa);
    MKLConf{k} = MKLCoMa; 
    
end

%% Quantitative Assessments

SVMAcc = sum(SVMAccuracy(:))/kfold;
MKLAcc = sum(MKLAccuracy(:))/kfold;

ConfMat_MKL = zeros(size(MKLConf{1}));
ConfMat_SVM = zeros(size(SVMConf{1}));

for w = 1 : kfold
    
    ConfMat_MKL = ConfMat_MKL + MKLConf{w};
    ConfMat_SVM = ConfMat_SVM + SVMConf{w};

end

ConfMat_MKL = round(100*(ConfMat_MKL/kfold)/(numel(TeLa)/NuOfTa));
ConfMat_SVM = round(100*(ConfMat_SVM/kfold)/(numel(TeLa)/NuOfTa));

save([SubjectName,num2str(DownSamp),'_',num2str(DownSamp)], 'SVMAcc', 'MKLAcc', 'ConfMat_MKL', 'ConfMat_SVM')

    end
end




















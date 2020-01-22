clear all 
clc
close all


 
 
%% Seg3: Extract Features (from gaze at (1), gaze away (0) coded lablels)
%in this part we force all gazeLables to have same frameRate (as
%Desired_FPS) and then we define new words or alphabet based on the
%sequences of these labels.

SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
%% Load TD kids Inforamtion
load( [SavingPath '\Part1_TD_LabGaze_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','FPS_NaoTalking')
load([SavingPath '\Part1_TD_GazeAnalysis.mat'],'Tot_Subj_Game_Sess_ID','SubjSess_Lab', 'NaoTalkingPercentage_GazeAt','NaoTalkingPercentage_GazeShifting','NaoTalkingRatio_GazeAt_Shifting', 'NaoTalkingEntropy_Shifting',...
     'KidTalkingPercentage_GazeAt', 'KidTalkingPercentage_GazeShifting', 'KidTalkingRatio_GazeAt_Shifting', 'KidTalkingEntropy_Shifting','FPS_NaoTalking','info')

 
T_Seq_Frames = 4;%%as Nao_gazeLabel has been coded by 7 miminum, we consider a sequence of one second (T_Seq =7) for defining one alphabet in the system.
FrameRates = FPS_NaoTalking;

% %%NAO TALKING %%extract some features from every T_Seq of the data
GazeCode = SameFPS_EntireCodes;
Segment = SameFPS_NaoTalking;
[NaoTalking_Features,NaoTalking_ClassLabel,Nao_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq_Frames, SubjSess_Lab )

%%KID TALKING %% extract some features from every T_Seq of the data
GazeCode = SameFPS_EntireCodes;
Segment = SameFPS_KidTalking;
[KidTalking_Features,KidTalking_ClassLabel,Kid_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq_Frames, SubjSess_Lab )

save ([SavingPath '\Part1_TD_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
    'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq_Frames')

% Load ASD kids Inforamtion
clear all

SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
load( [SavingPath '\Part1_ASD_LabGaze_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','FPS_NaoTalking')
load([SavingPath '\Part1_ASD_GazeAnalysis.mat'],'Tot_Subj_Game_Sess_ID','SubjSess_Lab', 'NaoTalkingPercentage_GazeAt','NaoTalkingPercentage_GazeShifting','NaoTalkingRatio_GazeAt_Shifting', 'NaoTalkingEntropy_Shifting',...
     'KidTalkingPercentage_GazeAt', 'KidTalkingPercentage_GazeShifting', 'KidTalkingRatio_GazeAt_Shifting', 'KidTalkingEntropy_Shifting','FPS_NaoTalking','info');

T_Seq_Frames = 4;%%as Nao_gazeLabel has been coded by 7 miminum, we consider a sequence of one second (T_Seq =7) for defining one alphabet in the system.
FrameRates = FPS_NaoTalking;
 
%%NAO TALKING %%extract some features from every T_Seq of the data
GazeCode = SameFPS_EntireCodes;
Segment = SameFPS_NaoTalking;
[NaoTalking_Features,NaoTalking_ClassLabel,Nao_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq_Frames, SubjSess_Lab );

%%KID TALKING %% extract some features from every T_Seq of the data
GazeCode = SameFPS_EntireCodes;
Segment = SameFPS_KidTalking;
[KidTalking_Features,KidTalking_ClassLabel,Kid_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq_Frames, SubjSess_Lab );

save ([SavingPath '\Part1_ASD_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
    'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq_Frames')




% Seg4: Sequence Defnition and HMM Training + Testing
%% Seg4: Part1
SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';;
ClassLable = [1 2];
ClassTag = {'TD' ;'ASD'};
for (i_Class = 1:2)
    load  ([SavingPath '\Part1_' ClassTag{i_Class} '_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
        'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq');
    GameTag = {'KidTalking' , 'NaoTalking'};
%% Load all the data for different classes into           
    if (i_Class == 1) %%Concatenating data from  ASD (both NAO/KID talking)
        Features = KidTalking_Features;
        Labels = KidTalking_ClassLabel;
        [TD_KidTalking_Feat_Tot, TD_KidTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
        TD_KidTalking_Label_Tot = ones(size(TD_KidTalking_Feat_Tot,1),1);%TD class => Label (1)
        TD_KidTalking_SubjSessItr_Tot = str2num(TD_KidTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        TD_KidTalking_SubjList_Tot = str2num(TD_KidTalking_ClassLable_Tot(:,[4:6]));
        Unique_TD_KidTalking_SubjSessItr_Tot = unique(TD_KidTalking_SubjSessItr_Tot);
        Num_TD_KidTalking_SubjSessItr_Tot = size(Unique_TD_KidTalking_SubjSessItr_Tot,1);
        
        TD_KidTalking. Feat_Tot = TD_KidTalking_Feat_Tot;
        TD_KidTalking.ClassLable_Tot = TD_KidTalking_ClassLable_Tot;
        TD_KidTalking.Label_Tot = TD_KidTalking_Label_Tot;
        TD_KidTalking.SubjSessItr_Tot = TD_KidTalking_SubjSessItr_Tot;
        TD_KidTalking.SubjList_Tot = TD_KidTalking_SubjList_Tot
        TD_KidTalking.Unique_SubjSessItr_Tot = Unique_TD_KidTalking_SubjSessItr_Tot;
        TD_KidTalking.Num_SubjSessItr_Tot = Num_TD_KidTalking_SubjSessItr_Tot;
        
        
        %%%
        Features = NaoTalking_Features;
        Labels = NaoTalking_ClassLabel;
        [TD_NaoTalking_Feat_Tot, TD_NaoTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
        TD_NaoTalking_Label_Tot = ones(size(TD_NaoTalking_Feat_Tot,1),1);%TD class => Label (1) 
        TD_NaoTalking_SubjSessItr_Tot = str2num(TD_NaoTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        TD_NaoTalking_SubjList_Tot = str2num(TD_NaoTalking_ClassLable_Tot(:,[4:6]));
        Unique_TD_NaoTalking_SubjSessItr_Tot = unique(TD_NaoTalking_SubjSessItr_Tot);
        Num_TD_NaoTalking_SubjSessItr_Tot = size(Unique_TD_NaoTalking_SubjSessItr_Tot,1);
        
        TD_NaoTalking. Feat_Tot = TD_NaoTalking_Feat_Tot;
        TD_NaoTalking.ClassLable_Tot = TD_NaoTalking_ClassLable_Tot;
        TD_NaoTalking.Label_Tot = TD_NaoTalking_Label_Tot;
        TD_NaoTalking.SubjSessItr_Tot = TD_NaoTalking_SubjSessItr_Tot;
        TD_NaoTalking.SubjList_Tot = TD_NaoTalking_SubjList_Tot
        TD_NaoTalking.Unique_SubjSessItr_Tot = Unique_TD_NaoTalking_SubjSessItr_Tot;
        TD_NaoTalking.Num_SubjSessItr_Tot = Num_TD_NaoTalking_SubjSessItr_Tot;
        
        
    elseif (i_Class == 2) %%Concatenating data from ASD (both NAO/KID talking)
        
        Features = KidTalking_Features;
        Labels = KidTalking_ClassLabel;
        [ASD_KidTalking_Feat_Tot, ASD_KidTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
        ASD_KidTalking_Label_Tot = 2*ones(size(ASD_KidTalking_Feat_Tot,1),1);%TD class => Label (1), ASD =>Label(2)
        ASD_KidTalking_SubjSessItr_Tot = str2num(ASD_KidTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        ASD_KidTalking_SubjList_Tot = str2num(ASD_KidTalking_ClassLable_Tot(:,[4:6]));
        Unique_ASD_KidTalking_SubjSessItr_Tot = unique(ASD_KidTalking_SubjSessItr_Tot);
        Num_ASD_KidTalking_SubjSessItr_Tot = size(Unique_ASD_KidTalking_SubjSessItr_Tot,1);
        
        ASD_KidTalking. Feat_Tot = ASD_KidTalking_Feat_Tot;
        ASD_KidTalking.ClassLable_Tot = ASD_KidTalking_ClassLable_Tot;
        ASD_KidTalking.Label_Tot = ASD_KidTalking_Label_Tot;
        ASD_KidTalking.SubjSessItr_Tot = ASD_KidTalking_SubjSessItr_Tot;
        ASD_KidTalking.SubjList_Tot = ASD_KidTalking_SubjList_Tot
        ASD_KidTalking.Unique_SubjSessItr_Tot = Unique_ASD_KidTalking_SubjSessItr_Tot;
        ASD_KidTalking.Num_SubjSessItr_Tot = Num_ASD_KidTalking_SubjSessItr_Tot;
        
        %%%
        
        Features = NaoTalking_Features;
        Labels = NaoTalking_ClassLabel;
        [ASD_NaoTalking_Feat_Tot, ASD_NaoTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels); 
        ASD_NaoTalking_Label_Tot = 2*ones(size(ASD_NaoTalking_Feat_Tot,1),1);%TD class => Label (1), ASD =>Label(2) 
        ASD_NaoTalking_SubjSessItr_Tot = str2num(ASD_NaoTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        ASD_NaoTalking_SubjList_Tot = str2num(ASD_NaoTalking_ClassLable_Tot(:,[4:6]));
        Unique_ASD_NaoTalking_SubjSessItr_Tot = unique(ASD_NaoTalking_SubjSessItr_Tot);
        Num_ASD_NaoTalking_SubjSessItr_Tot = size(Unique_ASD_NaoTalking_SubjSessItr_Tot,1);

        ASD_NaoTalking. Feat_Tot = ASD_NaoTalking_Feat_Tot;
        ASD_NaoTalking.ClassLable_Tot = ASD_NaoTalking_ClassLable_Tot;
        ASD_NaoTalking.Label_Tot = ASD_NaoTalking_Label_Tot;
        ASD_NaoTalking.SubjSessItr_Tot = ASD_NaoTalking_SubjSessItr_Tot;
        ASD_NaoTalking.SubjList_Tot = ASD_NaoTalking_SubjList_Tot;
        ASD_NaoTalking.Unique_SubjSessItr_Tot = Unique_ASD_NaoTalking_SubjSessItr_Tot;
        ASD_NaoTalking.Num_SubjSessItr_Tot = Num_ASD_NaoTalking_SubjSessItr_Tot;
    end

end

%% Seg4: Part2: arrange the Date w.r.t. subject Info
Experiment_Type = {'NaoTalking', 'KidTalking'};
for i_Class =1:length(Experiment_Type)
Exp_ID = Experiment_Type{i_Class};
    switch (Exp_ID)
        case 'NaoTalking'
            %%function: make the sequence of observation
            T_Seq_Seg = 5;
            featId=1 ;%(3 different types of feature) %we can determine the features using (Data.)                    
            
            Ind_Class= 'ASD';
            ASD_Data= ASD_NaoTalking;
            [ASD_Tot_SeqInd_Subjs,ASD_Tot_Subj_list,ASD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(ASD_Data,T_Seq_Seg,featId); 
            
            Ind_Class= 'TD';
            TD_Data= TD_NaoTalking;
            [TD_Tot_SeqInd_Subjs,TD_Tot_Subj_list,TD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(TD_Data,T_Seq_Seg,featId); 
            
            
            save([SavingPath '\Part1_' Experiment_Type{i_Class} '_TD_ASD_GazeFeatSeq_forHMM.mat'] , 'ASD_Tot_SeqInd_Subjs', 'ASD_Tot_Subj_list','ASD_Tot_SeqFeat_Subjs','ASD_Data',...
                'TD_Tot_SeqInd_Subjs', 'TD_Tot_Subj_list','TD_Tot_SeqFeat_Subjs','TD_Data','T_Seq_Seg');
          
        case 'KidTalking'
            T_Seq_Seg = 5;
            featId=1; %(3 different types of feature) %we can determine the features using (Data.)                    
            
            Ind_Class= 'ASD';
            ASD_Data= ASD_KidTalking;
            [ASD_Tot_SeqInd_Subjs,ASD_Tot_Subj_list,ASD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(ASD_Data,T_Seq_Seg,featId);
            
            Ind_Class= 'TD';
            TD_Data= TD_KidTalking;
            [TD_Tot_SeqInd_Subjs,TD_Tot_Subj_list,TD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(TD_Data,T_Seq_Seg,featId); 
            
            save([SavingPath '\Part1_' Experiment_Type{i_Class} '_TD_ASD_GazeFeatSeq_forHMM.mat'] , 'ASD_Tot_SeqInd_Subjs', 'ASD_Tot_Subj_list','ASD_Tot_SeqFeat_Subjs','ASD_Data',...
                'TD_Tot_SeqInd_Subjs', 'TD_Tot_Subj_list','TD_Tot_SeqFeat_Subjs','TD_Data','T_Seq_Seg');
    end
end

%% Seg4: part3
SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';;

%%subject independet Leave One Subject Out
Experiment_Type = {'NaoTalking', 'KidTalking'};
Exp_ID = Experiment_Type{2};%% Load the Data for NaoTalking
% Exp_ID = Experiment_Type{2};%% Load the Data for KidTalking

load([SavingPath '\Part1_' Exp_ID '_TD_ASD_GazeFeatSeq_forHMM.mat'] , 'ASD_Tot_SeqInd_Subjs', 'ASD_Tot_Subj_list','ASD_Tot_SeqFeat_Subjs','ASD_Data',...
                'TD_Tot_SeqInd_Subjs', 'TD_Tot_Subj_list','TD_Tot_SeqFeat_Subjs','TD_Data','T_Seq_Seg');

Total_Feat_Data = [TD_Data.Feat_Tot ; ASD_Data.Feat_Tot];
BiasInd = size(TD_Data.Feat_Tot,1)
Total_Data = [TD_Tot_SeqFeat_Subjs ASD_Tot_SeqFeat_Subjs]
% Total_SeqInd = [cell2mat(TD_Tot_SeqInd_Subjs'); (BiasInd+cell2mat(ASD_Tot_SeqInd_Subjs'))];%as we concatenate the indices, add the corresponding bias
Total_SeqInd = [TD_Tot_SeqInd_Subjs ASD_Tot_SeqInd_Subjs];%as we concatenate the indices, add the corresponding bias

Total_SubjList = [TD_Tot_Subj_list ASD_Tot_Subj_list];

NumTD= size(TD_Tot_Subj_list,2);
NumASD= size(ASD_Tot_Subj_list,2);

Total_LabelList =[ones(1,NumTD) 2*ones(1,NumASD)]; %TD(1),ASD(2)
T_Seq = T_Seq_Seg; %Number of dataPoints(Frames) in each sequnce


 ResultsNoteFile = fullfile(SavingPath, [Exp_ID '_HMM_File_Exp_Part1_GazeCode_LOSO_FeatVocab' num2str(T_Seq_Frames) '_TSequence' num2str(T_Seq) '.txt']);
            fid = fopen(ResultsNoteFile, 'w');
            if fid == -1; error('Cannot open file: %s', TheFile); end
            fprintf(fid, 'HMM RESULTS:Part 1 TD(1) and ASD(2) Classification using the manually coded  \r\n');
            fprintf(fid, ['HMM: Frame Rate video for gaze analysis is set to = 7fps, HMM T_Seq=' num2str(T_Seq) ' \r\n']);
            fprintf(fid, ['HMM RESULTS: for Observation of 2^' num2str(T_Seq_Frames) ' vocabulary(alphabet) \r\n']);
            fprintf(fid, '*********************************************************\r\n');
            fprintf(fid,'%10s %18s %18s %18s %10s\r\n','T_Seq(HMM)', 'Total Recog.(%)' ,'F1([0 1])','ConfusionMat','SubjID');
            


Te_Pred_Lab_Tot = []; Te_True_Lab_Tot = [];
NumSubj = numel(Total_SubjList);
for i_Subj = 1:NumSubj
    Tr_SubjIDs = Total_SubjList;
    Tr_SubjIDs(i_Subj) = [];

    
    %%Training Data
    Num_TrSubj= numel(Tr_SubjIDs) ;
    Tot_Tr_Seq =[];
    Tot_Tr_Lab =[];
    Tot_TrSeqInd =[];
    
    for j_subj =1:Num_TrSubj
        SelectedSubj = Tr_SubjIDs(j_subj);
        Ind = find(Total_SubjList==SelectedSubj);
        Tot_Tr_Seq = [Tot_Tr_Seq ;Total_Data{Ind}] ;
        Tot_Tr_Lab = [Tot_Tr_Lab ; repmat(Total_LabelList(Ind),size(Total_Data{Ind},1),1)];
        
        Num_Class1= size(TD_Tot_SeqInd_Subjs,2);
        if(Total_LabelList(Ind)==1)%%correspond to TD class
            Tot_TrSeqInd = [Tot_TrSeqInd ; TD_Tot_SeqInd_Subjs{Ind}];
        elseif(Total_LabelList(Ind)==2)
            Tot_TrSeqInd = [Tot_TrSeqInd ; BiasInd+ASD_Tot_SeqInd_Subjs{Ind-Num_Class1}];
        end
        
    end
     
    %%Test Data: Left out test subject
    Tot_Te_Seq=[];Tot_Te_Lab=[];Tot_TeSeqInd=[];
    Selected_TeSubj = Total_SubjList(i_Subj);
    Ind = find(Total_SubjList==Selected_TeSubj);
    Tot_Te_Seq = [Tot_Te_Seq ;Total_Data{Ind}] ;
    Tot_Te_Lab = [Tot_Te_Lab ; repmat(Total_LabelList(Ind),size(Total_Data{Ind},1),1)];
    
    if( isempty(Tot_Te_Seq)) 
        continue; 
    end
    
    Num_Class1= size(TD_Tot_SeqInd_Subjs,2);
    if(Total_LabelList(Ind)==1)%%correspond to TD class
       Tot_TeSeqInd = [Tot_TeSeqInd ; TD_Tot_SeqInd_Subjs{Ind}];
    elseif(Total_LabelList(Ind)==2)
       Tot_TeSeqInd = [Tot_TeSeqInd ; BiasInd+ASD_Tot_SeqInd_Subjs{Ind-Num_Class1}];
    end
    
    %%Till This section
    
    LabTr = Tot_Tr_Lab;
    
     %%Func2:Define NEW function for bellow
    %%Determine Symbol (HMM observation) for eachClass
    ListClasses = unique(LabTr);
    Centroid_Symbol = [];%%codebook of Symbols
    TrSymbol_IDs = []; NumSymb = 0;
    Categories_SymbolRelation = []; %%relates the category to the sysmbol defined for each class(Category). At most 'NumSymbols=12' suymbol for each class
    IndClass={[] [] };%at most we have 6 Category for AU intensity, and 3 category for Dynamics(Rise,Const,Fall)

    %%Determine the VQ sample(To have almost uniform sample from each category)
    MaxSampleCategory = 100;% at most this number of video sequnece(with T_Seq length) will be used for VQ for each category
    Selected_SeqID = [];% This is the total list of SeqIDs which is used for VQ

    for i_Class = 1:length(ListClasses) 
        ClassID = ListClasses(i_Class);
        IndClass{ClassID} = [IndClass{ClassID}  ; find(LabTr == ListClasses(i_Class))];      
        NumTrSampleClass(ClassID) = length(IndClass{ClassID});    

        if NumTrSampleClass(ClassID) < MaxSampleCategory %%Not enough sample for this category
               Selected_SeqID = [Selected_SeqID ; IndClass{ClassID}];% use all Sequence Samples we have

        else  %Enough Sample for this class is available
                Rand_ID = randperm(NumTrSampleClass(ClassID));    
                Rand_ID = Rand_ID(1:MaxSampleCategory);
                Selected_SeqID = [Selected_SeqID ; IndClass{ClassID}(Rand_ID)];% use all Sequence Samples we have
        end     
    end
    
    %%%
    Ind_Frames = Tot_TrSeqInd(Selected_SeqID,:)';
    Ind_Frames =Ind_Frames(:);
    Feat_Tr = Total_Feat_Data(Ind_Frames,:);%Frame by frame feature for selected Video Sequence
    VQ_SeqLab = Tot_Tr_Lab(Selected_SeqID); %Sequence label (Symbol or Observation Label);
    VQ_LabFrame = repmat(VQ_SeqLab,1,T_Seq)';
    VQ_LabFrame=VQ_LabFrame(:)  ; 
    VQ_Feat = Feat_Tr;%Frame by frame feature for selected Video Sequence
    
%% I directy used the vocabulary for the gaze to and consider them as the quantized values    
%     %%VQ (Learning)setting
%     NumSymbols = 8; % Number of clusters or Symbols or observations of VQ)
% %     Feat = VQ_Feat(:,1);
%     Feat = VQ_Feat;
%     if (NumSymbols >= size(Feat,1)); NumSymbols = size(Feat,1)-1; end%%NumSymb>NumSample -> NumSymb = NumSample-1
%     %%In order not to have empty cluster. Put 2 level Catch Try 
%     try  
%     [IDX, C]=kmeans(Feat,NumSymbols,'start','cluster');
%     catch exception1
%         NumSymbols = NumSymbols/2; % Number of clusters or Symbols or observations of VQ)
%         try
%             [IDX, C]=kmeans(Feat,NumSymbols);
%         catch exception2
%             NumSymbols = NumSymbols/2; % Number of clusters or Symbols or observations of VQ)
%             [IDX, C]=kmeans(Feat,NumSymbols);
%         end
%     end
%     Centroid_Symbol = [Centroid_Symbol ; C];

    %% Define VQ for Both Training and Testing Frames Considering VQ codebook (Centroids)
    Centroid_Symbol =1+[0:1:15]';
    Tr_VQ_Symbol =VQ_Feat(:,1);%%consider the first 
    LabTr = VQ_SeqLab
    %FeatTe;% FeatTe has (Nte x F): F is the size of Centroid_Symbol too
    Te_VQ_Symbol = Tot_Te_Seq;
    LabTe = Tot_Te_Lab;

    
    
            %% HMM Section  
                addpath(genpath('C:\Users\MahoorLab04\MMavadati_Files\MATLAB\HMM\HMMall')); %Downlowded: http://www.cs.ubc.ca/~murphyk/Software/HMM/hmm_download.html
                HMM_CategoryID = ListClasses ; %%illustrate the HMM classes (Categories)
                HMM_NumCategory = length(ListClasses) ; %%illustrate the Number of HMM classes (Categories)

                %%Arrange Data HMM
                    Tr_HMM_VQ_Symbol = 1+ reshape(Tr_VQ_Symbol,T_Seq,[])'; %%Put T_Seq of Symbols to make the Sequence Of Symbo for each Video
                    Tr_HMM_Categroy_Lab = LabTr; %%Put a lable for T_Seq of Symbols to make the Sequence Of Symbol for each Video

                    
%                     Te_HMM_VQ_Symbol = reshape(Te_VQ_Symbol,T_Seq,[])'; %%Put T_Seq of Symbols to make the Sequence Of Symbo for each Video
                    Te_HMM_VQ_Symbol = 1+Te_VQ_Symbol;%Te_VQ_Symbol has already set for the sequence format
                    Te_HMM_Categroy_Lab = LabTe; %%Put a lable for T_Seq of Symbols to make the Sequence Of Symbol for each Video
                %% Train HMM for Each Category
                    for i_HMM = 1 : HMM_NumCategory%% For each Category one HMModel will be defined
                            Selected_HMM_Category = HMM_CategoryID(i_HMM);
                        %%Deternube the SetOf Observations for the selected Category    
                            Seq_Ind = find (Tr_HMM_Categroy_Lab == Selected_HMM_Category);
                            Seq_Observation_OneCat = Tr_HMM_VQ_Symbol(Seq_Ind,:);   %%Select Sequence of one Category for HMM traininig

                            NumStates_HMM(i_HMM) = 5; %% for each Category(Model) I can define different number of states
                            NumObserv_HMM(i_HMM) = size(Centroid_Symbol,1);

                        %%Paramenter Selection for HMM
                            Q = NumStates_HMM(i_HMM); %Number of States in HMM
                            O = NumObserv_HMM(i_HMM); %Number of Observations(Symbols) in HMM

                        %%we start with a randomly initialized model
                            prior_hat = normalise(rand(Q,1));
                            A_hat = mk_stochastic(rand(Q,Q));
                            B_hat = mk_stochastic(rand(Q,O));  

                        %%learn from data by performing many iterations of EM
                            [LL,prior_hat,A_hat,B_hat] = dhmm_em(Seq_Observation_OneCat, prior_hat,A_hat,B_hat, 'max_iter',100);

                        %%Trained HMM Model Paramenters
                            Prior_Hat{i_HMM} = prior_hat; % Prior Matrix
                            A_Hat{i_HMM} = A_hat;   %Transmission Matrix
                            B_Hat{i_HMM} = B_hat;   %Observation Matrix

                    end % End i_HMM (Training HMM)    


                %% HMM Recognize (Classification)

                    HMM_CategoryID; %%illustrate the HMM classes (Categories)
                    HMM_NumCategory; %%illustrate the Number of HMM classes (Categories)    

                    Prior_Hat{i_HMM};% Prior Matrix (Belongs to i_HMM'th category)
                    A_Hat{i_HMM};%Transmission Matrix (Belongs to i_HMM'th category)
                    B_Hat{i_HMM};%Observation Matrix (Belongs to i_HMM'th category)
                    %%Testing Samples
                    Te_HMM_VQ_Symbol; %%Put T_Seq of Symbols to make the Sequence Of Symbo for each Video
                    Te_HMM_Categroy_Lab; %%Put a lable for T_Seq of Symbols to make the Sequence Of Symbol for each Video
                    Num_TeSeq = size(Te_HMM_Categroy_Lab,1);%Number of video sequence in the testing set.

                    Te_Categ_Pred = [];
                    LogLike = [];
                    for i_Te = 1:Num_TeSeq %%Through all Testing Sample
                        Te_Symbol = Te_HMM_VQ_Symbol(i_Te,:);%%Te_Symbol; Vector of symbols(1xT_Seq)
                        for i_HMM = 1:HMM_NumCategory%%Through all HMM Models (Category)
                             LogLike(i_Te,i_HMM) = dhmm_logprob(Te_Symbol, Prior_Hat{i_HMM},  A_Hat{i_HMM}, B_Hat{i_HMM} );
                        end
                        %%ArgMax LogLikelihood (Note: logLikelihood is negative value)
                        [~,IndMax] = max(LogLike(i_Te,:));
                        %%Categorize the Test sample into one of the classes(Categories).
                        Te_Categ_Pred(i_Te,1) = HMM_CategoryID(IndMax(1));%Predicted Category for the i_Te'th Seqence of Date      
                    end
                %%End ON HMM and CLassification

                %% Classification Results: 
                Te_Categ_Pred; %Predicted Result HMM
                Te_Categ_True = Te_HMM_Categroy_Lab; %True Label for Test Category

                Subj_Itr = i_Subj;
                ConfusionMat{Subj_Itr} = confusionmat(Te_Categ_True,Te_Categ_Pred);
                RecognitionRate = 100*(sum(diag(ConfusionMat{Subj_Itr}))/sum(ConfusionMat{Subj_Itr}(:)));
                F1_score(Subj_Itr)=Funct_F1score(Te_Categ_True, Te_Categ_Pred);
%                 ICC(Subj_Itr) = icc (3, 'single', [Te_Categ_Pred, Te_Categ_True]);

                Te_Pred_Lab{Subj_Itr} = Te_Categ_Pred;
                Te_True_Lab{Subj_Itr} = Te_Categ_True;

                Te_Pred_Lab_Tot = [Te_Pred_Lab_Tot; Te_Categ_Pred];
                Te_True_Lab_Tot = [Te_True_Lab_Tot; Te_Categ_True] ;

            %     figure(Subj_Itr)
            %     plot(Te_Categ_True,'ob'); hold on;
            %     plot(Te_Categ_Pred,'r'); hold off;  
        if (numel(ConfusionMat{Subj_Itr})==4)
            fprintf( fid, '\n T_Seq = %2d, \tAcc. = %5.2f(%%),   F1  = %.2f , Conf.Mat =[%3d,%3d;%3d,%3d] , SN =%2d \r\n', T_Seq, RecognitionRate , F1_score(Subj_Itr),...
                ConfusionMat{Subj_Itr}(1,1),ConfusionMat{Subj_Itr}(1,2),ConfusionMat{Subj_Itr}(2,1),ConfusionMat{Subj_Itr}(2,2), Total_SubjList(Subj_Itr));
        else             
           fprintf( fid, '\n T_Seq = %2d, \tAcc. = %5.2f(%%),   F1  = %.2f , Conf.Mat1Value =[%3d] , SN =%2d \r\n', T_Seq, RecognitionRate , F1_score(Subj_Itr),...
                ConfusionMat{Subj_Itr}, Total_SubjList(Subj_Itr));
        end
disp(['Current Iteration SN' SelectedSubj]);
end
ConfusionMat_Overall = confusionmat(Te_True_Lab_Tot,Te_Pred_Lab_Tot)
RecognitionRateOveral=100*(sum(diag(ConfusionMat_Overall))/sum(ConfusionMat_Overall(:)))
F1_score_Overall = Funct_F1score(Te_True_Lab_Tot, Te_Pred_Lab_Tot);

% ReadMe ={'Train HMM by %66 Samples of each Subject, %33 for Testing';
%     ['T_seq=' num2str(T_Seq) 'for HMM ']; ['Num VQ clusters= ' num2str(NumSymbols)];['Number Observation HMM = ' num2str(NumObserv_HMM)] ; 'Categories HMM: AU Insnity Rising(1), Fixed(2), Falling(3)'}

ReadMe ={['TD(1)_ASD(2) Gaze categorization: HMM Result LOSO SubjectInDependent (NumVocabulary = 2^)'  num2str(T_Seq_Frames) ] ;'Train HMM Leave one subject out (form the entir set of ASD+TD)';
    ['T_seq=' num2str(T_Seq) 'for HMM ']; ['Num VQ clusters= ' num2str(size(Centroid_Symbol,1))];['Number Observation HMM = ' num2str(NumObserv_HMM)] ; 'Categories HMM: TD(1) vs ASD(2)'}

save(fullfile(SavingPath, ['Protcol1_Gaze_HMM_Resutlts' Exp_ID ]),'ConfusionMat_Overall','F1_score_Overall','RecognitionRateOveral','ConfusionMat','F1_score','Te_True_Lab','Te_Pred_Lab','ReadMe' )

fprintf( fid, '\n --------------------------------------------------------------------------------------- \r\n')
fprintf( fid, '\n OVERALL \r\n');
fprintf( fid, '\n T_Seq = %2d, \tAcc. = %5.2f(%%),   F1 OVERALL  = %.2f  Conf.Mat OVERALL=[%3d,%3d;%3d,%3d] \r\n', T_Seq, RecognitionRateOveral , F1_score_Overall, ...
    ConfusionMat_Overall(1,1),ConfusionMat_Overall(1,2),ConfusionMat_Overall(2,1),ConfusionMat_Overall(2,2));
fprintf( fid, '\n ----------------------------------------------------------------------------------------- \r\n')
fclose(fid);

    

clear all 
clc
close all


 
 
%% Seg3: Extract Features (from gaze at (1), gaze away (0) coded lablels)
%in this part we force all gazeLables to have same frameRate (as
%Desired_FPS) and then we define new words or alphabet based on the
%sequences of these labels.

% SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
% %% Load TD kids Inforamtion
% load( [SavingPath '\Part1_TD_LabGaze_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','FPS_NaoTalking')
% load([SavingPath '\Part1_TD_GazeAnalysis.mat'],'Tot_Subj_Game_Sess_ID','SubjSess_Lab', 'NaoTalkingPercentage_GazeAt','NaoTalkingPercentage_GazeShifting','NaoTalkingRatio_GazeAt_Shifting', 'NaoTalkingEntropy_Shifting',...
%      'KidTalkingPercentage_GazeAt', 'KidTalkingPercentage_GazeShifting', 'KidTalkingRatio_GazeAt_Shifting', 'KidTalkingEntropy_Shifting','FPS_NaoTalking','info')
% 
%  
% T_Seq = 7;%%as Nao_gazeLabel has been coded by 7 miminum, we consider a sequence of one second (T_Seq =7) for defining one alphabet in the system.
% FrameRates = FPS_NaoTalking;
% 
% % %%NAO TALKING %%extract some features from every T_Seq of the data
% GazeCode = SameFPS_EntireCodes;
% Segment = SameFPS_NaoTalking;
% [NaoTalking_Features,NaoTalking_ClassLabel,Nao_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq, SubjSess_Lab )
% 
% %%KID TALKING %% extract some features from every T_Seq of the data
% GazeCode = SameFPS_EntireCodes;
% Segment = SameFPS_KidTalking;
% [KidTalking_Features,KidTalking_ClassLabel,Kid_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq, SubjSess_Lab )
% 
% save ([SavingPath '\Part1_TD_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
%     'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq')

%% Load ASD kids Inforamtion
% clear all
% 
% SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
% load( [SavingPath '\Part1_ASD_LabGaze_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','FPS_NaoTalking')
% load([SavingPath '\Part1_ASD_GazeAnalysis.mat'],'Tot_Subj_Game_Sess_ID','SubjSess_Lab', 'NaoTalkingPercentage_GazeAt','NaoTalkingPercentage_GazeShifting','NaoTalkingRatio_GazeAt_Shifting', 'NaoTalkingEntropy_Shifting',...
%      'KidTalkingPercentage_GazeAt', 'KidTalkingPercentage_GazeShifting', 'KidTalkingRatio_GazeAt_Shifting', 'KidTalkingEntropy_Shifting','FPS_NaoTalking','info')
% 
% T_Seq = 7;%%as Nao_gazeLabel has been coded by 7 miminum, we consider a sequence of one second (T_Seq =7) for defining one alphabet in the system.
% FrameRates = FPS_NaoTalking;
%  
% %%NAO TALKING %%extract some features from every T_Seq of the data
% GazeCode = SameFPS_EntireCodes;
% Segment = SameFPS_NaoTalking;
% [NaoTalking_Features,NaoTalking_ClassLabel,Nao_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq, SubjSess_Lab )
% 
% %%KID TALKING %% extract some features from every T_Seq of the data
% GazeCode = SameFPS_EntireCodes;
% Segment = SameFPS_KidTalking;
% [KidTalking_Features,KidTalking_ClassLabel,Kid_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq, SubjSess_Lab )
% 
% save ([SavingPath '\Part1_ASD_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
%     'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq')




%% Seg4: Sequence Defnition and HMM Training + Testing
%% Seg4: Part1
% SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';;
% ClassLable = [1 2];
% ClassTag = {'TD' ;'ASD'};
% for (i_Class = 1:2)
%     load  ([SavingPath '\Part1_' ClassTag{i_Class} '_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
%         'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq');
%     GameTag = {'KidTalking' , 'NaoTalking'};
% %% Load all the data for different classes into           
%     if (i_Class == 1) %%Concatenating data from  ASD (both NAO/KID talking)
%         Features = KidTalking_Features;
%         Labels = KidTalking_ClassLabel;
%         [TD_KidTalking_Feat_Tot, TD_KidTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
%         TD_KidTalking_Label_Tot = ones(size(TD_KidTalking_Feat_Tot,1),1);%TD class => Label (1)
%         TD_KidTalking_SubjSessItr_Tot = str2num(TD_KidTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
%         TD_KidTalking_SubjList_Tot = str2num(TD_KidTalking_ClassLable_Tot(:,[4:6]));
%         Unique_TD_KidTalking_SubjSessItr_Tot = unique(TD_KidTalking_SubjSessItr_Tot);
%         Num_TD_KidTalking_SubjSessItr_Tot = size(Unique_TD_KidTalking_SubjSessItr_Tot,1);
%         
%         TD_KidTalking. Feat_Tot = TD_KidTalking_Feat_Tot;
%         TD_KidTalking.ClassLable_Tot = TD_KidTalking_ClassLable_Tot;
%         TD_KidTalking.Label_Tot = TD_KidTalking_Label_Tot;
%         TD_KidTalking.SubjSessItr_Tot = TD_KidTalking_SubjSessItr_Tot;
%         TD_KidTalking.SubjList_Tot = TD_KidTalking_SubjList_Tot
%         TD_KidTalking.Unique_SubjSessItr_Tot = Unique_TD_KidTalking_SubjSessItr_Tot;
%         TD_KidTalking.Num_SubjSessItr_Tot = Num_TD_KidTalking_SubjSessItr_Tot;
%         
%         
%         %%%
%         Features = NaoTalking_Features;
%         Labels = NaoTalking_ClassLabel;
%         [TD_NaoTalking_Feat_Tot, TD_NaoTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
%         TD_NaoTalking_Label_Tot = ones(size(TD_NaoTalking_Feat_Tot,1),1);%TD class => Label (1) 
%         TD_NaoTalking_SubjSessItr_Tot = str2num(TD_NaoTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
%         TD_NaoTalking_SubjList_Tot = str2num(TD_NaoTalking_ClassLable_Tot(:,[4:6]));
%         Unique_TD_NaoTalking_SubjSessItr_Tot = unique(TD_NaoTalking_SubjSessItr_Tot);
%         Num_TD_NaoTalking_SubjSessItr_Tot = size(Unique_TD_NaoTalking_SubjSessItr_Tot,1);
%         
%         TD_NaoTalking. Feat_Tot = TD_NaoTalking_Feat_Tot;
%         TD_NaoTalking.ClassLable_Tot = TD_NaoTalking_ClassLable_Tot;
%         TD_NaoTalking.Label_Tot = TD_NaoTalking_Label_Tot;
%         TD_NaoTalking.SubjSessItr_Tot = TD_NaoTalking_SubjSessItr_Tot;
%         TD_NaoTalking.SubjList_Tot = TD_NaoTalking_SubjList_Tot
%         TD_NaoTalking.Unique_SubjSessItr_Tot = Unique_TD_NaoTalking_SubjSessItr_Tot;
%         TD_NaoTalking.Num_SubjSessItr_Tot = Num_TD_NaoTalking_SubjSessItr_Tot;
%         
%         
%     elseif (i_Class == 2) %%Concatenating data from ASD (both NAO/KID talking)
%         
%         Features = KidTalking_Features;
%         Labels = KidTalking_ClassLabel;
%         [ASD_KidTalking_Feat_Tot, ASD_KidTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
%         ASD_KidTalking_Label_Tot = 2*ones(size(ASD_KidTalking_Feat_Tot,1),1);%TD class => Label (1), ASD =>Label(2)
%         ASD_KidTalking_SubjSessItr_Tot = str2num(ASD_KidTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
%         ASD_KidTalking_SubjList_Tot = str2num(ASD_KidTalking_ClassLable_Tot(:,[4:6]));
%         Unique_ASD_KidTalking_SubjSessItr_Tot = unique(ASD_KidTalking_SubjSessItr_Tot);
%         Num_ASD_KidTalking_SubjSessItr_Tot = size(Unique_ASD_KidTalking_SubjSessItr_Tot,1);
%         
%         ASD_KidTalking. Feat_Tot = ASD_KidTalking_Feat_Tot;
%         ASD_KidTalking.ClassLable_Tot = ASD_KidTalking_ClassLable_Tot;
%         ASD_KidTalking.Label_Tot = ASD_KidTalking_Label_Tot;
%         ASD_KidTalking.SubjSessItr_Tot = ASD_KidTalking_SubjSessItr_Tot;
%         ASD_KidTalking.SubjList_Tot = ASD_KidTalking_SubjList_Tot
%         ASD_KidTalking.Unique_SubjSessItr_Tot = Unique_ASD_KidTalking_SubjSessItr_Tot;
%         ASD_KidTalking.Num_SubjSessItr_Tot = Num_ASD_KidTalking_SubjSessItr_Tot;
%         
%         %%%
%         
%         Features = NaoTalking_Features;
%         Labels = NaoTalking_ClassLabel;
%         [ASD_NaoTalking_Feat_Tot, ASD_NaoTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels); 
%         ASD_NaoTalking_Label_Tot = 2*ones(size(ASD_NaoTalking_Feat_Tot,1),1);%TD class => Label (1), ASD =>Label(2) 
%         ASD_NaoTalking_SubjSessItr_Tot = str2num(ASD_NaoTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
%         ASD_NaoTalking_SubjList_Tot = str2num(ASD_NaoTalking_ClassLable_Tot(:,[4:6]));
%         Unique_ASD_NaoTalking_SubjSessItr_Tot = unique(ASD_NaoTalking_SubjSessItr_Tot);
%         Num_ASD_NaoTalking_SubjSessItr_Tot = size(Unique_ASD_NaoTalking_SubjSessItr_Tot,1);
% 
%         ASD_NaoTalking. Feat_Tot = ASD_NaoTalking_Feat_Tot;
%         ASD_NaoTalking.ClassLable_Tot = ASD_NaoTalking_ClassLable_Tot;
%         ASD_NaoTalking.Label_Tot = ASD_NaoTalking_Label_Tot;
%         ASD_NaoTalking.SubjSessItr_Tot = ASD_NaoTalking_SubjSessItr_Tot;
%         ASD_NaoTalking.SubjList_Tot = ASD_NaoTalking_SubjList_Tot;
%         ASD_NaoTalking.Unique_SubjSessItr_Tot = Unique_ASD_NaoTalking_SubjSessItr_Tot;
%         ASD_NaoTalking.Num_SubjSessItr_Tot = Num_ASD_NaoTalking_SubjSessItr_Tot;
%     end
% 
% end

%% Seg4: Part2: arrange the Date w.r.t. subject Info
% Experiment_Type = {'NaoTalking', 'KidTalking'};
% for i_Class =1:length(Experiment_Type)
% Exp_ID = Experiment_Type{i_Class};
%     switch (Exp_ID)
%         case 'NaoTalking'
%             %%function: make the sequence of observation
%             T_Seq_Seg = 5;
%             featId=1 ;%(3 different types of feature) %we can determine the features using (Data.)                    
%             
%             Ind_Class= 'ASD';
%             Data= ASD_NaoTalking;
%             [ASD_Tot_SeqInd_Subjs,ASD_Tot_Subj_list,ASD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(Data,T_Seq_Seg,featId); 
%             
%             Ind_Class= 'TD';
%             Data= TD_NaoTalking;
%             [TD_Tot_SeqInd_Subjs,TD_Tot_Subj_list,TD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(Data,T_Seq_Seg,featId); 
%             
%             
%             save([SavingPath '\Part1_' Experiment_Type{i_Class} '_TD_ASD_GazeFeatSeq_forHMM.mat'] , 'ASD_Tot_SeqInd_Subjs', 'ASD_Tot_Subj_list','ASD_Tot_SeqFeat_Subjs',...
%                 'TD_Tot_SeqInd_Subjs', 'TD_Tot_Subj_list','TD_Tot_SeqFeat_Subjs')
%           
%         case 'KidTalking'
%             T_Seq_Seg = 5;
%             featId=1; %(3 different types of feature) %we can determine the features using (Data.)                    
%             
%             Ind_Class= 'ASD';
%             Data= ASD_KidTalking;
%             [ASD_Tot_SeqInd_Subjs,ASD_Tot_Subj_list,ASD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(Data,T_Seq_Seg,featId);
%             
%             Ind_Class= 'TD';
%             Data= TD_KidTalking;
%             [TD_Tot_SeqInd_Subjs,TD_Tot_Subj_list,TD_Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(Data,T_Seq_Seg,featId); 
%             
%             save([SavingPath '\Part1_' Experiment_Type{i_Class} '_TD_ASD_GazeFeatSeq_forHMM.mat'] , 'ASD_Tot_SeqInd_Subjs', 'ASD_Tot_Subj_list','ASD_Tot_SeqFeat_Subjs',...
%                 'TD_Tot_SeqInd_Subjs', 'TD_Tot_Subj_list','TD_Tot_SeqFeat_Subjs');
%     end
% end

%% Seg4: part3
SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';;

%%subject independet Leave One Subject Out
Experiment_Type = {'NaoTalking', 'KidTalking'};
Exp_ID = Experiment_Type{1};%% Load the Data for NaoTalking
% Exp_ID = Experiment_Type{2};%% Load the Data for KidTalking

load([SavingPath '\Part1_' Exp_ID '_TD_ASD_GazeFeatSeq_forHMM.mat'] , 'ASD_Tot_SeqInd_Subjs', 'ASD_Tot_Subj_list','ASD_Tot_SeqFeat_Subjs',...
                'TD_Tot_SeqInd_Subjs', 'TD_Tot_Subj_list','TD_Tot_SeqFeat_Subjs')

Total_Data = [TD_Tot_SeqFeat_Subjs ASD_Tot_SeqFeat_Subjs];
Total_SeqInd = [TD_Tot_SeqInd_Subjs ASD_Tot_SeqInd_Subjs];
Total_SubjList = [TD_Tot_Subj_list ASD_Tot_Subj_list
for i_Subj = Subjs_No
    
end

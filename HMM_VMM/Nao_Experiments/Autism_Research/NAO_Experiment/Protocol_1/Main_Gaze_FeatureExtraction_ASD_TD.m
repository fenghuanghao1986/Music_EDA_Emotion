clear all 
clc
close all

%% Seg3: Extract Features (from gaze at (1), gaze away (0) coded lablels)
%in this part we force all gazeLables to have same frameRate (as
%Desired_FPS) and then we define new words or alphabet based on the
%sequences of these labels.

SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
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
clear all

SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
load( [SavingPath '\Part1_ASD_LabGaze_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','FPS_NaoTalking')
load([SavingPath '\Part1_ASD_GazeAnalysis.mat'],'Tot_Subj_Game_Sess_ID','SubjSess_Lab', 'NaoTalkingPercentage_GazeAt','NaoTalkingPercentage_GazeShifting','NaoTalkingRatio_GazeAt_Shifting', 'NaoTalkingEntropy_Shifting',...
     'KidTalkingPercentage_GazeAt', 'KidTalkingPercentage_GazeShifting', 'KidTalkingRatio_GazeAt_Shifting', 'KidTalkingEntropy_Shifting','FPS_NaoTalking','info')

T_Seq = 7;%%as Nao_gazeLabel has been coded by 7 miminum, we consider a sequence of one second (T_Seq =7) for defining one alphabet in the system.
FrameRates = FPS_NaoTalking;
 
%%NAO TALKING %%extract some features from every T_Seq of the data
GazeCode = SameFPS_EntireCodes;
Segment = SameFPS_NaoTalking;
[NaoTalking_Features,NaoTalking_ClassLabel,Nao_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq, SubjSess_Lab )

%%KID TALKING %% extract some features from every T_Seq of the data
GazeCode = SameFPS_EntireCodes;
Segment = SameFPS_KidTalking;
[KidTalking_Features,KidTalking_ClassLabel,Kid_FeatInfo] = Funct_GazeFeatureExtraction (GazeCode,Segment, FrameRates, T_Seq, SubjSess_Lab )

save ([SavingPath '\Part1_ASD_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
    'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq')



























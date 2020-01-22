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




%% Seg4: HMM Training + Testing
SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
ClassLable = [1 2];
ClassTag = {'TD' ;'ASD'}
for (i_Class = 1:2)
    load  ([SavingPath '\Part1_' ClassTag{i_Class} '_Feat_Extraction_LabGaze_KidNaoTalking.mat'] , 'NaoTalking_Features','NaoTalking_ClassLabel','Nao_FeatInfo',...
        'KidTalking_Features','KidTalking_ClassLabel','Kid_FeatInfo','T_Seq');
    GameTag = {'KidTalking' , 'NaoTalking'}
%% Load all the data for different classes into           
    if (i_Class == 1) %%Concatenating data from  ASD (both NAO/KID talking)
        Features = KidTalking_Features
        Labels = KidTalking_ClassLabel
        [TD_KidTalking_Feat_Tot, TD_KidTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
        TD_KidTalking_Label_Tot = ones(size(TD_KidTalking_Feat_Tot,1),1);%TD class => Label (1)
        TD_KidTalking_SubjSessItr_Tot = str2num(TD_KidTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        Unique_TD_KidTalking_SubjSessItr_Tot = unique(TD_KidTalking_SubjSessItr_Tot);
        Num_TD_KidTalking_SubjSessItr_Tot = size(Unique_TD_KidTalking_SubjSessItr_Tot,1);
        
        TD_KidTalking. Feat_Tot = TD_KidTalking_Feat_Tot;
        TD_KidTalking.ClassLable_Tot = TD_KidTalking_ClassLable_Tot;
        TD_KidTalking.Label_Tot = TD_KidTalking_Label_Tot;
        TD_KidTalking.SubjSessItr_Tot = TD_KidTalking_SubjSessItr_Tot;
        TD_KidTalking.Unique_SubjSessItr_Tot = Unique_TD_KidTalking_SubjSessItr_Tot;
        TD_KidTalking.Num_SubjSessItr_Tot = Num_TD_KidTalking_SubjSessItr_Tot;
        
        
        %%%
        Features = NaoTalking_Features
        Labels = NaoTalking_ClassLabel
        [TD_NaoTalking_Feat_Tot, TD_NaoTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
        TD_NaoTalking_Label_Tot = ones(size(TD_NaoTalking_Feat_Tot,1),1);%TD class => Label (1) 
        TD_NaoTalking_SubjSessItr_Tot = str2num(TD_NaoTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        Unique_TD_NaoTalking_SubjSessItr_Tot = unique(TD_NaoTalking_SubjSessItr_Tot);
        Num_TD_NaoTalking_SubjSessItr_Tot = size(Unique_TD_NaoTalking_SubjSessItr_Tot,1);
        
        TD_NaoTalking. Feat_Tot = TD_NaoTalking_Feat_Tot;
        TD_NaoTalking.ClassLable_Tot = TD_NaoTalking_ClassLable_Tot;
        TD_NaoTalking.Label_Tot = TD_NaoTalking_Label_Tot;
        TD_NaoTalking.SubjSessItr_Tot = TD_NaoTalking_SubjSessItr_Tot;
        TD_NaoTalking.Unique_SubjSessItr_Tot = Unique_TD_NaoTalking_SubjSessItr_Tot;
        TD_NaoTalking.Num_SubjSessItr_Tot = Num_TD_NaoTalking_SubjSessItr_Tot;
        
        
    elseif (i_Class == 2) %%Concatenating data from ASD (both NAO/KID talking)
        
        Features = KidTalking_Features
        Labels = KidTalking_ClassLabel
        [ASD_KidTalking_Feat_Tot, ASD_KidTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
        ASD_KidTalking_Label_Tot = 2*ones(size(ASD_KidTalking_Feat_Tot,1),1);%TD class => Label (1)
        ASD_KidTalking_SubjSessItr_Tot = str2num(ASD_KidTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        Unique_ASD_KidTalking_SubjSessItr_Tot = unique(ASD_KidTalking_SubjSessItr_Tot);
        Num_ASD_KidTalking_SubjSessItr_Tot = size(Unique_ASD_KidTalking_SubjSessItr_Tot,1);
        
        ASD_KidTalking. Feat_Tot = ASD_KidTalking_Feat_Tot;
        ASD_KidTalking.ClassLable_Tot = ASD_KidTalking_ClassLable_Tot;
        ASD_KidTalking.Label_Tot = ASD_KidTalking_Label_Tot;
        ASD_KidTalking.SubjSessItr_Tot = ASD_KidTalking_SubjSessItr_Tot;
        ASD_KidTalking.Unique_SubjSessItr_Tot = Unique_ASD_KidTalking_SubjSessItr_Tot;
        ASD_KidTalking.Num_SubjSessItr_Tot = Num_ASD_KidTalking_SubjSessItr_Tot;
        
        %%%
        
        Features = NaoTalking_Features
        Labels = NaoTalking_ClassLabel
        [ASD_NaoTalking_Feat_Tot, ASD_NaoTalking_ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels); 
        ASD_NaoTalking_Label_Tot = 2*ones(size(ASD_NaoTalking_Feat_Tot,1),1);%TD class => Label (1) 
        ASD_NaoTalking_SubjSessItr_Tot = str2num(ASD_NaoTalking_ClassLable_Tot(:,[4:6 8:9 11:12]));
        Unique_ASD_NaoTalking_SubjSessItr_Tot = unique(ASD_NaoTalking_SubjSessItr_Tot);
        Num_ASD_NaoTalking_SubjSessItr_Tot = size(Unique_ASD_NaoTalking_SubjSessItr_Tot,1);

        ASD_NaoTalking. Feat_Tot = ASD_NaoTalking_Feat_Tot;
        ASD_NaoTalking.ClassLable_Tot = ASD_NaoTalking_ClassLable_Tot;
        ASD_NaoTalking.Label_Tot = ASD_NaoTalking_Label_Tot;
        ASD_NaoTalking.SubjSessItr_Tot = ASD_NaoTalking_SubjSessItr_Tot;
        ASD_NaoTalking.Unique_SubjSessItr_Tot = Unique_ASD_NaoTalking_SubjSessItr_Tot;
        ASD_NaoTalking.Num_SubjSessItr_Tot = Num_ASD_NaoTalking_SubjSessItr_Tot;
    end

end



%% pat2: Put T_Seq frame toghether and make a new label for that
SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';

T_Seq_List = [8 12 16 20]%%Determine the number of Frames in each sequenceof HMM (DISFA fps =20 so 10 frames = 0.5 second video)

%%T_Seq of HMM on recogntion results for each AU
for i_T_Seq = T_Seq_List
    %T_Seq = 10; % length of observation sequence(forHMM)
    T_Seq = i_T_Seq; % length of observation sequence(forHMM)
%     % ExperimentID = ['Exp_1_SubjDepndent_Dyn3Level_TSequence' num2str(T_Seq)]
%     ExperimentID = ['Exp_1_DiffFeat_SubjDepndent_2ClassTD_vs_ASD_TSequence' num2str(T_Seq) '_AU' num2str(AU_Selected)]
% 

%     %%Write the Results in the ResultsNoteFil
%     ResultsNoteFile = fullfile(SavingPath, ['HMM_File_Exp_1_SubjDepen_TSequence' num2str(T_Seq) '.txt']);
%     fid = fopen(ResultsNoteFile, 'w');
%     if fid == -1; error('Cannot open file: %s', TheFile); end
%     fprintf(fid, 'HMM RESULTS:Experiment 1 - Subject Dependent All AUS\r\n');
%     fprintf(fid, ['HMM: Frame Rate DISFA video = 20fps, HMM T_Seq=' num2str(T_Seq) ' \r\n']);
%     fprintf(fid, 'HMM RESULTS:Differential Local Gabor Features Have been Used (MeanLocalGabor Reduced)\r\n');
%     fprintf(fid, '*********************************************************\r\n');
%     fprintf(fid,'%3s %12s %22s %22s \r\n','AU#','T_Seq(HMM)', 'Total Recog.(%)' ,'ICC Overall ([0 1])');


    Tot_Local_Feat=[];
    Tot_Lab = [];Tot_SubjID=[];
    Subj_Itr =0;
    Te_Pred_Lab_Tot= [];%%Keep record of the Pred_Labels for all testing set for all i_Subj
    Te_True_Lab_Tot =[];%%Keep record of the True_Labels for all testing set for all i_Subj
    ConfusionMat_Overall = []
    RecognitionRateOveral=[]
    ICC_Overall = []

    for i_Subj = Subjs_No
        Subj_Itr = Subj_Itr+1; 
        Subj_ID = sprintf('Gabor_SN%03d_GoodFrames',i_Subj);

        load(fullfile(path_Gabor_File,Subj_ID));


    %%Extracte Local Gabor Feature Corresponds to AU_Selected
        % [LocalFeat, LabFrames] = Funct_Gabor_LocalFeature(Label, AU_Selected);
        [LocalFeat,Diff_LocalFeat, LabFrames] = Funct_DiffGabor_LocalFeature(Label, AU_Selected);

        LocalFeat = Diff_LocalFeat;%use the differential Gabor Feature (Mean Subj Reduced)


    %% Define Sequence(Image Sequences) with length 'T_Sequence'to be applied to HMM
        CategoryType = 'AU_intensity';%% AU intensity: Intensity 0-5
    %     CategoryType = 'Dynamic';%%Dynnica AU intnsity: Rising, Constant, Falling 

    if CategoryType == 'AU_intensity';%The lable of CategoryID should be NotEqual to zero
        LabFrames = LabFrames+1;%add one to every intensity label so we have 1 to 6 inesnity
    end
    %Start Funct1:
    %     T_Seq = 10; % length of observation sequence
        NumSeq = floor(length(LabFrames)/T_Seq);%Determines Number of Video(seq) Segments
        LabFrames_Sq = LabFrames(1:NumSeq*T_Seq);
        LocalFeat_Sq = LocalFeat(1:NumSeq*T_Seq, :);

        Lab_SQ = reshape(LabFrames_Sq,T_Seq,NumSeq);%Make Sequence of T_Seq Frame


        switch CategoryType
            case 'AU_intensity'
                %%CaseI: category AU Intnsity: is the Average AU_Intensity in the Sequence of T_Seq frames
    %             Category_ID = ceil(mean(Lab_SQ))'; %Each Sequence is Within Caegory 0 to 5 (AU intensity)

                %%To have CategoryID bigger than zero
                Category_ID = ceil(mean(Lab_SQ))'; %Each Sequence is Within Caegory 0 to 5 (AU intensity)
            case 'Dynamic'
                %%CaseII: category AU dynmics: Three Categorys a) Rizing(onset:+1),b)Constant(0) c) falling(Offset:-1)
                T1 = floor(T_Seq/2); %Divide Starting vs. End Segment of Each sequence to find dynamics
                M1 = mean(Lab_SQ(1:T1,:));%Mean AU intensity of first half of sequence
                M2 = mean(Lab_SQ(T1+1:T_Seq, :));%Mean AU intensity of second half of sequence

                Dyn = M2 - M1 ;
                Dyn(Dyn>0) = 1;
                Dyn(Dyn==0) = 2;
                Dyn(Dyn<0) = 3;
                Category_ID = Dyn'; %Three labels for Category(Dynamics Rise+1,Const0,Fall-1)
        end

        %%OutPutFunction
        T_Seq; %Number of Images(Frames) in each sequnce
        LabFrames_Sq; %%Au IntensityLabelFrameByFrame
        LocalFeat_Sq;  %%Feature Vector(Gabor) FrameByFrame 
        Category_ID;  %%Category of Sequence of each Data Sequence
        CategoryType; %%Type oF category for Data Sequence()
    %End Funct1:
    end

end
  















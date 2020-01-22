clear all
clc
close all
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seg1: Extracting the Labels for Gaze and Each Favorite Section
%%this Gaze code load the txt file for Part1(game1) in which
%%kidsTalking/NaoTalking and align the frame rate of the coded gaze wr.t.
%%nao talking segemnt

Listing = dir('C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded\WholeASD\ASD_Part1\*.txt')
Data_Path = 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded\WholeASD\ASD_Part1\';
Figure_Path = 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Figures\ASD_Gaze\'

NameID= { '_code', '_kid_talking', '_nao_talking'} %tag for the .Txt files

Tot_Subj_Game_Sess_ID =[];
itr=0;
%%load the data
numFiles = size(Listing,1);
for i_file = 1:numFiles%%remove the dots and double dots
    Subj_Game_Sess_ID = Listing(i_file).name(1:11);%%Extract the SN_Sess_Game ID
    strcmpi(Subj_Game_Sess_ID,Tot_Subj_Game_Sess_ID);
    
    %%Check if already captured these data
    if length(strfind(upper(Tot_Subj_Game_Sess_ID),upper(Subj_Game_Sess_ID))) > 0
        %this set of samples have been processed before
        disp('Already Processed');
    else
        %new sample session
        itr = itr+1;
        disp('New Sample');
        Tot_Subj_Game_Sess_ID = [Tot_Subj_Game_Sess_ID ' ' upper(Subj_Game_Sess_ID)];
        
%         EntireCode{itr} =  textread([Data_Path Subj_Game_Sess_ID NameID{1} '.txt'],'%q');      
%         KidTalking_Segment{itr} = textread([Data_Path Subj_Game_Sess_ID NameID{2} '.txt'],'%q');
%         NaoTalking_Segment{itr} = textread([Data_Path Subj_Game_Sess_ID NameID{3} '.txt'],'%q');       

        Text_DIR_CODE= [Data_Path Subj_Game_Sess_ID NameID{1}];       
        [EntireCode{itr},FPS_EntireCode(itr),StartFrame_EntireCode(itr)] = Funct_Label_FPS_Extraction(Text_DIR_CODE)

        Text_DIR_KidTalks= [Data_Path Subj_Game_Sess_ID NameID{2}];       
        [KidTalking_Segment{itr} ,FPS_KidTalking(itr),StartFrame_KidTalks(itr)] = Funct_Label_FPS_Extraction(Text_DIR_KidTalks)

        Text_DIR_NaoTalks= [Data_Path Subj_Game_Sess_ID NameID{3}];       
        [NaoTalking_Segment{itr},FPS_NaoTalking(itr),StartFrame_NaoTalks(itr)] = Funct_Label_FPS_Extraction(Text_DIR_NaoTalks);

        %%normalize the videos w.r.t the frame length of FPS_NaoTalking
        Num_EntireCodes = length(EntireCode{itr});
        Num_KidTalking = length(KidTalking_Segment{itr});

        Ratio_EntireCoding = FPS_EntireCode(itr)/FPS_NaoTalking(itr) ;
        Ratio_KidTalking = FPS_KidTalking(itr)/FPS_NaoTalking(itr) ;

        Ind_EntireCode= floor( [1: Ratio_EntireCoding: Num_EntireCodes] );
        Ind_KidTalking= floor( [1: Ratio_KidTalking: Num_KidTalking] );

        %%Labels with the same FPS
        S1 = floor((StartFrame_EntireCode(itr)-1)/Ratio_EntireCoding);
        S2 = floor((StartFrame_KidTalks(itr)-1)/Ratio_KidTalking);
        S3 = floor((StartFrame_NaoTalks(itr)-1)/1);
        
        SameFPS_EntireCodes{itr} =[-1*ones(S1,1); EntireCode{itr}(Ind_EntireCode)];      
        SameFPS_KidTalking{itr} = [-1*ones(S2,1); KidTalking_Segment{itr}(Ind_KidTalking)];
        SameFPS_NaoTalking{itr} = [-1*ones(S3,1); NaoTalking_Segment{itr}(1:end)];%%all the videos are aligned with FPS NAO_Talking

%         SameFPS_EntireCodes{itr} = EntireCode{itr}(Ind_EntireCode);
%         SameFPS_KidTalking{itr} = KidTalking_Segment{itr}(Ind_KidTalking);
%         SameFPS_NaoTalking{itr} = NaoTalking_Segment{itr}(1:end);%%all the videos are aligned with FPS NAO_Talking

        %%
        h=figure(1); 
        set(h,'units','normalized','outerposition',[0 0 1 1]);
        plot(SameFPS_EntireCodes{itr},'b'); hold on;
        plot( SameFPS_KidTalking{itr} ,'*g');
        plot(SameFPS_NaoTalking{itr} ,'.r'); hold off
        grid;
        hleg=legend('EntireCode', 'KidTalking Segment', 'NaoTalking Segment');
        set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1],'fontsize',12);
        set(hleg,'Location','SouthEast');
%         title(['Three Coding Lables (with' num2str(FPS_NaoTalking(itr)) ' fps)' ], 'fontsize',14)
        title([Subj_Game_Sess_ID ' Three Coding Lables (with' num2str(FPS_NaoTalking(itr)) ' fps)' num2str(StartFrame_EntireCode(itr)) ',' num2str(StartFrame_KidTalks(itr))  ',' num2str(StartFrame_NaoTalks(itr))], 'fontsize',12);
        FigName = [Figure_Path Subj_Game_Sess_ID 'ASD_NaoKidTalking'];
        saveas(h,FigName,'jpg') ;
        saveas(h,FigName,'fig') ;
    end
end
SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';

% save ( [SavingPath '\Part1_Lab_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking')
info = {'all lables have be aligne w.r.t the FPS_NaoTalking=> fps all labels = FPS_NaoTalking'}
save ( [SavingPath '\Part1_ASD_LabGaze_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','FPS_NaoTalking','info')


%% Seg1.1: what should I do for the Labels that are not 1:
%% Seg2: Analyzing the Coded Data, for NaoTalking, KidTalking, etc...
SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Saved';
% load( [SavingPath '\Part1_Lab_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking')
load( [SavingPath '\Part1_ASD_LabGaze_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking', 'FPS_NaoTalking')

NumSessions = size(SameFPS_EntireCodes,2)
for itr =1: NumSessions
    Lab_NaoTalking = SameFPS_NaoTalking{itr};
    Lab_KidTalking = SameFPS_KidTalking{itr};
    CodedGaze = SameFPS_EntireCodes{itr};

    [NaoTalkingPercentage_GazeAt(itr), NaoTalkingPercentage_GazeShifting(itr), NaoTalkingRatio_GazeAt_Shifting(itr), NaoTalkingEntropy_Shifting(itr)]=Funct_GazeAnalysis(CodedGaze,Lab_NaoTalking)
    [KidTalkingPercentage_GazeAt(itr), KidTalkingPercentage_GazeShifting(itr), KidTalkingRatio_GazeAt_Shifting(itr), KidTalkingEntropy_Shifting(itr)]=Funct_GazeAnalysis(CodedGaze,Lab_KidTalking)

end

SubjSess_Lab = reshape(Tot_Subj_Game_Sess_ID(1:end),12,[])' 
[ 100*NaoTalkingPercentage_GazeAt' 100*NaoTalkingPercentage_GazeShifting' NaoTalkingRatio_GazeAt_Shifting'  NaoTalkingEntropy_Shifting']
[ 100*KidTalkingPercentage_GazeAt' 100*KidTalkingPercentage_GazeShifting' KidTalkingRatio_GazeAt_Shifting'  KidTalkingEntropy_Shifting']

info = {'all lables have be aligne w.r.t the FPS_NaoTalking=> fps all labels = FPS_NaoTalking'}

save([SavingPath '\Part1_ASD_GazeAnalysis.mat'],'Tot_Subj_Game_Sess_ID','SubjSess_Lab', 'NaoTalkingPercentage_GazeAt','NaoTalkingPercentage_GazeShifting','NaoTalkingRatio_GazeAt_Shifting', 'NaoTalkingEntropy_Shifting',...
    'KidTalkingPercentage_GazeAt', 'KidTalkingPercentage_GazeShifting', 'KidTalkingRatio_GazeAt_Shifting', 'KidTalkingEntropy_Shifting','FPS_NaoTalking','info')





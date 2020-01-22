close all
clear all
clc


%% Seg2: For each of video segment apply the INTERAFACE and store the registerd data in separate folder (for each segment of video)
%%loading the information about each segment, and save it in
%%'\Autism_Reserach\NaoExperiment\Protocol_1\IntraFace_Results\KidTalking_Results'
LoadingPath= 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded';
load( [LoadingPath '\Part1_Lab_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','VideoInd_KidTalking','VideoInd_NAOTalking','Tot_Subj_Game_Sess_ID_Vid','FPS_NaoTalking');
%videoFrameRate = FPS_NaoTalking;



%%load the path for loading the videos and saving videos
Overall_Path = 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\';

Saved_IntraFace_Path = fullfile(Overall_Path, 'IntraFace_Results');
if(exist(Saved_IntraFace_Path)==0)      mkdir(Saved_IntraFace_Path); end

Saved_IntraFace_KidTalk_Path = fullfile(Saved_IntraFace_Path, 'KidTalking_Results');
if(exist(Saved_IntraFace_KidTalk_Path)==0) mkdir(Saved_IntraFace_KidTalk_Path); end

Saved_IntraFace_NaoTalk_Path = fullfile(Saved_IntraFace_Path, 'NaoTalking_Results');
if(exist(Saved_IntraFace_NaoTalk_Path)==0) mkdir(Saved_IntraFace_NaoTalk_Path); end


NumVideoSegment = length(Tot_Subj_Game_Sess_ID_Vid);
for i_VidSeg = 1:NumVideoSegment
   
    %%IntraFace Head Pose Section
    NameSeg = Tot_Subj_Game_Sess_ID_Vid{i_VidSeg};

    Subj_ID = NameSeg(1:5);
    Sess_No = ['session' num2str(str2double(NameSeg(10:11)))];
    Vid_Id =  [NameSeg '_F.avi'];
% 
     Frontal_Video = fullfile(Overall_Path,Subj_ID,Sess_No,Vid_Id);

    input = Frontal_Video ;
    outputFolder=  fullfile(Overall_Path,Subj_ID,Sess_No, [Vid_Id(1:end-4) '_IFace'] );
    VideoName = Vid_Id
   


    for i_Seg =1:2%number of segment in each video(1->KidTalking,2->NaoTalking
        switch (i_Seg)
            case 1 %Kid talking segment
                FrameRangeSegment= VideoInd_KidTalking{i_VidSeg};
                VidSegID ='KidTalking';
                outputFolder_seg = [outputFolder '_' VidSegID];
                %%Save The facial models of each subject-sessions. 
                Kid_HeadPos_Model = Funct_HeadPoseAngleSeg( outputFolder_seg );
                
                %%gaze Code for Kid TalkingSection
                GazeLabel = SameFPS_EntireCodes{i_VidSeg};
                Ind = VideoInd_KidTalking{i_VidSeg};
                KidTalking_GazeLabel = GazeLabel(Ind);
                KidTalking_GazeLabel = (KidTalking_GazeLabel==1);%1 look at, other look away
                KidTalking_GazeLabel = KidTalking_GazeLabel(1:end-1);%interaFace has one less frame
                
                Kid_HeadPos_Model.KidTalking_GazeLabel = KidTalking_GazeLabel;
                Id= Kid_HeadPos_Model.GameInfo;
                save([Saved_IntraFace_KidTalk_Path, '\', Id], 'Kid_HeadPos_Model')
                
            case 2 %NaoTalking Segment
                FrameRangeSegment= VideoInd_NAOTalking{i_VidSeg};
                VidSegID ='NaoTalking';
                outputFolder_seg = [outputFolder '_' VidSegID];
                 %%Save The facial models of each subject-sessions. 
                Nao_HeadPos_Model = Funct_HeadPoseAngleSeg( outputFolder_seg );
                
                 %%gaze Code for Nao TalkingSection
                GazeLabel = SameFPS_EntireCodes{i_VidSeg};
                Ind = VideoInd_NAOTalking{i_VidSeg};
                numCoded = size(GazeLabel,1);
                if (Ind(end)> size(GazeLabel,1))%if gaze has not been coded for the indices, consider them as zero
                    addZero = Ind(end) - size(GazeLabel,1) ;
                    GazeLabel = [GazeLabel ; zeros(addZero,1)]
                end
                NaoTalking_GazeLabel = GazeLabel(Ind);
                NaoTalking_GazeLabel = (NaoTalking_GazeLabel==1);%1 look at, other look away
                NaoTalking_GazeLabel = NaoTalking_GazeLabel(1:end-1);%interaFace has one less frame
                
                Nao_HeadPos_Model.NaoTalking_GazeLabel = NaoTalking_GazeLabel;                               
                Id= Nao_HeadPos_Model.GameInfo;
                save([Saved_IntraFace_NaoTalk_Path, '\', Id], 'Nao_HeadPos_Model')
                
                
            otherwise
                disp ('Wrong Segment...')
        end
    end
    %track_video_Mohammad(input,outputFolder,VideoName,FramRateVid)   
end





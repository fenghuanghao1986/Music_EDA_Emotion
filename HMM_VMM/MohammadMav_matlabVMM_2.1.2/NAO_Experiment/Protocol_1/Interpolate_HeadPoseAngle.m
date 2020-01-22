close all
clear all
clc


%% Seg3: find the frames which Intraface Failed to analyze and interpolate their values.
% LoadingPath= 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded';
% load( [LoadingPath '\Part1_Lab_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','VideoInd_KidTalking','VideoInd_NAOTalking','Tot_Subj_Game_Sess_ID_Vid','FPS_NaoTalking');

%%load the path for loading the videos and saving videos
Overall_Path = 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\';

Saved_IntraFace_Path = fullfile(Overall_Path, 'IntraFace_Results');
if(exist(Saved_IntraFace_Path)==0)      mkdir(Saved_IntraFace_Path); end

Saved_IntraFace_KidTalk_Path = fullfile(Saved_IntraFace_Path, 'KidTalking_Results');
if(exist(Saved_IntraFace_KidTalk_Path)==0) mkdir(Saved_IntraFace_KidTalk_Path); end

Saved_IntraFace_NaoTalk_Path = fullfile(Saved_IntraFace_Path, 'NaoTalking_Results');
if(exist(Saved_IntraFace_NaoTalk_Path)==0) mkdir(Saved_IntraFace_NaoTalk_Path); end

CurrentPath = cd ;
%% Kid TALKING 
cd (Saved_IntraFace_KidTalk_Path)
list = ls ('SN*F_IFace_KidTalking.mat') ; % extract the name of Files for interpolating head angle
NumVideoSegment = size(list,1);
for i_VidSeg = 1:NumVideoSegment
   
    %%IntraFace Head Pose Section
    cd (Saved_IntraFace_KidTalk_Path)

    NameSeg = list(i_VidSeg,:);
    load (NameSeg , 'Kid_HeadPos_Model')
    if (~isfield(Kid_HeadPos_Model, 'headPoseAngle'))
        continue 
    end
    Angle = Kid_HeadPos_Model.headPoseAngle;
    Interp_Angle = zeros(size(Angle));
    
    Ind = find(sum(Angle,2)==0)%if three (x,y,z) for angle is zero the index will be selected
    cd(CurrentPath)
    for (i_Dim = 1:3)%for 3 dimension of angle interpolate for the (0,0,0) indices
        Interp_Angle(:,i_Dim)=fixgaps(double(Angle(:,i_Dim)));
    end
    Kid_HeadPos_Model.Interpolate_HeadPose = Interp_Angle;
    
    cd (Saved_IntraFace_KidTalk_Path)
    save (['Interp_' NameSeg ],'Kid_HeadPos_Model')
end

%% NAO TALKING 
cd (Saved_IntraFace_NaoTalk_Path)
list = ls ('SN*F_IFace_NaoTalking.mat') ; % extract the name of Files for interpolating head angle
NumVideoSegment = size(list,1);
for i_VidSeg = 1:NumVideoSegment
   
    %%IntraFace Head Pose Section
    cd (Saved_IntraFace_NaoTalk_Path)

    NameSeg = list(i_VidSeg,:);
    load (NameSeg , 'Nao_HeadPos_Model')
    
    if (~isfield(Nao_HeadPos_Model, 'headPoseAngle'))
        continue 
    end
    
    Angle = Nao_HeadPos_Model.headPoseAngle;
    Interp_Angle = zeros(size(Angle));
    
    Ind = find(sum(Angle,2)==0)%if three (x,y,z) for angle is zero the index will be selected
    cd(CurrentPath)
    for (i_Dim = 1:3)%for 3 dimension of angle interpolate for the (0,0,0) indices
        Interp_Angle(:,i_Dim)=fixgaps(double(Angle(:,i_Dim)));
    end
    Nao_HeadPos_Model.Interpolate_HeadPose = Interp_Angle;
    
    cd (Saved_IntraFace_NaoTalk_Path)
    save (['Interp_' NameSeg ],'Nao_HeadPos_Model')
end







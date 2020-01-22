%Mohammad_ASD_TrackFaces_V1: Load Txt files that define the segments in the
%video for NaoTalking, KidTalking, etc. and we only extract the pose and
%lanmark point for those video segments

clear all
close all
clc

%% Seg1: Extracting the Labels for Gaze and Each Favorite Section
% %Listing = dir('D:\Mohammad\Matlab\Autism_Nao_Experiments\Data_FirstProtocol\Labels\Part1_v\*.txt')
% %Data_Path = 'D:\Mohammad\Matlab\Autism_Nao_Experiments\Data_FirstProtocol\Labels\Part1_v\';
% Listing = dir('C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded\Part1_v\*.txt')
% Data_Path = 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded\Part1_v\';
% 
% 
% 
% NameID= { '_code', '_kid_talking', '_nao_talking'} %tag for the .Txt files
% 
% Tot_Subj_Game_Sess_ID =[];
% itr=0;
% %%load the data
% numFiles = size(Listing,1);
% for i_file = 1:numFiles%%remove the dots and double dots
%     Subj_Game_Sess_ID = Listing(i_file).name(1:11)%%Extract the SN_Sess_Game ID
%     strcmpi(Subj_Game_Sess_ID,Tot_Subj_Game_Sess_ID);
%     
%     %%Check if already captured these data
%     if length(strfind(upper(Tot_Subj_Game_Sess_ID),upper(Subj_Game_Sess_ID))) > 0
%         %this set of samples have been processed before
%         disp('Already Processed');
%     else
%         %new sample session
%         itr = itr+1;
%         disp('New Sample');
%         Tot_Subj_Game_Sess_ID = [Tot_Subj_Game_Sess_ID ' ' upper(Subj_Game_Sess_ID)];
%         Tot_Subj_Game_Sess_ID_Vid{itr} = upper(Subj_Game_Sess_ID);
% %         EntireCode{itr} =  textread([Data_Path Subj_Game_Sess_ID NameID{1} '.txt'],'%q');      
% %         KidTalking_Segment{itr} = textread([Data_Path Subj_Game_Sess_ID NameID{2} '.txt'],'%q');
% %         NaoTalking_Segment{itr} = textread([Data_Path Subj_Game_Sess_ID NameID{3} '.txt'],'%q');       
% 
%         Text_DIR_CODE= [Data_Path Subj_Game_Sess_ID NameID{1}];       
%         [EntireCode{itr},FPS_EntireCode(itr),StartFrame_EntireCode(itr)] = Funct_Label_FPS_Extraction(Text_DIR_CODE);
% 
%         Text_DIR_KidTalks= [Data_Path Subj_Game_Sess_ID NameID{2}];       
%         [KidTalking_Segment{itr} ,FPS_KidTalking(itr),StartFrame_KidTalks(itr)] = Funct_Label_FPS_Extraction(Text_DIR_KidTalks);
% 
%         Text_DIR_NaoTalks= [Data_Path Subj_Game_Sess_ID NameID{3}];       
%         [NaoTalking_Segment{itr},FPS_NaoTalking(itr),StartFrame_NaoTalks(itr)] = Funct_Label_FPS_Extraction(Text_DIR_NaoTalks);
% 
%         %%normalize the videos w.r.t the frame length of FPS_NaoTalking
%         Num_EntireCodes = length(EntireCode{itr});
%         Num_KidTalking = length(KidTalking_Segment{itr});
% 
%         Ratio_EntireCoding = FPS_EntireCode(itr)/FPS_NaoTalking(itr) ;
%         Ratio_KidTalking = FPS_KidTalking(itr)/FPS_NaoTalking(itr) ;
% 
%         Ind_EntireCode= floor( [1: Ratio_EntireCoding: Num_EntireCodes] );
%         Ind_KidTalking= floor( [1: Ratio_KidTalking: Num_KidTalking] );
% 
%         %%Labels with the same FPS
%         S1 = floor((StartFrame_EntireCode(itr)-1)/Ratio_EntireCoding);
%         S2 = floor((StartFrame_KidTalks(itr)-1)/Ratio_KidTalking);
%         S3 = floor((StartFrame_NaoTalks(itr)-1)/1);
%         
%         SameFPS_EntireCodes{itr} =[-1*ones(S1,1); EntireCode{itr}(Ind_EntireCode)];      
%         SameFPS_KidTalking{itr} = [-1*ones(S2,1); KidTalking_Segment{itr}(Ind_KidTalking)];
%         SameFPS_NaoTalking{itr} = [-1*ones(S3,1); NaoTalking_Segment{itr}(1:end)];%%all the videos are aligned with FPS NAO_Talking
%         
%         %%keep track of frames for each of the video segment
%         VideoInd_KidTalking{itr} = find(SameFPS_KidTalking{itr}==1);%index of video frams that correspond to kid talking
%         VideoInd_NAOTalking{itr} = find(SameFPS_NaoTalking{itr}==1);%index of video frams that correspond to kid talking
%         
%         
%         
% 
% %         %%
% %         h=figure(1); 
% %         set(h,'units','normalized','outerposition',[0 0 1 1]);
% %         plot(SameFPS_EntireCodes{itr},'b'); hold on;
% %         plot( SameFPS_KidTalking{itr} ,'*g');
% %         plot(SameFPS_NaoTalking{itr} ,'.r'); hold off
% %         grid;
% %         hleg=legend('EntireCode', 'KidTalking Segment', 'NaoTalking Segment');
% %         set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1],'fontsize',12);
% %         set(hleg,'Location','SouthEast');
% % %         title(['Three Coding Lables (with' num2str(FPS_NaoTalking(itr)) ' fps)' ], 'fontsize',14)
% %         title([Subj_Game_Sess_ID ' Three Coding Lables (with' num2str(FPS_NaoTalking(itr)) ' fps)' num2str(StartFrame_EntireCode(itr)) ',' num2str(StartFrame_KidTalks(itr))  ',' num2str(StartFrame_NaoTalks(itr))], 'fontsize',12);
% %         FigName = ['C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Autism_Research\NAO_Experiment\Protocol_1\Figures\Labels\' Subj_Game_Sess_ID];
% %         saveas(h,FigName,'jpg') ;
% %         saveas(h,FigName,'fig') ;
%     end
% end
% SavingPath= 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded';
% 
% save ( [SavingPath '\Part1_Lab_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','VideoInd_KidTalking','VideoInd_NAOTalking','Tot_Subj_Game_Sess_ID_Vid','FPS_NaoTalking' , 'FPS_KidTalking','FPS_EntireCode')


%% Seg2: For each of video segment apply the INTERAFACE and store the registerd data in separate folder (for each segment of video)
%%loading the information about each segment
LoadingPath= 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\GazeCoded';
load( [LoadingPath '\Part1_Lab_KidNaoTalking.mat'],'Tot_Subj_Game_Sess_ID', 'SameFPS_EntireCodes','SameFPS_KidTalking', 'SameFPS_NaoTalking','VideoInd_KidTalking','VideoInd_NAOTalking','Tot_Subj_Game_Sess_ID_Vid','FPS_NaoTalking');
videoFrameRate = FPS_NaoTalking;


%%add to path (IntraFaces directory)
addpath('C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Intraface\FacialFeatureDetection&Tracking_v1.3\FacialFeatureDetection&Tracking_v1.3')
cd ('C:\Users\MahoorLab04\MMavadati_Files\MATLAB\Intraface\FacialFeatureDetection&Tracking_v1.3\FacialFeatureDetection&Tracking_v1.3')


%%load the path for loading the videos and saving videos
Overall_Path = 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_1\';

% Subj_ID = 'SN002'
% Sess_No = 'session2'
% Vid_Id = 'SN002_02_02_F.avi'

NumVideoSegment = length(Tot_Subj_Game_Sess_ID_Vid);
for i_VidSeg = 19:NumVideoSegment
    NameSeg = Tot_Subj_Game_Sess_ID_Vid{i_VidSeg}

    Subj_ID = NameSeg(1:5);
    Sess_No = ['session' num2str(str2double(NameSeg(10:11)))]
    Vid_Id =  [NameSeg '_F.avi']

    Frontal_Video = fullfile(Overall_Path,Subj_ID,Sess_No,Vid_Id)

    input = Frontal_Video ;
    outputFolder=  fullfile(Overall_Path,Subj_ID,Sess_No, [Vid_Id(1:end-4) '_IFace'] );
    VideoName = Vid_Id
    FramRateVid =videoFrameRate(i_VidSeg);


    for i_Seg =1:2%number of segment in each video(2->KidTalking,NaoTalking
        switch (i_Seg)
            case 1 %Kid talking segment
                FrameRangeSegment= VideoInd_KidTalking{i_VidSeg};
                VidSegID ='KidTalking'
                outputFolder_seg = [outputFolder '_' VidSegID]
                if (length(FrameRangeSegment)>0)
                    track_video_Mohammad_VidSegment(input,outputFolder_seg,VideoName,FramRateVid,FrameRangeSegment,VidSegID)
                end
            case 2 %NaoTalking Segment
                FrameRangeSegment= VideoInd_NAOTalking{i_VidSeg};
                VidSegID ='NaoTalking'
                outputFolder_seg = [outputFolder '_' VidSegID]
                if (length(FrameRangeSegment)>0)%if there at least one frame
                    track_video_Mohammad_VidSegment(input,outputFolder_seg,VideoName,FramRateVid,FrameRangeSegment,VidSegID)
                end
            otherwise
                disp ('Wrong Segment...')
        end
    end
    %track_video_Mohammad(input,outputFolder,VideoName,FramRateVid)
    
end
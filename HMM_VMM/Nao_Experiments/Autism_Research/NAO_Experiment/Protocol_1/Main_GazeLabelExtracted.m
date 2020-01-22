clear all
clc
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd D:\Mohammad\Matlab\Autism_Nao_Experiments\Data_FirstProtocol
% Listing = dir('D:\Mohammad\Matlab\Autism_Nao_Experiments\Data_FirstProtocol\*.txt')
Listing = dir('D:\Mohammad\Matlab\Autism_Nao_Experiments\Data_FirstProtocol\Data\*.txt')
Data_Path = 'D:\Mohammad\Matlab\Autism_Nao_Experiments\Data_FirstProtocol\';

NameID= { '_code', '_kid_talking', '_nao_talking'} %tag for the .Txt files

Tot_Subj_Game_Sess_ID =[];
itr=0;
%%load the data
numFiles = size(Listing,1);
for i_file = 1:numFiles%%remove the dots and double dots
    Subj_Game_Sess_ID = Listing(i_file).name(1:11);%%Extract the SN_Sess_Game ID
    strcmp(Subj_Game_Sess_ID,Tot_Subj_Game_Sess_ID)
    
    %%Check if already captured these data
    if length(strfind(Tot_Subj_Game_Sess_ID,Subj_Game_Sess_ID)) > 0
        %this set of samples have been processed before
        disp('Already Processed');
    else
        %new sample session
        itr = itr+1;
        disp('New Sample');
        Tot_Subj_Game_Sess_ID = [Tot_Subj_Game_Sess_ID ' ' Subj_Game_Sess_ID];
        
%         EntireCode{itr} =  textread([Data_Path Subj_Game_Sess_ID NameID{1} '.txt'],'%q');      
%         KidTalking_Segment{itr} = textread([Data_Path Subj_Game_Sess_ID NameID{2} '.txt'],'%q');
%         NaoTalking_Segment{itr} = textread([Data_Path Subj_Game_Sess_ID NameID{3} '.txt'],'%q');       

        Text_DIR_CODE= [Data_Path Subj_Game_Sess_ID NameID{1}]   ;       
        [EntireCode{itr},FPS_EntireCode(itr)] = Funct_Label_FPS_Extraction(Text_DIR_CODE)

        Text_DIR_KidTalks= [Data_Path Subj_Game_Sess_ID NameID{2}]   ;       
        [KidTalking_Segment{itr} ,FPS_KidTalking(itr)] = Funct_Label_FPS_Extraction(Text_DIR_KidTalks)

        Text_DIR_NaoTalks= [Data_Path Subj_Game_Sess_ID NameID{3}]   ;       
        [NaoTalking_Segment{itr},FPS_NaoTalking(itr)] = Funct_Label_FPS_Extraction(Text_DIR_NaoTalks)

        %%normalize the videos w.r.t the frame length of FPS_NaoTalking
        Num_EntireCodes = length(EntireCode{itr})
        Num_KidTalking = length(KidTalking_Segment{itr})

        Ratio_EntireCoding = FPS_EntireCode(itr)/FPS_NaoTalking(itr) ;
        Ratio_KidTalking = FPS_KidTalking(itr)/FPS_NaoTalking(itr) ;

        Ind_EntireCode= floor( [1: Ratio_EntireCoding: Num_EntireCodes] )
        Ind_KidTalking= floor( [1: Ratio_KidTalking: Num_KidTalking] )

        %%Labels with the same FPS 
        SameFPS_EntireCodes{itr} = EntireCode{1}(Ind_EntireCode)
        SameFPS_KidTalking{itr} = KidTalking_Segment{itr}(Ind_KidTalking)
        SameFPS_NaoTalking{itr} = NaoTalking_Segment{itr}(1:end)%%all the videos are aligned with FPS NAO_Talking

        %%
        figure(1), 
        plot(EntireCode{1}(Ind_EntireCode)); hold on;
        plot(KidTalking_Segment{1}(Ind_KidTalking),'*g');
        plot(NaoTalking_Segment{1},'.r'); hold off
        hleg=legend('EntireCode', 'KidTalking Segment', 'NaoTalking Segment')
        set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1],'fontsize',12)
        title(['Three Coding Lables (with' num2str(FPS_NaoTalking_(itr)) ' fps)' ], 'fontsize',14)
    end
end







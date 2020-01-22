


% New Update: Dec. 09, 2015
% Sample Extraction

% *********************************************
% % ==================== Start. Load Data =====================
% 
% for tt=1:4
%     
%     clc
%     close all
%     warning off
% 
%     InpPool={'O14AK_20141210.mat','O14AK_20141210_response.mat';
%     'O14AJ_20141103.mat','O14AJ_20141103_response.mat';
%     'A15K_20150511.mat','A15K_20150511_response.mat';
%     'J15M_20150608.mat','J15M_20150608_response.mat';
%     'A15L_20150427.mat','A15L_20150427_response.mat'};
% 
%     NamPool={'O14AK';'O14AJ';'A15K';'J15M';'A15L'};
%     chPool=[1;2;3];
%     sidePool={'Left';'Right'};
%     targetPool={'Button','Audio','Video','Reach','Random'};
% 
%     name1=InpPool{tt,1}
%     name2=InpPool{tt,2}
%     name=NamPool{tt}
%     
%    for tt3=1:5
%     
%       target=targetPool{tt3}
%       
%       for tt2=1:2
%         
%          side=sidePool{tt2}
%         
%          for tt1=1:3
%              
%              load(name1);
%              load(name2);
%              TempSignal=signal(:,1:8);   
%              clear audio digital intracranial intracranial_channel_names ...
%                original_parameters signal signal_channel_names states 
%              signal=TempSignal;
%              clear TempSignal
%              
%              ch=chPool(tt1)
% 
%              if strcmp(side,'Right')
%                 if ch==1
%                    BipolarSignal=signal(:,2)-signal(:,1);
%                 elseif ch==2
%                    BipolarSignal=signal(:,3)-signal(:,2);
%                 else
%                    BipolarSignal=signal(:,4)-signal(:,3);
%                 end
%     
%              else
%                 if ch==1
%                    BipolarSignal=signal(:,6)-signal(:,5);
%                 elseif ch==2
%                    BipolarSignal=signal(:,7)-signal(:,6);
%                 else
%                    BipolarSignal=signal(:,8)-signal(:,7);
%                 end
%    
%              end
% 
%             clear signal
% 
%             if strcmp(target,'Button')
%    
%                flag=1;
%                LL=length(PCS_button_press);
%                onset=zeros(1,LL);
%                offset=zeros(1,LL);
% 
%                for i=1:LL
%     
%                   if PCS_button_press(i).valid==1 
% %                 if strcmp(PCS_button_press(i).code,side)==1
%         
%                      onset(i)=PCS_button_press(i).response.index;
%                      offset(i)=PCS_button_press(i).response.duration;
%               
% %                 end
%                   end
%     
%                end
%      
%             elseif strcmp(target,'Audio')
%    
%                 flag=1;
%                 LL=length(AudioEvents);
%                 onset=zeros(1,LL);
%                 offset=zeros(1,LL);
% 
%                 for i=1:LL
%     
%                     if AudioEvents(i).valid==1 
%         
%                        onset(i)=AudioEvents(i).response.index;
%                        offset(i)=AudioEvents(i).response.duration;
%         
%                     end
%         
%                 end
% 
%            elseif strcmp(target,'Video')
%    
%                 flag=1;
%                 LL=length(VideoEvents);
%                 onset=zeros(1,LL);
%                 offset=zeros(1,LL);
% 
%                 for i=1:LL
%     
%                    if VideoEvents(i).valid==1 
%         
%                       onset(i)=VideoEvents(i).response.index;
%                       offset(i)=VideoEvents(i).response.duration;
%         
%                    end
%         
%                 end
%     
%            elseif strcmp(target,'Reach')
%     
%                 flag=1;
%                 LL=length(PCS_reach);
%                 onset=zeros(1,LL);
%                 offset=zeros(1,LL);
% 
%                 for i=1:LL
%     
%                    if PCS_reach(i).valid==1 
% %                  if strcmp(PCS_reach(i).side,side)==1
%         
%                   onset(i)=PCS_reach(i).response.index;
%                   offset(i)=PCS_reach(i).response.duration;
%         
% %                  end
%                    end
%     
%                 end
%     
%             else
%                 
%                 flag=0;
%                 StartPoint=round(-1*Fs);
%                 EndPoint=round(1*Fs);  
%                 Epoch=EndPoint-StartPoint;
%                 InitialValue=round(7*Fs/17); 
%                 LoopNumber=round((length(BipolarSignal)-Epoch)/Epoch);
%                 LoopNumber=min(LoopNumber,50);
% 
%             end
% 
%             if flag==1
%    
%                offset=offset+onset;
% 
%                index=find(onset>0);
%                onset=onset(index).*Fs; 
%                offset=offset(index).*Fs;
%                StartPoint=round(-1*Fs);
%                EndPoint=round(1*Fs);       
%                LoopNumber=numel(onset);
% 
%             end
%             
%             DownSamp=1;
%             DesiredFrequency=linspace(8,30,255);
%             fw=DesiredFrequency/2;
%             scales=Fs./fw;
%             DownRawSignal=cell(1,LoopNumber);
%             TF=cell(1,LoopNumber);
%             TF1=cell(1,LoopNumber);
%             Vector1=cell(1,LoopNumber);
%             Vector11=cell(1,LoopNumber);
%             Vector2=cell(1,LoopNumber);
%             Vector22=cell(1,LoopNumber);
%             
%             for count=1:LoopNumber
%     
%                 disp(['Iteration ', num2str(count), ' out of ', num2str(LoopNumber)])
%     
%                 if strcmp(target,'Random')
%                    ST1=InitialValue+(count-1)*Epoch;
%                    EN1=InitialValue+count*Epoch;
%                 else
%                    ST1=onset(count)+StartPoint;
%                    EN1=onset(count)+EndPoint;
%                 end
%        
%                 TempSignal=BipolarSignal(ST1:EN1);
%                 TempR=TempSignal';
%                 DownRawSignal(count)={downsample(TempR,DownSamp)};
%         
%                 DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/Fs);
%                 TempMap1=cwt(TempSignal,scales,'cmor1.5-2');
%                 TempMap=abs(TempMap1);
%                 AnglMap=angle(TempMap1);
%                 DownS=(downsample(TempMap',DownSamp))';
%                 DownSA=(downsample(AnglMap',DownSamp))';
%                 [DownSampled2D,Vector1{count}]=FrequencyMap(DownS,'Radial',0);
%                 [DownSampled2D,Vector11{count}]=FrequencyMap(DownSA,'Radial',0);
%                 [DownSampled2D,Vector2{count}]=FrequencyMap(DownS,'Spiral',0);
%                 [DownSampled2D,Vector22{count}]=FrequencyMap(DownSA,'Spiral',0);
%     
%                 TF(count)={DownS(round(linspace(1,255,23)),:)}; 
%                 TF1(count)={DownSA(round(linspace(1,255,23)),:)};
%                 
%     
%             end
% 
%             Input=TF; 
%             Input1=TF1;
% 
%             clear BipolarSignal TF TF1 TempSignal TempR TempMap1 TempMap DownS DownSA DownSampled2D
% 
%             Row=numel(DesiredFrequency(round(linspace(1,255,23))));
%             NewInput=zeros(size(Input{1}));
%             NewInput1=zeros(size(Input1{1}));
% 
%             DownFiltered=zeros(size(Input{1}));
%             DownFiltered1=zeros(size(Input1{1}));
%             DownFilteredRaw=cell(1,LoopNumber);
%             
%             Ampl=zeros(numel(Input),Row*size(NewInput,2));
%             AmplLowPass=zeros(numel(Input),Row*size(NewInput,2));
%             Phas=zeros(numel(Input),Row*size(NewInput,2));
%             PhasLowPass=zeros(numel(Input),Row*size(NewInput,2));
%             
%             RadAmpl=zeros(LoopNumber,numel(Vector1{1}));
%             RadAmplLowPass=zeros(LoopNumber,numel(Vector1{1}));
%             RadPhas=zeros(LoopNumber,numel(Vector1{1}));
%             RadPhasLowPass=zeros(LoopNumber,numel(Vector1{1}));
%             
%             SpiAmpl=zeros(LoopNumber,numel(Vector2{1}));
%             SpiAmplLowPass=zeros(LoopNumber,numel(Vector2{1}));
%             SpiPhas=zeros(LoopNumber,numel(Vector2{1}));
%             SpiPhasLowPass=zeros(LoopNumber,numel(Vector2{1}));
%             
%             [s1,s2]=size(NewInput);
%             [num,den]=butter(10,0.2);
% 
%             for z=1:numel(Input)
%     
%                 TempInput=Input{z};
%                 TempInput1=Input1{z};
%                 DownFilteredRaw{z}=filter(num,den,DownRawSignal{z});
%                 
%                 for i=1:Row
%      
%                    NewInput(i,:)=TempInput(i,:);
%                    DownFiltered(i,:)=filter(num,den,NewInput(i,:));
%                    NewInput1(i,:)=TempInput1(i,:);
%                    DownFiltered1(i,:)=filter(num,den,NewInput1(i,:));
%                        
%                 end
%                 
%                 Ampl(z,:)=reshape(NewInput',1,s1*s2);        
%                 AmplLowPass(z,:)=reshape(DownFiltered',1,s1*s2); 
%                 Phas(z,:)=reshape(NewInput1',1,s1*s2);        
%                 PhasLowPass(z,:)=reshape(DownFiltered1',1,s1*s2);
%                 
%                 RadAmpl(z,:)=Vector1{z};
%                 RadAmplLowPass(z,:)=filter(num,den,Vector1{z});
%                 RadPhas(z,:)=Vector11{z};
%                 RadPhasLowPass(z,:)=filter(num,den,Vector11{z});
%                 
%                 SpiAmpl(z,:)=Vector2{z};
%                 SpiAmplLowPass(z,:)=filter(num,den,Vector2{z});
%                 SpiPhas(z,:)=Vector22{z};
%                 SpiPhasLowPass(z,:)=filter(num,den,Vector22{z});
%     
%             end
% 
%             if strcmp(side,'Left')
%                SID='L';
%             else 
%                SID='R';
%             end
%             
%             save(['C:\Users\Lab User\Desktop\Simulate3\', name, '-', target, '-', 'CH', num2str(ch), SID],...
%                 'DownRawSignal','DownFilteredRaw','Ampl','AmplLowPass','Phas','PhasLowPass','RadAmpl',...
%                 'RadAmplLowPass','RadPhas','RadPhasLowPass','SpiAmpl',...
%                 'SpiAmplLowPass','SpiPhas','SpiPhasLowPass')
% 
%          end
%       end
%    end
%    
% end
% 
% 
% 
% 
% 
% % Last Update: Dec. 12, 2015

%% Load DBS Data

clc
clear all
close all
warning off

disp('Please set the parameters:')

% prompt='1. Choose the number of K-folds for cross validation approach, (K>=2):';
% kfold=input(prompt);

kfold=8;
if kfold==1; disp('please set "kfold">1 !!!'); return; end

% prompt='2. Choose the number of classes (2 - 5): ';
% NoE=input(prompt);

% prompt='3. SubjectDependent/SubjectIndependent:';
% mode=input(prompt);
   
DownSamp=2400;

InpPool={'O14AK','O14AJ','A15K','J15M'};
Modality={'Bidirectional','Whole(OldVersion)','Left','Right'};
EventPool={'Button','Audio','Random','Reach','Video'};
DirPoolLeft={'CH1L','CH2L','CH3L'};
DirPoolRight={'CH1R','CH2R','CH3R'};

for b1=1:numel(InpPool)
    
    InpP=InpPool{b1};
    disp('Loading Dataset ...')
    
    for NoE=2:5
        
    for b2=1:NoE
            
        EventP=EventPool{b2};
        BlockLeft=[];
        BlockRight=[];
        
        for b3=1:3
            
           DirPL=DirPoolLeft{b3};          
           name=[InpP,'-',EventP,'-',DirPL];
           load(name);
           clear Ampl DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockLeft=[BlockLeft;AmplLowPass];
           clear AmplLowPass
            
        end

        for b4=1:3
            
           DirPR=DirPoolRight{b4};          
           name=[InpP,'-',EventP,'-',DirPR];
           load(name);
           clear Ampl DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockRight=[BlockRight;AmplLowPass];
           clear AmplLowPass
            
        end
        
        if b2==1;  ButtonSampleL=(downsample(BlockLeft',DownSamp))'; ButtonSampleR=(downsample(BlockRight',DownSamp))'; ...
           ButtonSampleT=[ButtonSampleL;ButtonSampleR]; name1='Button'; 
           ButtonSampleT=ButtonSampleT(1:2:end,:); 
           
        elseif b2==2; AudioSampleL=(downsample(BlockLeft',DownSamp))'; AudioSampleR=(downsample(BlockRight',DownSamp))'; ...
           AudioSampleT=[AudioSampleL;AudioSampleR]; name2='Audio'; 
           AudioSampleT=AudioSampleT(1:2:end,:);
           
        elseif b2==3; RandomSampleL=(downsample(BlockLeft',DownSamp))'; RandomSampleR=(downsample(BlockRight',DownSamp))';  ...
           RandomSampleT=[RandomSampleL;RandomSampleR]; name3='Random'; 
           RandomSampleT=RandomSampleT(1:2:end,:);
           
        elseif b2==4; ReachSampleL=(downsample(BlockLeft',DownSamp))'; ReachSampleR=(downsample(BlockRight',DownSamp))';  ...
           ReachSampleT=[ReachSampleL;ReachSampleR]; name4='Reach'; 
           ReachSampleT=ReachSampleT(1:2:end,:);
           
        else  VideoSampleL=(downsample(BlockLeft',DownSamp))'; VideoSampleR=(downsample(BlockRight',DownSamp))';  ...
           VideoSampleT=[VideoSampleL;VideoSampleR]; name5='Video'; 
           VideoSampleT=VideoSampleT(1:2:end,:);
            
        end
            
        clear BlockLeft BlockRight
        
    end 
    
    for b0=1:4
    
        Moda=Modality{b0};
               
       % K-Fold; e.g., K=5;
       if strcmp(Moda,'Whole(OldVersion)')
           L1=size(ButtonSampleT,1);
           L2=size(AudioSampleT,1);
           if NoE==3; L3=size(RandomSampleT,1);end
           if NoE==4; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1);end
           if NoE==5; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1); L5=size(VideoSampleT,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
           
       else
           L1=size(ButtonSampleL,1);
           L2=size(AudioSampleL,1);
           if NoE==3; L3=size(RandomSampleL,1);end
           if NoE==4; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1);end
           if NoE==5; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1); L5=size(VideoSampleL,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
       end   
       
       ToNu=SamNum-mod(SamNum,kfold); 
       TrNu=((kfold-1)/kfold)*ToNu;
       TeNu=(1/kfold)*ToNu;
       disp(['TrainingSize:', num2str(TrNu), ' TestSize:', num2str(TeNu)])
       
       if strcmp(Moda,'Whole(OldVersion)')
          S1 = ButtonSampleT(1:ToNu,:);
          S2 = AudioSampleT(1:ToNu,:);
          if NoE==3; S3 = RandomSampleT(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); S5 = VideoSampleT(1:ToNu,:); end
          SVMAccuracy=zeros(1,kfold);
          SVMConfusionMatrix=cell(1,kfold);

       elseif strcmp(Moda,'Left')
          S1 = ButtonSampleL(1:ToNu,:);
          S2 = AudioSampleL(1:ToNu,:);
          if NoE==3; S3 = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); S5 = VideoSampleL(1:ToNu,:); end
          SVMAccuracyL=zeros(1,kfold);
          SVMConfusionMatrixL=cell(1,kfold);

       elseif strcmp(Moda,'Right')
          S1 = ButtonSampleR(1:ToNu,:);
          S2 = AudioSampleR(1:ToNu,:);
          if NoE==3; S3 = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); S5 = VideoSampleR(1:ToNu,:); end
          SVMAccuracyR=zeros(1,kfold);
          SVMConfusionMatrixR=cell(1,kfold);

       else
          S1L = ButtonSampleL(1:ToNu,:);
          S2L = AudioSampleL(1:ToNu,:);
          if NoE==3; S3L = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); S5L = VideoSampleL(1:ToNu,:); end
          
          S1R = ButtonSampleR(1:ToNu,:);
          S2R = AudioSampleR(1:ToNu,:);
          if NoE==3; S3R = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); S5R = VideoSampleR(1:ToNu,:); end
          MKLAccuracy=zeros(1,kfold);
          MKLConfusionMatrix=cell(1,kfold);

       end
       
       if NoE==2
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1)]; 
       elseif NoE==3
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1)];
       elseif NoE==4
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1)];   
       else
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1);5*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1);5*ones(TeNu,1)];
       end

%% SVM & MKLInitial Prepration

      

%% K-Fold & Dimensionality Reduction SubRoutine
   
       disp('K-Fold & Dimensionality Reduction ...')

       PCAratio=0.05;
       block=TeNu;
       Reduct=zeros(1,kfold);

       for k=1:kfold 
    
           disp(['Fold Number : ', num2str(k),' out of ', num2str(kfold)])
           
           if k==1
               
                if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
        
                   train1=S1(1:(kfold-1)*block,:);
                   test1=S1((kfold-1)*block+1:end,:);
                   train2=S2(1:(kfold-1)*block,:);
                   test2=S2((kfold-1)*block+1:end,:);
                   TrainChunk=[train1;train2];
                   TestChunk=[test1;test2];
                   if NoE==3
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3];
                       TestChunk=[test1;test2;test3];
                   elseif NoE==4
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4];
                       TestChunk=[test1;test2;test3;test4];
                   elseif NoE==5 
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       train5=S5(1:(kfold-1)*block,:);
                       test5=S5((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4;train5];
                       TestChunk=[test1;test2;test3;test4;test5];
                   end

                else
                    
                   train1L=S1L(1:(kfold-1)*block,:);
                   test1L=S1L((kfold-1)*block+1:end,:);
                   train2L=S2L(1:(kfold-1)*block,:);
                   test2L=S2L((kfold-1)*block+1:end,:);
                   TrainChunkL=[train1L;train2L];
                   TestChunkL=[test1L;test2L];
                   if NoE==3
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L];
                       TestChunkL=[test1L;test2L;test3L];
                   elseif NoE==4
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L];
                       TestChunkL=[test1L;test2L;test3L;test4L];
                   elseif NoE==5
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       train5L=S5L(1:(kfold-1)*block,:);
                       test5L=S5L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                       TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                   end
                   
                   train1R=S1R(1:(kfold-1)*block,:);
                   test1R=S1R((kfold-1)*block+1:end,:);
                   train2R=S2R(1:(kfold-1)*block,:);
                   test2R=S2R((kfold-1)*block+1:end,:);
                   TrainChunkR=[train1R;train2R];
                   TestChunkR=[test1R;test2R];
                   if NoE==3
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       TrainChunkR=[train1R;train2R;train3R];
                       TestChunkR=[test1R;test2R;test3R];
                   elseif NoE==4
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R];
                       TestChunkR=[test1R;test2R;test3R;test4R];
                   elseif NoE==5
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       train5R=S5R(1:(kfold-1)*block,:);
                       test5R=S5R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                       TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                   end
                   
                end                
                
           elseif k==kfold
               
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                                           
                  train1=S1(block+1:end,:);
                  test1=S1(1:block,:);
                  train2=S2(block+1:end,:);
                  test2=S2(1:block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);
                      train5=S5(block+1:end,:);
                      test5=S5(1:block,:);                                       
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end
                  
               else
                   
                  train1L=S1L(block+1:end,:);
                  test1L=S1L(1:block,:);
                  train2L=S2L(block+1:end,:);
                  test2L=S2L(1:block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      train5L=S5L(block+1:end,:);
                      test5L=S5L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=S1R(block+1:end,:);
                  test1R=S1R(1:block,:);
                  train2R=S2R(block+1:end,:);
                  test2R=S2R(1:block,:);
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      train5R=S5R(block+1:end,:);
                      test5R=S5R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end
                
               end
                                   
        
           else
        
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                   
                  train1=[S1(1:(kfold-k)*block,:);S1((kfold-k+1)*block+1:end,:)];
                  test1=S1((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2=[S2(1:(kfold-k)*block,:);S2((kfold-k+1)*block+1:end,:)];
                  test2=S2((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);    
                      train5=[S5(1:(kfold-k)*block,:);S5((kfold-k+1)*block+1:end,:)];
                      test5=S5((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end

                  
               else
                   
                  train1L=[S1L(1:(kfold-k)*block,:);S1L((kfold-k+1)*block+1:end,:)];
                  test1L=S1L((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2L=[S2L(1:(kfold-k)*block,:);S2L((kfold-k+1)*block+1:end,:)];
                  test2L=S2L((kfold-k)*block+1:(kfold-k+1)*block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train5L=[S5L(1:(kfold-k)*block,:);S5L((kfold-k+1)*block+1:end,:)];
                      test5L=S5L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=[S1R(1:(kfold-k)*block,:);S1R((kfold-k+1)*block+1:end,:)];
                  test1R=S1R((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2R=[S2R(1:(kfold-k)*block,:);S2R((kfold-k+1)*block+1:end,:)];
                  test2R=S2R((kfold-k)*block+1:(kfold-k+1)*block,:);                                 
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);                                        
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train5R=[S5R(1:(kfold-k)*block,:);S5R((kfold-k+1)*block+1:end,:)];
                      test5R=S5R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end                  
                  
               end              
               
           end 
           
           if strcmp(Moda,'Bidirectional')
              
               if NoE==2
                   clear train1R train2R train1L train2L ...
                    test1R test2R test1L test2L 
               elseif NoE==3
                   clear train1R train2R train3R train1L train2L train3L ...
                     test1R test2R test3R test1L test2L test3L 
               elseif NoE==4
                   clear train1R train2R train3R train4R train1L train2L train3L train4L ...
                     test1R test2R test3R test4R test1L test2L test3L test4L 
               else
                   clear train1R train2R train3R train4R train5R train1L train2L train3L train4L train5L ...
                     test1R test2R test3R test4R test5R test1L test2L test3L test4L test5L
               end
                                   
             
              TrainChunkL=(TrainChunkL-min(TrainChunkL(:)))/(max(TrainChunkL(:))-min(TrainChunkL(:)));
              TestChunkL=(TestChunkL-min(TestChunkL(:)))/(max(TestChunkL(:))-min(TestChunkL(:))); 
              [TrainFeaturePoolL, TestFeaturePoolL] = NewPCA2(TrainChunkL,TestChunkL,PCAratio);
              ReductL=1-size(TrainFeaturePoolL,2)/size(TrainChunkL,2);
              
              clear TrainChunkL TestChunkL
              
              TrainChunkR=(TrainChunkR-min(TrainChunkR(:)))/(max(TrainChunkR(:))-min(TrainChunkR(:)));
              TestChunkR=(TestChunkR-min(TestChunkR(:)))/(max(TestChunkR(:))-min(TestChunkR(:)));              
              [TrainFeaturePoolR, TestFeaturePoolR] = NewPCA2(TrainChunkR,TestChunkR,PCAratio);            
              ReductR=1-size(TrainFeaturePoolR,2)/size(TrainChunkR,2);
              
              Reduct(k)=(ReductL+ReductR)/2;
              
              clear TrainChunkR TestChunkR
              
           else
              
              if NoE==2
                  clear train1 train2  ...
                   test1 test2 
              elseif NoE==3
                  clear train1 train2 train3 ...
                   test1 test2 test3
              elseif NoE==4
                  clear train1 train2 train3 train4 ...
                   test1 test2 test3 test4 
              else
                  clear train1 train2 train3 train4 train5 ...
                   test1 test2 test3 test4 test5
              end
               
              TrainChunk=(TrainChunk-min(TrainChunk(:)))/(max(TrainChunk(:))-min(TrainChunk(:)));
              TestChunk=(TestChunk-min(TestChunk(:)))/(max(TestChunk(:))-min(TestChunk(:)));              
              [TrainFeaturePool, TestFeaturePool] = NewPCA2(TrainChunk,TestChunk,PCAratio);
              Reduct(k)=1-size(TrainFeaturePool,2)/size(TrainChunk,2);
              
              clear TrainChunk TestChunk
              
           end
       
%% SVM & KLM
           
           disp('Classification Procedures ...')
           
           if ~strcmp(Moda,'Bidirectional')
              
              disp(['SVM, FoldNumber:', num2str(k), ' out of ', num2str(kfold)])
              model = svmtrain(TrainLabelPool,TrainFeaturePool,'-s 0 -c 0.0001 -t 0 ');
              [SVMPredictedLabel,accuracy,DecEst] = svmpredict(TestLabelPool, TestFeaturePool, model);
              SConfusionMatrix=zeros(NoE,NoE);
    
              clear TrainFeaturePool TestFeaturePool
              
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(SVMPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
           
              if strcmp(Moda,'Whole(OldVersion)')
                 
                 SVMAccuracy(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrix{k}=SConfusionMatrix;  
              
             elseif strcmp(Moda,'Left')
               
                 SVMAccuracyL(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixL{k}=SConfusionMatrix;  
                 
              else strcmp(Moda,'Right')
                  
                 SVMAccuracyR(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixR{k}=SConfusionMatrix;  

              end
              
           else
              
               if NoE==2; Numbe=2; elseif NoE==3; Numbe=3; elseif NoE==4; Numbe=4; else Numbe=5; end
              MKLPredictedLabel = LpMKL_MW_2f(TrainFeaturePoolL,TrainFeaturePoolR,TrainLabelPool,TestFeaturePoolL,TestFeaturePoolR,100,Numbe,2);
           
              clear TrainFeaturePoolL TrainFeaturePoolR TestFeaturePoolL TestFeaturePoolR
              
              SConfusionMatrix=zeros(NoE,NoE);
    
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(MKLPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
              
              MKLAccuracy(k)=numel(find((MKLPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
              MKLConfusionMatrix{k}=SConfusionMatrix;  

           end
           
       end
        
       %% SVM & MKL: Quality Assessment
   
       disp('Quality Assessment ...')
       
       if strcmp(Moda,'Whole(OldVersion)')
          AvAcSVM=sum(SVMAccuracy(:))/kfold;

          AvConMatSVM=0;
          for i=1:kfold
             AvConMatSVM=AvConMatSVM+SVMConfusionMatrix{i};
          end
          AvConMatSVM=round(((AvConMatSVM/kfold)/TeNu)*100);  

          [BestAccuracy, BestSVM]=max(SVMAccuracy(:));
          BestAccuracySVM=BestAccuracy;
          BestConfusionMatrixSVM=round((SVMConfusionMatrix{BestSVM}/TeNu)*100);
          
       elseif strcmp(Moda,'Left')
          AvAcSVML=sum(SVMAccuracyL(:))/kfold;

          AvConMatSVML=0;
          for i=1:kfold
             AvConMatSVML=AvConMatSVML+SVMConfusionMatrixL{i};
          end
          AvConMatSVML=round(((AvConMatSVML/kfold)/TeNu)*100);  

          [BestAccuracyL, BestSVML]=max(SVMAccuracyL(:));
          BestAccuracySVML=BestAccuracyL;
          BestConfusionMatrixSVML=round((SVMConfusionMatrixL{BestSVML}/TeNu)*100);
          
       elseif strcmp(Moda,'Right')
          AvAcSVMR=sum(SVMAccuracyR(:))/kfold;

          AvConMatSVMR=0;
          for i=1:kfold
             AvConMatSVMR=AvConMatSVMR+SVMConfusionMatrixR{i};
          end
          AvConMatSVMR=round(((AvConMatSVMR/kfold)/TeNu)*100);  

          [BestAccuracyR, BestSVMR]=max(SVMAccuracyR(:));
          BestAccuracySVMR=BestAccuracyR;
          BestConfusionMatrixSVMR=round((SVMConfusionMatrixR{BestSVMR}/TeNu)*100);
          
       else          
          AvAcMKL=sum(MKLAccuracy(:))/kfold;

          AvConMatMKL=0;
          for i=1:kfold
             AvConMatMKL=AvConMatMKL+MKLConfusionMatrix{i};
          end
          AvConMatMKL=round(((AvConMatMKL/kfold)/TeNu)*100);  

          [BestAccuracyM, BestMKL]=max(MKLAccuracy(:));
          BestAccuracyMKL=BestAccuracyM;
          BestConfusionMatrixMKL=round((MKLConfusionMatrix{BestMKL}/TeNu)*100);
          
       end      
       
       clc
       
    end 
    
    clc
    
    disp('Data Storage ...')
    
    if NoE==2
        save(['C:\Users\Lab User\Desktop\Simulate3\Usual\2tasks\', 'ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==3
        save(['C:\Users\Lab User\Desktop\Simulate3\Usual\3tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==4
        save(['C:\Users\Lab User\Desktop\Simulate3\Usual\4tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    else
        save(['C:\Users\Lab User\Desktop\Simulate3\Usual\5tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    end
        
   
    figure;      
    DimReduct=sum(Reduct(:))/kfold;
    subplot(1,2,1); XLim=1:4; bar(XLim,[AvAcSVM;AvAcSVML;AvAcSVMR;AvAcMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
        
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Average Accuracy (%)')
    ylim([0 1])

    subplot(1,2,2); XLim=1:4; bar(XLim,[BestAccuracySVM;BestAccuracySVML;BestAccuracySVMR;BestAccuracyMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Best Accuracy (Best Fold) (%)')
    ylim([0 1])
    
    
    if NoE==2
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Usual\2tasks\', InpP, '.fig']);
    elseif NoE==3
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Usual\3tasks\', InpP, '.fig']);
    elseif NoE==4
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Usual\4tasks\', InpP, '.fig']);
    else
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Usual\5tasks\', InpP, '.fig']);
    end
    close all
    clc   
    
    TempSVM(NoE)=AvAcSVM;
    TempSVML(NoE)=AvAcSVML;
    TempSVMR(NoE)=AvAcSVMR;
    TempMKL(NoE)=AvAcMKL;
    
    BTempSVM(NoE)=BestAccuracySVM;
    BTempSVML(NoE)=BestAccuracySVML;
    BTempSVMR(NoE)=BestAccuracySVMR;
    BTempMKL(NoE)=BestAccuracyMKL;
    
    end
    
    DD=[TempSVM;TempSVML;TempSVMR;TempMKL];
    figure; subplot(1,2,1); bar(DD')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Average Accuracy (%)'); title(['Average Accuracy vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    DD1=[BTempSVM;BTempSVML;BTempSVMR;BTempMKL];
    subplot(1,2,2); bar(DD1')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Accuracy of Best Fold (%)'); title(['Accuracy of Best Fold vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Usual\AccVsTas\', InpP, 'AccuracyVSTasks.fig']);
    
end
clc












% Last Update: Dec. 12, 2015

%% Load DBS Data

clc
clear all
close all
warning off

disp('Please set the parameters:')

% prompt='1. Choose the number of K-folds for cross validation approach, (K>=2):';
% kfold=input(prompt);

kfold=8;
if kfold==1; disp('please set "kfold">1 !!!'); return; end

% prompt='2. Choose the number of classes (2 - 5): ';
% NoE=input(prompt);

% prompt='3. SubjectDependent/SubjectIndependent:';
% mode=input(prompt);
   
DownSamp=200;

InpPool={'O14AK','O14AJ','A15K','J15M'};
Modality={'Bidirectional','Whole(OldVersion)','Left','Right'};
EventPool={'Button','Audio','Random','Reach','Video'};
DirPoolLeft={'CH1L','CH2L','CH3L'};
DirPoolRight={'CH1R','CH2R','CH3R'};

for b1=1:numel(InpPool)
    
    InpP=InpPool{b1};
    disp('Loading Dataset ...')
    
    for NoE=2:5
        
    for b2=1:NoE
            
        EventP=EventPool{b2};
        BlockLeft=[];
        BlockRight=[];
        
        for b3=1:3
            
           DirPL=DirPoolLeft{b3};          
           name=[InpP,'-',EventP,'-',DirPL];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
                RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockLeft=[BlockLeft;RadAmplLowPass];
           clear RadAmplLowPass
            
        end

        for b4=1:3
            
           DirPR=DirPoolRight{b4};          
           name=[InpP,'-',EventP,'-',DirPR];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockRight=[BlockRight;RadAmplLowPass];
           clear RadAmplLowPass
            
        end
        
        if b2==1;  ButtonSampleL=(downsample(BlockLeft',DownSamp))'; ButtonSampleR=(downsample(BlockRight',DownSamp))'; ...
           ButtonSampleT=[ButtonSampleL;ButtonSampleR]; name1='Button'; 
           ButtonSampleT=ButtonSampleT(1:2:end,:); 
           
        elseif b2==2; AudioSampleL=(downsample(BlockLeft',DownSamp))'; AudioSampleR=(downsample(BlockRight',DownSamp))'; ...
           AudioSampleT=[AudioSampleL;AudioSampleR]; name2='Audio'; 
           AudioSampleT=AudioSampleT(1:2:end,:);
           
        elseif b2==3; RandomSampleL=(downsample(BlockLeft',DownSamp))'; RandomSampleR=(downsample(BlockRight',DownSamp))';  ...
           RandomSampleT=[RandomSampleL;RandomSampleR]; name3='Random'; 
           RandomSampleT=RandomSampleT(1:2:end,:);
           
        elseif b2==4; ReachSampleL=(downsample(BlockLeft',DownSamp))'; ReachSampleR=(downsample(BlockRight',DownSamp))';  ...
           ReachSampleT=[ReachSampleL;ReachSampleR]; name4='Reach'; 
           ReachSampleT=ReachSampleT(1:2:end,:);
           
        else  VideoSampleL=(downsample(BlockLeft',DownSamp))'; VideoSampleR=(downsample(BlockRight',DownSamp))';  ...
           VideoSampleT=[VideoSampleL;VideoSampleR]; name5='Video'; 
           VideoSampleT=VideoSampleT(1:2:end,:);
            
        end
            
        clear BlockLeft BlockRight
        
    end 
    
    for b0=1:4
    
        Moda=Modality{b0};
               
       % K-Fold; e.g., K=5;
       if strcmp(Moda,'Whole(OldVersion)')
           L1=size(ButtonSampleT,1);
           L2=size(AudioSampleT,1);
           if NoE==3; L3=size(RandomSampleT,1);end
           if NoE==4; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1);end
           if NoE==5; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1); L5=size(VideoSampleT,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
           
       else
           L1=size(ButtonSampleL,1);
           L2=size(AudioSampleL,1);
           if NoE==3; L3=size(RandomSampleL,1);end
           if NoE==4; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1);end
           if NoE==5; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1); L5=size(VideoSampleL,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
       end   
       
       ToNu=SamNum-mod(SamNum,kfold); 
       TrNu=((kfold-1)/kfold)*ToNu;
       TeNu=(1/kfold)*ToNu;
       disp(['TrainingSize:', num2str(TrNu), ' TestSize:', num2str(TeNu)])
       
       if strcmp(Moda,'Whole(OldVersion)')
          S1 = ButtonSampleT(1:ToNu,:);
          S2 = AudioSampleT(1:ToNu,:);
          if NoE==3; S3 = RandomSampleT(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); S5 = VideoSampleT(1:ToNu,:); end
          SVMAccuracy=zeros(1,kfold);
          SVMConfusionMatrix=cell(1,kfold);

       elseif strcmp(Moda,'Left')
          S1 = ButtonSampleL(1:ToNu,:);
          S2 = AudioSampleL(1:ToNu,:);
          if NoE==3; S3 = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); S5 = VideoSampleL(1:ToNu,:); end
          SVMAccuracyL=zeros(1,kfold);
          SVMConfusionMatrixL=cell(1,kfold);

       elseif strcmp(Moda,'Right')
          S1 = ButtonSampleR(1:ToNu,:);
          S2 = AudioSampleR(1:ToNu,:);
          if NoE==3; S3 = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); S5 = VideoSampleR(1:ToNu,:); end
          SVMAccuracyR=zeros(1,kfold);
          SVMConfusionMatrixR=cell(1,kfold);

       else
          S1L = ButtonSampleL(1:ToNu,:);
          S2L = AudioSampleL(1:ToNu,:);
          if NoE==3; S3L = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); S5L = VideoSampleL(1:ToNu,:); end
          
          S1R = ButtonSampleR(1:ToNu,:);
          S2R = AudioSampleR(1:ToNu,:);
          if NoE==3; S3R = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); S5R = VideoSampleR(1:ToNu,:); end
          MKLAccuracy=zeros(1,kfold);
          MKLConfusionMatrix=cell(1,kfold);

       end
       
       if NoE==2
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1)]; 
       elseif NoE==3
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1)];
       elseif NoE==4
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1)];   
       else
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1);5*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1);5*ones(TeNu,1)];
       end

%% SVM & MKLInitial Prepration

      

%% K-Fold & Dimensionality Reduction SubRoutine
   
       disp('K-Fold & Dimensionality Reduction ...')

       PCAratio=0.05;
       block=TeNu;
       Reduct=zeros(1,kfold);

       for k=1:kfold 
    
           disp(['Fold Number : ', num2str(k),' out of ', num2str(kfold)])
           
           if k==1
               
                if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
        
                   train1=S1(1:(kfold-1)*block,:);
                   test1=S1((kfold-1)*block+1:end,:);
                   train2=S2(1:(kfold-1)*block,:);
                   test2=S2((kfold-1)*block+1:end,:);
                   TrainChunk=[train1;train2];
                   TestChunk=[test1;test2];
                   if NoE==3
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3];
                       TestChunk=[test1;test2;test3];
                   elseif NoE==4
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4];
                       TestChunk=[test1;test2;test3;test4];
                   elseif NoE==5 
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       train5=S5(1:(kfold-1)*block,:);
                       test5=S5((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4;train5];
                       TestChunk=[test1;test2;test3;test4;test5];
                   end

                else
                    
                   train1L=S1L(1:(kfold-1)*block,:);
                   test1L=S1L((kfold-1)*block+1:end,:);
                   train2L=S2L(1:(kfold-1)*block,:);
                   test2L=S2L((kfold-1)*block+1:end,:);
                   TrainChunkL=[train1L;train2L];
                   TestChunkL=[test1L;test2L];
                   if NoE==3
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L];
                       TestChunkL=[test1L;test2L;test3L];
                   elseif NoE==4
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L];
                       TestChunkL=[test1L;test2L;test3L;test4L];
                   elseif NoE==5
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       train5L=S5L(1:(kfold-1)*block,:);
                       test5L=S5L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                       TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                   end
                   
                   train1R=S1R(1:(kfold-1)*block,:);
                   test1R=S1R((kfold-1)*block+1:end,:);
                   train2R=S2R(1:(kfold-1)*block,:);
                   test2R=S2R((kfold-1)*block+1:end,:);
                   TrainChunkR=[train1R;train2R];
                   TestChunkR=[test1R;test2R];
                   if NoE==3
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       TrainChunkR=[train1R;train2R;train3R];
                       TestChunkR=[test1R;test2R;test3R];
                   elseif NoE==4
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R];
                       TestChunkR=[test1R;test2R;test3R;test4R];
                   elseif NoE==5
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       train5R=S5R(1:(kfold-1)*block,:);
                       test5R=S5R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                       TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                   end
                   
                end                
                
           elseif k==kfold
               
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                                           
                  train1=S1(block+1:end,:);
                  test1=S1(1:block,:);
                  train2=S2(block+1:end,:);
                  test2=S2(1:block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);
                      train5=S5(block+1:end,:);
                      test5=S5(1:block,:);                                       
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end
                  
               else
                   
                  train1L=S1L(block+1:end,:);
                  test1L=S1L(1:block,:);
                  train2L=S2L(block+1:end,:);
                  test2L=S2L(1:block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      train5L=S5L(block+1:end,:);
                      test5L=S5L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=S1R(block+1:end,:);
                  test1R=S1R(1:block,:);
                  train2R=S2R(block+1:end,:);
                  test2R=S2R(1:block,:);
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      train5R=S5R(block+1:end,:);
                      test5R=S5R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end
                
               end
                                   
        
           else
        
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                   
                  train1=[S1(1:(kfold-k)*block,:);S1((kfold-k+1)*block+1:end,:)];
                  test1=S1((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2=[S2(1:(kfold-k)*block,:);S2((kfold-k+1)*block+1:end,:)];
                  test2=S2((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);    
                      train5=[S5(1:(kfold-k)*block,:);S5((kfold-k+1)*block+1:end,:)];
                      test5=S5((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end

                  
               else
                   
                  train1L=[S1L(1:(kfold-k)*block,:);S1L((kfold-k+1)*block+1:end,:)];
                  test1L=S1L((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2L=[S2L(1:(kfold-k)*block,:);S2L((kfold-k+1)*block+1:end,:)];
                  test2L=S2L((kfold-k)*block+1:(kfold-k+1)*block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train5L=[S5L(1:(kfold-k)*block,:);S5L((kfold-k+1)*block+1:end,:)];
                      test5L=S5L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=[S1R(1:(kfold-k)*block,:);S1R((kfold-k+1)*block+1:end,:)];
                  test1R=S1R((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2R=[S2R(1:(kfold-k)*block,:);S2R((kfold-k+1)*block+1:end,:)];
                  test2R=S2R((kfold-k)*block+1:(kfold-k+1)*block,:);                                 
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);                                        
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train5R=[S5R(1:(kfold-k)*block,:);S5R((kfold-k+1)*block+1:end,:)];
                      test5R=S5R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end                  
                  
               end              
               
           end 
           
           if strcmp(Moda,'Bidirectional')
              
               if NoE==2
                   clear train1R train2R train1L train2L ...
                    test1R test2R test1L test2L 
               elseif NoE==3
                   clear train1R train2R train3R train1L train2L train3L ...
                     test1R test2R test3R test1L test2L test3L 
               elseif NoE==4
                   clear train1R train2R train3R train4R train1L train2L train3L train4L ...
                     test1R test2R test3R test4R test1L test2L test3L test4L 
               else
                   clear train1R train2R train3R train4R train5R train1L train2L train3L train4L train5L ...
                     test1R test2R test3R test4R test5R test1L test2L test3L test4L test5L
               end
                                   
             
              TrainChunkL=(TrainChunkL-min(TrainChunkL(:)))/(max(TrainChunkL(:))-min(TrainChunkL(:)));
              TestChunkL=(TestChunkL-min(TestChunkL(:)))/(max(TestChunkL(:))-min(TestChunkL(:))); 
              [TrainFeaturePoolL, TestFeaturePoolL] = NewPCA2(TrainChunkL,TestChunkL,PCAratio);
              ReductL=1-size(TrainFeaturePoolL,2)/size(TrainChunkL,2);
              
              clear TrainChunkL TestChunkL
              
              TrainChunkR=(TrainChunkR-min(TrainChunkR(:)))/(max(TrainChunkR(:))-min(TrainChunkR(:)));
              TestChunkR=(TestChunkR-min(TestChunkR(:)))/(max(TestChunkR(:))-min(TestChunkR(:)));              
              [TrainFeaturePoolR, TestFeaturePoolR] = NewPCA2(TrainChunkR,TestChunkR,PCAratio);            
              ReductR=1-size(TrainFeaturePoolR,2)/size(TrainChunkR,2);
              
              Reduct(k)=(ReductL+ReductR)/2;
              
              clear TrainChunkR TestChunkR
              
           else
              
              if NoE==2
                  clear train1 train2  ...
                   test1 test2 
              elseif NoE==3
                  clear train1 train2 train3 ...
                   test1 test2 test3
              elseif NoE==4
                  clear train1 train2 train3 train4 ...
                   test1 test2 test3 test4 
              else
                  clear train1 train2 train3 train4 train5 ...
                   test1 test2 test3 test4 test5
              end
               
              TrainChunk=(TrainChunk-min(TrainChunk(:)))/(max(TrainChunk(:))-min(TrainChunk(:)));
              TestChunk=(TestChunk-min(TestChunk(:)))/(max(TestChunk(:))-min(TestChunk(:)));              
              [TrainFeaturePool, TestFeaturePool] = NewPCA2(TrainChunk,TestChunk,PCAratio);
              Reduct(k)=1-size(TrainFeaturePool,2)/size(TrainChunk,2);
              
              clear TrainChunk TestChunk
              
           end
       
%% SVM & KLM
           
           disp('Classification Procedures ...')
           
           if ~strcmp(Moda,'Bidirectional')
              
              disp(['SVM, FoldNumber:', num2str(k), ' out of ', num2str(kfold)])
              model = svmtrain(TrainLabelPool,TrainFeaturePool,'-s 0 -c 0.0001 -t 0 ');
              [SVMPredictedLabel,accuracy,DecEst] = svmpredict(TestLabelPool, TestFeaturePool, model);
              SConfusionMatrix=zeros(NoE,NoE);
    
              clear TrainFeaturePool TestFeaturePool
              
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(SVMPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
           
              if strcmp(Moda,'Whole(OldVersion)')
                 
                 SVMAccuracy(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrix{k}=SConfusionMatrix;  
              
             elseif strcmp(Moda,'Left')
               
                 SVMAccuracyL(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixL{k}=SConfusionMatrix;  
                 
              else strcmp(Moda,'Right')
                  
                 SVMAccuracyR(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixR{k}=SConfusionMatrix;  

              end
              
           else
              
               if NoE==2; Numbe=2; elseif NoE==3; Numbe=3; elseif NoE==4; Numbe=4; else Numbe=5; end
              MKLPredictedLabel = LpMKL_MW_2f(TrainFeaturePoolL,TrainFeaturePoolR,TrainLabelPool,TestFeaturePoolL,TestFeaturePoolR,100,Numbe,2);
           
              clear TrainFeaturePoolL TrainFeaturePoolR TestFeaturePoolL TestFeaturePoolR
              
              SConfusionMatrix=zeros(NoE,NoE);
    
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(MKLPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
              
              MKLAccuracy(k)=numel(find((MKLPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
              MKLConfusionMatrix{k}=SConfusionMatrix;  

           end
           
       end
        
       %% SVM & MKL: Quality Assessment
   
       disp('Quality Assessment ...')
       
       if strcmp(Moda,'Whole(OldVersion)')
          AvAcSVM=sum(SVMAccuracy(:))/kfold;

          AvConMatSVM=0;
          for i=1:kfold
             AvConMatSVM=AvConMatSVM+SVMConfusionMatrix{i};
          end
          AvConMatSVM=round(((AvConMatSVM/kfold)/TeNu)*100);  

          [BestAccuracy, BestSVM]=max(SVMAccuracy(:));
          BestAccuracySVM=BestAccuracy;
          BestConfusionMatrixSVM=round((SVMConfusionMatrix{BestSVM}/TeNu)*100);
          
       elseif strcmp(Moda,'Left')
          AvAcSVML=sum(SVMAccuracyL(:))/kfold;

          AvConMatSVML=0;
          for i=1:kfold
             AvConMatSVML=AvConMatSVML+SVMConfusionMatrixL{i};
          end
          AvConMatSVML=round(((AvConMatSVML/kfold)/TeNu)*100);  

          [BestAccuracyL, BestSVML]=max(SVMAccuracyL(:));
          BestAccuracySVML=BestAccuracyL;
          BestConfusionMatrixSVML=round((SVMConfusionMatrixL{BestSVML}/TeNu)*100);
          
       elseif strcmp(Moda,'Right')
          AvAcSVMR=sum(SVMAccuracyR(:))/kfold;

          AvConMatSVMR=0;
          for i=1:kfold
             AvConMatSVMR=AvConMatSVMR+SVMConfusionMatrixR{i};
          end
          AvConMatSVMR=round(((AvConMatSVMR/kfold)/TeNu)*100);  

          [BestAccuracyR, BestSVMR]=max(SVMAccuracyR(:));
          BestAccuracySVMR=BestAccuracyR;
          BestConfusionMatrixSVMR=round((SVMConfusionMatrixR{BestSVMR}/TeNu)*100);
          
       else          
          AvAcMKL=sum(MKLAccuracy(:))/kfold;

          AvConMatMKL=0;
          for i=1:kfold
             AvConMatMKL=AvConMatMKL+MKLConfusionMatrix{i};
          end
          AvConMatMKL=round(((AvConMatMKL/kfold)/TeNu)*100);  

          [BestAccuracyM, BestMKL]=max(MKLAccuracy(:));
          BestAccuracyMKL=BestAccuracyM;
          BestConfusionMatrixMKL=round((MKLConfusionMatrix{BestMKL}/TeNu)*100);
          
       end      
       
       clc
       
    end 
    
    clc
    
    disp('Data Storage ...')
    
    if NoE==2
        save(['C:\Users\Lab User\Desktop\Simulate3\Radial\2tasks\', 'ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==3
        save(['C:\Users\Lab User\Desktop\Simulate3\Radial\3tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==4
        save(['C:\Users\Lab User\Desktop\Simulate3\Radial\4tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    else
        save(['C:\Users\Lab User\Desktop\Simulate3\Radial\5tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    end
        
   
    figure;      
    DimReduct=sum(Reduct(:))/kfold;
    subplot(1,2,1); XLim=1:4; bar(XLim,[AvAcSVM;AvAcSVML;AvAcSVMR;AvAcMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
        
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Average Accuracy (%)')
    ylim([0 1])

    subplot(1,2,2); XLim=1:4; bar(XLim,[BestAccuracySVM;BestAccuracySVML;BestAccuracySVMR;BestAccuracyMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Best Accuracy (Best Fold) (%)')
    ylim([0 1])
    
    
    if NoE==2
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Radial\2tasks\', InpP, '.fig']);
    elseif NoE==3
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Radial\3tasks\', InpP, '.fig']);
    elseif NoE==4
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Radial\4tasks\', InpP, '.fig']);
    else
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Radial\5tasks\', InpP, '.fig']);
    end
    close all
    clc   
    
    TempSVM(NoE)=AvAcSVM;
    TempSVML(NoE)=AvAcSVML;
    TempSVMR(NoE)=AvAcSVMR;
    TempMKL(NoE)=AvAcMKL;
    
    BTempSVM(NoE)=BestAccuracySVM;
    BTempSVML(NoE)=BestAccuracySVML;
    BTempSVMR(NoE)=BestAccuracySVMR;
    BTempMKL(NoE)=BestAccuracyMKL;
    
    end
    
    DD=[TempSVM;TempSVML;TempSVMR;TempMKL];
    figure; subplot(1,2,1); bar(DD')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Average Accuracy (%)'); title(['Average Accuracy vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    DD1=[BTempSVM;BTempSVML;BTempSVMR;BTempMKL];
    subplot(1,2,2); bar(DD1')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Accuracy of Best Fold (%)'); title(['Accuracy of Best Fold vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Radial\AccVsTas\', InpP, 'AccuracyVSTasks.fig']);
    
end
clc












% Last Update: Dec. 12, 2015

%% Load DBS Data

clc
clear all
close all
warning off

disp('Please set the parameters:')

% prompt='1. Choose the number of K-folds for cross validation approach, (K>=2):';
% kfold=input(prompt);

kfold=8;
if kfold==1; disp('please set "kfold">1 !!!'); return; end

% prompt='2. Choose the number of classes (2 - 5): ';
% NoE=input(prompt);

% prompt='3. SubjectDependent/SubjectIndependent:';
% mode=input(prompt);
   
DownSamp=200;

InpPool={'O14AK','O14AJ','A15K','J15M'};
Modality={'Bidirectional','Whole(OldVersion)','Left','Right'};
EventPool={'Button','Audio','Random','Reach','Video'};
DirPoolLeft={'CH1L','CH2L','CH3L'};
DirPoolRight={'CH1R','CH2R','CH3R'};

for b1=1:numel(InpPool)
    
    InpP=InpPool{b1};
    disp('Loading Dataset ...')
    
    for NoE=2:5
        
    for b2=1:NoE
            
        EventP=EventPool{b2};
        BlockLeft=[];
        BlockRight=[];
        
        for b3=1:3
            
           DirPL=DirPoolLeft{b3};          
           name=[InpP,'-',EventP,'-',DirPL];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiPhas SpiPhasLowPass
           BlockLeft=[BlockLeft; SpiAmplLowPass];
           clear  SpiAmplLowPass
            
        end

        for b4=1:3
            
           DirPR=DirPoolRight{b4};          
           name=[InpP,'-',EventP,'-',DirPR];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiPhas SpiPhasLowPass
           BlockRight=[BlockRight; SpiAmplLowPass];
           clear SpiAmplLowPass
            
        end
        
        if b2==1;  ButtonSampleL=(downsample(BlockLeft',DownSamp))'; ButtonSampleR=(downsample(BlockRight',DownSamp))'; ...
           ButtonSampleT=[ButtonSampleL;ButtonSampleR]; name1='Button'; 
           ButtonSampleT=ButtonSampleT(1:2:end,:); 
           
        elseif b2==2; AudioSampleL=(downsample(BlockLeft',DownSamp))'; AudioSampleR=(downsample(BlockRight',DownSamp))'; ...
           AudioSampleT=[AudioSampleL;AudioSampleR]; name2='Audio'; 
           AudioSampleT=AudioSampleT(1:2:end,:);
           
        elseif b2==3; RandomSampleL=(downsample(BlockLeft',DownSamp))'; RandomSampleR=(downsample(BlockRight',DownSamp))';  ...
           RandomSampleT=[RandomSampleL;RandomSampleR]; name3='Random'; 
           RandomSampleT=RandomSampleT(1:2:end,:);
           
        elseif b2==4; ReachSampleL=(downsample(BlockLeft',DownSamp))'; ReachSampleR=(downsample(BlockRight',DownSamp))';  ...
           ReachSampleT=[ReachSampleL;ReachSampleR]; name4='Reach'; 
           ReachSampleT=ReachSampleT(1:2:end,:);
           
        else  VideoSampleL=(downsample(BlockLeft',DownSamp))'; VideoSampleR=(downsample(BlockRight',DownSamp))';  ...
           VideoSampleT=[VideoSampleL;VideoSampleR]; name5='Video'; 
           VideoSampleT=VideoSampleT(1:2:end,:);
            
        end
            
        clear BlockLeft BlockRight
        
    end 
    
    for b0=1:4
    
        Moda=Modality{b0};
               
       % K-Fold; e.g., K=5;
       if strcmp(Moda,'Whole(OldVersion)')
           L1=size(ButtonSampleT,1);
           L2=size(AudioSampleT,1);
           if NoE==3; L3=size(RandomSampleT,1);end
           if NoE==4; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1);end
           if NoE==5; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1); L5=size(VideoSampleT,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
           
       else
           L1=size(ButtonSampleL,1);
           L2=size(AudioSampleL,1);
           if NoE==3; L3=size(RandomSampleL,1);end
           if NoE==4; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1);end
           if NoE==5; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1); L5=size(VideoSampleL,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
       end   
       
       ToNu=SamNum-mod(SamNum,kfold); 
       TrNu=((kfold-1)/kfold)*ToNu;
       TeNu=(1/kfold)*ToNu;
       disp(['TrainingSize:', num2str(TrNu), ' TestSize:', num2str(TeNu)])
       
       if strcmp(Moda,'Whole(OldVersion)')
          S1 = ButtonSampleT(1:ToNu,:);
          S2 = AudioSampleT(1:ToNu,:);
          if NoE==3; S3 = RandomSampleT(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); S5 = VideoSampleT(1:ToNu,:); end
          SVMAccuracy=zeros(1,kfold);
          SVMConfusionMatrix=cell(1,kfold);

       elseif strcmp(Moda,'Left')
          S1 = ButtonSampleL(1:ToNu,:);
          S2 = AudioSampleL(1:ToNu,:);
          if NoE==3; S3 = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); S5 = VideoSampleL(1:ToNu,:); end
          SVMAccuracyL=zeros(1,kfold);
          SVMConfusionMatrixL=cell(1,kfold);

       elseif strcmp(Moda,'Right')
          S1 = ButtonSampleR(1:ToNu,:);
          S2 = AudioSampleR(1:ToNu,:);
          if NoE==3; S3 = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); S5 = VideoSampleR(1:ToNu,:); end
          SVMAccuracyR=zeros(1,kfold);
          SVMConfusionMatrixR=cell(1,kfold);

       else
          S1L = ButtonSampleL(1:ToNu,:);
          S2L = AudioSampleL(1:ToNu,:);
          if NoE==3; S3L = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); S5L = VideoSampleL(1:ToNu,:); end
          
          S1R = ButtonSampleR(1:ToNu,:);
          S2R = AudioSampleR(1:ToNu,:);
          if NoE==3; S3R = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); S5R = VideoSampleR(1:ToNu,:); end
          MKLAccuracy=zeros(1,kfold);
          MKLConfusionMatrix=cell(1,kfold);

       end
       
       if NoE==2
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1)]; 
       elseif NoE==3
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1)];
       elseif NoE==4
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1)];   
       else
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1);5*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1);5*ones(TeNu,1)];
       end

%% SVM & MKLInitial Prepration

      

%% K-Fold & Dimensionality Reduction SubRoutine
   
       disp('K-Fold & Dimensionality Reduction ...')

       PCAratio=0.05;
       block=TeNu;
       Reduct=zeros(1,kfold);

       for k=1:kfold 
    
           disp(['Fold Number : ', num2str(k),' out of ', num2str(kfold)])
           
           if k==1
               
                if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
        
                   train1=S1(1:(kfold-1)*block,:);
                   test1=S1((kfold-1)*block+1:end,:);
                   train2=S2(1:(kfold-1)*block,:);
                   test2=S2((kfold-1)*block+1:end,:);
                   TrainChunk=[train1;train2];
                   TestChunk=[test1;test2];
                   if NoE==3
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3];
                       TestChunk=[test1;test2;test3];
                   elseif NoE==4
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4];
                       TestChunk=[test1;test2;test3;test4];
                   elseif NoE==5 
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       train5=S5(1:(kfold-1)*block,:);
                       test5=S5((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4;train5];
                       TestChunk=[test1;test2;test3;test4;test5];
                   end

                else
                    
                   train1L=S1L(1:(kfold-1)*block,:);
                   test1L=S1L((kfold-1)*block+1:end,:);
                   train2L=S2L(1:(kfold-1)*block,:);
                   test2L=S2L((kfold-1)*block+1:end,:);
                   TrainChunkL=[train1L;train2L];
                   TestChunkL=[test1L;test2L];
                   if NoE==3
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L];
                       TestChunkL=[test1L;test2L;test3L];
                   elseif NoE==4
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L];
                       TestChunkL=[test1L;test2L;test3L;test4L];
                   elseif NoE==5
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       train5L=S5L(1:(kfold-1)*block,:);
                       test5L=S5L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                       TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                   end
                   
                   train1R=S1R(1:(kfold-1)*block,:);
                   test1R=S1R((kfold-1)*block+1:end,:);
                   train2R=S2R(1:(kfold-1)*block,:);
                   test2R=S2R((kfold-1)*block+1:end,:);
                   TrainChunkR=[train1R;train2R];
                   TestChunkR=[test1R;test2R];
                   if NoE==3
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       TrainChunkR=[train1R;train2R;train3R];
                       TestChunkR=[test1R;test2R;test3R];
                   elseif NoE==4
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R];
                       TestChunkR=[test1R;test2R;test3R;test4R];
                   elseif NoE==5
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       train5R=S5R(1:(kfold-1)*block,:);
                       test5R=S5R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                       TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                   end
                   
                end                
                
           elseif k==kfold
               
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                                           
                  train1=S1(block+1:end,:);
                  test1=S1(1:block,:);
                  train2=S2(block+1:end,:);
                  test2=S2(1:block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);
                      train5=S5(block+1:end,:);
                      test5=S5(1:block,:);                                       
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end
                  
               else
                   
                  train1L=S1L(block+1:end,:);
                  test1L=S1L(1:block,:);
                  train2L=S2L(block+1:end,:);
                  test2L=S2L(1:block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      train5L=S5L(block+1:end,:);
                      test5L=S5L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=S1R(block+1:end,:);
                  test1R=S1R(1:block,:);
                  train2R=S2R(block+1:end,:);
                  test2R=S2R(1:block,:);
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      train5R=S5R(block+1:end,:);
                      test5R=S5R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end
                
               end
                                   
        
           else
        
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                   
                  train1=[S1(1:(kfold-k)*block,:);S1((kfold-k+1)*block+1:end,:)];
                  test1=S1((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2=[S2(1:(kfold-k)*block,:);S2((kfold-k+1)*block+1:end,:)];
                  test2=S2((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);    
                      train5=[S5(1:(kfold-k)*block,:);S5((kfold-k+1)*block+1:end,:)];
                      test5=S5((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end

                  
               else
                   
                  train1L=[S1L(1:(kfold-k)*block,:);S1L((kfold-k+1)*block+1:end,:)];
                  test1L=S1L((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2L=[S2L(1:(kfold-k)*block,:);S2L((kfold-k+1)*block+1:end,:)];
                  test2L=S2L((kfold-k)*block+1:(kfold-k+1)*block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train5L=[S5L(1:(kfold-k)*block,:);S5L((kfold-k+1)*block+1:end,:)];
                      test5L=S5L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=[S1R(1:(kfold-k)*block,:);S1R((kfold-k+1)*block+1:end,:)];
                  test1R=S1R((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2R=[S2R(1:(kfold-k)*block,:);S2R((kfold-k+1)*block+1:end,:)];
                  test2R=S2R((kfold-k)*block+1:(kfold-k+1)*block,:);                                 
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);                                        
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train5R=[S5R(1:(kfold-k)*block,:);S5R((kfold-k+1)*block+1:end,:)];
                      test5R=S5R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end                  
                  
               end              
               
           end 
           
           if strcmp(Moda,'Bidirectional')
              
               if NoE==2
                   clear train1R train2R train1L train2L ...
                    test1R test2R test1L test2L 
               elseif NoE==3
                   clear train1R train2R train3R train1L train2L train3L ...
                     test1R test2R test3R test1L test2L test3L 
               elseif NoE==4
                   clear train1R train2R train3R train4R train1L train2L train3L train4L ...
                     test1R test2R test3R test4R test1L test2L test3L test4L 
               else
                   clear train1R train2R train3R train4R train5R train1L train2L train3L train4L train5L ...
                     test1R test2R test3R test4R test5R test1L test2L test3L test4L test5L
               end
                                   
             
              TrainChunkL=(TrainChunkL-min(TrainChunkL(:)))/(max(TrainChunkL(:))-min(TrainChunkL(:)));
              TestChunkL=(TestChunkL-min(TestChunkL(:)))/(max(TestChunkL(:))-min(TestChunkL(:))); 
              [TrainFeaturePoolL, TestFeaturePoolL] = NewPCA2(TrainChunkL,TestChunkL,PCAratio);
              ReductL=1-size(TrainFeaturePoolL,2)/size(TrainChunkL,2);
              
              clear TrainChunkL TestChunkL
              
              TrainChunkR=(TrainChunkR-min(TrainChunkR(:)))/(max(TrainChunkR(:))-min(TrainChunkR(:)));
              TestChunkR=(TestChunkR-min(TestChunkR(:)))/(max(TestChunkR(:))-min(TestChunkR(:)));              
              [TrainFeaturePoolR, TestFeaturePoolR] = NewPCA2(TrainChunkR,TestChunkR,PCAratio);            
              ReductR=1-size(TrainFeaturePoolR,2)/size(TrainChunkR,2);
              
              Reduct(k)=(ReductL+ReductR)/2;
              
              clear TrainChunkR TestChunkR
              
           else
              
              if NoE==2
                  clear train1 train2  ...
                   test1 test2 
              elseif NoE==3
                  clear train1 train2 train3 ...
                   test1 test2 test3
              elseif NoE==4
                  clear train1 train2 train3 train4 ...
                   test1 test2 test3 test4 
              else
                  clear train1 train2 train3 train4 train5 ...
                   test1 test2 test3 test4 test5
              end
               
              TrainChunk=(TrainChunk-min(TrainChunk(:)))/(max(TrainChunk(:))-min(TrainChunk(:)));
              TestChunk=(TestChunk-min(TestChunk(:)))/(max(TestChunk(:))-min(TestChunk(:)));              
              [TrainFeaturePool, TestFeaturePool] = NewPCA2(TrainChunk,TestChunk,PCAratio);
              Reduct(k)=1-size(TrainFeaturePool,2)/size(TrainChunk,2);
              
              clear TrainChunk TestChunk
              
           end
       
%% SVM & KLM
           
           disp('Classification Procedures ...')
           
           if ~strcmp(Moda,'Bidirectional')
              
              disp(['SVM, FoldNumber:', num2str(k), ' out of ', num2str(kfold)])
              model = svmtrain(TrainLabelPool,TrainFeaturePool,'-s 0 -c 0.0001 -t 0 ');
              [SVMPredictedLabel,accuracy,DecEst] = svmpredict(TestLabelPool, TestFeaturePool, model);
              SConfusionMatrix=zeros(NoE,NoE);
    
              clear TrainFeaturePool TestFeaturePool
              
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(SVMPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
           
              if strcmp(Moda,'Whole(OldVersion)')
                 
                 SVMAccuracy(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrix{k}=SConfusionMatrix;  
              
             elseif strcmp(Moda,'Left')
               
                 SVMAccuracyL(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixL{k}=SConfusionMatrix;  
                 
              else strcmp(Moda,'Right')
                  
                 SVMAccuracyR(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixR{k}=SConfusionMatrix;  

              end
              
           else
              
               if NoE==2; Numbe=2; elseif NoE==3; Numbe=3; elseif NoE==4; Numbe=4; else Numbe=5; end
              MKLPredictedLabel = LpMKL_MW_2f(TrainFeaturePoolL,TrainFeaturePoolR,TrainLabelPool,TestFeaturePoolL,TestFeaturePoolR,100,Numbe,2);
           
              clear TrainFeaturePoolL TrainFeaturePoolR TestFeaturePoolL TestFeaturePoolR
              
              SConfusionMatrix=zeros(NoE,NoE);
    
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(MKLPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
              
              MKLAccuracy(k)=numel(find((MKLPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
              MKLConfusionMatrix{k}=SConfusionMatrix;  

           end
           
       end
        
       %% SVM & MKL: Quality Assessment
   
       disp('Quality Assessment ...')
       
       if strcmp(Moda,'Whole(OldVersion)')
          AvAcSVM=sum(SVMAccuracy(:))/kfold;

          AvConMatSVM=0;
          for i=1:kfold
             AvConMatSVM=AvConMatSVM+SVMConfusionMatrix{i};
          end
          AvConMatSVM=round(((AvConMatSVM/kfold)/TeNu)*100);  

          [BestAccuracy, BestSVM]=max(SVMAccuracy(:));
          BestAccuracySVM=BestAccuracy;
          BestConfusionMatrixSVM=round((SVMConfusionMatrix{BestSVM}/TeNu)*100);
          
       elseif strcmp(Moda,'Left')
          AvAcSVML=sum(SVMAccuracyL(:))/kfold;

          AvConMatSVML=0;
          for i=1:kfold
             AvConMatSVML=AvConMatSVML+SVMConfusionMatrixL{i};
          end
          AvConMatSVML=round(((AvConMatSVML/kfold)/TeNu)*100);  

          [BestAccuracyL, BestSVML]=max(SVMAccuracyL(:));
          BestAccuracySVML=BestAccuracyL;
          BestConfusionMatrixSVML=round((SVMConfusionMatrixL{BestSVML}/TeNu)*100);
          
       elseif strcmp(Moda,'Right')
          AvAcSVMR=sum(SVMAccuracyR(:))/kfold;

          AvConMatSVMR=0;
          for i=1:kfold
             AvConMatSVMR=AvConMatSVMR+SVMConfusionMatrixR{i};
          end
          AvConMatSVMR=round(((AvConMatSVMR/kfold)/TeNu)*100);  

          [BestAccuracyR, BestSVMR]=max(SVMAccuracyR(:));
          BestAccuracySVMR=BestAccuracyR;
          BestConfusionMatrixSVMR=round((SVMConfusionMatrixR{BestSVMR}/TeNu)*100);
          
       else          
          AvAcMKL=sum(MKLAccuracy(:))/kfold;

          AvConMatMKL=0;
          for i=1:kfold
             AvConMatMKL=AvConMatMKL+MKLConfusionMatrix{i};
          end
          AvConMatMKL=round(((AvConMatMKL/kfold)/TeNu)*100);  

          [BestAccuracyM, BestMKL]=max(MKLAccuracy(:));
          BestAccuracyMKL=BestAccuracyM;
          BestConfusionMatrixMKL=round((MKLConfusionMatrix{BestMKL}/TeNu)*100);
          
       end      
       
       clc
       
    end 
    
    clc
    
    disp('Data Storage ...')
    
    if NoE==2
        save(['C:\Users\Lab User\Desktop\Simulate3\Spiral\2tasks\', 'ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==3
        save(['C:\Users\Lab User\Desktop\Simulate3\Spiral\3tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==4
        save(['C:\Users\Lab User\Desktop\Simulate3\Spiral\4tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    else
        save(['C:\Users\Lab User\Desktop\Simulate3\Spiral\5tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    end
        
   
    figure;      
    DimReduct=sum(Reduct(:))/kfold;
    subplot(1,2,1); XLim=1:4; bar(XLim,[AvAcSVM;AvAcSVML;AvAcSVMR;AvAcMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
        
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Average Accuracy (%)')
    ylim([0 1])

    subplot(1,2,2); XLim=1:4; bar(XLim,[BestAccuracySVM;BestAccuracySVML;BestAccuracySVMR;BestAccuracyMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Best Accuracy (Best Fold) (%)')
    ylim([0 1])
    
    
    if NoE==2
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Spiral\2tasks\', InpP, '.fig']);
    elseif NoE==3
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Spiral\3tasks\', InpP, '.fig']);
    elseif NoE==4
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Spiral\4tasks\', InpP, '.fig']);
    else
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Spiral\5tasks\', InpP, '.fig']);
    end
    close all
    clc   
    
    TempSVM(NoE)=AvAcSVM;
    TempSVML(NoE)=AvAcSVML;
    TempSVMR(NoE)=AvAcSVMR;
    TempMKL(NoE)=AvAcMKL;
    
    BTempSVM(NoE)=BestAccuracySVM;
    BTempSVML(NoE)=BestAccuracySVML;
    BTempSVMR(NoE)=BestAccuracySVMR;
    BTempMKL(NoE)=BestAccuracyMKL;
    
    end
    
    DD=[TempSVM;TempSVML;TempSVMR;TempMKL];
    figure; subplot(1,2,1); bar(DD')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Average Accuracy (%)'); title(['Average Accuracy vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    DD1=[BTempSVM;BTempSVML;BTempSVMR;BTempMKL];
    subplot(1,2,2); bar(DD1')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Accuracy of Best Fold (%)'); title(['Accuracy of Best Fold vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\Spiral\AccVsTas\', InpP, 'AccuracyVSTasks.fig']);
    
end
clc







% Last Update: Dec. 12, 2015

%% Load DBS Data

clc
clear all
close all
warning off

disp('Please set the parameters:')

% prompt='1. Choose the number of K-folds for cross validation approach, (K>=2):';
% kfold=input(prompt);

kfold=8;
if kfold==1; disp('please set "kfold">1 !!!'); return; end

% prompt='2. Choose the number of classes (2 - 5): ';
% NoE=input(prompt);

% prompt='3. SubjectDependent/SubjectIndependent:';
% mode=input(prompt);
   
DownSamp=24000;

InpPool={'O14AK','O14AJ','A15K','J15M'};
Modality={'Bidirectional','Whole(OldVersion)','Left','Right'};
EventPool={'Button','Audio','Random','Reach','Video'};
DirPoolLeft={'CH1L','CH2L','CH3L'};
DirPoolRight={'CH1R','CH2R','CH3R'};

for b1=1:numel(InpPool)
    
    InpP=InpPool{b1};
    disp('Loading Dataset ...')
    
    for NoE=2:5
        
    for b2=1:NoE
            
        EventP=EventPool{b2};
        BlockLeft=[];
        BlockRight=[];
        
        for b3=1:3
            
           DirPL=DirPoolLeft{b3};          
           name=[InpP,'-',EventP,'-',DirPL];
           load(name);
           clear Ampl DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockLeft=[BlockLeft;AmplLowPass];
           clear AmplLowPass
            
        end

        for b4=1:3
            
           DirPR=DirPoolRight{b4};          
           name=[InpP,'-',EventP,'-',DirPR];
           load(name);
           clear Ampl DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockRight=[BlockRight;AmplLowPass];
           clear AmplLowPass
            
        end
        
        if b2==1;  ButtonSampleL=(downsample(BlockLeft',DownSamp))'; ButtonSampleR=(downsample(BlockRight',DownSamp))'; ...
           ButtonSampleT=[ButtonSampleL;ButtonSampleR]; name1='Button'; 
           ButtonSampleT=ButtonSampleT(1:2:end,:); 
           
        elseif b2==2; AudioSampleL=(downsample(BlockLeft',DownSamp))'; AudioSampleR=(downsample(BlockRight',DownSamp))'; ...
           AudioSampleT=[AudioSampleL;AudioSampleR]; name2='Audio'; 
           AudioSampleT=AudioSampleT(1:2:end,:);
           
        elseif b2==3; RandomSampleL=(downsample(BlockLeft',DownSamp))'; RandomSampleR=(downsample(BlockRight',DownSamp))';  ...
           RandomSampleT=[RandomSampleL;RandomSampleR]; name3='Random'; 
           RandomSampleT=RandomSampleT(1:2:end,:);
           
        elseif b2==4; ReachSampleL=(downsample(BlockLeft',DownSamp))'; ReachSampleR=(downsample(BlockRight',DownSamp))';  ...
           ReachSampleT=[ReachSampleL;ReachSampleR]; name4='Reach'; 
           ReachSampleT=ReachSampleT(1:2:end,:);
           
        else  VideoSampleL=(downsample(BlockLeft',DownSamp))'; VideoSampleR=(downsample(BlockRight',DownSamp))';  ...
           VideoSampleT=[VideoSampleL;VideoSampleR]; name5='Video'; 
           VideoSampleT=VideoSampleT(1:2:end,:);
            
        end
            
        clear BlockLeft BlockRight
        
    end 
    
    for b0=1:4
    
        Moda=Modality{b0};
               
       % K-Fold; e.g., K=5;
       if strcmp(Moda,'Whole(OldVersion)')
           L1=size(ButtonSampleT,1);
           L2=size(AudioSampleT,1);
           if NoE==3; L3=size(RandomSampleT,1);end
           if NoE==4; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1);end
           if NoE==5; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1); L5=size(VideoSampleT,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
           
       else
           L1=size(ButtonSampleL,1);
           L2=size(AudioSampleL,1);
           if NoE==3; L3=size(RandomSampleL,1);end
           if NoE==4; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1);end
           if NoE==5; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1); L5=size(VideoSampleL,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
       end   
       
       ToNu=SamNum-mod(SamNum,kfold); 
       TrNu=((kfold-1)/kfold)*ToNu;
       TeNu=(1/kfold)*ToNu;
       disp(['TrainingSize:', num2str(TrNu), ' TestSize:', num2str(TeNu)])
       
       if strcmp(Moda,'Whole(OldVersion)')
          S1 = ButtonSampleT(1:ToNu,:);
          S2 = AudioSampleT(1:ToNu,:);
          if NoE==3; S3 = RandomSampleT(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); S5 = VideoSampleT(1:ToNu,:); end
          SVMAccuracy=zeros(1,kfold);
          SVMConfusionMatrix=cell(1,kfold);

       elseif strcmp(Moda,'Left')
          S1 = ButtonSampleL(1:ToNu,:);
          S2 = AudioSampleL(1:ToNu,:);
          if NoE==3; S3 = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); S5 = VideoSampleL(1:ToNu,:); end
          SVMAccuracyL=zeros(1,kfold);
          SVMConfusionMatrixL=cell(1,kfold);

       elseif strcmp(Moda,'Right')
          S1 = ButtonSampleR(1:ToNu,:);
          S2 = AudioSampleR(1:ToNu,:);
          if NoE==3; S3 = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); S5 = VideoSampleR(1:ToNu,:); end
          SVMAccuracyR=zeros(1,kfold);
          SVMConfusionMatrixR=cell(1,kfold);

       else
          S1L = ButtonSampleL(1:ToNu,:);
          S2L = AudioSampleL(1:ToNu,:);
          if NoE==3; S3L = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); S5L = VideoSampleL(1:ToNu,:); end
          
          S1R = ButtonSampleR(1:ToNu,:);
          S2R = AudioSampleR(1:ToNu,:);
          if NoE==3; S3R = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); S5R = VideoSampleR(1:ToNu,:); end
          MKLAccuracy=zeros(1,kfold);
          MKLConfusionMatrix=cell(1,kfold);

       end
       
       if NoE==2
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1)]; 
       elseif NoE==3
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1)];
       elseif NoE==4
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1)];   
       else
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1);5*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1);5*ones(TeNu,1)];
       end

%% SVM & MKLInitial Prepration

      

%% K-Fold & Dimensionality Reduction SubRoutine
   
       disp('K-Fold & Dimensionality Reduction ...')

       PCAratio=0.05;
       block=TeNu;
       Reduct=zeros(1,kfold);

       for k=1:kfold 
    
           disp(['Fold Number : ', num2str(k),' out of ', num2str(kfold)])
           
           if k==1
               
                if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
        
                   train1=S1(1:(kfold-1)*block,:);
                   test1=S1((kfold-1)*block+1:end,:);
                   train2=S2(1:(kfold-1)*block,:);
                   test2=S2((kfold-1)*block+1:end,:);
                   TrainChunk=[train1;train2];
                   TestChunk=[test1;test2];
                   if NoE==3
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3];
                       TestChunk=[test1;test2;test3];
                   elseif NoE==4
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4];
                       TestChunk=[test1;test2;test3;test4];
                   elseif NoE==5 
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       train5=S5(1:(kfold-1)*block,:);
                       test5=S5((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4;train5];
                       TestChunk=[test1;test2;test3;test4;test5];
                   end

                else
                    
                   train1L=S1L(1:(kfold-1)*block,:);
                   test1L=S1L((kfold-1)*block+1:end,:);
                   train2L=S2L(1:(kfold-1)*block,:);
                   test2L=S2L((kfold-1)*block+1:end,:);
                   TrainChunkL=[train1L;train2L];
                   TestChunkL=[test1L;test2L];
                   if NoE==3
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L];
                       TestChunkL=[test1L;test2L;test3L];
                   elseif NoE==4
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L];
                       TestChunkL=[test1L;test2L;test3L;test4L];
                   elseif NoE==5
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       train5L=S5L(1:(kfold-1)*block,:);
                       test5L=S5L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                       TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                   end
                   
                   train1R=S1R(1:(kfold-1)*block,:);
                   test1R=S1R((kfold-1)*block+1:end,:);
                   train2R=S2R(1:(kfold-1)*block,:);
                   test2R=S2R((kfold-1)*block+1:end,:);
                   TrainChunkR=[train1R;train2R];
                   TestChunkR=[test1R;test2R];
                   if NoE==3
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       TrainChunkR=[train1R;train2R;train3R];
                       TestChunkR=[test1R;test2R;test3R];
                   elseif NoE==4
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R];
                       TestChunkR=[test1R;test2R;test3R;test4R];
                   elseif NoE==5
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       train5R=S5R(1:(kfold-1)*block,:);
                       test5R=S5R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                       TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                   end
                   
                end                
                
           elseif k==kfold
               
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                                           
                  train1=S1(block+1:end,:);
                  test1=S1(1:block,:);
                  train2=S2(block+1:end,:);
                  test2=S2(1:block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);
                      train5=S5(block+1:end,:);
                      test5=S5(1:block,:);                                       
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end
                  
               else
                   
                  train1L=S1L(block+1:end,:);
                  test1L=S1L(1:block,:);
                  train2L=S2L(block+1:end,:);
                  test2L=S2L(1:block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      train5L=S5L(block+1:end,:);
                      test5L=S5L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=S1R(block+1:end,:);
                  test1R=S1R(1:block,:);
                  train2R=S2R(block+1:end,:);
                  test2R=S2R(1:block,:);
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      train5R=S5R(block+1:end,:);
                      test5R=S5R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end
                
               end
                                   
        
           else
        
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                   
                  train1=[S1(1:(kfold-k)*block,:);S1((kfold-k+1)*block+1:end,:)];
                  test1=S1((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2=[S2(1:(kfold-k)*block,:);S2((kfold-k+1)*block+1:end,:)];
                  test2=S2((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);    
                      train5=[S5(1:(kfold-k)*block,:);S5((kfold-k+1)*block+1:end,:)];
                      test5=S5((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end

                  
               else
                   
                  train1L=[S1L(1:(kfold-k)*block,:);S1L((kfold-k+1)*block+1:end,:)];
                  test1L=S1L((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2L=[S2L(1:(kfold-k)*block,:);S2L((kfold-k+1)*block+1:end,:)];
                  test2L=S2L((kfold-k)*block+1:(kfold-k+1)*block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train5L=[S5L(1:(kfold-k)*block,:);S5L((kfold-k+1)*block+1:end,:)];
                      test5L=S5L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=[S1R(1:(kfold-k)*block,:);S1R((kfold-k+1)*block+1:end,:)];
                  test1R=S1R((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2R=[S2R(1:(kfold-k)*block,:);S2R((kfold-k+1)*block+1:end,:)];
                  test2R=S2R((kfold-k)*block+1:(kfold-k+1)*block,:);                                 
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);                                        
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train5R=[S5R(1:(kfold-k)*block,:);S5R((kfold-k+1)*block+1:end,:)];
                      test5R=S5R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end                  
                  
               end              
               
           end 
           
           if strcmp(Moda,'Bidirectional')
              
               if NoE==2
                   clear train1R train2R train1L train2L ...
                    test1R test2R test1L test2L 
               elseif NoE==3
                   clear train1R train2R train3R train1L train2L train3L ...
                     test1R test2R test3R test1L test2L test3L 
               elseif NoE==4
                   clear train1R train2R train3R train4R train1L train2L train3L train4L ...
                     test1R test2R test3R test4R test1L test2L test3L test4L 
               else
                   clear train1R train2R train3R train4R train5R train1L train2L train3L train4L train5L ...
                     test1R test2R test3R test4R test5R test1L test2L test3L test4L test5L
               end
                                   
             
              TrainChunkL=(TrainChunkL-min(TrainChunkL(:)))/(max(TrainChunkL(:))-min(TrainChunkL(:)));
              TestChunkL=(TestChunkL-min(TestChunkL(:)))/(max(TestChunkL(:))-min(TestChunkL(:))); 
              [TrainFeaturePoolL, TestFeaturePoolL] = NewPCA2(TrainChunkL,TestChunkL,PCAratio);
              ReductL=1-size(TrainFeaturePoolL,2)/size(TrainChunkL,2);
              
              clear TrainChunkL TestChunkL
              
              TrainChunkR=(TrainChunkR-min(TrainChunkR(:)))/(max(TrainChunkR(:))-min(TrainChunkR(:)));
              TestChunkR=(TestChunkR-min(TestChunkR(:)))/(max(TestChunkR(:))-min(TestChunkR(:)));              
              [TrainFeaturePoolR, TestFeaturePoolR] = NewPCA2(TrainChunkR,TestChunkR,PCAratio);            
              ReductR=1-size(TrainFeaturePoolR,2)/size(TrainChunkR,2);
              
              Reduct(k)=(ReductL+ReductR)/2;
              
              clear TrainChunkR TestChunkR
              
           else
              
              if NoE==2
                  clear train1 train2  ...
                   test1 test2 
              elseif NoE==3
                  clear train1 train2 train3 ...
                   test1 test2 test3
              elseif NoE==4
                  clear train1 train2 train3 train4 ...
                   test1 test2 test3 test4 
              else
                  clear train1 train2 train3 train4 train5 ...
                   test1 test2 test3 test4 test5
              end
               
              TrainChunk=(TrainChunk-min(TrainChunk(:)))/(max(TrainChunk(:))-min(TrainChunk(:)));
              TestChunk=(TestChunk-min(TestChunk(:)))/(max(TestChunk(:))-min(TestChunk(:)));              
              [TrainFeaturePool, TestFeaturePool] = NewPCA2(TrainChunk,TestChunk,PCAratio);
              Reduct(k)=1-size(TrainFeaturePool,2)/size(TrainChunk,2);
              
              clear TrainChunk TestChunk
              
           end
       
%% SVM & KLM
           
           disp('Classification Procedures ...')
           
           if ~strcmp(Moda,'Bidirectional')
              
              disp(['SVM, FoldNumber:', num2str(k), ' out of ', num2str(kfold)])
              model = svmtrain(TrainLabelPool,TrainFeaturePool,'-s 0 -c 0.0001 -t 0 ');
              [SVMPredictedLabel,accuracy,DecEst] = svmpredict(TestLabelPool, TestFeaturePool, model);
              SConfusionMatrix=zeros(NoE,NoE);
    
              clear TrainFeaturePool TestFeaturePool
              
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(SVMPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
           
              if strcmp(Moda,'Whole(OldVersion)')
                 
                 SVMAccuracy(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrix{k}=SConfusionMatrix;  
              
             elseif strcmp(Moda,'Left')
               
                 SVMAccuracyL(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixL{k}=SConfusionMatrix;  
                 
              else strcmp(Moda,'Right')
                  
                 SVMAccuracyR(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixR{k}=SConfusionMatrix;  

              end
              
           else
              
               if NoE==2; Numbe=2; elseif NoE==3; Numbe=3; elseif NoE==4; Numbe=4; else Numbe=5; end
              MKLPredictedLabel = LpMKL_MW_2f(TrainFeaturePoolL,TrainFeaturePoolR,TrainLabelPool,TestFeaturePoolL,TestFeaturePoolR,100,Numbe,2);
           
              clear TrainFeaturePoolL TrainFeaturePoolR TestFeaturePoolL TestFeaturePoolR
              
              SConfusionMatrix=zeros(NoE,NoE);
    
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(MKLPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
              
              MKLAccuracy(k)=numel(find((MKLPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
              MKLConfusionMatrix{k}=SConfusionMatrix;  

           end
           
       end
        
       %% SVM & MKL: Quality Assessment
   
       disp('Quality Assessment ...')
       
       if strcmp(Moda,'Whole(OldVersion)')
          AvAcSVM=sum(SVMAccuracy(:))/kfold;

          AvConMatSVM=0;
          for i=1:kfold
             AvConMatSVM=AvConMatSVM+SVMConfusionMatrix{i};
          end
          AvConMatSVM=round(((AvConMatSVM/kfold)/TeNu)*100);  

          [BestAccuracy, BestSVM]=max(SVMAccuracy(:));
          BestAccuracySVM=BestAccuracy;
          BestConfusionMatrixSVM=round((SVMConfusionMatrix{BestSVM}/TeNu)*100);
          
       elseif strcmp(Moda,'Left')
          AvAcSVML=sum(SVMAccuracyL(:))/kfold;

          AvConMatSVML=0;
          for i=1:kfold
             AvConMatSVML=AvConMatSVML+SVMConfusionMatrixL{i};
          end
          AvConMatSVML=round(((AvConMatSVML/kfold)/TeNu)*100);  

          [BestAccuracyL, BestSVML]=max(SVMAccuracyL(:));
          BestAccuracySVML=BestAccuracyL;
          BestConfusionMatrixSVML=round((SVMConfusionMatrixL{BestSVML}/TeNu)*100);
          
       elseif strcmp(Moda,'Right')
          AvAcSVMR=sum(SVMAccuracyR(:))/kfold;

          AvConMatSVMR=0;
          for i=1:kfold
             AvConMatSVMR=AvConMatSVMR+SVMConfusionMatrixR{i};
          end
          AvConMatSVMR=round(((AvConMatSVMR/kfold)/TeNu)*100);  

          [BestAccuracyR, BestSVMR]=max(SVMAccuracyR(:));
          BestAccuracySVMR=BestAccuracyR;
          BestConfusionMatrixSVMR=round((SVMConfusionMatrixR{BestSVMR}/TeNu)*100);
          
       else          
          AvAcMKL=sum(MKLAccuracy(:))/kfold;

          AvConMatMKL=0;
          for i=1:kfold
             AvConMatMKL=AvConMatMKL+MKLConfusionMatrix{i};
          end
          AvConMatMKL=round(((AvConMatMKL/kfold)/TeNu)*100);  

          [BestAccuracyM, BestMKL]=max(MKLAccuracy(:));
          BestAccuracyMKL=BestAccuracyM;
          BestConfusionMatrixMKL=round((MKLConfusionMatrix{BestMKL}/TeNu)*100);
          
       end      
       
       clc
       
    end 
    
    clc
    
    disp('Data Storage ...')
    
    if NoE==2
        save(['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\2tasks\', 'ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==3
        save(['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\3tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==4
        save(['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\4tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    else
        save(['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\5tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    end
        
   
    figure;      
    DimReduct=sum(Reduct(:))/kfold;
    subplot(1,2,1); XLim=1:4; bar(XLim,[AvAcSVM;AvAcSVML;AvAcSVMR;AvAcMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
        
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Average Accuracy (%)')
    ylim([0 1])

    subplot(1,2,2); XLim=1:4; bar(XLim,[BestAccuracySVM;BestAccuracySVML;BestAccuracySVMR;BestAccuracyMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Best Accuracy (Best Fold) (%)')
    ylim([0 1])
    
    
    if NoE==2
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\2tasks\', InpP, '.fig']);
    elseif NoE==3
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\3tasks\', InpP, '.fig']);
    elseif NoE==4
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\4tasks\', InpP, '.fig']);
    else
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\5tasks\', InpP, '.fig']);
    end
    close all
    clc   
    
    TempSVM(NoE)=AvAcSVM;
    TempSVML(NoE)=AvAcSVML;
    TempSVMR(NoE)=AvAcSVMR;
    TempMKL(NoE)=AvAcMKL;
    
    BTempSVM(NoE)=BestAccuracySVM;
    BTempSVML(NoE)=BestAccuracySVML;
    BTempSVMR(NoE)=BestAccuracySVMR;
    BTempMKL(NoE)=BestAccuracyMKL;
    
    end
    
    DD=[TempSVM;TempSVML;TempSVMR;TempMKL];
    figure; subplot(1,2,1); bar(DD')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Average Accuracy (%)'); title(['Average Accuracy vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    DD1=[BTempSVM;BTempSVML;BTempSVMR;BTempMKL];
    subplot(1,2,2); bar(DD1')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Accuracy of Best Fold (%)'); title(['Accuracy of Best Fold vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\UsualFewSam\AccVsTas\', InpP, 'AccuracyVSTasks.fig']);
    
end
clc












% Last Update: Dec. 12, 2015

%% Load DBS Data

clc
clear all
close all
warning off

disp('Please set the parameters:')

% prompt='1. Choose the number of K-folds for cross validation approach, (K>=2):';
% kfold=input(prompt);

kfold=8;
if kfold==1; disp('please set "kfold">1 !!!'); return; end

% prompt='2. Choose the number of classes (2 - 5): ';
% NoE=input(prompt);

% prompt='3. SubjectDependent/SubjectIndependent:';
% mode=input(prompt);
   
DownSamp=2000;

InpPool={'O14AK','O14AJ','A15K','J15M'};
Modality={'Bidirectional','Whole(OldVersion)','Left','Right'};
EventPool={'Button','Audio','Random','Reach','Video'};
DirPoolLeft={'CH1L','CH2L','CH3L'};
DirPoolRight={'CH1R','CH2R','CH3R'};

for b1=1:numel(InpPool)
    
    InpP=InpPool{b1};
    disp('Loading Dataset ...')
    
    for NoE=2:5
        
    for b2=1:NoE
            
        EventP=EventPool{b2};
        BlockLeft=[];
        BlockRight=[];
        
        for b3=1:3
            
           DirPL=DirPoolLeft{b3};          
           name=[InpP,'-',EventP,'-',DirPL];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
                RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockLeft=[BlockLeft;RadAmplLowPass];
           clear RadAmplLowPass
            
        end

        for b4=1:3
            
           DirPR=DirPoolRight{b4};          
           name=[InpP,'-',EventP,'-',DirPR];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadPhas RadPhasLowPass SpiAmpl SpiAmplLowPass SpiPhas SpiPhasLowPass
           BlockRight=[BlockRight;RadAmplLowPass];
           clear RadAmplLowPass
            
        end
        
        if b2==1;  ButtonSampleL=(downsample(BlockLeft',DownSamp))'; ButtonSampleR=(downsample(BlockRight',DownSamp))'; ...
           ButtonSampleT=[ButtonSampleL;ButtonSampleR]; name1='Button'; 
           ButtonSampleT=ButtonSampleT(1:2:end,:); 
           
        elseif b2==2; AudioSampleL=(downsample(BlockLeft',DownSamp))'; AudioSampleR=(downsample(BlockRight',DownSamp))'; ...
           AudioSampleT=[AudioSampleL;AudioSampleR]; name2='Audio'; 
           AudioSampleT=AudioSampleT(1:2:end,:);
           
        elseif b2==3; RandomSampleL=(downsample(BlockLeft',DownSamp))'; RandomSampleR=(downsample(BlockRight',DownSamp))';  ...
           RandomSampleT=[RandomSampleL;RandomSampleR]; name3='Random'; 
           RandomSampleT=RandomSampleT(1:2:end,:);
           
        elseif b2==4; ReachSampleL=(downsample(BlockLeft',DownSamp))'; ReachSampleR=(downsample(BlockRight',DownSamp))';  ...
           ReachSampleT=[ReachSampleL;ReachSampleR]; name4='Reach'; 
           ReachSampleT=ReachSampleT(1:2:end,:);
           
        else  VideoSampleL=(downsample(BlockLeft',DownSamp))'; VideoSampleR=(downsample(BlockRight',DownSamp))';  ...
           VideoSampleT=[VideoSampleL;VideoSampleR]; name5='Video'; 
           VideoSampleT=VideoSampleT(1:2:end,:);
            
        end
            
        clear BlockLeft BlockRight
        
    end 
    
    for b0=1:4
    
        Moda=Modality{b0};
               
       % K-Fold; e.g., K=5;
       if strcmp(Moda,'Whole(OldVersion)')
           L1=size(ButtonSampleT,1);
           L2=size(AudioSampleT,1);
           if NoE==3; L3=size(RandomSampleT,1);end
           if NoE==4; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1);end
           if NoE==5; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1); L5=size(VideoSampleT,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
           
       else
           L1=size(ButtonSampleL,1);
           L2=size(AudioSampleL,1);
           if NoE==3; L3=size(RandomSampleL,1);end
           if NoE==4; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1);end
           if NoE==5; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1); L5=size(VideoSampleL,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
       end   
       
       ToNu=SamNum-mod(SamNum,kfold); 
       TrNu=((kfold-1)/kfold)*ToNu;
       TeNu=(1/kfold)*ToNu;
       disp(['TrainingSize:', num2str(TrNu), ' TestSize:', num2str(TeNu)])
       
       if strcmp(Moda,'Whole(OldVersion)')
          S1 = ButtonSampleT(1:ToNu,:);
          S2 = AudioSampleT(1:ToNu,:);
          if NoE==3; S3 = RandomSampleT(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); S5 = VideoSampleT(1:ToNu,:); end
          SVMAccuracy=zeros(1,kfold);
          SVMConfusionMatrix=cell(1,kfold);

       elseif strcmp(Moda,'Left')
          S1 = ButtonSampleL(1:ToNu,:);
          S2 = AudioSampleL(1:ToNu,:);
          if NoE==3; S3 = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); S5 = VideoSampleL(1:ToNu,:); end
          SVMAccuracyL=zeros(1,kfold);
          SVMConfusionMatrixL=cell(1,kfold);

       elseif strcmp(Moda,'Right')
          S1 = ButtonSampleR(1:ToNu,:);
          S2 = AudioSampleR(1:ToNu,:);
          if NoE==3; S3 = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); S5 = VideoSampleR(1:ToNu,:); end
          SVMAccuracyR=zeros(1,kfold);
          SVMConfusionMatrixR=cell(1,kfold);

       else
          S1L = ButtonSampleL(1:ToNu,:);
          S2L = AudioSampleL(1:ToNu,:);
          if NoE==3; S3L = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); S5L = VideoSampleL(1:ToNu,:); end
          
          S1R = ButtonSampleR(1:ToNu,:);
          S2R = AudioSampleR(1:ToNu,:);
          if NoE==3; S3R = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); S5R = VideoSampleR(1:ToNu,:); end
          MKLAccuracy=zeros(1,kfold);
          MKLConfusionMatrix=cell(1,kfold);

       end
       
       if NoE==2
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1)]; 
       elseif NoE==3
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1)];
       elseif NoE==4
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1)];   
       else
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1);5*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1);5*ones(TeNu,1)];
       end

%% SVM & MKLInitial Prepration

      

%% K-Fold & Dimensionality Reduction SubRoutine
   
       disp('K-Fold & Dimensionality Reduction ...')

       PCAratio=0.05;
       block=TeNu;
       Reduct=zeros(1,kfold);

       for k=1:kfold 
    
           disp(['Fold Number : ', num2str(k),' out of ', num2str(kfold)])
           
           if k==1
               
                if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
        
                   train1=S1(1:(kfold-1)*block,:);
                   test1=S1((kfold-1)*block+1:end,:);
                   train2=S2(1:(kfold-1)*block,:);
                   test2=S2((kfold-1)*block+1:end,:);
                   TrainChunk=[train1;train2];
                   TestChunk=[test1;test2];
                   if NoE==3
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3];
                       TestChunk=[test1;test2;test3];
                   elseif NoE==4
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4];
                       TestChunk=[test1;test2;test3;test4];
                   elseif NoE==5 
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       train5=S5(1:(kfold-1)*block,:);
                       test5=S5((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4;train5];
                       TestChunk=[test1;test2;test3;test4;test5];
                   end

                else
                    
                   train1L=S1L(1:(kfold-1)*block,:);
                   test1L=S1L((kfold-1)*block+1:end,:);
                   train2L=S2L(1:(kfold-1)*block,:);
                   test2L=S2L((kfold-1)*block+1:end,:);
                   TrainChunkL=[train1L;train2L];
                   TestChunkL=[test1L;test2L];
                   if NoE==3
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L];
                       TestChunkL=[test1L;test2L;test3L];
                   elseif NoE==4
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L];
                       TestChunkL=[test1L;test2L;test3L;test4L];
                   elseif NoE==5
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       train5L=S5L(1:(kfold-1)*block,:);
                       test5L=S5L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                       TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                   end
                   
                   train1R=S1R(1:(kfold-1)*block,:);
                   test1R=S1R((kfold-1)*block+1:end,:);
                   train2R=S2R(1:(kfold-1)*block,:);
                   test2R=S2R((kfold-1)*block+1:end,:);
                   TrainChunkR=[train1R;train2R];
                   TestChunkR=[test1R;test2R];
                   if NoE==3
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       TrainChunkR=[train1R;train2R;train3R];
                       TestChunkR=[test1R;test2R;test3R];
                   elseif NoE==4
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R];
                       TestChunkR=[test1R;test2R;test3R;test4R];
                   elseif NoE==5
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       train5R=S5R(1:(kfold-1)*block,:);
                       test5R=S5R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                       TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                   end
                   
                end                
                
           elseif k==kfold
               
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                                           
                  train1=S1(block+1:end,:);
                  test1=S1(1:block,:);
                  train2=S2(block+1:end,:);
                  test2=S2(1:block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);
                      train5=S5(block+1:end,:);
                      test5=S5(1:block,:);                                       
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end
                  
               else
                   
                  train1L=S1L(block+1:end,:);
                  test1L=S1L(1:block,:);
                  train2L=S2L(block+1:end,:);
                  test2L=S2L(1:block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      train5L=S5L(block+1:end,:);
                      test5L=S5L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=S1R(block+1:end,:);
                  test1R=S1R(1:block,:);
                  train2R=S2R(block+1:end,:);
                  test2R=S2R(1:block,:);
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      train5R=S5R(block+1:end,:);
                      test5R=S5R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end
                
               end
                                   
        
           else
        
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                   
                  train1=[S1(1:(kfold-k)*block,:);S1((kfold-k+1)*block+1:end,:)];
                  test1=S1((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2=[S2(1:(kfold-k)*block,:);S2((kfold-k+1)*block+1:end,:)];
                  test2=S2((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);    
                      train5=[S5(1:(kfold-k)*block,:);S5((kfold-k+1)*block+1:end,:)];
                      test5=S5((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end

                  
               else
                   
                  train1L=[S1L(1:(kfold-k)*block,:);S1L((kfold-k+1)*block+1:end,:)];
                  test1L=S1L((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2L=[S2L(1:(kfold-k)*block,:);S2L((kfold-k+1)*block+1:end,:)];
                  test2L=S2L((kfold-k)*block+1:(kfold-k+1)*block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train5L=[S5L(1:(kfold-k)*block,:);S5L((kfold-k+1)*block+1:end,:)];
                      test5L=S5L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=[S1R(1:(kfold-k)*block,:);S1R((kfold-k+1)*block+1:end,:)];
                  test1R=S1R((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2R=[S2R(1:(kfold-k)*block,:);S2R((kfold-k+1)*block+1:end,:)];
                  test2R=S2R((kfold-k)*block+1:(kfold-k+1)*block,:);                                 
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);                                        
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train5R=[S5R(1:(kfold-k)*block,:);S5R((kfold-k+1)*block+1:end,:)];
                      test5R=S5R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end                  
                  
               end              
               
           end 
           
           if strcmp(Moda,'Bidirectional')
              
               if NoE==2
                   clear train1R train2R train1L train2L ...
                    test1R test2R test1L test2L 
               elseif NoE==3
                   clear train1R train2R train3R train1L train2L train3L ...
                     test1R test2R test3R test1L test2L test3L 
               elseif NoE==4
                   clear train1R train2R train3R train4R train1L train2L train3L train4L ...
                     test1R test2R test3R test4R test1L test2L test3L test4L 
               else
                   clear train1R train2R train3R train4R train5R train1L train2L train3L train4L train5L ...
                     test1R test2R test3R test4R test5R test1L test2L test3L test4L test5L
               end
                                   
             
              TrainChunkL=(TrainChunkL-min(TrainChunkL(:)))/(max(TrainChunkL(:))-min(TrainChunkL(:)));
              TestChunkL=(TestChunkL-min(TestChunkL(:)))/(max(TestChunkL(:))-min(TestChunkL(:))); 
              [TrainFeaturePoolL, TestFeaturePoolL] = NewPCA2(TrainChunkL,TestChunkL,PCAratio);
              ReductL=1-size(TrainFeaturePoolL,2)/size(TrainChunkL,2);
              
              clear TrainChunkL TestChunkL
              
              TrainChunkR=(TrainChunkR-min(TrainChunkR(:)))/(max(TrainChunkR(:))-min(TrainChunkR(:)));
              TestChunkR=(TestChunkR-min(TestChunkR(:)))/(max(TestChunkR(:))-min(TestChunkR(:)));              
              [TrainFeaturePoolR, TestFeaturePoolR] = NewPCA2(TrainChunkR,TestChunkR,PCAratio);            
              ReductR=1-size(TrainFeaturePoolR,2)/size(TrainChunkR,2);
              
              Reduct(k)=(ReductL+ReductR)/2;
              
              clear TrainChunkR TestChunkR
              
           else
              
              if NoE==2
                  clear train1 train2  ...
                   test1 test2 
              elseif NoE==3
                  clear train1 train2 train3 ...
                   test1 test2 test3
              elseif NoE==4
                  clear train1 train2 train3 train4 ...
                   test1 test2 test3 test4 
              else
                  clear train1 train2 train3 train4 train5 ...
                   test1 test2 test3 test4 test5
              end
               
              TrainChunk=(TrainChunk-min(TrainChunk(:)))/(max(TrainChunk(:))-min(TrainChunk(:)));
              TestChunk=(TestChunk-min(TestChunk(:)))/(max(TestChunk(:))-min(TestChunk(:)));              
              [TrainFeaturePool, TestFeaturePool] = NewPCA2(TrainChunk,TestChunk,PCAratio);
              Reduct(k)=1-size(TrainFeaturePool,2)/size(TrainChunk,2);
              
              clear TrainChunk TestChunk
              
           end
       
%% SVM & KLM
           
           disp('Classification Procedures ...')
           
           if ~strcmp(Moda,'Bidirectional')
              
              disp(['SVM, FoldNumber:', num2str(k), ' out of ', num2str(kfold)])
              model = svmtrain(TrainLabelPool,TrainFeaturePool,'-s 0 -c 0.0001 -t 0 ');
              [SVMPredictedLabel,accuracy,DecEst] = svmpredict(TestLabelPool, TestFeaturePool, model);
              SConfusionMatrix=zeros(NoE,NoE);
    
              clear TrainFeaturePool TestFeaturePool
              
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(SVMPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
           
              if strcmp(Moda,'Whole(OldVersion)')
                 
                 SVMAccuracy(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrix{k}=SConfusionMatrix;  
              
             elseif strcmp(Moda,'Left')
               
                 SVMAccuracyL(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixL{k}=SConfusionMatrix;  
                 
              else strcmp(Moda,'Right')
                  
                 SVMAccuracyR(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixR{k}=SConfusionMatrix;  

              end
              
           else
              
               if NoE==2; Numbe=2; elseif NoE==3; Numbe=3; elseif NoE==4; Numbe=4; else Numbe=5; end
              MKLPredictedLabel = LpMKL_MW_2f(TrainFeaturePoolL,TrainFeaturePoolR,TrainLabelPool,TestFeaturePoolL,TestFeaturePoolR,100,Numbe,2);
           
              clear TrainFeaturePoolL TrainFeaturePoolR TestFeaturePoolL TestFeaturePoolR
              
              SConfusionMatrix=zeros(NoE,NoE);
    
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(MKLPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
              
              MKLAccuracy(k)=numel(find((MKLPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
              MKLConfusionMatrix{k}=SConfusionMatrix;  

           end
           
       end
        
       %% SVM & MKL: Quality Assessment
   
       disp('Quality Assessment ...')
       
       if strcmp(Moda,'Whole(OldVersion)')
          AvAcSVM=sum(SVMAccuracy(:))/kfold;

          AvConMatSVM=0;
          for i=1:kfold
             AvConMatSVM=AvConMatSVM+SVMConfusionMatrix{i};
          end
          AvConMatSVM=round(((AvConMatSVM/kfold)/TeNu)*100);  

          [BestAccuracy, BestSVM]=max(SVMAccuracy(:));
          BestAccuracySVM=BestAccuracy;
          BestConfusionMatrixSVM=round((SVMConfusionMatrix{BestSVM}/TeNu)*100);
          
       elseif strcmp(Moda,'Left')
          AvAcSVML=sum(SVMAccuracyL(:))/kfold;

          AvConMatSVML=0;
          for i=1:kfold
             AvConMatSVML=AvConMatSVML+SVMConfusionMatrixL{i};
          end
          AvConMatSVML=round(((AvConMatSVML/kfold)/TeNu)*100);  

          [BestAccuracyL, BestSVML]=max(SVMAccuracyL(:));
          BestAccuracySVML=BestAccuracyL;
          BestConfusionMatrixSVML=round((SVMConfusionMatrixL{BestSVML}/TeNu)*100);
          
       elseif strcmp(Moda,'Right')
          AvAcSVMR=sum(SVMAccuracyR(:))/kfold;

          AvConMatSVMR=0;
          for i=1:kfold
             AvConMatSVMR=AvConMatSVMR+SVMConfusionMatrixR{i};
          end
          AvConMatSVMR=round(((AvConMatSVMR/kfold)/TeNu)*100);  

          [BestAccuracyR, BestSVMR]=max(SVMAccuracyR(:));
          BestAccuracySVMR=BestAccuracyR;
          BestConfusionMatrixSVMR=round((SVMConfusionMatrixR{BestSVMR}/TeNu)*100);
          
       else          
          AvAcMKL=sum(MKLAccuracy(:))/kfold;

          AvConMatMKL=0;
          for i=1:kfold
             AvConMatMKL=AvConMatMKL+MKLConfusionMatrix{i};
          end
          AvConMatMKL=round(((AvConMatMKL/kfold)/TeNu)*100);  

          [BestAccuracyM, BestMKL]=max(MKLAccuracy(:));
          BestAccuracyMKL=BestAccuracyM;
          BestConfusionMatrixMKL=round((MKLConfusionMatrix{BestMKL}/TeNu)*100);
          
       end      
       
       clc
       
    end 
    
    clc
    
    disp('Data Storage ...')
    
    if NoE==2
        save(['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\2tasks\', 'ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==3
        save(['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\3tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==4
        save(['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\4tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    else
        save(['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\5tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    end
        
   
    figure;      
    DimReduct=sum(Reduct(:))/kfold;
    subplot(1,2,1); XLim=1:4; bar(XLim,[AvAcSVM;AvAcSVML;AvAcSVMR;AvAcMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
        
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Average Accuracy (%)')
    ylim([0 1])

    subplot(1,2,2); XLim=1:4; bar(XLim,[BestAccuracySVM;BestAccuracySVML;BestAccuracySVMR;BestAccuracyMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Best Accuracy (Best Fold) (%)')
    ylim([0 1])
    
    
    if NoE==2
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\2tasks\', InpP, '.fig']);
    elseif NoE==3
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\3tasks\', InpP, '.fig']);
    elseif NoE==4
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\4tasks\', InpP, '.fig']);
    else
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\5tasks\', InpP, '.fig']);
    end
    close all
    clc   
    
    TempSVM(NoE)=AvAcSVM;
    TempSVML(NoE)=AvAcSVML;
    TempSVMR(NoE)=AvAcSVMR;
    TempMKL(NoE)=AvAcMKL;
    
    BTempSVM(NoE)=BestAccuracySVM;
    BTempSVML(NoE)=BestAccuracySVML;
    BTempSVMR(NoE)=BestAccuracySVMR;
    BTempMKL(NoE)=BestAccuracyMKL;
    
    end
    
    DD=[TempSVM;TempSVML;TempSVMR;TempMKL];
    figure; subplot(1,2,1); bar(DD')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Average Accuracy (%)'); title(['Average Accuracy vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    DD1=[BTempSVM;BTempSVML;BTempSVMR;BTempMKL];
    subplot(1,2,2); bar(DD1')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Accuracy of Best Fold (%)'); title(['Accuracy of Best Fold vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\RadialFewSam\AccVsTas\', InpP, 'AccuracyVSTasks.fig']);
    
end
clc












% Last Update: Dec. 12, 2015

%% Load DBS Data

clc
clear all
close all
warning off

disp('Please set the parameters:')

% prompt='1. Choose the number of K-folds for cross validation approach, (K>=2):';
% kfold=input(prompt);

kfold=8;
if kfold==1; disp('please set "kfold">1 !!!'); return; end

% prompt='2. Choose the number of classes (2 - 5): ';
% NoE=input(prompt);

% prompt='3. SubjectDependent/SubjectIndependent:';
% mode=input(prompt);
   
DownSamp=2000;

InpPool={'O14AK','O14AJ','A15K','J15M'};
Modality={'Bidirectional','Whole(OldVersion)','Left','Right'};
EventPool={'Button','Audio','Random','Reach','Video'};
DirPoolLeft={'CH1L','CH2L','CH3L'};
DirPoolRight={'CH1R','CH2R','CH3R'};

for b1=1:numel(InpPool)
    
    InpP=InpPool{b1};
    disp('Loading Dataset ...')
    
    for NoE=2:5
        
    for b2=1:NoE
            
        EventP=EventPool{b2};
        BlockLeft=[];
        BlockRight=[];
        
        for b3=1:3
            
           DirPL=DirPoolLeft{b3};          
           name=[InpP,'-',EventP,'-',DirPL];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiPhas SpiPhasLowPass
           BlockLeft=[BlockLeft; SpiAmplLowPass];
           clear  SpiAmplLowPass
            
        end

        for b4=1:3
            
           DirPR=DirPoolRight{b4};          
           name=[InpP,'-',EventP,'-',DirPR];
           load(name);
           clear Ampl AmplLowPass DownFilteredRaw DownRawSignal Phas PhasLowPass RadAmple ...
               RadAmplLowPass RadPhas RadPhasLowPass SpiAmpl SpiPhas SpiPhasLowPass
           BlockRight=[BlockRight; SpiAmplLowPass];
           clear SpiAmplLowPass
            
        end
        
        if b2==1;  ButtonSampleL=(downsample(BlockLeft',DownSamp))'; ButtonSampleR=(downsample(BlockRight',DownSamp))'; ...
           ButtonSampleT=[ButtonSampleL;ButtonSampleR]; name1='Button'; 
           ButtonSampleT=ButtonSampleT(1:2:end,:); 
           
        elseif b2==2; AudioSampleL=(downsample(BlockLeft',DownSamp))'; AudioSampleR=(downsample(BlockRight',DownSamp))'; ...
           AudioSampleT=[AudioSampleL;AudioSampleR]; name2='Audio'; 
           AudioSampleT=AudioSampleT(1:2:end,:);
           
        elseif b2==3; RandomSampleL=(downsample(BlockLeft',DownSamp))'; RandomSampleR=(downsample(BlockRight',DownSamp))';  ...
           RandomSampleT=[RandomSampleL;RandomSampleR]; name3='Random'; 
           RandomSampleT=RandomSampleT(1:2:end,:);
           
        elseif b2==4; ReachSampleL=(downsample(BlockLeft',DownSamp))'; ReachSampleR=(downsample(BlockRight',DownSamp))';  ...
           ReachSampleT=[ReachSampleL;ReachSampleR]; name4='Reach'; 
           ReachSampleT=ReachSampleT(1:2:end,:);
           
        else  VideoSampleL=(downsample(BlockLeft',DownSamp))'; VideoSampleR=(downsample(BlockRight',DownSamp))';  ...
           VideoSampleT=[VideoSampleL;VideoSampleR]; name5='Video'; 
           VideoSampleT=VideoSampleT(1:2:end,:);
            
        end
            
        clear BlockLeft BlockRight
        
    end 
    
    for b0=1:4
    
        Moda=Modality{b0};
               
       % K-Fold; e.g., K=5;
       if strcmp(Moda,'Whole(OldVersion)')
           L1=size(ButtonSampleT,1);
           L2=size(AudioSampleT,1);
           if NoE==3; L3=size(RandomSampleT,1);end
           if NoE==4; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1);end
           if NoE==5; L3=size(RandomSampleT,1); L4=size(ReachSampleT,1); L5=size(VideoSampleT,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
           
       else
           L1=size(ButtonSampleL,1);
           L2=size(AudioSampleL,1);
           if NoE==3; L3=size(RandomSampleL,1);end
           if NoE==4; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1);end
           if NoE==5; L3=size(RandomSampleL,1); L4=size(ReachSampleL,1); L5=size(VideoSampleL,1);end
           
           if NoE==2
               SamNum=min([L1,L2]);
           elseif NoE==3
               SamNum=min([L1,L2,L3]);
           elseif NoE==4
               SamNum=min([L1,L2,L3,L4]);
           else
               SamNum=min([L1,L2,L3,L4,L5]);
           end
       end   
       
       ToNu=SamNum-mod(SamNum,kfold); 
       TrNu=((kfold-1)/kfold)*ToNu;
       TeNu=(1/kfold)*ToNu;
       disp(['TrainingSize:', num2str(TrNu), ' TestSize:', num2str(TeNu)])
       
       if strcmp(Moda,'Whole(OldVersion)')
          S1 = ButtonSampleT(1:ToNu,:);
          S2 = AudioSampleT(1:ToNu,:);
          if NoE==3; S3 = RandomSampleT(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleT(1:ToNu,:); S4 = ReachSampleT(1:ToNu,:); S5 = VideoSampleT(1:ToNu,:); end
          SVMAccuracy=zeros(1,kfold);
          SVMConfusionMatrix=cell(1,kfold);

       elseif strcmp(Moda,'Left')
          S1 = ButtonSampleL(1:ToNu,:);
          S2 = AudioSampleL(1:ToNu,:);
          if NoE==3; S3 = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleL(1:ToNu,:); S4 = ReachSampleL(1:ToNu,:); S5 = VideoSampleL(1:ToNu,:); end
          SVMAccuracyL=zeros(1,kfold);
          SVMConfusionMatrixL=cell(1,kfold);

       elseif strcmp(Moda,'Right')
          S1 = ButtonSampleR(1:ToNu,:);
          S2 = AudioSampleR(1:ToNu,:);
          if NoE==3; S3 = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3 = RandomSampleR(1:ToNu,:); S4 = ReachSampleR(1:ToNu,:); S5 = VideoSampleR(1:ToNu,:); end
          SVMAccuracyR=zeros(1,kfold);
          SVMConfusionMatrixR=cell(1,kfold);

       else
          S1L = ButtonSampleL(1:ToNu,:);
          S2L = AudioSampleL(1:ToNu,:);
          if NoE==3; S3L = RandomSampleL(1:ToNu,:); end
          if NoE==4; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); end
          if NoE==5; S3L = RandomSampleL(1:ToNu,:); S4L = ReachSampleL(1:ToNu,:); S5L = VideoSampleL(1:ToNu,:); end
          
          S1R = ButtonSampleR(1:ToNu,:);
          S2R = AudioSampleR(1:ToNu,:);
          if NoE==3; S3R = RandomSampleR(1:ToNu,:); end
          if NoE==4; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); end
          if NoE==5; S3R = RandomSampleR(1:ToNu,:); S4R = ReachSampleR(1:ToNu,:); S5R = VideoSampleR(1:ToNu,:); end
          MKLAccuracy=zeros(1,kfold);
          MKLConfusionMatrix=cell(1,kfold);

       end
       
       if NoE==2
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1)]; 
       elseif NoE==3
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1)];
       elseif NoE==4
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1)];   
       else
           TrainLabelPool=[1*ones(TrNu,1);2*ones(TrNu,1);3*ones(TrNu,1);4*ones(TrNu,1);5*ones(TrNu,1)];
           TestLabelPool=[1*ones(TeNu,1);2*ones(TeNu,1);3*ones(TeNu,1);4*ones(TeNu,1);5*ones(TeNu,1)];
       end

%% SVM & MKLInitial Prepration

      

%% K-Fold & Dimensionality Reduction SubRoutine
   
       disp('K-Fold & Dimensionality Reduction ...')

       PCAratio=0.05;
       block=TeNu;
       Reduct=zeros(1,kfold);

       for k=1:kfold 
    
           disp(['Fold Number : ', num2str(k),' out of ', num2str(kfold)])
           
           if k==1
               
                if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
        
                   train1=S1(1:(kfold-1)*block,:);
                   test1=S1((kfold-1)*block+1:end,:);
                   train2=S2(1:(kfold-1)*block,:);
                   test2=S2((kfold-1)*block+1:end,:);
                   TrainChunk=[train1;train2];
                   TestChunk=[test1;test2];
                   if NoE==3
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3];
                       TestChunk=[test1;test2;test3];
                   elseif NoE==4
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4];
                       TestChunk=[test1;test2;test3;test4];
                   elseif NoE==5 
                       train3=S3(1:(kfold-1)*block,:);
                       test3=S3((kfold-1)*block+1:end,:);
                       train4=S4(1:(kfold-1)*block,:);
                       test4=S4((kfold-1)*block+1:end,:);
                       train5=S5(1:(kfold-1)*block,:);
                       test5=S5((kfold-1)*block+1:end,:);
                       TrainChunk=[train1;train2;train3;train4;train5];
                       TestChunk=[test1;test2;test3;test4;test5];
                   end

                else
                    
                   train1L=S1L(1:(kfold-1)*block,:);
                   test1L=S1L((kfold-1)*block+1:end,:);
                   train2L=S2L(1:(kfold-1)*block,:);
                   test2L=S2L((kfold-1)*block+1:end,:);
                   TrainChunkL=[train1L;train2L];
                   TestChunkL=[test1L;test2L];
                   if NoE==3
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L];
                       TestChunkL=[test1L;test2L;test3L];
                   elseif NoE==4
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L];
                       TestChunkL=[test1L;test2L;test3L;test4L];
                   elseif NoE==5
                       train3L=S3L(1:(kfold-1)*block,:);
                       test3L=S3L((kfold-1)*block+1:end,:);
                       train4L=S4L(1:(kfold-1)*block,:);
                       test4L=S4L((kfold-1)*block+1:end,:);
                       train5L=S5L(1:(kfold-1)*block,:);
                       test5L=S5L((kfold-1)*block+1:end,:);
                       TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                       TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                   end
                   
                   train1R=S1R(1:(kfold-1)*block,:);
                   test1R=S1R((kfold-1)*block+1:end,:);
                   train2R=S2R(1:(kfold-1)*block,:);
                   test2R=S2R((kfold-1)*block+1:end,:);
                   TrainChunkR=[train1R;train2R];
                   TestChunkR=[test1R;test2R];
                   if NoE==3
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       TrainChunkR=[train1R;train2R;train3R];
                       TestChunkR=[test1R;test2R;test3R];
                   elseif NoE==4
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R];
                       TestChunkR=[test1R;test2R;test3R;test4R];
                   elseif NoE==5
                       train3R=S3R(1:(kfold-1)*block,:);
                       test3R=S3R((kfold-1)*block+1:end,:); 
                       train4R=S4R(1:(kfold-1)*block,:);
                       test4R=S4R((kfold-1)*block+1:end,:);
                       train5R=S5R(1:(kfold-1)*block,:);
                       test5R=S5R((kfold-1)*block+1:end,:);
                       TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                       TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                   end
                   
                end                
                
           elseif k==kfold
               
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                                           
                  train1=S1(block+1:end,:);
                  test1=S1(1:block,:);
                  train2=S2(block+1:end,:);
                  test2=S2(1:block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=S3(block+1:end,:);
                      test3=S3(1:block,:);
                      train4=S4(block+1:end,:);
                      test4=S4(1:block,:);
                      train5=S5(block+1:end,:);
                      test5=S5(1:block,:);                                       
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end
                  
               else
                   
                  train1L=S1L(block+1:end,:);
                  test1L=S1L(1:block,:);
                  train2L=S2L(block+1:end,:);
                  test2L=S2L(1:block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=S3L(block+1:end,:);
                      test3L=S3L(1:block,:);
                      train4L=S4L(block+1:end,:);
                      test4L=S4L(1:block,:);
                      train5L=S5L(block+1:end,:);
                      test5L=S5L(1:block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=S1R(block+1:end,:);
                  test1R=S1R(1:block,:);
                  train2R=S2R(block+1:end,:);
                  test2R=S2R(1:block,:);
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=S3R(block+1:end,:);
                      test3R=S3R(1:block,:);
                      train4R=S4R(block+1:end,:);
                      test4R=S4R(1:block,:);
                      train5R=S5R(block+1:end,:);
                      test5R=S5R(1:block,:);
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end
                
               end
                                   
        
           else
        
               if strcmp(Moda,'Whole(OldVersion)') || strcmp(Moda,'Left') || strcmp(Moda,'Right')
                   
                  train1=[S1(1:(kfold-k)*block,:);S1((kfold-k+1)*block+1:end,:)];
                  test1=S1((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2=[S2(1:(kfold-k)*block,:);S2((kfold-k+1)*block+1:end,:)];
                  test2=S2((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                  TrainChunk=[train1;train2];
                  TestChunk=[test1;test2];
                  if NoE==3
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3];
                      TestChunk=[test1;test2;test3];
                  elseif NoE==4
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4];
                      TestChunk=[test1;test2;test3;test4];
                  elseif NoE==5
                      train3=[S3(1:(kfold-k)*block,:);S3((kfold-k+1)*block+1:end,:)];
                      test3=S3((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4=[S4(1:(kfold-k)*block,:);S4((kfold-k+1)*block+1:end,:)];
                      test4=S4((kfold-k)*block+1:(kfold-k+1)*block,:);    
                      train5=[S5(1:(kfold-k)*block,:);S5((kfold-k+1)*block+1:end,:)];
                      test5=S5((kfold-k)*block+1:(kfold-k+1)*block,:);                  
                      TrainChunk=[train1;train2;train3;train4;train5];
                      TestChunk=[test1;test2;test3;test4;test5];
                  end

                  
               else
                   
                  train1L=[S1L(1:(kfold-k)*block,:);S1L((kfold-k+1)*block+1:end,:)];
                  test1L=S1L((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2L=[S2L(1:(kfold-k)*block,:);S2L((kfold-k+1)*block+1:end,:)];
                  test2L=S2L((kfold-k)*block+1:(kfold-k+1)*block,:);
                  TrainChunkL=[train1L;train2L];
                  TestChunkL=[test1L;test2L];
                  if NoE==3
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L];
                      TestChunkL=[test1L;test2L;test3L];
                  elseif NoE==4
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L];
                      TestChunkL=[test1L;test2L;test3L;test4L];
                  elseif NoE==5
                      train3L=[S3L(1:(kfold-k)*block,:);S3L((kfold-k+1)*block+1:end,:)];
                      test3L=S3L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train4L=[S4L(1:(kfold-k)*block,:);S4L((kfold-k+1)*block+1:end,:)];
                      test4L=S4L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      train5L=[S5L(1:(kfold-k)*block,:);S5L((kfold-k+1)*block+1:end,:)];
                      test5L=S5L((kfold-k)*block+1:(kfold-k+1)*block,:);
                      TrainChunkL=[train1L;train2L;train3L;train4L;train5L];
                      TestChunkL=[test1L;test2L;test3L;test4L;test5L];
                  end
                  
                  train1R=[S1R(1:(kfold-k)*block,:);S1R((kfold-k+1)*block+1:end,:)];
                  test1R=S1R((kfold-k)*block+1:(kfold-k+1)*block,:); 
                  train2R=[S2R(1:(kfold-k)*block,:);S2R((kfold-k+1)*block+1:end,:)];
                  test2R=S2R((kfold-k)*block+1:(kfold-k+1)*block,:);                                 
                  TrainChunkR=[train1R;train2R];
                  TestChunkR=[test1R;test2R];
                  if NoE==3
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R];
                      TestChunkR=[test1R;test2R;test3R];
                  elseif NoE==4
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);                                        
                      TrainChunkR=[train1R;train2R;train3R;train4R];
                      TestChunkR=[test1R;test2R;test3R;test4R];
                  elseif NoE==5
                      train3R=[S3R(1:(kfold-k)*block,:);S3R((kfold-k+1)*block+1:end,:)];
                      test3R=S3R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train4R=[S4R(1:(kfold-k)*block,:);S4R((kfold-k+1)*block+1:end,:)];
                      test4R=S4R((kfold-k)*block+1:(kfold-k+1)*block,:);  
                      train5R=[S5R(1:(kfold-k)*block,:);S5R((kfold-k+1)*block+1:end,:)];
                      test5R=S5R((kfold-k)*block+1:(kfold-k+1)*block,:);                   
                      TrainChunkR=[train1R;train2R;train3R;train4R;train5R];
                      TestChunkR=[test1R;test2R;test3R;test4R;test5R];
                  end                  
                  
               end              
               
           end 
           
           if strcmp(Moda,'Bidirectional')
              
               if NoE==2
                   clear train1R train2R train1L train2L ...
                    test1R test2R test1L test2L 
               elseif NoE==3
                   clear train1R train2R train3R train1L train2L train3L ...
                     test1R test2R test3R test1L test2L test3L 
               elseif NoE==4
                   clear train1R train2R train3R train4R train1L train2L train3L train4L ...
                     test1R test2R test3R test4R test1L test2L test3L test4L 
               else
                   clear train1R train2R train3R train4R train5R train1L train2L train3L train4L train5L ...
                     test1R test2R test3R test4R test5R test1L test2L test3L test4L test5L
               end
                                   
             
              TrainChunkL=(TrainChunkL-min(TrainChunkL(:)))/(max(TrainChunkL(:))-min(TrainChunkL(:)));
              TestChunkL=(TestChunkL-min(TestChunkL(:)))/(max(TestChunkL(:))-min(TestChunkL(:))); 
              [TrainFeaturePoolL, TestFeaturePoolL] = NewPCA2(TrainChunkL,TestChunkL,PCAratio);
              ReductL=1-size(TrainFeaturePoolL,2)/size(TrainChunkL,2);
              
              clear TrainChunkL TestChunkL
              
              TrainChunkR=(TrainChunkR-min(TrainChunkR(:)))/(max(TrainChunkR(:))-min(TrainChunkR(:)));
              TestChunkR=(TestChunkR-min(TestChunkR(:)))/(max(TestChunkR(:))-min(TestChunkR(:)));              
              [TrainFeaturePoolR, TestFeaturePoolR] = NewPCA2(TrainChunkR,TestChunkR,PCAratio);            
              ReductR=1-size(TrainFeaturePoolR,2)/size(TrainChunkR,2);
              
              Reduct(k)=(ReductL+ReductR)/2;
              
              clear TrainChunkR TestChunkR
              
           else
              
              if NoE==2
                  clear train1 train2  ...
                   test1 test2 
              elseif NoE==3
                  clear train1 train2 train3 ...
                   test1 test2 test3
              elseif NoE==4
                  clear train1 train2 train3 train4 ...
                   test1 test2 test3 test4 
              else
                  clear train1 train2 train3 train4 train5 ...
                   test1 test2 test3 test4 test5
              end
               
              TrainChunk=(TrainChunk-min(TrainChunk(:)))/(max(TrainChunk(:))-min(TrainChunk(:)));
              TestChunk=(TestChunk-min(TestChunk(:)))/(max(TestChunk(:))-min(TestChunk(:)));              
              [TrainFeaturePool, TestFeaturePool] = NewPCA2(TrainChunk,TestChunk,PCAratio);
              Reduct(k)=1-size(TrainFeaturePool,2)/size(TrainChunk,2);
              
              clear TrainChunk TestChunk
              
           end
       
%% SVM & KLM
           
           disp('Classification Procedures ...')
           
           if ~strcmp(Moda,'Bidirectional')
              
              disp(['SVM, FoldNumber:', num2str(k), ' out of ', num2str(kfold)])
              model = svmtrain(TrainLabelPool,TrainFeaturePool,'-s 0 -c 0.0001 -t 0 ');
              [SVMPredictedLabel,accuracy,DecEst] = svmpredict(TestLabelPool, TestFeaturePool, model);
              SConfusionMatrix=zeros(NoE,NoE);
    
              clear TrainFeaturePool TestFeaturePool
              
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(SVMPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
           
              if strcmp(Moda,'Whole(OldVersion)')
                 
                 SVMAccuracy(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrix{k}=SConfusionMatrix;  
              
             elseif strcmp(Moda,'Left')
               
                 SVMAccuracyL(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixL{k}=SConfusionMatrix;  
                 
              else strcmp(Moda,'Right')
                  
                 SVMAccuracyR(k)=numel(find((SVMPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
                 SVMConfusionMatrixR{k}=SConfusionMatrix;  

              end
              
           else
              
               if NoE==2; Numbe=2; elseif NoE==3; Numbe=3; elseif NoE==4; Numbe=4; else Numbe=5; end
              MKLPredictedLabel = LpMKL_MW_2f(TrainFeaturePoolL,TrainFeaturePoolR,TrainLabelPool,TestFeaturePoolL,TestFeaturePoolR,100,Numbe,2);
           
              clear TrainFeaturePoolL TrainFeaturePoolR TestFeaturePoolL TestFeaturePoolR
              
              SConfusionMatrix=zeros(NoE,NoE);
    
              for i=1:NoE  
                  for j=1:NoE
        
                      SConfusionMatrix(i,j)=numel(find(MKLPredictedLabel(1+(i-1)*TeNu:i*TeNu)==j));
        
                  end    
              end
              
              MKLAccuracy(k)=numel(find((MKLPredictedLabel-TestLabelPool)==0))/numel(TestLabelPool);
              MKLConfusionMatrix{k}=SConfusionMatrix;  

           end
           
       end
        
       %% SVM & MKL: Quality Assessment
   
       disp('Quality Assessment ...')
       
       if strcmp(Moda,'Whole(OldVersion)')
          AvAcSVM=sum(SVMAccuracy(:))/kfold;

          AvConMatSVM=0;
          for i=1:kfold
             AvConMatSVM=AvConMatSVM+SVMConfusionMatrix{i};
          end
          AvConMatSVM=round(((AvConMatSVM/kfold)/TeNu)*100);  

          [BestAccuracy, BestSVM]=max(SVMAccuracy(:));
          BestAccuracySVM=BestAccuracy;
          BestConfusionMatrixSVM=round((SVMConfusionMatrix{BestSVM}/TeNu)*100);
          
       elseif strcmp(Moda,'Left')
          AvAcSVML=sum(SVMAccuracyL(:))/kfold;

          AvConMatSVML=0;
          for i=1:kfold
             AvConMatSVML=AvConMatSVML+SVMConfusionMatrixL{i};
          end
          AvConMatSVML=round(((AvConMatSVML/kfold)/TeNu)*100);  

          [BestAccuracyL, BestSVML]=max(SVMAccuracyL(:));
          BestAccuracySVML=BestAccuracyL;
          BestConfusionMatrixSVML=round((SVMConfusionMatrixL{BestSVML}/TeNu)*100);
          
       elseif strcmp(Moda,'Right')
          AvAcSVMR=sum(SVMAccuracyR(:))/kfold;

          AvConMatSVMR=0;
          for i=1:kfold
             AvConMatSVMR=AvConMatSVMR+SVMConfusionMatrixR{i};
          end
          AvConMatSVMR=round(((AvConMatSVMR/kfold)/TeNu)*100);  

          [BestAccuracyR, BestSVMR]=max(SVMAccuracyR(:));
          BestAccuracySVMR=BestAccuracyR;
          BestConfusionMatrixSVMR=round((SVMConfusionMatrixR{BestSVMR}/TeNu)*100);
          
       else          
          AvAcMKL=sum(MKLAccuracy(:))/kfold;

          AvConMatMKL=0;
          for i=1:kfold
             AvConMatMKL=AvConMatMKL+MKLConfusionMatrix{i};
          end
          AvConMatMKL=round(((AvConMatMKL/kfold)/TeNu)*100);  

          [BestAccuracyM, BestMKL]=max(MKLAccuracy(:));
          BestAccuracyMKL=BestAccuracyM;
          BestConfusionMatrixMKL=round((MKLConfusionMatrix{BestMKL}/TeNu)*100);
          
       end      
       
       clc
       
    end 
    
    clc
    
    disp('Data Storage ...')
    
    if NoE==2
        save(['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\2tasks\', 'ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==3
        save(['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\3tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    elseif NoE==4
        save(['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\4tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    else
        save(['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\5tasks\','ConfusionMatrix', InpP], 'AvConMatSVM','BestConfusionMatrixSVM', 'AvConMatSVMR','BestConfusionMatrixSVMR', ...
        'AvConMatSVML','BestConfusionMatrixSVML','AvConMatMKL','BestConfusionMatrixMKL')
    end
        
   
    figure;      
    DimReduct=sum(Reduct(:))/kfold;
    subplot(1,2,1); XLim=1:4; bar(XLim,[AvAcSVM;AvAcSVML;AvAcSVMR;AvAcMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
        
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Average Accuracy (%)')
    ylim([0 1])

    subplot(1,2,2); XLim=1:4; bar(XLim,[BestAccuracySVM;BestAccuracySVML;BestAccuracySVMR;BestAccuracyMKL]');
    if NoE==2
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2])
    elseif NoE==3
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3])
    elseif NoE==4
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4])
    else
        title(['Subject: ', InpP, '; tasks: ', name1, '-', name2, '-', name3, '-', name4, '-', name5])
    end
    xlabel('1 : SVM, 2 : SVM (LeftChannel), 3 : SVM (RightChannel), 4 : MKL')
    ylabel('Best Accuracy (Best Fold) (%)')
    ylim([0 1])
    
    
    if NoE==2
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\2tasks\', InpP, '.fig']);
    elseif NoE==3
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\3tasks\', InpP, '.fig']);
    elseif NoE==4
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\4tasks\', InpP, '.fig']);
    else
       saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\5tasks\', InpP, '.fig']);
    end
    close all
    clc   
    
    TempSVM(NoE)=AvAcSVM;
    TempSVML(NoE)=AvAcSVML;
    TempSVMR(NoE)=AvAcSVMR;
    TempMKL(NoE)=AvAcMKL;
    
    BTempSVM(NoE)=BestAccuracySVM;
    BTempSVML(NoE)=BestAccuracySVML;
    BTempSVMR(NoE)=BestAccuracySVMR;
    BTempMKL(NoE)=BestAccuracyMKL;
    
    end
    
    DD=[TempSVM;TempSVML;TempSVMR;TempMKL];
    figure; subplot(1,2,1); bar(DD')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Average Accuracy (%)'); title(['Average Accuracy vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    DD1=[BTempSVM;BTempSVML;BTempSVMR;BTempMKL];
    subplot(1,2,2); bar(DD1')
    ylim([0 1]); xlim([1.5 5.5]); xlabel('Number of Classes (Tasks)'); ylabel('Accuracy of Best Fold (%)'); title(['Accuracy of Best Fold vs the Number of Classes (Tasks); Subject', InpP])
    legend('SVM','SVM-LeftChannel','SVM-RightChannel','MKL')
    
    saveas(gcf,['C:\Users\Lab User\Desktop\Simulate3\SpiralFewSam\AccVsTas\', InpP, 'AccuracyVSTasks.fig']);
    
end
clc


















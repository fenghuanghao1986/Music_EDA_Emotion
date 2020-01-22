
% New Update: Dec. 09, 2015
% Sample Extraction

% *********************************************
% ==================== Start. Load Data =====================

for tt=1:4
    
    clc
    close all;
    warning off

    InpPool={'O14AK_20141210.mat','O14AK_20141210_response.mat';
    'O14AJ_20141103.mat','O14AJ_20141103_response.mat';
    'A15K_20150511.mat','A15K_20150511_response.mat'
    'J15M_20150608.mat','J15M_20150608_response.mat';
    'A15L_20150427.mat','A15L_20150427_response.mat'};

    NamPool={'O14AK';'O14AJ';'A15K';'J15M';'A15L'};
    chPool=[1;2;3];
    sidePool={'Left';'Right'};
    targetPool={'Button','Audio','Video','Reach','Random'};

    name1=InpPool{tt,1}
    name2=InpPool{tt,2}
    name=NamPool{tt}
    
   for tt3=1:5
    
      target=targetPool{tt3}
      
      for tt2=1:2
        
         side=sidePool{tt2}
        
         for tt1=1:3
             
             load(name1);
             load(name2);
             TempSignal=signal(:,1:8);   
             clear audio digital intracranial intracranial_channel_names ...
               original_parameters signal signal_channel_names states 
             signal=TempSignal;
             clear TempSignal
             
             ch=chPool(tt1)

             if strcmp(side,'Right')
                if ch==1
                   BipolarSignal=signal(:,2)-signal(:,1);
                elseif ch==2
                   BipolarSignal=signal(:,3)-signal(:,2);
                else
                   BipolarSignal=signal(:,4)-signal(:,3);
                end
    
             else
                if ch==1
                   BipolarSignal=signal(:,6)-signal(:,5);
                elseif ch==2
                   BipolarSignal=signal(:,7)-signal(:,6);
                else
                   BipolarSignal=signal(:,8)-signal(:,7);
                end
   
             end

            clear signal

            if strcmp(target,'Button')
   
               flag=1;
               LL=length(PCS_button_press);
               onset=zeros(1,LL);
               offset=zeros(1,LL);

               for i=1:LL
    
                  if PCS_button_press(i).valid==1 
%                 if strcmp(PCS_button_press(i).code,side)==1
        
                     onset(i)=PCS_button_press(i).response.index;
                     offset(i)=PCS_button_press(i).response.duration;
              
%                 end
                  end
    
               end
     
            elseif strcmp(target,'Audio')
   
                flag=1;
                LL=length(AudioEvents);
                onset=zeros(1,LL);
                offset=zeros(1,LL);

                for i=1:LL
    
                    if AudioEvents(i).valid==1 
        
                       onset(i)=AudioEvents(i).response.index;
                       offset(i)=AudioEvents(i).response.duration;
        
                    end
        
                end

           elseif strcmp(target,'Video')
   
                flag=1;
                LL=length(VideoEvents);
                onset=zeros(1,LL);
                offset=zeros(1,LL);

                for i=1:LL
    
                   if VideoEvents(i).valid==1 
        
                      onset(i)=VideoEvents(i).response.index;
                      offset(i)=VideoEvents(i).response.duration;
        
                   end
        
                end
    
           elseif strcmp(target,'Reach')
    
                flag=1;
                LL=length(PCS_reach);
                onset=zeros(1,LL);
                offset=zeros(1,LL);

                for i=1:LL
    
                   if PCS_reach(i).valid==1 
%                  if strcmp(PCS_reach(i).side,side)==1
        
                  onset(i)=PCS_reach(i).response.index;
                  offset(i)=PCS_reach(i).response.duration;
        
%                  end
                   end
    
                end
    
            else
                
                flag=0;
                StartPoint=round(-1*Fs);
                EndPoint=round(1*Fs);  
                Epoch=EndPoint-StartPoint;
                InitialValue=round(7*Fs/17); 
                LoopNumber=round((length(BipolarSignal)-Epoch)/Epoch);
                LoopNumber=min(LoopNumber,50);

            end

            if flag==1
   
               offset=offset+onset;

               index=find(onset>0);
               onset=onset(index).*Fs; 
               offset=offset(index).*Fs;
               StartPoint=round(-1*Fs);
               EndPoint=round(1*Fs);       
               LoopNumber=numel(onset);

            end
            
            DownSamp=1;
            DesiredFrequency=linspace(8,30,255);
            fw=DesiredFrequency/2;
            scales=Fs./fw;
            DownRawSignal=cell(1,LoopNumber);
            TF=cell(1,LoopNumber);
            TF1=cell(1,LoopNumber);
            Vector1=cell(1,LoopNumber);
            Vector11=cell(1,LoopNumber);
            Vector2=cell(1,LoopNumber);
            Vector22=cell(1,LoopNumber);
            
            for count=1:LoopNumber
    
                disp(['Iteration ', num2str(count), ' out of ', num2str(LoopNumber)])
    
                if strcmp(target,'Random')
                   ST1=InitialValue+(count-1)*Epoch;
                   EN1=InitialValue+count*Epoch;
                else
                   ST1=onset(count)+StartPoint;
                   EN1=onset(count)+EndPoint;
                end
       
                TempSignal=BipolarSignal(ST1:EN1);
                TempR=TempSignal';
                DownRawSignal(count)={downsample(TempR,DownSamp)};
        
                DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/Fs);
                TempMap1=cwt(TempSignal,scales,'cmor1.5-2');
                TempMap=abs(TempMap1);
                AnglMap=angle(TempMap1);
                DownS=(downsample(TempMap',DownSamp))';
                DownSA=(downsample(AnglMap',DownSamp))';
                [DownSampled2D,Vector1{count}]=FrequencyMap(DownS,'Radial',0);
                [DownSampled2D,Vector11{count}]=FrequencyMap(DownSA,'Radial',0);
                [DownSampled2D,Vector2{count}]=FrequencyMap(DownS,'Spiral',0);
                [DownSampled2D,Vector22{count}]=FrequencyMap(DownSA,'Spiral',0);
    
                TF(count)={DownS(round(linspace(1,255,23)),:)}; 
                TF1(count)={DownSA(round(linspace(1,255,23)),:)};
                
    
            end

            Input=TF; 
            Input1=TF1;

            clear BipolarSignal TF TF1 TempSignal TempR TempMap1 TempMap DownS DownSA DownSampled2D

            Row=numel(DesiredFrequency(round(linspace(1,255,23))));
            NewInput=zeros(size(Input{1}));
            NewInput1=zeros(size(Input1{1}));

            DownFiltered=zeros(size(Input{1}));
            DownFiltered1=zeros(size(Input1{1}));
            DownFilteredRaw=cell(1,LoopNumber);
            
            Ampl=zeros(numel(Input),Row*size(NewInput,2));
            AmplLowPass=zeros(numel(Input),Row*size(NewInput,2));
            Phas=zeros(numel(Input),Row*size(NewInput,2));
            PhasLowPass=zeros(numel(Input),Row*size(NewInput,2));
            
            RadAmpl=zeros(LoopNumber,numel(Vector1{1}));
            RadAmplLowPass=zeros(LoopNumber,numel(Vector1{1}));
            RadPhas=zeros(LoopNumber,numel(Vector1{1}));
            RadPhasLowPass=zeros(LoopNumber,numel(Vector1{1}));
            
            SpiAmpl=zeros(LoopNumber,numel(Vector2{1}));
            SpiAmplLowPass=zeros(LoopNumber,numel(Vector2{1}));
            SpiPhas=zeros(LoopNumber,numel(Vector2{1}));
            SpiPhasLowPass=zeros(LoopNumber,numel(Vector2{1}));
            
            [s1,s2]=size(NewInput);
            [num,den]=butter(10,0.2);

            for z=1:numel(Input)
    
                TempInput=Input{z};
                TempInput1=Input1{z};
                DownFilteredRaw{z}=filter(num,den,DownRawSignal{z});
                
                for i=1:Row
     
                   NewInput(i,:)=TempInput(i,:);
                   DownFiltered(i,:)=filter(num,den,NewInput(i,:));
                   NewInput1(i,:)=TempInput1(i,:);
                   DownFiltered1(i,:)=filter(num,den,NewInput1(i,:));
                       
                end
                
                Ampl(z,:)=reshape(NewInput',1,s1*s2);        
                AmplLowPass(z,:)=reshape(DownFiltered',1,s1*s2); 
                Phas(z,:)=reshape(NewInput1',1,s1*s2);        
                PhasLowPass(z,:)=reshape(DownFiltered1',1,s1*s2);
                
                RadAmpl(z,:)=Vector1{z};
                RadAmplLowPass(z,:)=filter(num,den,Vector1{z});
                RadPhas(z,:)=Vector11{z};
                RadPhasLowPass(z,:)=filter(num,den,Vector11{z});
                
                SpiAmpl(z,:)=Vector2{z};
                SpiAmplLowPass(z,:)=filter(num,den,Vector2{z});
                SpiPhas(z,:)=Vector22{z};
                SpiPhasLowPass(z,:)=filter(num,den,Vector22{z});
    
            end

            if strcmp(side,'Left')
               SID='L';
            else 
               SID='R';
            end
            
            save(['C:\Users\Lab User\Desktop\Simulate3\', name, '-', target, '-', 'CH', num2str(ch), SID],...
                'DownRawSignal','DownFilteredRaw','Ampl','AmplLowPass','Phas','PhasLowPass','RadAmpl',...
                'RadAmplLowPass','RadPhas','RadPhasLowPass','SpiAmpl',...
                'SpiAmplLowPass','SpiPhas','SpiPhasLowPass')

         end
      end
   end
   
end










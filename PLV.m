
function PLV(SubjectName,SubjectResponse,name,LFPChannel,ECoGChannel,SideLFP,SideECoG,Task,DownSamp)


% By Hosein M. Golshan
% Last Update: Apr. 22, 2016

% SubjectName= 'O14AK_20141210.mat' 
% SubjectResponse= 'O14AK_20141210_response.mat'
% name= 'O14AK'
% LFPChannel/ECoGChannel= 1, 2, 3
% SideLFP/SideECoG= 'Left', 'Right'
% Task= 'Button', 'Audio', 'Reach', 'Video'
% DownSamp=10
% Example: SubjectName: PLV('O14AK_20141210',...
% 'O14AK_20141210_response','O14AK',1,2,'Left','Right','Button',10)

% ============================================================
% Load dataset
close all
warning off

load(SubjectName, 'signal');
load(SubjectName, 'Fs');
load(SubjectResponse);
target = Task;

% ============================================================
% Compute the bipolar signal

if strcmp(SideECoG, 'Right')
   if ECoGChannel == 1
       BipolarECoG = signal(:, 10) - signal(:, 9);         
   elseif ECoGChannel == 2
       BipolarECoG = signal(:, 11) - signal(:, 10);
   else
       BipolarECoG = signal(:, 12) - signal(:, 11);
   end
   
else
   if ECoGChannel == 1
       BipolarECoG = signal(:, 14) - signal(:, 13);
   elseif ECoGChannel == 2
       BipolarECoG = signal(:, 15) - signal(:, 14);
   else
       BipolarECoG = signal(:, 16) - signal(:, 15);
   end   
end
   
    
if strcmp(SideLFP, 'Right')
   if LFPChannel == 1
       BipolarLFP = signal(:, 2) - signal(:, 1);
   elseif LFPChannel == 2
       BipolarLFP = signal(:, 3) - signal(:, 2);
   else
       BipolarLFP = signal(:, 4) - signal(:, 3);
   end
   
else
   if LFPChannel == 1
       BipolarLFP = signal(:, 6) - signal(:, 5);
   elseif LFPChannel == 2
       BipolarLFP = signal(:, 7) - signal(:, 6);
   else
       BipolarLFP = signal(:, 8) - signal(:, 7);
   end   
end

clear signal

% ============================================================
% Extract onset, offset, and cue for each event

if strcmp(target,'Button')
   
    LL=length(PCS_button_press);
    cuetime=zeros(1,LL);
    onset=zeros(1,LL);
    offset=zeros(1,LL);

    for i=1:LL
    
        if PCS_button_press(i).valid==1           
        
              cuetime(i)=PCS_button_press(i).cue.index;
              onset(i)=PCS_button_press(i).response.index;
              offset(i)=PCS_button_press(i).response.duration;
        
        end
    
    end
     
elseif strcmp(target,'Audio')
   
    LL=length(AudioEvents);
    cuetime=zeros(1,LL);
    onset=zeros(1,LL);
    offset=zeros(1,LL);

    for i=1:LL
    
        if AudioEvents(i).valid==1 
        
              cuetime(i)=AudioEvents(i).cue.index; % **** No Cue exists in the file *********%
              onset(i)=AudioEvents(i).response.index;
              offset(i)=AudioEvents(i).response.duration;
        
        end
        
    end

elseif strcmp(target,'Video')
   
    LL=length(VideoEvents);
    cuetime=zeros(1,LL);
    onset=zeros(1,LL);
    offset=zeros(1,LL);

    for i=1:LL
    
        if VideoEvents(i).valid==1 
        
              cuetime(i)=VideoEvents(i).cue.index; % **** No Cue exists in the file *********%
              onset(i)=VideoEvents(i).response.index;
              offset(i)=VideoEvents(i).response.duration;
        
        end
        
    end
    
else
    
    LL=length(PCS_reach);
    cuetime=zeros(1,LL);
    onset=zeros(1,LL);
    offset=zeros(1,LL);

    for i=1:LL
    
        if PCS_reach(i).valid==1 
        
              cuetime(i)=PCS_reach(i).cue.index;
              onset(i)=PCS_reach(i).response.index;
              offset(i)=PCS_reach(i).response.duration;
       
        end
    
    end
    
end  

clear All_cues AudioEvents PCS_button_press PCS_reach Task_code VideoEvents

index=find(onset>0);
onset=onset(index).*Fs; 
cuetime=cuetime(index).*Fs;
% offset=offset+onset;
% offset=offset(index).*Fs;

% ============================================================
% Assign a time-window for all events centered around onset

StartPoint=round(-3*Fs);
EndPoint=round(3*Fs);       
Epoch=int32(StartPoint:EndPoint);

% ============================================================
% Define the Frequency range and the corresponding C-Morlet scales

F1 = 0.5; F2 = 40;
DesiredFrequency = F1:0.5:F2;
fw = DesiredFrequency;
LoopNumber = numel(onset);
map = 0;

% % Define an arbitrary baseline 
% BaseStart=-round(0.6*Fs).*ones(1,LoopNumber);  
% Gap=-round(0.1*Fs).*ones(1,LoopNumber);        

% ============================================================
% Spectroram sub-routine

for count1 = 1:LoopNumber
    
%     for count2 = 1:LoopNumber
               
    
       % ============================================== 
       % Compute the spectrogram of each event
    
       ST1=onset(count1)+StartPoint;
       EN1=onset(count1)+EndPoint;
       
       TempSignalLFP = downsample(BipolarLFP(ST1:EN1), DownSamp);
       TempSignalECoG = downsample(BipolarECoG(ST1:EN1), DownSamp);
           
       TempMap = abs(compute_plv_hilbert(TempSignalLFP,TempSignalECoG,fw,Fs/DownSamp,10,100,0,1));
       TempMap = TempMap';
       % ============================================== 
       % Normalize the TimeFrequency coefficients based on a variable baseline before each cue
    
%        ST2=cuetime(count1)+BaseStart(count1);
%        EN2=cuetime(count1)+Gap(count1);
%     
%        if ST2<ST1 
%           ST2=ST1+1;
%           disp('Authomatically set Baseline!!')
%        end
%        if EN2<ST1
%            EN2=ST1+1; 
%            disp('Authomatically set Gap!!')
%        end
%     
%        MST2=(ST2-ST1)+1;
%        MEN2=(EN2-ST1)+1;
    
%        BaseMean=repmat(mean(TempMap(:,MST2:MEN2),2),1,length(TempMap));                   
%        BaseStd=repmat(std(TempMap(:,MST2:MEN2)')',1,length(TempMap));  

       BaseMean=repmat(mean(TempMap,2),1,length(TempMap));                   
       BaseStd=repmat(std(TempMap')',1,length(TempMap)); 
       TempMap=(TempMap-BaseMean)./BaseStd;
       map=map+TempMap;
    
%     end
   
end

% ============================================================
% Compute the Average Map and Plot the results
map=map/LoopNumber; 

% Set Time & Frequency Axes
xRange=0:Fs:length(Epoch);
xLabel=cell(1,length(xRange));
for i=1:length(xRange)
     xLabel{i}=num2str((xRange(i)+StartPoint)/Fs);
end

yRange=linspace(1,length(fw),5);
yLabel=cell(1,length(yRange));
freqLabel=linspace(fw(1),fw(end),5);
for i=1:length(yRange)
     yLabel{i}=num2str(freqLabel(i));
end

yLabelnew=cell(1,length(yRange));
for ii=1:length(yRange)   
    yLabelnew{ii}=yLabel{length(yRange)-ii+1};
    
end

% Plot Figures
figure; subplot(2,1,1);
map1=map(end:-1:1,:); 
imagesc(map1);
set(gca,'XTick',xRange);
set(gca,'XTickLabel',xLabel);
set(gca,'YTick',yRange);
set(gca,'YTickLabel',yLabelnew);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title(['PLV of the "', target, '" event using Hilbert Transform;',...
       'LFP',' CH=', num2str(LFPChannel), ' ', SideLFP, 'side', ' & ', 'ECoG',' CH=', ...
       num2str(ECoGChannel), ' ', SideECoG, 'side', '; Subject: ',name]);

colorbar
% % ****************************** 
% 
% SamplingRate=10;
% Epoch=double(Epoch); 
% scales=double(scales);
% Dmap=map(1:SamplingRate:end,1:SamplingRate:end);
% SubScales=scales(1:SamplingRate:end);
% SubTime=Epoch(1:SamplingRate:end);
% [x,y]=meshgrid(SubTime,SubScales);
% 
% [x1,y1]=meshgrid(Epoch,scales);
% IMap=interp2(x,y,Dmap,x1,y1,'cubic');
% 
% subplot(2,2,3)
% Imap1=IMap(end:-1:1,:);  
% imagesc(Imap1);
% set(gca,'XTick',xRange);
% set(gca,'XTickLabel',xLabel);
% set(gca,'YTick',yRange);
% set(gca,'YTickLabel',yLabelnew);
% xlabel('Time (s)');
% ylabel(['Frequency (Hz)']);
% title(['Another version of the above figure aimed to make it visually look better!'])
% 
% colorbar
% *****************************

saveas(gcf,[name, '_', Task, '_event_', 'LFP_CH_', num2str(LFPChannel), '_', SideLFP, '_side', '_vs_',...
    'ECoG_CH_', num2str(ECoGChannel), '_' SideECoG, '_side', '.fig'])















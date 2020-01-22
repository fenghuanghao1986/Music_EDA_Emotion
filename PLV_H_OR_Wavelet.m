
function [map]=PLV_H_OR_Wavelet(SubjectName,SubjectResponse,name,LFPChannel,ECoGChannel,SideLFP,SideECoG,Task,DownSamp,Method)


% By Hosein M. Golshan
% Last Update: Apr. 26, 2016

% SubjectName= 'O14AK_20141210.mat' 
% SubjectResponse= 'O14AK_20141210_response.mat'
% name= 'O14AK'
% LFPChannel/ECoGChannel= 1, 2, 3
% SideLFP/SideECoG= 'Left', 'Right'
% Task= 'Button', 'Audio', 'Reach', 'Video'
% DownSamp=10
% Method= 'Wavelet','Hilbert'
% Example: SubjectName: PLV('O14AK_20141210',...
% 'O14AK_20141210_response','O14AK',1,2,'Left','Right','Button',10,'Wavelet')

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

    
if strcmp(SideLFP, 'Right')
   if LFPChannel == 1
       BipolarLFP = signal(:, 2) - signal(:, 1);
%        BipolarLFP = signal(:,1);
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


if strcmp(SideECoG, 'Right')
   if ECoGChannel == 1
       BipolarECoG = signal(:, 10) - signal(:, 9); 
%        BipolarECoG = signal(:,9);
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
        
%               cuetime(i)=AudioEvents(i).cue.index; % **** No Cue exists in the file *********%
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
        
%               cuetime(i)=VideoEvents(i).cue.index; % **** No Cue exists in the file *********%
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

Fs = Fs / DownSamp;
index=find(onset>0);
onset=onset(index).*Fs; 

% ============================================================
% Assign a time-window for all events centered around onset

StartPoint=-1*Fs;       % StartPoint=round(-3*Fs);
EndPoint=3*Fs;          % EndPoint=round(3*Fs);    
Epoch=int32(StartPoint:EndPoint);

% ============================================================
% Define the Frequency range and the corresponding C-Morlet scales

F1 = 0.5; F2 = 40;
DesiredFrequency = F1:0.5:F2;
fw = DesiredFrequency;
LoopNumber = numel(onset);
TempMap = 0;
BaseLineLenght = 1*Fs;
% ============================================================
% Spectroram sub-routine

for count1 = 1:LoopNumber
    
       % ============================================== 
       % Compute the spectrogram of each event
    
       ST1=(onset(count1)+StartPoint)*DownSamp;
       EN1=(onset(count1)+EndPoint)*DownSamp;
       
       TempSignalLFP = downsample(BipolarLFP(ST1:EN1), DownSamp);
       TempSignalECoG = downsample(BipolarECoG(ST1:EN1), DownSamp);

       if strcmp(Method,'Hilbert')
          TempMap = TempMap + abs(compute_plv_hilbert(TempSignalLFP,TempSignalECoG,fw,Fs,10,100,0,1))/LoopNumber;
       else
          TempMap = TempMap + abs(compute_plv_wavelet(TempSignalLFP,TempSignalECoG,fw,Fs,0,'MATLAB'))/LoopNumber;
       end
       % ==============================================       
end

% ============================================================
% Compute the Average Map and Plot the results
TempMap = TempMap';
BaseMean=repmat(mean(TempMap(:,1:BaseLineLenght),2),1,length(TempMap));
BaseStd=repmat(std(TempMap(:,1:BaseLineLenght)')',1,length(TempMap));  
TempMap=(TempMap-BaseMean)./BaseStd;

map=TempMap;     

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
figure; subplot(1,2,1);
map1=map(end:-1:1,:); 
imagesc(map1);
set(gca,'XTick',xRange);
set(gca,'XTickLabel',xLabel);
set(gca,'YTick',yRange);
set(gca,'YTickLabel',yLabelnew);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title(['PLV of the "', target, '" event using ', Method, 'Transform;',...
       'LFP',' CH=', num2str(LFPChannel), ' ', SideLFP, 'side', ' & ', 'ECoG',' CH=', ...
       num2str(ECoGChannel), ' ', SideECoG, 'side', '; Subject: ',name]);

colorbar
% ****************************** 

SamplingRate=10;
Epoch=double(Epoch); 
Freq=double(fw);
Dmap=map(:,1:SamplingRate:end);
SubFreq=Freq;
SubTime=Epoch(1:SamplingRate:end);
[x,y]=meshgrid(SubTime,SubFreq);

[x1,y1]=meshgrid(Epoch,Freq);
IMap=interp2(x,y,Dmap,x1,y1,'cubic');

subplot(1,2,2)
Imap1=IMap(end:-1:1,:);  
imagesc(Imap1);
set(gca,'XTick',xRange);
set(gca,'XTickLabel',xLabel);
set(gca,'YTick',yRange);
set(gca,'YTickLabel',yLabelnew);
xlabel('Time (s)');
ylabel(['Frequency (Hz)']);
title(['Another version of the above figure aimed to make it visually look better!'])

colorbar
% *****************************

saveas(gcf,[name, '_', Task, '_event_', 'LFP_CH_', num2str(LFPChannel), '_', SideLFP, '_side', '_vs_',...
    'ECoG_CH_', num2str(ECoGChannel), '_' SideECoG, '_side', '.fig'])


% SamplingRate=10;
% Epoch=double(Epoch); 
% Freq=double(fw);
% Dmap=map(1:SamplingRate:end,1:SamplingRate:end);
% SubFreq=Freq(1:SamplingRate:end);
% SubTime=Epoch(1:SamplingRate:end);
% [x,y]=meshgrid(SubTime,SubFreq);
% 
% [x1,y1]=meshgrid(Epoch,Freq);
% IMap=interp2(x,y,Dmap,x1,y1,'cubic');
% 
% subplot(1,2,2)
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













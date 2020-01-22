

function PlotDataSet(SubjectName,SubjectResponse,name,Channel,Side,Task,DownSamp,ECoG_OR_LFP)

% By Hosein Golshan
% Last Update: Feb. 26, 2016

% SubjectName= 'O14AK_20141210.mat' 
% SubjectResponse= 'O14AK_20141210_response.mat'
% name= 'O14AK'
% Channel= 1, 2, 3
% Side= 'Left', 'Right'
% Task= 'Button', 'Audio', 'Reach', 'Video'
% DownSamp=10
% ECoG_OR_LFP= 'ECoG', 'LFP'
% Example: SubjectName: PlotDataSet('O14AK_20141210','O14AK_20141210_response','O14AK',2,'Left','Button',10,'ECoG')

% ============================================================
% Load dataset
close all
warning off

load(SubjectName, 'signal');
load(SubjectName, 'Fs');
load(SubjectResponse);
ch = Channel;
side = Side;
target = Task;

% ============================================================
% Compute the bipolar signal

if strcmp(ECoG_OR_LFP,'ECoG')
   if strcmp(side, 'Right')
      if ch == 1
          BipolarSignal = signal(:, 10) - signal(:, 9);
      elseif ch == 2
          BipolarSignal = signal(:, 11) - signal(:, 10);
      else
          BipolarSignal = signal(:, 12) - signal(:, 11);
      end
   else
      if ch == 1
          BipolarSignal = signal(:, 14) - signal(:, 13);
      elseif ch == 2
          BipolarSignal = signal(:, 15) - signal(:, 14);
      else
          BipolarSignal = signal(:, 16) - signal(:, 15);
      end   
   end
   
else
    
    if strcmp(side, 'Right')
      if ch == 1
          BipolarSignal = signal(:, 2) - signal(:, 1);
      elseif ch == 2
          BipolarSignal = signal(:, 3) - signal(:, 2);
      else
          BipolarSignal = signal(:, 4) - signal(:, 3);
      end
   else
      if ch == 1
          BipolarSignal = signal(:, 6) - signal(:, 5);
      elseif ch == 2
          BipolarSignal = signal(:, 7) - signal(:, 6);
      else
          BipolarSignal = signal(:, 8) - signal(:, 7);
      end   
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
cuetime=cuetime(index).*Fs;
onset=onset(index).*Fs; 
% offset=offset+onset;
% offset=offset(index).*Fs;

% ============================================================
% Assign a time-window for all events centered around onset

StartPoint=round(-3*Fs);
EndPoint=round(3*Fs);       
Epoch=int32(StartPoint:EndPoint);

% ============================================================
% Define the Frequency range and the corresponding C-Morlet scales

F1 = 8; F2 = 100;
DesiredFrequency=F1:0.3:F2;
LoopNumber=numel(onset);
map=0; PSD=0; PSDBase=0;
fw=DesiredFrequency/2;
scales=Fs./fw;

% Define an arbitrary baseline 
BaseStart=-round(0.6*Fs).*ones(1,LoopNumber);  
Gap=-round(0.1*Fs).*ones(1,LoopNumber);        

% ============================================================
% Spectroram sub-routine

for count=1:LoopNumber
    
    disp(['Iteration ', num2str(count), ' out of ', num2str(LoopNumber)])
    
    % ============================================== 
    % Compute the spectrogram of each event
    
    ST1=onset(count)+StartPoint;
    EN1=onset(count)+EndPoint;
    TempSignal = downsample(BipolarSignal(ST1:EN1), DownSamp);
           
    DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/Fs);
    TempMap=abs(cwt(TempSignal,scales,'cmor1.5-2'));
     
    % ============================================== 
    % Normalize the TimeFrequency coefficients based on a variable baseline before each cue
    
    ST2=cuetime(count)+BaseStart(count);
    EN2=cuetime(count)+Gap(count);
    
    if ST2<ST1 
        ST2=ST1+1;
        disp('Authomatically set Baseline!!')
    end
    if EN2<ST1
        EN2=ST1+1; 
        disp('Authomatically set Gap!!')
    end
    
    MST2=(ST2-ST1)+1;
    MEN2=(EN2-ST1)+1;
    
    BaseMean=repmat(mean(TempMap(:,MST2:MEN2),2),1,length(TempMap));                   
    BaseStd=repmat(std(TempMap(:,MST2:MEN2)')',1,length(TempMap));             
    TempMap=(TempMap-BaseMean)./BaseStd;
    map=map+TempMap;
    
    % ==============================================    
    % Compute the PSD components using pwelch method
    
    WindowLengthSec=0.5;
    WindowLengthSam=fix(WindowLengthSec*Fs);
    
    if WindowLengthSam>length(TempSignal)
        disp('Authomatically set Hann-window!')
        WindowLengthSam=0.5*length(TempSignal);
    end
    
    if WindowLengthSam>length(TempSignal(MST2:MEN2))
        disp('Authomatically set the length of Hann window w.r.t. baseline!')
        WindowLengthSam=0.5*length(TempSignal(MST2:MEN2));
    end
    
	HannW=hann(WindowLengthSam);
    [TempPSD,f] = pwelch(TempSignal,HannW,[],DesiredFrequency,Fs);
    PSD=PSD+TempPSD;

    [TempPSDBaseline,fb] = pwelch(TempSignal(MST2:MEN2),HannW,[],DesiredFrequency,Fs);
    PSDBase=PSDBase+TempPSDBaseline;    
    
end

% ============================================================
% Compute the Average Map and Plot the results

map=map/LoopNumber; 
PSD=PSD/LoopNumber;
PSDBase=PSDBase/LoopNumber;

% Set Time & Frequency Axes
xRange=0:Fs:length(Epoch);
xLabel=cell(1,length(xRange));
for i=1:length(xRange)
     xLabel{i}=num2str((xRange(i)+StartPoint)/Fs);
end

yRange=linspace(1,length(f),5);
yLabel=cell(1,length(yRange));
freqLabel=linspace(f(1),f(end),5);
for i=1:length(yRange)
     yLabel{i}=num2str(freqLabel(i));
end

yLabelnew=cell(1,length(yRange));
for ii=1:length(yRange)   
    yLabelnew{ii}=yLabel{length(yRange)-ii+1};
    
end

% Plot Figures
figure; subplot(2,2,1)
map1=map(end:-1:1,:); 
imagesc(map1);
set(gca,'XTick',xRange);
set(gca,'XTickLabel',xLabel);
set(gca,'YTick',yRange);
set(gca,'YTickLabel',yLabelnew);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title(['Spectrogram of the "', target, '" event using C-Morlet Wavelet',...
    ' & baseline normalization; ', side, ' side', '; CH=', num2str(ch), '; Subject: ', name, '; ', ECoG_OR_LFP])
colorbar
% ******************************

subplot(2,2,2)
plot(f,10*log10(PSD),'r')
hold on
plot(fb,10*log10(PSDBase),'b--')
grid on
legend('PSD Event','PSD Base Line','Location','SouthWest')
ylabel('Log PSD')
xlabel('Frequency(Hz)')
title(['Average PSD Graph of ', target, ' event using ', ' pwelch method']) 
% ****************************** 

SamplingRate=10;
Epoch=double(Epoch); 
scales=double(scales);
Dmap=map(1:SamplingRate:end,1:SamplingRate:end);
SubScales=scales(1:SamplingRate:end);
SubTime=Epoch(1:SamplingRate:end);
[x,y]=meshgrid(SubTime,SubScales);

[x1,y1]=meshgrid(Epoch,scales);
IMap=interp2(x,y,Dmap,x1,y1,'cubic');

subplot(2,2,3)
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
% 
% x1=0;
% [num,den]=butter(10,0.2);
% y1=0;
% 
% for i=F1:F2
%     
%     Frequency=i;
%     scale=round(((numel(scales)-1)/(DesiredFrequency(1)-DesiredFrequency(end)))*...
%          (Frequency-DesiredFrequency(end))+1);
% 
%     xt=downsample(map1(scale,:),1);
%     x1=x1+xt;
%     yt=filter(num,den,xt);
%     y1=y1+yt;
%     
% end
% 
% x1=x1/(F2-F1);
% y1=y1/(F2-F1);
% 
% subplot(2,2,4)
% plot(x1,'g')
% hold on
% plot(y1,'r')
% grid on
% legend('Original Data','Low-Pass Filtered Data','Location','SouthWest')
% xlabel('Sample (Time(s)*Fs(Hz))')
% ylabel('Magnitude of C-morlet coefficients')
% title(['Average Plot of the Spectrogram  in the Frequency range of ~ ['...
%     , num2str(F1), ',' num2str(F2), '] (Hz)'])
% 

saveas(gcf,[name, '_CH', num2str(ch), '_', Side, '_', Task, '_', ECoG_OR_LFP, '.fig'])















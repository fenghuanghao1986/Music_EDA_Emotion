

function map1=PlotDataSet2(SubjectName,SubjectResponse,name,LFP_ECoG1,LFP_ECoG2,Task,DownSamp,ECoG_OR_LFP)

% By Hosein Golshan
% Last Update: Jun. 30, 2016

% SubjectName= 'O14AK_20141210.mat' 
% SubjectResponse= 'O14AK_20141210_response.mat'
% name= 'O14AK'
% if LFP_ECoG == LFP, then 1 < LFP_ECoG1 , LFP_ECoG2 < 8 
% if LFP_OR_ECoG == ECoG, then 9 < LFP_ECoG1 , LFP_ECoG2 < 16
% Task= 'Button', 'Audio', 'Reach', 'Video'
% DownSamp=10
% ECoG_OR_LFP= 'ECoG', 'LFP'
% Example: SubjectName: o = PlotDataSet2('A15K_20150511','A15K_20150511_response','A15K',6,7,'Button',1,'LFP')

% ============================================================
% Load dataset
close all
warning off

load(SubjectName, 'signal');
load(SubjectName, 'Fs');
load(SubjectResponse);
target = Task;
Adaptive = 1;

% ============================================================
% Compute the bipolar signal

if strcmp(ECoG_OR_LFP, 'LFP')
    if LFP_ECoG1 > 8 || LFP_ECoG2 > 8
        disp('Error: 1<= LFP_ECoG1 and LFP_ECoG2 <= 8')
        return
    end
elseif strcmp(ECoG_OR_LFP, 'ECoG')
    if LFP_ECoG1 < 9 || LFP_ECoG1 > 16 || LFP_ECoG2 < 9 || LFP_ECoG2 > 16
        disp('Error: 9<= LFP_ECoG1 and LFP_ECoG2 <= 16')
        return
    end
end

BipolarSignal = signal(:, LFP_ECoG2) - signal(:, LFP_ECoG1);

clear signal

% ============================================================
% Extract onset, offset, and cue for each event

if strcmp(target,'Button')
   
    LL = length(PCS_button_press);
    cuetime = zeros(1,LL);
    onset = zeros(1,LL);
 
    for i = 1:LL
    
        if PCS_button_press(i).valid == 1           
        
              cuetime(i) = PCS_button_press(i).cue.index;
              onset(i) = PCS_button_press(i).response.index;
              
        end
    
    end
     
elseif strcmp(target,'Audio')
   
    LL = length(AudioEvents);
    cuetime = zeros(1,LL);
    onset = zeros(1,LL);
    
    for i=1:LL
    
        if AudioEvents(i).valid == 1 
        
%               cuetime(i) = AudioEvents(i).cue.index; % **** No Cue exists in the file ******** %
              onset(i) = AudioEvents(i).response.index;
              cuetime(i) = onset(i) - 1;
              
        end
        
    end

elseif strcmp(target,'Video')
   
    LL = length(VideoEvents);
    cuetime = zeros(1,LL);
    onset = zeros(1,LL);
   
    for i = 1:LL
    
        if VideoEvents(i).valid == 1 
        
%               cuetime(i) = VideoEvents(i).cue.index; % **** No Cue exists in the file *********%
              onset(i) = VideoEvents(i).response.index;
              cuetime(i) = onset(i) - 1;
              
        end
        
    end
    
else
    
    LL = length(PCS_reach);
    cuetime = zeros(1,LL);
    onset = zeros(1,LL);
    
    for i = 1:LL
    
        if PCS_reach(i).valid == 1 
        
              cuetime(i) = PCS_reach(i).cue.index;
              onset(i) = PCS_reach(i).response.index;
              
        end
    
    end
    
end  

clear All_cues AudioEvents PCS_button_press PCS_reach Task_code VideoEvents

index = find(onset>0);
cuetime = cuetime(index).*Fs;
onset = onset(index).*Fs; 

% ============================================================
% Assign a time-window for all events centered around onset

StartPoint = round(-3*Fs);
EndPoint = round(3*Fs);       
Epoch = int32(StartPoint:EndPoint);

% ============================================================
% Define the Frequency range and the corresponding C-Morlet scales

F1 = 3; F2 = 100;
DesiredFrequency = F1:0.3:F2;
LoopNumber = numel(onset);
map = 0; PSD = 0; PSDBase = 0;
fw = DesiredFrequency/2;
scales = Fs./fw;

% Define an arbitrary baseline

if Adaptive == 1
   BaseStart = -round(1.1*Fs).*ones(1,LoopNumber);  
   Gap = -round(0.1*Fs).*ones(1,LoopNumber);        

else
    BaseStart = 1;
    BaseEnd = Fs;
    
end
% ============================================================
% Spectroram sub-routine

for count = 1:LoopNumber
    
    disp(['Iteration ', num2str(count), ' out of ', num2str(LoopNumber)])
    
    % ============================================== 
    % Compute the spectrogram of each event
    
    ST1 = onset(count) + StartPoint;
    EN1 = onset(count) + EndPoint;
    TempSignal = downsample(BipolarSignal(ST1:EN1), DownSamp);
           
    DesiredFrequency = scal2frq(scales,'cmor1.5-2',1/Fs);
    TempMap = abs(cwt(TempSignal,scales,'cmor1.5-2'));
     
    % ============================================== 
    % Normalize the TimeFrequency coefficients based on a variable baseline before each cue
    
    if Adaptive == 1
        ST2 = round((cuetime(count) + BaseStart(count))/DownSamp);
        EN2 = round((cuetime(count) + Gap(count))/DownSamp);
    
        if ST2<round(ST1/DownSamp) 
            ST2 = round(ST1/DownSamp);
            disp('Authomatically set Baseline!!')
        end
        if EN2<round(ST1/DownSamp)
            EN2 = round(ST1/DownSamp)+1; 
            disp('Authomatically set Gap!!')
        end
        
        MST2=(ST2-round(ST1/DownSamp))+1;
        MEN2=(EN2-round(ST1/DownSamp))+1;
            
    else
        
        ST2 = 1;
        EN2 = floor(BaseEnd/DownSamp);
        MST2 = ST2;
        MEN2 = EN2;
        
    end
    
    
    BaseMean = repmat(mean(TempMap(:,MST2:MEN2),2),1,length(TempMap));                   
    BaseStd = repmat(std(TempMap(:,MST2:MEN2)')',1,length(TempMap));             
    TempMap = (TempMap-BaseMean)./BaseStd;
    map = map+TempMap;
    
    % ==============================================    
    % Compute the PSD components using pwelch method
    
    WindowLengthSec = 0.5;
    WindowLengthSam = fix(WindowLengthSec*Fs);
    
    if WindowLengthSam > length(TempSignal)
        disp('Authomatically set Hann-window!')
        WindowLengthSam = 0.5*length(TempSignal);
    end
    
    if WindowLengthSam > length(TempSignal(MST2:MEN2))
        disp('Authomatically set the length of Hann window w.r.t. baseline!')
        WindowLengthSam = 0.5*length(TempSignal(MST2:MEN2));
    end
    
	HannW=hann(WindowLengthSam);
    [TempPSD,f] = pwelch(TempSignal,HannW,[],DesiredFrequency,Fs);
    PSD=PSD+TempPSD;

    [TempPSDBaseline,fb] = pwelch(TempSignal(MST2:MEN2),HannW,[],DesiredFrequency,Fs);
    PSDBase=PSDBase+TempPSDBaseline;    
    
end

% ============================================================
% Compute the Average Map and Plot the results

map = map/LoopNumber; 
PSD = PSD/LoopNumber;
PSDBase = PSDBase/LoopNumber;

% Set Time & Frequency Axes
xRange=0:Fs:length(Epoch);
xLabel=cell(1,length(xRange));
for i=1:length(xRange)
     xLabel{i}=num2str((xRange(i)+StartPoint)/Fs);
end

f = DesiredFrequency;
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
figure;
map1=map(end:-1:1,:);
map1 = ColMap(map1, 1, 'cm');
h = fspecial('average',[5,10]);
map1 = imfilter(map1, h);
imagesc(map1);
set(gca,'XTick',xRange);
set(gca,'XTickLabel',xLabel);
set(gca,'YTick',yRange);
set(gca,'YTickLabel',yLabelnew);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title([ 'Spectrogram: ', name,', ' target,', ',ECoG_OR_LFP, ' Contacts: ', num2str(LFP_ECoG1), ' & ', num2str(LFP_ECoG2)])
colorbar
% ******************************
saveas(gcf,['C:\Users\Lab User\Desktop\Spectrogram\',name, '_', ECoG_OR_LFP, '_', Task, '_Contact_', num2str(LFP_ECoG1), '&', num2str(LFP_ECoG2),'.jpg'])

figure
plot(f,10*log10(PSD),'r')
hold on
plot(fb,10*log10(PSDBase),'b--')
grid on
legend('Epoch','Base-Line','Location','SouthWest')
ylabel('Log PSD')
xlabel('Frequency(Hz)')
title([ 'PSD: ', name,', ' target,', ',ECoG_OR_LFP, ' Contacts: ', num2str(LFP_ECoG1), ' & ', num2str(LFP_ECoG2)]) 
% ****************************** 

saveas(gcf,['C:\Users\Lab User\Desktop\PSD\',name, '_', ECoG_OR_LFP, '_', Task, '_Contact_', num2str(LFP_ECoG1), '&', num2str(LFP_ECoG2),'.jpg'])

close all 













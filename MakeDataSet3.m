
function [DataSet] = MakeDataSet3(SubjectName,InterestedTasks,DataType,DirPoolLeft,DirPoolRight,DownSamp,ECoG_OR_LFP,normalization)

% By Hosein M. Golshan
% Last Update Jun 9, 2016

% Example: [DataSet] = MakeDataSet3('O14AK',{'Button','Random'},'Ampl','CH1L','CH2R',20,'LFP',1);

% Button=DataSet{1,1:2}; 
% Audio=DataSet{2,1:2}; 
% Random=DataSet{3,1:2}; 
% Reach=DataSet{4,1:2}; 
% Video=DataSet{5,1:2}; 

% Caution!! : the Subject Dataset must be located on the same directory,
% where this m-file exists.

% SubjectName : it should be a string like 'O14AK'

% InterestedTasks: it should be a cell array including the name of tasks
% like {'Button','Audio','Random','Reach','Video'}; 

% DataType: it is the name of raw data you want to use, including one of the following names: 
% Ampl AmplLowPass DownRaw DownRawFiltered Ampl2 AmplLowPass2
% For this function only 'Ampl' or 'AmplLowPass' works
% you can add the other enteries by changing the related lines at the
% beginning of the second and third 'for loops'

% DownSamp: the down-sampling rate.

% DirPoolLeft='CH1L','CH2L','CH3L';
% DirPoolRight='CH1R','CH2R','CH3R';
% ECoG_OR_LFP: 'ECoG','LFP'
% Note that, Left and Right channels are always separated.


EventPool=InterestedTasks;
InpP=SubjectName;

ButtonSampleL=cell(1,1); ButtonSampleR=cell(1,1);
AudioSampleL=cell(1,1); AudioSampleR=cell(1,1); 
RandomSampleL=cell(1,1); RandomSampleR=cell(1,1);
ReachSampleL=cell(1,1); ReachSampleR=cell(1,1);
VideoSampleL=cell(1,1); VideoSampleR=cell(1,1);

for b2=1:numel(InterestedTasks)
    
    EventP=EventPool{b2};
                     
    name=[InpP,'-',EventP,'-',DirPoolLeft,'-',ECoG_OR_LFP];
    TempData1 = load(name,DataType);
        
    if strcmp(DataType,'Ampl')
        TempData1 = TempData1.Ampl;
    elseif strcmp(DataType,'AmplLowPass')
        TempData1 = TempData1.AmplLowPass;
    elseif strcmp(DataType,'Ampl2')
        TempData1 = TempData1.Ampl2;
    elseif strcmp(DataType,'AmplLowPass2')
        TempData1 = TempData1.AmplLowPass2;
    end
            
    LeftSide={(downsample(TempData1',DownSamp))'}; 
%     LeftSide={Block_Cropper(TempData1,1,DownSamp,'size')};
                     
    name=[InpP,'-',EventP,'-',DirPoolRight,'-',ECoG_OR_LFP];
    TempData2 = load(name,DataType);
        
    if strcmp(DataType,'Ampl')
        TempData2 = TempData2.Ampl;
    elseif strcmp(DataType,'AmplLowPass')
        TempData2 = TempData2.AmplLowPass;
    elseif strcmp(DataType,'Ampl2');
        TempData2 = TempData2.Ampl2;
    elseif strcmp(DataType,'AmplLowPass2')
        TempData2 = TempData2.AmplLowPass2;
    end
        
    RightSide={(downsample(TempData2',DownSamp))'};
%     RightSide={Block_Cropper(TempData2,1,DownSamp,'size')};
          
        
    if strcmp('Button',EventP)  
        ButtonSampleL=LeftSide; 
        ButtonSampleR=RightSide; 
           
    elseif strcmp('Audio',EventP)
        AudioSampleL=LeftSide;
        AudioSampleR=RightSide;
           
    elseif strcmp('Random',EventP) 
        RandomSampleL=LeftSide;
        RandomSampleR=RightSide;
           
    elseif strcmp('Reach',EventP) 
        ReachSampleL=LeftSide;
        ReachSampleR=RightSide;
           
    elseif strcmp('Video',EventP)
        VideoSampleL=LeftSide;
        VideoSampleR=RightSide;
            
    end
        
end 
           
if normalization == 1
    
    k1 = cell2mat(ButtonSampleL);
    k11 = cell2mat(ButtonSampleR);
    BuL = zeros(size(k1));
    BuR = zeros(size(k11));
    
    for i = 1:size(BuL,1)
        
        Tem1 = k1(i,:);
        BuL(i,:) = (Tem1 - min(Tem1(:))) / (max(Tem1(:)) - min(Tem1(:)));
        Tem11 = k11(i,:);
        BuR(i,:) = (Tem11 - min(Tem11(:))) / (max(Tem11(:)) - min(Tem11(:)));
        
    end 
    ButtonSampleL = {BuL(:,2:end)};
    ButtonSampleR = {BuR(:,2:end)};
    
    k2 = cell2mat(AudioSampleL);
    k22 = cell2mat(AudioSampleR);
    AuL = zeros(size(k2));
    AuR = zeros(size(k22));
    
    for i = 1:size(AuL,1)
        
        Tem2 = k2(i,:);
        AuL(i,:) = (Tem2 - min(Tem2(:))) / (max(Tem2(:)) - min(Tem2(:)));
        Tem22 = k22(i,:);
        AuR(i,:) = (Tem22 - min(Tem22(:))) / (max(Tem22(:)) - min(Tem22(:)));
        
    end 
    AudioSampleL = {AuL(:,2:end)};
    AudioSampleR = {AuR(:,2:end)};
    
    k3 = cell2mat(RandomSampleL);
    k33 = cell2mat(RandomSampleR);
    RaL = zeros(size(k3));
    RaR = zeros(size(k33));
    
    for i = 1:size(RaL,1)
        
        Tem3 = k3(i,:);
        RaL(i,:) = (Tem3 - min(Tem3(:))) / (max(Tem3(:)) - min(Tem3(:)));
        Tem33 = k33(i,:);
        RaR(i,:) = (Tem33 - min(Tem33(:))) / (max(Tem33(:)) - min(Tem33(:)));
        
    end 
    RandomSampleL = {RaL(:,2:end)};
    RandomSampleR = {RaR(:,2:end)};
    
    k4 = cell2mat(ReachSampleL);
    k44 = cell2mat(ReachSampleR);
    ReL = zeros(size(k4));
    ReR = zeros(size(k44));
    
    for i = 1:size(ReL,1)
        
        Tem4 = k4(i,:);
        ReL(i,:) = (Tem4 - min(Tem4(:))) / (max(Tem4(:)) - min(Tem4(:)));
        Tem44 = k44(i,:);
        ReR(i,:) = (Tem44 - min(Tem44(:))) / (max(Tem44(:)) - min(Tem44(:)));
        
    end 
    ReachSampleL = {ReL(:,2:end)};
    ReachSampleR = {ReR(:,2:end)};
    
    k5 = cell2mat(VideoSampleL);
    k55 = cell2mat(VideoSampleR);
    ViL = zeros(size(k5));
    ViR = zeros(size(k55));
    
    for i = 1:size(ViL,1)
        
        Tem5 = k5(i,:);
        ViL(i,:) = (Tem5 - min(Tem5(:))) / (max(Tem5(:)) - min(Tem5(:)));
        Tem55 = k55(i,:);
        ViR(i,:) = (Tem55 - min(Tem55(:))) / (max(Tem55(:)) - min(Tem55(:)));
        
    end 
    VideoSampleL = {ViL(:,2:end)};
    VideoSampleR = {ViR(:,2:end)};
    
%     k5 = cell2mat(VideoSampleL);
%     k55 =  cell2mat(VideoSampleR);
%     VideoSampleL = {(k5 - min(k5(:))) / (max(k5(:)) - min(k5(:)))};
%     VideoSampleR = {(k55 - min(k55(:))) / (max(k55(:)) - min(k55(:)))};
     
else
    
    k1 = cell2mat(ButtonSampleL);
    k11 = cell2mat(ButtonSampleR);
    ButtonSampleL = {k1(:,2:end)};
    ButtonSampleR = {k11(:,2:end)};
    
    k2 = cell2mat(AudioSampleL);
    k22 = cell2mat(AudioSampleR);
    AudioSampleL = {k2(:,2:end)};
    AudioSampleR = {k22(:,2:end)};
    
    k3 = cell2mat(RandomSampleL);
    k33 = cell2mat(RandomSampleR);
    RandomSampleL = {k3(:,2:end)};
    RandomSampleR = {k33(:,2:end)};
    
    k4 = cell2mat(ReachSampleL);
    k44 = cell2mat(ReachSampleR);
    ReachSampleL = {k4(:,2:end)};
    ReachSampleR = {k44(:,2:end)};
    
    k5 = cell2mat(VideoSampleL);
    k55 = cell2mat(VideoSampleR);
    VideoSampleL = {k5(:,2:end)};
    VideoSampleR = {k55(:,2:end)};
    
end    
                      
DataSet = [ButtonSampleL,ButtonSampleR;
           AudioSampleL,AudioSampleR;
           RandomSampleL,RandomSampleR;
           ReachSampleL,ReachSampleR;
           VideoSampleL,VideoSampleR];
    
       
    
    
        
        




    



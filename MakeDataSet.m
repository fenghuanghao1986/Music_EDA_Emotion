
function [DataSet] = MakeDataSet(SubjectName,InterestedTasks,DataType,DownSamp,All_OR_Each,ECoG_OR_LFP)

% Example: [DataSet] = MakeDataSet('O15AK',{'Button','Random'},'Ampl',20,'Each','ECoG');

% Button=DataSet{1:3,1:2};  OR Button=DataSet{1:3,1:2};
% Audio=DataSet{4:6,1:2};   OR Audio=DataSet{4:6,1:2};
% Random=DataSet{7:9,1:2};  OR Random=DataSet{7:9,1:2};
% Reach=DataSet{10:12,1:2}; OR Reach=DataSet{10:12,1:2};
% Video=DataSet{13:15,1:2}; OR Video=DataSet{13:15,1:2};

% Caution!! : the Subject Data set must be located on the same directory,
% where this m-file exists.

% SubjectName : it should be a string like 'O14AK'

% InterestedTasks: it should be a cell array including the name of tasks
% like {'Button','Audio','Random','Reach','Video'}; 

% DataType: it is the name of raw data you want to use including one of the following names: 
% Ampl AmplLowPass DCT Phas PhasLowPass DownRaw DownRawFiltered 
% For this function only 'Ampl' ,'AmplLowPass', 'DCT' works
% you can add the other enteries by changing the related lines at the
% beginning of the second 'for loop'

% DownSAmp: the down-sampling rate.

% All_OR_Each: if you want to get each bipolar channel separately
% (CH1,CH2,CH3) for next processing stages you have to enter 'Each' as the
% input. Otherwise, you can enter 'All' to get a combination of all
% channels (CH1, CH2, CH3) as a big block.
% ECoG_OR_LFP: 'ECoG','LFP'
% Note that, Left and Right channels are always separated.


EventPool=InterestedTasks;
InpP=SubjectName;
LeftSide=cell(3,1); 
RightSide=cell(3,1);
DirPoolLeft={'CH1L','CH2L','CH3L'};
DirPoolRight={'CH1R','CH2R','CH3R'};

ButtonSampleL=cell(3,1); ButtonSampleR=cell(3,1);
AudioSampleL=cell(3,1); AudioSampleR=cell(3,1); 
RandomSampleL=cell(3,1); RandomSampleR=cell(3,1);
ReachSampleL=cell(3,1); ReachSampleR=cell(3,1);
VideoSampleL=cell(3,1); VideoSampleR=cell(3,1);
        
for b2=1:numel(InterestedTasks)
            
    EventP=EventPool{b2};
        
    for b3=1:3
            
        DirPL=DirPoolLeft{b3};          
        name=[InpP,'-',EventP,'-',DirPL,'-',ECoG_OR_LFP];
        load(name);
           
        if strcmp(DataType,'Ampl')
            LeftSide{b3}=(downsample(Ampl',DownSamp))';
        elseif strcmp(DataType,'AmplLowPass')
            LeftSide{b3}=(downsample(AmplLowPass',DownSamp))';
        elseif strcmp(DataType,'DCT')
            LeftSide{b3}=(downsample(DCT',DownSamp))';
        end
               
        clear DownRaw DownRawFiltered Ampl AmplLowPass Phas PhasLowPass DCT
            
    end

    for b4=1:3
            
        DirPR=DirPoolRight{b4};          
        name=[InpP,'-',EventP,'-',DirPR,'-',ECoG_OR_LFP];
        load(name);
           
        if strcmp(DataType,'Ampl')
            RightSide{b4}=(downsample(Ampl',DownSamp))';
        elseif strcmp(DataType,'AmplLowPass')
            RightSide{b4}=(downsample(AmplLowPass',DownSamp))';
        elseif strcmp(DataType,'DCT')
            RightSide{b4}=(downsample(DCT',DownSamp))';
        end
          
        clear DownRaw DownRawFiltered Ampl AmplLowPass Phas PhasLowPass DCT
            
    end
        
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

if strcmp(All_OR_Each,'Each')
    
    DataSet = [ButtonSampleL,ButtonSampleR;
               AudioSampleL,AudioSampleR;
               RandomSampleL,RandomSampleR;
               ReachSampleL,ReachSampleR;
               VideoSampleL,VideoSampleR];
           
else
    
    ButtonSampleAllL={[ButtonSampleL{1};ButtonSampleL{2};ButtonSampleL{3}]};
    ButtonSampleAllR={[ButtonSampleR{1};ButtonSampleR{2};ButtonSampleR{3}]};
    AudioSampleAllL={[AudioSampleL{1};AudioSampleL{2};AudioSampleL{3}]};
    AudioSampleAllR={[AudioSampleR{1};AudioSampleR{2};AudioSampleR{3}]};
    RandomSampleAllL={[RandomSampleL{1};RandomSampleL{2};RandomSampleL{3}]};
    RandomSampleAllR={[RandomSampleR{1};RandomSampleR{2};RandomSampleR{3}]};
    ReachSampleAllL={[ReachSampleL{1};ReachSampleL{2};ReachSampleL{3}]};
    ReachSampleAllR={[ReachSampleR{1};ReachSampleR{2};ReachSampleR{3}]};
    VideoSampleAllL={[VideoSampleL{1};VideoSampleL{2};VideoSampleL{3}]};
    VideoSampleAllR={[VideoSampleR{1};VideoSampleR{2};VideoSampleR{3}]};
    
    DataSet = [ButtonSampleAllL,ButtonSampleAllR;
               AudioSampleAllL,AudioSampleAllR;
               RandomSampleAllL,RandomSampleAllR;
               ReachSampleAllL,ReachSampleAllR;
               VideoSampleAllL,VideoSampleAllR];
           
end
    
    
    
    
    
        
        




    
    


function [FeaturesAll,ClassLabel,Info] = Funct_GazeFeatureExtraction (GazeCode,Segment,FrameRates, T_Seq , SubjSess_Lab)

%%input: GazeCode and FrameRate
%%output: Alphabets and new code (features)




NumSegments = size(GazeCode,2);

Desired_FPS = 7; %%this is the frame rate of eye gaze labels we used or transform the data to.

Input_Tseq = T_Seq;%%determine the sequence of labels (0,1) that we used for defineing new vocabulary

for (i_seg = 1:NumSegments)
    IndSegment = [find(Segment{i_seg}==0) ; find(Segment{i_seg}==1)];%%select the segment that corresponds to Nao Talkin or kid Talkin
    IndSegment= unique(IndSegment);
    
    GazeLab = GazeCode{i_seg};%%this is the Gaze Label befor ma 
    if (size(GazeLab,1)<IndSegment(end))
        GazeLab = GazeLab(IndSegment(1):end);    
    else
        GazeLab = GazeLab(IndSegment(1):IndSegment(end));
    end
    
    NumFrames = size(GazeLab,1);
   
    Ratio_FPS = FrameRates(i_seg)/Desired_FPS;
    
    Ind = [1:Ratio_FPS:NumFrames ];
    Ind = floor(Ind);
    
    GazeLab_DesiredFPS = GazeLab(Ind);
    %Check THis part for other games if we have more than 0,1 lables we
    %need to revise this section
    GazeLab_DesiredFPS(GazeLab_DesiredFPS>1) =0;%if there are labels bigger than one=> make them zero
    GazeLab_DesiredFPS(GazeLab_DesiredFPS<0) =0;
%     IndLabel_DesiredSegment = [find(GazeLab_DesiredFPS==0) ; find(GazeLab_DesiredFPS ==1)];%select only segments coded (e.g. kid talkin/Nao Talking)
%     IndLabel_DesiredSegment = unique(IndLabel_DesiredSegment);
%     RangFrames = [IndLabel_DesiredSegment(1) IndLabel_DesiredSegment(end)];%to be sure select all consecutive frames
%     
%     SelectedFrame = [ RangFrames(1) : RangFrames(2)];%select the initial and end of the selection range
%     Index_Oringinal_DesiredSegment = Ind(SelectedFrame);  
%     Input_Feat = GazeLab_DesiredFPS(SelectedFrame)%this segment contains only 0 -1
    

    Input_Feat = GazeLab_DesiredFPS;
    
    

    %% Gaze Vocabulary Definition
    %% Method1:
    %Select T_sequence Consecutive Frames and define 2^T_sequence words
    %this approach is same as "Analysis of Eye Gaze Pattern of Infants at rist of ASD using Markov Models"
    %the Ratio of Desired_FPS/T_sequence defines the amount in second for each word
    Num_InputFeat =size(Input_Feat,1);
    Remainder = mod(Num_InputFeat,Input_Tseq );
    Input_Feat = Input_Feat(1:end-Remainder);
    
    InputSeq = reshape(Input_Feat,Input_Tseq,[])';%sequence of 'Input_Tseq' frame that we define new Alphabet for this sequnce
    Alphabet1_InputSeq = bi2de (InputSeq);%conver binary to decimal number (0-15 = A-P letter)
    
    %% OTher Methods
    Alphabet2_InputSeq = sum(InputSeq,2);%conver binary to a number between (0-Input_Tseq = summation of binary labels)
    
    A = InputSeq;
    B = circshift(A, [0,1]);%shift every column to the right
    B = [A(:,1) B(:,2:end)];
    Shifting = xor(A,B);
    Alphabet3_InputSeq = sum(Shifting,2);%counts the number of shifting withing  Input_Tseq frames
    
    FeaturesAll{i_seg} = [Alphabet1_InputSeq Alphabet2_InputSeq  Alphabet3_InputSeq];
    ClassLabel{i_seg} = repmat(SubjSess_Lab(i_seg,:),size(InputSeq,1),1);
    Info = {'Feature 2^T_seq words' ; 'conver T_seq binary to Integer number' ; 'Counts the number of shifting between 0 and 1 in T_Seq'};
end
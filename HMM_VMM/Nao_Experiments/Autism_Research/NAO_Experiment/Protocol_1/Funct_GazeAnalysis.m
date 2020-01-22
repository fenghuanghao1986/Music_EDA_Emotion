function [Percentage_GazeAt,Percentage_GazeShifting,Ratio_GazeAt_Shifting,Entropy_H]=Funct_GazeAnalysis(CodedGaze,Label_Segment)
    %%CodedGaze: contains the labels for looking At(1) or Averted(0)
    %%Label_Segment: contains the label for specific task that we are
    %%interested to (e.g. Segment of Nao Talking=1, rest zero)
    %%OUTPUTS: 
    %%Percentage_GazeAt:Percentage of the time the Kid look AT robot
    %%Percentage_GazeShifting: Percentage of Shifting of Look At, Look Averted.
    
    %%Gaze AT Duration (in Percentage)
    Selected_Ind= find(Label_Segment ==1);
    Good_ind = Selected_Ind < length(CodedGaze);%%find those indices that has the corresponding label for the gaze
    Selected_Ind= Selected_Ind(Good_ind);
    
    GazeLabel = CodedGaze(Selected_Ind);
    Total_NumFrames = length(GazeLabel);%%total number of frame for selected segment
    NumFrames_Gaze_AT=length(find(GazeLabel==1));%%total number of samples with Gaze At Robot (1-> Gaze at, 0-> Gaze Averted)
    Percentage_GazeAt = NumFrames_Gaze_AT/Total_NumFrames
    
    %%Percentage of Shifting
    Shifting_Lab = xor(GazeLabel, circshift(GazeLabel,[-1,-1]) )%%shift the lables to the left
    NumShifting = length(find(Shifting_Lab==1))%%Specify the spikes as number of gaze shifting
    Percentage_GazeShifting = NumShifting/Total_NumFrames%%Calculate the frequencey of Shifting
    
    %%Percentage GazeAt/Percentage Shifting
    Ratio_GazeAt_Shifting = Percentage_GazeAt/Percentage_GazeShifting;
    %%Entropy of Gaze Pattern
    p1 = Percentage_GazeShifting;
    p2 = 1- p1;
    Entropy_H = -(p1*log2(p1) + p2*log2(p2) );
    
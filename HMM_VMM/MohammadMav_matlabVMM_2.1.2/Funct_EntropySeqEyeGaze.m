%function Funct_EntropySeqEyeGaze(PathData,SavingFile)
%calcuate the entropy of the EyeGaze patterns by considering the
%probability of each eye gaze word/alphabet and corresponding probabaility
%of presence for TD and ASD kids (consider only those alphabet that are acitve , if Pr=0 => ignore in entropy calculation)

% clear all
% close all
% clc

% T = 4;
% numStages =2;
%%in the function format PathData and SavingFile are the input of the
%%function
%%load the TD sequence probability
% PathData = 'C:\Documents and Settings\Vision\My Documents\Dave\Gaze Project\MohammadMavadati\MiamiProjectGaze\Saved';
% SavingFile = ['\Part_TD_ASD_VMM_Classifications_ProbSeq_ImageFormat']
% SavingFile = [SavingFile 'T' num2str(T) '_NumStage' num2str(numStages)]

load ([PathData, SavingFile], 'TD_Tot_Prob' ,'TD_Tot_Symb','ASD_Tot_Prob','ASD_Tot_Symb');


PROB = TD_Tot_Prob;
SYMB = TD_Tot_Symb;
NumSeq = size(PROB,2)    
for i_Seq=1:NumSeq
    TD.SymbList{i_Seq} = SYMB{i_Seq};
    TD.ProbSymb{i_Seq} = prod(PROB{i_Seq},2 );%multiplying the probability of each character in the sequence
    Ind = find(prod(PROB{i_Seq},2) ~= 0);
    TD.NumActiveVocabTot{i_Seq} =  size(Ind);
    TD.Entropy{i_Seq} = -sum(TD.ProbSymb{i_Seq}(Ind) .* log2(TD.ProbSymb{i_Seq}(Ind)));
end


PROB_ASD = ASD_Tot_Prob;
SYMB_ASD = ASD_Tot_Symb;
NumSeq = size(PROB,2)  
for i_Seq=1:NumSeq
    ASD.SymbList{i_Seq} = SYMB_ASD{i_Seq};
    ASD.ProbSymb{i_Seq} = prod(PROB_ASD{i_Seq},2 );%multiplying the probability of each character in the sequence
    Ind = find(prod(PROB_ASD{i_Seq},2) ~= 0);
    ASD.NumActiveVocabTot{i_Seq} =  size(Ind);
    ASD.Entropy{i_Seq} = -sum(ASD.ProbSymb{i_Seq}(Ind) .* log2(ASD.ProbSymb{i_Seq}(Ind)));
end

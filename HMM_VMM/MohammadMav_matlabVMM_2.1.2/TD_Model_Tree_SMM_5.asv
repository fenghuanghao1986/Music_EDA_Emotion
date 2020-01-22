% A simple hands-on tutorial
% Browse the code to get the basics of how-to utilize this VMM tool
clc
clear all
close all hidden

global T

verbose = 0;
m = 0;
k =18; % smoothing factor
delay = 0; %starting point delay in coding


for T = 4;
    m = m + 1;
    n = 0;
    for ds = 18;
        n = n + 1;
        epis = 1; % FF = 1, SF = 2, RE = 3;
        [seqTD, seqASD]=readDataSeqKdx(ds, T, epis, k, delay);
        
        createParams;
        
        % use AB with size = 5
        disp('---------------------------------------------------');
        if (verbose == 1), disp('working with AB ={A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P }'); end
        disp('---------------------------------------------------');
        s = 3;
        % 3. run each of the VMM algorithms
        %%the name of the VMM algorithm; one of the followings: {'LZms', 'LZ78', 'PPMC', 'DCTW', 'BinaryCTW', 'PST'}
        if (verbose == 1), disp(sprintf('Working with %s', 'PPMC' )); end
        %     disp('--------')
        
        jVmmTD_full = vmm_createNew(map(ab, seqTD),  ALGS{s}, paramsTD);
        jVmmASD_full = vmm_createNew(map(ab, seqASD),  ALGS{s}, paramsASD);
        

% 
% TD_VMM_Results =  Prob_TransitionVMM(jVmmTD_full, ab, T);
% ASD_VMM_Results =  Prob_TransitionVMM(jVmmASD_full, ab, T);

numStages=2%specifies the number of stages we want to caclulate the probability of each seq.

[TD_VMM_Results,TD_P0_Symb] =  Prob_TransitionVMM_V2(jVmmTD_full, ab, T, seqTD,numStages);
P0_Symb = TD_P0_Symb;
VMM_Prob = TD_VMM_Results;
[TD_mat_Image,TD_Tot_Prob,TD_Tot_Symb ] = Funct_Plot_ProbAllSeq(P0_Symb,VMM_Prob,T, numStages,'TD');


[ASD_VMM_Results ,ASD_P0_Symb]=  Prob_TransitionVMM_V2(jVmmASD_full, ab, T, seqASD,numStages);
P0_Symb = ASD_P0_Symb;
VMM_Prob = ASD_VMM_Results;
[ASD_mat_Image,ASD_Tot_Prob,ASD_Tot_Symb ] = Funct_Plot_ProbAllSeq(P0_Symb,VMM_Prob,T, numStages,'ASD');

% %% Representing the probability of every sequence as an image
% %rows correspond to the probability of each sequence of, column corresponds
% %to the stages (numStages) that we would have;
% P0_Symb = TD_P0_Symb;
% VMM_Prob = TD_VMM_Results;
% %%Define a function for ploting the symbols 
% Mat_Prob = [P0_Symb]';
% Coef = 2^T;% multiplyingCoef for each iteration
% Symbols = (char(64+(1:2^T)));
% for i_Stage =1:numStages
%       VMM_Prob.SeqSymbols;  
%       Temp_Symbol = VMM_Prob.SeqSymbols{i_Stage}
%       Temp_ProbStage = VMM_Prob.ProbSeqSymbols{i_Stage}(:);
% 
%       size_MatProb= size(Mat_Prob,1)
%       t_Prob=[];%keep track of the probability for each sequence (VMM getPr resutls)
%       s_Symb=[];%keep track of the symbol sequences
%       for i = 1:size_MatProb
%         t = repmat(Mat_Prob(i,:),Coef,1);
%         t_Prob = [t_Prob; t];
%         s = repmat(Temp_Symbol(i,:),Coef,1)
%         s= [s Symbols(:)];
%         s_Symb = [s_Symb; s];
%       end
%     Mat_Prob = [t_Prob Temp_ProbStage];
%     
%     Tot_Prob{i_Stage} = Mat_Prob;   
%     Tot_Symb{i_Stage} = s_Symb ;
%     
%    %%ploting the probability of each symbol as an Image ()
%    size_MatProb= size(Mat_Prob,1)
%    mat=[];
%    for i=1:size(Mat_Prob,2)
%        CoefIncrease = floor(size_MatProb/size(Mat_Prob,2)); %%this increasing make the final probability matrix square matrix (goood for ploting)
%        mat = [mat repmat(Mat_Prob(:,i),1,CoefIncrease)];
%    end
%     figure, imagesc(mat,[0,1])
%     colormap(bone)
%     colorbar('YTickLabel',...
%     {'0','0.1','0.2', '0.3', '0.4','0.5',...
%     '0.6','0.7' , '0.8', '0.9' ,'1.0'})
%     clear t_Prob;
% end

        disp ([ TD_VMM_Results.SeqSymbols{2} num2str([TD_VMM_Results.ProbSeqSymbols{2}]) ... 
         ASD_VMM_Results.SeqSymbols{2} num2str([ASD_VMM_Results.ProbSeqSymbols{2}]) ]);
    end
end
PathData = 'C:\Documents and Settings\Vision\My Documents\Dave\Gaze Project\MohammadMavadati\MiamiProjectGaze\Saved';
mkdir(PathData);
SavingFile = ['\Part_TD_ASD_VMM_Classifications_ProbSeq']
save ([PathData, SavingFile], 'TD_VMM_Results', 'ASD_VMM_Results');



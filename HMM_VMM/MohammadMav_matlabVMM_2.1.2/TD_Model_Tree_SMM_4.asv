% A simple hands-on tutorial
% Browse the code to get the basics of how-to utilize this VMM tool
clc
clear all

global T

verbose = 0;
m = 0;
k =18; % smoothing factor
delay = 0; %starting point delay in coding


for T = 2;
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
        


TD_VMM_Results =  Prob_TransitionVMM(jVmmTD_full, ab, T);
ASD_VMM_Results =  Prob_TransitionVMM(jVmmASD_full, ab, T);

disp ([ TD_VMM_Results.SeqSymbols{2} num2str([TD_VMM_Results.ProbSeqSymbols{2}]) ... 
         ASD_VMM_Results.SeqSymbols{2} num2str([ASD_VMM_Results.ProbSeqSymbols{2}]) ])
    end
end
PathData = 'C:\Documents and Settings\Vision\My Documents\Dave\Gaze Project\MohammadMavadati\MiamiProjectGaze\Saved';
mkdir(PathData);
SavingFile = ['\Part_TD_ASD_VMM_Classifications_ProbSeq']
save ([PathData, SavingFile], 'TD_VMM_Results', 'ASD_VMM_Results');
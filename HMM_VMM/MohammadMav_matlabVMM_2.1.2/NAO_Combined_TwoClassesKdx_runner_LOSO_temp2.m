% A simple hands-on tutorial
% Browse the code to get the basics of how-to utilize this VMM tool
clear all
close all
clc

%%load the sequence of Both ASD and TD individuals + NAO experiments
PathData = 'C:\Documents and Settings\Vision\My Documents\Dave\Gaze Project\MohammadMavadati\Nao_Experiments\Autism_Research\NAO_Experiment\Protocol_1\Saved';
load( fullfile(PathData,'Part1_KidTalking_TD_ASD_GazeFeatSeq_forHMM'));

%%One sequence per subject section
NumSubj = size(ASD_Tot_SeqFeat_Subjs,2)
for i_Subj =1:NumSubj
    seqASD_OverallSubj{i_Subj} = reshape(ASD_Tot_SeqFeat_Subjs{i_Subj}',1,[]);
    subjASD_List= ASD_Tot_Subj_list;
end

NumSubj = size(TD_Tot_SeqFeat_Subjs,2)
for i_Subj =1:NumSubj
    seqTD_OverallSubj{i_Subj} = reshape(TD_Tot_SeqFeat_Subjs{i_Subj}',1,[]);
    subjTD_List= TD_Tot_Subj_list;
end



      
%%Each subject with few sequence of videos
%%ASD Section
itr=1; seqASD_sameLength={};
NumSubj = size(ASD_Tot_SeqFeat_Subjs,2)
for i_Subj =1:NumSubj
    Data = ASD_Tot_SeqFeat_Subjs{i_Subj};
    NumSeqs = size(Data,1)
    for i_seq = 1:NumSeqs
        seqASD_sameLength{itr}.se = Data(i_seq,:);
        seqASD_SameLength{itr}.sn = ASD_Tot_Subj_list(i_Subj);
        itr = itr+1;
    end
end

%%TD Section
itr=1;seqTD_sameLength={}
NumSubj = size(TD_Tot_SeqFeat_Subjs,2)
for i_Subj =1:NumSubj
    Data = TD_Tot_SeqFeat_Subjs{i_Subj};
    NumSeqs = size(Data,1)
    for i_seq = 1:NumSeqs
        seqTD_sameLength{itr}.se = Data(i_seq,:);
        seqTD_SameLength{itr}.sn = TD_Tot_Subj_list(i_Subj);
        itr = itr+1;
    end
end


%% Choosing Classifying eye gaze based on one 
ExperimentID = {'oneSeqPerSubj', 'fewSeqsPerSubj'};
exper = 'oneSeqPerSubj'
switch(exper)
    case 'oneSeqPerSubj'
        itr =1;%some of the Td seq are empty
        for (i_seq = 1:size(seqTD_OverallSubj,2) ) 
            if (~isempty(seqTD_OverallSubj{i_seq}))
                seqTD{itr}.se = seqTD_OverallSubj{i_seq};
                seqTD{itr}.sn = subjTD_List(i_seq);
                itr=itr+1;
            end
        end
        itr =1;%some of the Td seq are empty
        for (i_seq = 1:size(seqASD_OverallSubj,2) )
            if (~isempty(seqASD_OverallSubj{i_seq}))
                seqASD{itr}.se = seqASD_OverallSubj{i_seq};
                seqASD{itr}.sn = subjASD_List(i_seq);
                itr=itr+1;
            end
        end
        
        
%     case 'fewSeqsPerSubj'
%         seqTD = seqTD_SameLength;
%         subjTD_List_SameLength
%         
%         seqASD = seqASd_sameLength;
%         subjASD_List_SameLength
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global T

verbose = 0;
m = 0;
k =18; % smoothing factor
delay = 0; %starting point delay in coding

for T = 4
    m = m + 1;
    n = 0;
    for ds = 18;
     k = ds;
        n = n + 1;
        epis = 1; % FF = 1, SF = 2, RE = 3;
%         [seqTD, seqASD]=readDataSeqKdx(ds, T, epis, k, delay);

        createParams; % ALGS and other parameters of VMM is defined inside this function
        
        % use AB with size = 5
        disp('---------------------------------------------------');
        if (verbose == 1), disp('working with AB={A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P }'); end
        disp('---------------------------------------------------');
        s = 3;
        % 3. run each of the VMM algorithms
        if (verbose == 1), disp(sprintf('Working with %s', 'PPMC' )); end
        %     disp('--------')
        jVmmASD_full = vmm_createNew(seqASD,  ALGS{s}, paramsASD);
        jVmmTD_full = vmm_createNew(seqTD,  ALGS{s}, paramsTD);
         disp(sprintf('Pr(A | A) = %f', vmm_getPr(jVmmTD_full, mapS(ab,'A'), mapS(ab,'A'))));
        
        % test TD sequences versus two models: model_1: TD_LOSO; model_2:
        % ASD_full
        for i = 1:length(seqTD)
            jVmmTD_LOSO = vmm_createLOSO(seqTD,  ALGS{s}, i,  paramsTD);
            logLikTD(i,1) = vmm_logEval(jVmmTD_LOSO, seqTD{i}.se);
            logLikTD(i,2) = vmm_logEval(jVmmASD_full, seqTD{i}.se);
            if (verbose == 1) ,   disp([ logLikTD(i,1), logLikTD(i,2), round((logLikTD(i,1) - logLikTD(i,2))*100)/100]); end
            clear jVmmTD_LOSO
            
        end
        disp(sprintf('epis= %d, delay= %d ds= %d \n' , epis, delay, ds));
        disp(sprintf('TD = %f', sum(logLikTD(:,1) > logLikTD(:,2))/length(seqTD)*100))
        resultsTD(m,n) = sum(logLikTD(:,1) > logLikTD(:,2))/length(seqTD)*100;
        
        for i = 1:length(seqASD)
            jVmmASD_LOSO = vmm_createLOSO( seqASD,  ALGS{s}, i,  paramsASD);
            logLikASD(i,1) = vmm_logEval(jVmmASD_LOSO, seqASD{i}.se);
            logLikASD(i,2) = vmm_logEval(jVmmTD_full, seqASD{i}.se);
            if (verbose == 1), disp([ logLikASD(i,1), logLikASD(i,2), round((logLikASD(i,1) - logLikASD(i,2))*100)/100]); end
            clear jVmmASD_LOSO
        end
        resultsASD(m,n) = sum(logLikASD(:,1) > logLikASD(:,2))/length(seqASD)*100;
        disp(sprintf('ASD= %f', sum(logLikASD(:,1) > logLikASD(:,2))/length(seqASD)*100));
        
        %for i = 1:length(seqASDF)
        %  jVmmASD_LOSO = vmm_createLOSO(map(ab, seqASD),  ALGS{s}, i,  paramsASD);
        %  logLikASDF(i,1) = vmm_logEval(jVmmTD_full,mapS(ab, seqASDF{i}.se));
        %  logLikASDF(i,2) = vmm_logEval(jVmmASD_full,mapS(ab, seqASDF{i}.se));
        %  disp([ logLikASDF(i,1), logLikASDF(i,2), logLikASDF(i,1) - logLikASDF(i,2)]);
        %  clear jVmmASD_LOSO
        %end
        %  disp(sprintf('ASDF= %f' , sum(logLikASDF(:,1) > logLikASDF(:,2))/length(seqASDF)*100))
        
    end
end

%save resultsKDX.mat resultsASD resultsTD

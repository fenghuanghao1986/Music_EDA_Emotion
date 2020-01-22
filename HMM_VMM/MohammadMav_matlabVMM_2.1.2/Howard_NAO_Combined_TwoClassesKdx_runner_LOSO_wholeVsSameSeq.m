
% A simple hands-on tutorial
% Browse the code to get the basics of how-to utilize this VMM tool
clear all
close all
clc
javaaddpath('F:\Lab Work\MohammadMavadati\MohammadMav_matlabVMM_2.1.2\vmm\vmm');
%%load the sequence of Both ASD and TD individuals + NAO experiments
PathData = 'F:\Lab Work\HMM_VMM\Nao_Experiments\Autism_Research\NAO_Experiment\Protocol_1\Howard_saved';
% GameSeg = 'KidTalking'
 GameSeg = 'NaoTalking'
% load( fullfile(PathData,['Part1_' GameSeg '_TD_ASD_GazeFeatSeq_forHMM']));
%%COntains the data for each interveention episodes of ASD individuals
load( fullfile(PathData,['Part1_' GameSeg '_TD_ASD_GazeFeatSeq_forHMM_EpisodeBased']));


%%
Num_EpisInter =3 %at most 3 sessions of intervensiton for ASD individuals
for i_Epis =1:Num_EpisInter
    ASD_Tot_SeqFeat_Subjs = ASD_Epis_FeatSubj(i_Epis,:)
    ASD_Epis_IndSubj
    ASD_Epis_SubjSess_ID
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
            seqASD_sameLength{itr} = Data(i_seq,:);
            subjASD_sameLength(itr) = ASD_Tot_Subj_list(i_Subj);
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
            seqTD_sameLength{itr} = Data(i_seq,:);
            subjTD_sameLength(itr) = TD_Tot_Subj_list(i_Subj);
            itr = itr+1;
        end
    end


    %% Choosing Classifying eye gaze based on one 
    ExperimentID = {'oneSeqPerSubj', 'fewSeqsPerSubj'};
%     exper = 'oneSeqPerSubj'
     exper = 'fewSeqsPerSubj'
    switch(exper)
        case 'oneSeqPerSubj'
            itr =1;%some of the Td seq are empty
            for (i_seq = 1:size(seqTD_OverallSubj,2) ) 
                if (~isempty(seqTD_OverallSubj{i_seq}))
                    seqTD{itr}.se = seqTD_OverallSubj{i_seq};
                    seqTD{itr}.sn = subjTD_List(i_seq);
                    TD_SNs(itr,1) = subjTD_sameLength(i_seq);
                    itr=itr+1;
                end
            end
            itr =1;%some of the Td seq are empty
            for (i_seq = 1:size(seqASD_OverallSubj,2) )
                if (~isempty(seqASD_OverallSubj{i_seq}))
                    seqASD{itr}.se = seqASD_OverallSubj{i_seq};
                    seqASD{itr}.sn = subjASD_List(i_seq);
                    ASD_SNs(itr,1) = subjTD_sameLength(i_seq);
                    itr=itr+1;
                end
            end


        case 'fewSeqsPerSubj'
            itr =1;%some of the Td seq are empty
            for (i_seq = 1:size(seqTD_sameLength,2) )
                if (~isempty(seqTD_sameLength{i_seq}))
                    seqTD{itr}.se = seqTD_sameLength{i_seq};
                    seqTD{itr}.sn = subjTD_sameLength(i_seq);
                    TD_SNs(itr,1) = subjTD_sameLength(i_seq);
                    itr=itr+1;
                end
            end     

            itr =1;%some of the Td seq are empty
            for (i_seq = 1:size(seqASD_sameLength,2) )
                if (~isempty(seqASD_sameLength{i_seq}))
                    seqASD{itr}.se = seqASD_sameLength{i_seq};
                    seqASD{itr}.sn = subjASD_sameLength(i_seq);
                    ASD_SNs(itr,1) = subjASD_sameLength(i_seq);
                    itr=itr+1;
                end
            end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global T

    verbose = 0;
    m = 0;
    k =18; % smoothing factor
    delay = 0; %starting point delay in coding

    for T = 5
        m = m + 1;
        n = 0;
        for ds = 18;
         k = ds;
            n = n + 1;
            epis = 1; % FF = 1, SF = 2, RE = 3;
    %         [seqTD, seqASD]=readDataSeqKdx(ds, T, epis, k, delay);

    %         createParams; % ALGS and other parameters of VMM is defined inside this function
             createParamsSMM % change d = 5
            % use AB with size = 5
            disp('---------------------------------------------------');
            if (verbose == 1), disp('working with AB={A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P }'); end
            disp('---------------------------------------------------');
            s = 3;
            % 3. run each of the VMM algorithms
            if (verbose == 1), disp(sprintf('Working with %s', 'PPMC' )); end
 %% TRAINING THE VMM using the first session of TD and ASD individuals
            if (i_Epis ==1)
                jVmmASD_full = vmm_createNew(seqASD,  ALGS{s}, paramsASD);
                jVmmTD_full = vmm_createNew(seqTD,  ALGS{s}, paramsTD);
                disp(sprintf('Pr(A | A) = %f', vmm_getPr(jVmmTD_full, mapS(ab,'A'), mapS(ab,'A'))));
                
            end
            
 %% TESTING THE OTHER 
            % test TD sequences versus two models: model_1: TD_LOSO; model_2:
            % ASD_full
            for i = 1:length(seqTD)
%                 jVmmTD_LOSO = vmm_createLOSO(seqTD,  ALGS{s}, i,  paramsTD);
%                 logLikTD(i,1) = vmm_logEval(jVmmTD_LOSO, seqTD{i}.se);
                logLikTD(i,1) = vmm_logEval(jVmmTD_full, seqTD{i}.se);
                logLikTD(i,2) = vmm_logEval(jVmmASD_full, seqTD{i}.se);
                if (verbose == 1) ,   disp([ logLikTD(i,1), logLikTD(i,2), round((logLikTD(i,1) - logLikTD(i,2))*100)/100]); end
                %clear jVmmTD_LOSO

            end
            disp(sprintf('epis= %d, delay= %d ds= %d \n' , epis, delay, ds));
            disp(sprintf('TD = %f', sum(logLikTD(:,1) > logLikTD(:,2))/length(seqTD)*100))
            resultsTD(m,n) = sum(logLikTD(:,1) > logLikTD(:,2))/length(seqTD)*100;
            Classification_TD = logLikTD(:,1) > logLikTD(:,2)


            for i = 1:length(seqASD)
%                 jVmmASD_LOSO = vmm_createLOSO( seqASD,  ALGS{s}, i,  paramsASD);
%                 logLikASD(i,1) = vmm_logEval(jVmmASD_LOSO, seqASD{i}.se);
                logLikASD(i,1) = vmm_logEval(jVmmASD_full, seqASD{i}.se);
                logLikASD(i,2) = vmm_logEval(jVmmTD_full, seqASD{i}.se);
                if (verbose == 1), disp([ logLikASD(i,1), logLikASD(i,2), round((logLikASD(i,1) - logLikASD(i,2))*100)/100]); end
                %clear jVmmASD_LOSO
            end
            resultsASD(m,n) = sum(logLikASD(:,1) > logLikASD(:,2))/length(seqASD)*100;
            disp(sprintf('ASD= %f', sum(logLikASD(:,1) > logLikASD(:,2))/length(seqASD)*100));

            Classification_ASD = logLikASD(:,1) > logLikASD(:,2)



            disp(' ASD Classification Results');
            disp([GameSeg '=> ' exper  ])
            disp('   SN ID  LogL(ASD,ASD) LogL(ASD,TD) ClassificationResults')
            disp([ ASD_SNs logLikASD(:,1) logLikASD(:,2)  Classification_ASD])
            disp (['OVERALL Results: (' GameSeg ' => ' exper ')'])
            disp(['Accuracy ASD recognition  using VMM: ' num2str(resultsASD) '(%)'])
            disp(['Accuracy TD recognition  using VMM: ' num2str(resultsTD) '(%)'])
            disp('********************************************************************');

        end
    end

    TrueLab = [zeros(size(Classification_TD,1),1) ;ones(size(Classification_ASD,1),1)]
    PredLab = double([~Classification_TD ; Classification_ASD])

    Overall_Conf = confusionmat(TrueLab,PredLab); 
    Overall_Acc = sum(diag(Overall_Conf))/sum(Overall_Conf(:));
    Overall_F1 = Funct_F1score(TrueLab, PredLab)



    % SavingFile = ['\Part1_' GameSeg '_TD_ASD_VMM_Classifications_' exper]
    %%D is VMM order
    VMM_order = paramsASD.vmmOrder %
    SavingFile = ['\Part1_' GameSeg '_TD_ASD_VMM_Classifications_' exper '_D_' num2str(VMM_order) 'IntervEpis_' num2str(i_Epis) 'Ep1Tr_Ep23Te' ]
%     save ([PathData, SavingFile], 'resultsASD' , 'ASD_SNs', 'logLikASD' , 'Classification_ASD', ... 
%             'resultsTD', 'TD_SNs', 'logLikTD' , 'Classification_TD', 'Overall_Conf', 'Overall_Acc', 'Overall_F1') 

clear  'resultsASD'  'ASD_SNs' 'logLikASD'  'Classification_ASD'   'resultsTD' 'TD_SNs' 'logLikTD' 
clear 'Classification_TD' 'Overall_Conf' 'Overall_Acc' 'Overall_F1'
clear ASD_Tot_SeqFeat_Subjs seqTD seqASD
end

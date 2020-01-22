function [Tot_SeqInd_Subjs,Tot_Subj_list,Tot_SeqFeat_Subjs]=Funct_makeSeqFrames_Gaze(Data,T_Seq_Seg,featId) 

% %%function: make the sequence of observation
%T_Seq_Seg = 5;%%number of consecutive frames to be conside as a sequence
%Data= ASD_NaoTalking;%type of the features we used
% featId=1 %(3 different types of feature)                     
%This function return the Index of the frames for each Sequecne and assign
%them separately inside a subject based structure. (Later on we can use the 'Tot_SeqInd_Subjs' to extract the 
%frames indices that corresponds to the same subjec (for all sessions))
            
            
    %define the Feature sequenc and corresponding lable for each sequence
    Data_Feat_Frame = Data.Feat_Tot(:,featId);
    SubjList = unique(Data.SubjList_Tot);
    NumSubj = size(SubjList,1);
    for i_Subj = 1: NumSubj
        Subj_ID = SubjList(i_Subj);

        tot_SubjSess = Data.SubjSessItr_Tot;
        SubjSess =num2str(Data.Unique_SubjSessItr_Tot);
        numFrames = size(Data.SubjSessItr_Tot,1);

        temp = SubjSess(:,1:end-4);%exclude the sessgion and game info (just keep subject info)
        temp = str2num(temp);
        Ind = find(temp==Subj_ID);
        Sessions = SubjSess(Ind,:);
        NumSess = size(Ind,1);
        Seq_FeatSubj=[];
        Seq_IndSubj =[];
        for i_Sess = 1:NumSess%%selected sessions that have the same subjec Session ID
            Diff = tot_SubjSess - str2num(Sessions(i_Sess,:));
            Index = find(Diff==0);
            %%for the selected Indicis make the sequence with the
            %%length of T_Seq_Seg and then concantenate the
            %%sequence from all NumSess
            NumSeq = floor(numel(Index)/T_Seq_Seg);
            Seq=[];
            IndFrame_Seq=[];
            for i_Seq =1:NumSeq
                ind_Frames = Index([1:T_Seq_Seg]+T_Seq_Seg*(i_Seq-1));
                Seq(i_Seq,:) = Data_Feat_Frame(ind_Frames)';%is (NumSeq x T_Seq_Seg)
                IndFrame_Seq (i_Seq,:) = ind_Frames' ;% is (NumSeq x T_Seq_Seg)
            end
            Seq_FeatSubj  = [Seq_FeatSubj ;Seq];
            Seq_IndSubj  = [Seq_IndSubj ;IndFrame_Seq]  ; 
        end
        Tot_SeqFeat_Subjs{i_Subj} = Seq_FeatSubj;
        Tot_SeqInd_Subjs{i_Subj} = Seq_IndSubj;
        Tot_Subj_list(i_Subj) = Subj_ID;

    end


end

%% The Folllowing FUnction was written in a wrong data structure, and hard to be used
%  function [FeatLabSubj_tot,SubjList_Total]=Funct_makeSeqFrames_Gaze(Data,T_Seq_Seg,Ind_Class)
%         
%             Feature = Data. Feat_Tot;
%             NumSubjSess = Data.Num_SubjSessItr_Tot;
%             LIST_IDs =  Data.SubjSessItr_Tot;
%             SubjList_Total=[];
%             
%             for (itr = 1:NumSubjSess)
%                 ID = Data.Unique_SubjSessItr_Tot(itr,:)
% 
%                 Ind = strfind(LIST_IDs', ID)';
%                 SubjectID{itr} = Data.SubjList_Tot(Ind)
%                 NumFrame = size(Ind,1);
%                 Remainder = mod(NumFrame,T_Seq_Seg)
%                 Feat = Feature(Ind(1:end-Remainder),:);
%                 NumSeq = size(Feat,1)/T_Seq_Seg;
%                 %Each element of Feat_Sequence contains specific set of
%                 %observation, so we can use then independently
%                 FeatLabSubj_tot{1}.Feat_Sequence{itr} = reshape(Feat(:,1),T_Seq_Seg,NumSeq);
%                 FeatLabSubj_tot{2}.Feat_Sequence{itr} = reshape(Feat(:,2),T_Seq_Seg,NumSeq);
%                 FeatLabSubj_tot{3}.Feat_Sequence{itr} = reshape(Feat(:,3),T_Seq_Seg,NumSeq);
%                 
%                 
%                 FeatLabSubj_tot{1}.SubjectID{itr} =SubjectID{itr}
%                 FeatLabSubj_tot{2}.SubjectID{itr} =SubjectID{itr}
%                 FeatLabSubj_tot{3}.SubjectID{itr} =SubjectID{itr}
% 
%                 SubjList_Total = [SubjList_Total ; SubjectID{itr}]
%                 
%                 if (strcmp(Ind_Class, 'TD'))
%                     FeatLabSubj_tot{1}.Label_Sequence{itr} = 1*ones(1,NumSeq);
%                     FeatLabSubj_tot{2}.Label_Sequence{itr} = 1*ones(1,NumSeq);
%                     FeatLabSubj_tot{3}.Label_Sequence{itr} = 1*ones(1,NumSeq);
%                     
%                 elseif (strcmp(Ind_Class, 'ASD'))  
%                     FeatLabSubj_tot{1}.Label_Sequence{itr} = 2*ones(1,NumSeq);
%                     FeatLabSubj_tot{2}.Label_Sequence{itr} = 2*ones(1,NumSeq);
%                     FeatLabSubj_tot{3}.Label_Sequence{itr} = 2*ones(1,NumSeq);
%                 else 
%                     disp('Inappropriate Class Type (only ASD or TD)')
%                 end
%             end
%  end
%         
%  
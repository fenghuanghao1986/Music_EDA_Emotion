function VMM_Results = Prob_TransitionVMM(jVmm_full, ab, T)
%mohammad Mavadati wrote this function on feb 2014
%ab is jave object 
%T => number of alphabeds are 2^T

            numStages = 4 %number of alphabets in each frames (level of dependencies between alphabet)
            numSymbol = 2^T;%all possibel number of stages
            NumCombStages = numSymbol^numStages;
            TotNumCombStages = numSymbol* NumCombStages;

            %% Calcuate the probability for each stage

            SeqSymb = [];
            Vec = [1: numSymbol]
            tempV = Vec';
            Temp1 = Vec;
            NewSymbol = tempV;
            SymbolList = {NewSymbol};
            for i_Stage = 2:numStages

                    tempV = repmat(tempV, numSymbol,1)
                    sortedSymbols = sortrows(repmat(NewSymbol,numSymbol,1));
                    NewSymbol = [sortedSymbols tempV];

                    SymbolList{i_Stage} = NewSymbol

            end

            % symbol = 'ABCD'
            symbol = (char(64+(1:2^T)))

            % Alphabets='ABCD' ;%T =2 => 4 Symbols
            sizeAlphabets =size(symbol,2)
            for i_Stage = 1:numStages
                tot_Symb=[];%total symbols for each stage
                for i_sym = 1: size(SymbolList{i_Stage},1)
                    symb = symbol( SymbolList{i_Stage}(i_sym,:))
                    tot_Symb = [tot_Symb ; symb];
                    for i_Alphabet =1:sizeAlphabets
                        selected_Alphabed = symbol(i_Alphabet);
                        %prob (selected_Alphabed | symb)
                        prob_VMM_iSeg{i_Stage}(i_sym,i_Alphabet)= vmm_getPr(jVmm_full, mapS(ab,selected_Alphabed), mapS(ab,symb));
                    end
                end
                SeqSymbols{i_Stage} = tot_Symb;

            end
            
VMM_Results.SeqSymbols = SeqSymbols;
VMM_Results.ProbSeqSymbols = prob_VMM_iSeg;
VMM_Results.Info.T_Seq = T;
VMM_Results.Info.symbol = symbol;            
            
end

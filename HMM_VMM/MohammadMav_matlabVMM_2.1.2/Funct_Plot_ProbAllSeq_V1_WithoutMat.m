    
function [Tot_Prob,Tot_Symb ] = Funct_Plot_ProbAllSeq_V1_WithoutMat(P0_Symb,VMM_Prob, T, numStages,fileID)
%%Funct_Plot_ProbAllSeq_V1_WithoutMat is exactly similar to
%%Funct_Plot_ProbAllSeq_V1, but since the we had OutOFMemory Problem, the
%%step related to making Mat_Imgage is excluded in this file.

%% Representing the probability of every sequence as an image
    %rows correspond to the probability of each sequence of, column corresponds
    %to the stages (numStages) that we would have;
%     P0_Symb = TD_P0_Symb;
%     VMM_Prob = TD_VMM_Results;
% T defines the possible numbe of symbols (2^T symbol will be defined)
    %%Define a function for ploting the symbols 
    Mat_Prob = [P0_Symb]';
    Coef = 2^T;% multiplyingCoef for each iteration
    Symbols = (char(64+(1:2^T)));
    for i_Stage =1:numStages
          VMM_Prob.SeqSymbols;  
          Temp_Symbol = VMM_Prob.SeqSymbols{i_Stage};
          %Temp_ProbStage = VMM_Prob.ProbSeqSymbols{i_Stage}(:);

          size_MatProb= size(Mat_Prob,1);
          t_Prob=[];%keep track of the probability for each sequence (VMM getPr resutls)
          s_Symb=[];%keep track of the symbol sequences
          t_ProbStage = [];
          for i = 1:size_MatProb
            t = repmat(Mat_Prob(i,:),Coef,1);
            t_Prob = [t_Prob; t];
            s = repmat(Temp_Symbol(i,:),Coef,1);
            s= [s Symbols(:)];
            s_Symb = [s_Symb; s];
            
            %
            t_ProbStage = [t_ProbStage; VMM_Prob.ProbSeqSymbols{i_Stage}(i,:)'];
            
          end
         
%          Mat_Prob = [t_Prob Temp_ProbStage];
        Mat_Prob = [t_Prob t_ProbStage];

        Tot_Prob{i_Stage} = Mat_Prob;   
        Tot_Symb{i_Stage} = s_Symb ;
        
%%Funct_Plot_ProbAllSeq_V1_WithoutMat: this section will be commented
% 
%         %%Return the mat_Image which contains all possible sequences
%         %%intensity in almost square format (good for ploting)(Num row = num possible sequences, Num Unique columns = num stages in sequnce)
%         mat_Image{i_Stage} = plotProbImage (Mat_Prob,s_Symb,T , 1, fileID);% set flag_figure==1 to plot the results

    end
end

function [mat]=plotProbImage (Mat_Prob,s_Symb,T , flag_figure,fileID)
%if flag_figure ==1 plot the figures
 %%ploting the probability of each symbol as an Image ()
   size_MatProb= size(Mat_Prob,1);
   mat=[];
   for i=1:size(Mat_Prob,2)
       CoefIncrease = floor(size(Mat_Prob,1)/size(Mat_Prob,2)); %%this increasing make the final probability matrix square matrix (goood for ploting)
       mat = [mat repmat(Mat_Prob(:,i),1,CoefIncrease)];
   end
   
   
   if(flag_figure == 1)
    figure('units','normalized','outerposition',[0 0 1 1]);
    imagesc(1-mat,[0 1]);
    colormap(jet);
    colormap(gray);
    LabelColorMap = {'0','0.1','0.2', '0.3', '0.4','0.5',...
    '0.6','0.7' , '0.8', '0.9' ,'1.0'}
    colorbar('YTickLabel',LabelColorMap(end:-1:1) );
   
    
    xlabel ( 'Sequence ID');
    h = get(gca,'ylabel');
    pos = get(h,'position');
    set(gca,'yTick',[]);
    %set(gca,'xTick',[1:2]);
    ColIm = size(Mat_Prob,2);
    set(gca,'XTick',[ColIm/2  : size(mat,2)/ColIm : size(mat,2) ]);
    set(gca,'XTickLabel',[1 : 1 : ColIm]);
    set(get(gca, 'YLabel' ), 'Rotation' ,0 );
     
    yy = ylabel(s_Symb);
    ylimits = get(gca,'ylim');

    pos = [-size(mat,2)/10  ylimits(2)] ;
    set(h,'position',pos);

    title ({[fileID ' Probability of Sequence of Alphabeets (T^2= ' num2str(T^2) ',#Seq= ' num2str(size(Mat_Prob,2)) ')'];...
        ['Top to Buttom:' s_Symb(1,:) ', ' s_Symb(2,:)  ', ... ,' s_Symb(end,:) ] },...
        'fontsize', 14);
    savingFile = 'C:\Documents and Settings\Vision\My Documents\Dave\Gaze Project\MohammadMavadati\MiamiProjectGaze\Figure\'
    fileName = [fileID '_Seq_Prob_T' num2str(T) '_NumSeq' num2str(size(Mat_Prob,2))];
    fullFilePath = fullfile(savingFile,fileName);
    saveas(gcf, [fullFilePath '.fig']);
    saveas(gcf, [fullFilePath '.png']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %plot sequence probability with probability higher than a thereshold
    Thresh_Prob = 0.2;
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    Mat_Thresh= zeros(size(mat));
    ind = find(mat >Thresh_Prob);
    Mat_Thresh(ind) = mat(ind);
    imagesc(Mat_Thresh,[0 1]);
    colormap(gray);
    LabelColorMap = {'0','0.1','0.2', '0.3', '0.4','0.5',...
    '0.6','0.7' , '0.8', '0.9' ,'1.0'};
    colorbar('YTickLabel',LabelColorMap(1:end) );
   
    
    xlabel ( 'Sequence ID');
    h = get(gca,'ylabel');
    pos = get(h,'position');
    set(gca,'yTick',[]);
    %set(gca,'xTick',[1:2]);
    ColIm = size(Mat_Prob,2);
    set(gca,'XTick',[ColIm/2  : size(mat,2)/ColIm : size(mat,2) ]);
    set(gca,'XTickLabel',[1 : 1 : ColIm]);
    set(get(gca, 'YLabel' ), 'Rotation' ,0 );
     
    yy = ylabel(s_Symb);
    ylimits = get(gca,'ylim');

    pos = [-size(mat,2)/10  ylimits(2)] ;
    set(h,'position',pos);

    title ({[fileID ' Threshold Probability (' num2str(Thresh_Prob) ')of Sequence  of Alphabeets (T^2= ' num2str(T^2) ',#Seq= ' num2str(size(Mat_Prob,2)) ')'];...
        ['Top to Buttom:' s_Symb(1,:) ', ' s_Symb(2,:)  ', ... ,' s_Symb(end,:) ] },...
        'fontsize', 14);
    savingFile = 'C:\Documents and Settings\Vision\My Documents\Dave\Gaze Project\MohammadMavadati\MiamiProjectGaze\Figure\'
    fileName = [fileID '_Seq_Prob_TreshProb_T' num2str(T) '_NumSeq' num2str(size(Mat_Prob,2))];
    fullFilePath = fullfile(savingFile,fileName);
    saveas(gcf, [fullFilePath '.fig']);
    saveas(gcf, [fullFilePath '.png']);
    
    
   end
    
    
    
    
%     
%     ResolutionCol = size(mat,2)/ColIm;
%     set(gca,'XTick',[1 : 2 : size(mat,2) ])
%     set(gca,'XTickLabel',[1 : 1 : ColIm])
  
   
    
end
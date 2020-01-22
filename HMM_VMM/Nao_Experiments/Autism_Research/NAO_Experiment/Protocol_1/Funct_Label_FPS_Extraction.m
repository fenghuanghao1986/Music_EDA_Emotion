       
function [LAB,FPS,StartingFrame ]=Funct_Label_FPS_Extraction(Text_DIR)
%%This function load the content of .txt file and base on the keywords
%%'[STARTCODES]' it find the begining of the coding section and then it
%%only extract the Frame Per Second that was assumed for coding and
%%Extracted the coded lables for the video.
%%starting frame is the Index of that the coding has been started.
          Text_DIR        ;   
          Text1 =  textread([Text_DIR '.txt'],'%q');
          Ind_StartLab = find(strcmp(Text1,'[STARTCODES]'));
          Ind_EndLab = find(strcmp(Text1,'[ENDCODE]'));
          NumFrames_Labeled= Ind_EndLab - Ind_StartLab -1;
          Num_Columns= 3; %TXT file has three columns
          
          %%Extract only Corresponding labels out of each TXT file
          StartingFrame= str2num(Text1{Ind_StartLab+1});
          Labels = (Text1(Ind_StartLab+3 : Num_Columns : Ind_EndLab-2));
          
          %%change all the 'NC' to '-1'
          if length(find(strcmp(Labels ,'NC')))>0
              Ind_NotCoded= find(strcmp(Labels ,'NC'));
              for i_NC = 1: length(Ind_NotCoded)
                Labels{Ind_NotCoded(i_NC)} = '-1';
              end
          end
          
          NumFrames = length(Labels);
          for i_frames=1:NumFrames
        
            LAB(i_frames,1) = str2num(Labels{i_frames});
          end
          %%find the frame per second of that is coded
          ind = strfind(Text1{Ind_StartLab-1} ,'=');%extract index for begning of FPS
          FPS = Text1{Ind_StartLab-1}(ind+1: end); %%frame rate coded for the labels
          FPS = str2num(FPS);
end
          
          
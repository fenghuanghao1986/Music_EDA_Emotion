
% Dec 10, 2015

clc
close all
clear all
warning off

InpPool={'A15K','O14AJ','O14AK'};
KindPool={'Raw','Filtered'};
InpMode={'Expanded','Original','ShiftLef','ShiftRig'};
InpEvent={'Button','Audio','Reach','Video','Random'};
InpDirection={'CH1L','CH2L','CH3L','CH1R','CH2R','CH3R'};

for x=1:3
    
    InpP=InpPool{x};               

    for q=1:2
        
        InpK=KindPool{q};
        BTrain=[];
        BTest=[];
        
        for y=1:5
            
           InpE=InpEvent{y};
            
           if strcmp(InpP,'A15K')
               if strcmp(InpE,'Button') || strcmp(InpE,'Random')
                   if strcmp(InpK,'Raw')
                      Div=55;
                   else
                      Div=60;
                   end
               else
                   if strcmp(InpK,'Raw')
                      Div=54;
                   else
                      Div=59;
                   end
               end
            else
               if strcmp(InpE,'Button') || strcmp(InpE,'Random')
                  if strcmp(InpK,'Raw')
                     Div=56;
                  else
                     Div=61;
                  end
               else
                  if strcmp(InpK,'Raw')
                     Div=55;
                  else
                     Div=60;
                  end

               end
            end
        
            for h=1:4
                
                InpM=InpMode{h};
        
                for z=1:6
                    
                    InpD=InpDirection{z};
                    
                    fid=fopen(['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\',...
                        InpP, '\' , InpK, '\', InpM, '\', InpE, '\', InpD, '\', 'Labels.txt']);
                    A=fread(fid);
                    fclose(fid);
                    
                    Len=numel(A);
                    EachAdd=Len/Div;
                    TestSiz=round(0.2*EachAdd);
                    TrainSiz=EachAdd-TestSiz;
                    ATrain=A(1:TrainSiz*Div);
                    ATest=A(TrainSiz*Div+1:end);
                    
                    
                    BTrain=cat(1,BTrain,ATrain);
                    BTest=cat(1,BTest,ATest);
                    
                end
            end         
        end
       
        if strcmp(InpK,'Raw')
           fName1 = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', ...
                   InpK, InpP, 'TrainLabels.txt'];        
           fid1 = fopen(fName1,'w');    
           fwrite(fid1,BTrain);
           fclose(fid1);
      
           fName2 = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', ...
                 InpK, InpP, 'TestLabels.txt'];        
           fid2 = fopen(fName2,'w');    
           fwrite(fid2,BTest);
           fclose(fid2);
        else
            fName11 = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', ...
                   InpK, InpP, 'TrainLabels.txt'];        
           fid11 = fopen(fName11,'w');    
           fwrite(fid11,BTrain);
           fclose(fid11);
      
           fName22 = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', ...
                 InpK, InpP, 'TestLabels.txt'];        
           fid22 = fopen(fName22,'w');    
           fwrite(fid22,BTest);
           fclose(fid22);
        end
            

    end

end
                    



            

    
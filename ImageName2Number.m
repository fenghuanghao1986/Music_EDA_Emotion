
clc
close all
clear all
warning off

InpPool={'A15K','O14AJ','O14AK'};
KindPool={'Filtered','Raw'};
InpMode={'Expanded','Original','ShiftLef','ShiftRig'};
InpEvent={'Button','Audio','Reach','Video','Random'};
InpDirection={'CH1L','CH2L','CH3L','CH1R','CH2R','CH3R'};

for x=1:3
    
    InpP=InpPool{x};
    
    for q=1:2
        
        InpK=KindPool{q};
    
        for h=1:4
                
            InpM=InpMode{h};
     
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
              
                for z=1:6
                    
                    InpD=InpDirection{z};
                    
                    fid=fopen(['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\',...
                            InpP, '\' , InpK, '\', InpM, '\', InpE, '\', InpD, '\', 'Labels.txt']);
                    A=fread(fid);
                    fclose(fid);
                    
                    Len=numel(A);
                    EachAdd=Len/Div;
                                       
                    for c=1:EachAdd
                        
                        if c<10                           
                           NumberBound=['00',num2str(c)];
                        elseif c>=10 && c<100
                           NumberBound=['0',num2str(c)];
                        else
                           NumberBound=num2str(c); 
                        end
                            
                        
                        name=['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\',...
                            InpP, '\' , InpK, '\', InpM, '\', InpE, '\', InpD, '\', ...
                            InpP, '-', InpK, '-', InpM, '-', InpE, '-', InpD, '-', NumberBound, '.png'];
                    
                        A=imread(name);
                        
                        imwrite(A,['C:\Users\Lab User\Desktop\', InpP, '\' , InpK, '\', InpM, '\', InpE, '\', InpD, '\',NumberBound, '.png']);
                        
                    end
                    
                end
            end
        end
    end
end
                    
                    
                    
                    
                    
                    
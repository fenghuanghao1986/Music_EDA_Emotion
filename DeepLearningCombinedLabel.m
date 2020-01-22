
clc
close all
clear all
warning off

InpPool={'A15K','O14AJ','O14AK'};
InpMode={'Expanded','Original','ShiftLef','ShiftRig'};
InpEvent={'Button','Audio','Reach','Video','Random'};
InpDirection={'CH1L','CH2L','CH3L','CH1R','CH2R','CH3R'};

for x=1:3
    
    InpP=InpPool{x}
    
        for y=1:5
            
            InpE=InpEvent{y}
            
            if strcmp(InpP,'A15K')
                if strcmp(InpE,'Button') || strcmp(InpE,'Random')
                    Div=55;
                else
                    Div=54;
                end
            else
                if strcmp(InpE,'Button') || strcmp(InpE,'Random')
                    Div=56;
                else
                    Div=55;
                end
            end
        
            for h=1:4
                
                InpM=InpMode{h}
        
                for z=1:6
                    
                    InpD=InpDirection{z}
                    
                    fid=fopen(['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\',...
                        InpP, '\Raw\', InpM, '\', InpE, '\', InpD, '\', 'Labels.txt']);
                    A=fread(fid);
                    fclose(fid);
                    
                    Len=numel(A);
                    EachAdd=Len/Div;
                    TestSiz=round(0.2*EachAdd);
                    TrainSiz=EachAdd-TestSiz;
                    ATrain=A(1:TrainSiz*Div);
                    ATest=A(TrainSiz*Div+1:end);
                    
                    fName1 = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', ...
                        InpP, 'TrainLabels.txt'];        
                    fid1 = fopen(fName1,'w');
                    n1=0;
                    for i=1:TrainSiz 
                        fprintf(fid1,'%s \n',ATrain(n1*Div+1:(n1+1)*Div));  
                        n1=n1+1;                        
                    end
                    
                    
                    fName2 = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', ...
                        InpP, 'TestLabels.txt'];        
                    fid2 = fopen(fName2,'w'); 
                    n2=0;
                    for i=1:TestSiz  
                        fprintf(fid2,'%s \n',ATest(n2*Div+1:(n2+1)*Div));  
                        n2=n2+1;
                    end
                    
                end
            end
           
            
        end
        fclose(fid1);
        fclose(fid2);
end
                    



            

    
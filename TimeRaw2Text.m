
clc
close all
clear all
warning off

InpPool={'A15K','O14AJ','O14AK'};
InpEvent={'Button','Audio','Reach','Video','Random'};
InpDirection={'CH1L','CH2L','CH3L','CH1R','CH2R','CH3R'};

for x=1:3
    
    InpP=InpPool{x};
    
    for y=1:5
        
        InpE=InpEvent{y};
        
        for z=1:6
            
            InpD=InpDirection{z};
            
            name=[InpP,'-',InpE,'-',InpD];
            
            load(name);
            E=DownRawSignal;
            s1=numel(E);
            s2=size(E{1},2);
            A=zeros(s1,s2);
            
            for i=1:s1
    
                A(i,:)=E{i};
    
            end
            dlmwrite([name,'.txt'],A);
            
        end
    end
end
            

    
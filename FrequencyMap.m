
function [DownSampled2D,Vector,mn]=FrequencyMap(InputMap,name,Circuled)

InputMap=double(InputMap);

if strcmp('Radial',name)
    
    Temp=[zeros(255,127),ones(255,1),zeros(255,127)];
    degree=2.4;
    beams=0:degree:(360-degree);
    A=0;
    for i=1:numel(beams)
        
        A=A+degree_rotation(Temp,beams(i));
        
    end
    
    A(find(A>1))=1;

    if Circuled==1
    
       load CirculeTemp
       percent=0.3;
       [a,b]=size(r);
       a1=round(a/percent);
       if mod(a1,2)~=0
           a1=a1+1;
       end
       r1=padarray(r,[abs(a1-a)/2,abs(a1-a)/2]);
       o=double(A).*double(imresize(r1,size(A),'nearest'));
       
    else
        o=A;
    end          
    
    [mn]=find(o==1);
    
    Tem=imresize(o,size(InputMap),'nearest');
    TemMap=Tem.*InputMap;
    DownSampled=imresize(TemMap,[255,255],'nearest');
    DownSampled2D=DownSampled.*o;
    Vector=DownSampled2D(mn)';

elseif strcmp('Spiral',name)
    
    load LinLogTemplate        % if 'LinearSpiral' is needed please use LinearMap!!   
    A=LogMap;
    A(find(A>1))=1;
    
    if Circuled==1
    
       load CirculeTemp
       percent=0.3;
       [a,b]=size(r);
       a1=round(a/percent);
       if mod(a1,2)~=0
           a1=a1+1;
       end
       r1=padarray(r,[abs(a1-a)/2,abs(a1-a)/2]);
       o=double(A).*double(imresize(r1,size(A),'nearest'));
       
    else
        o=A;
    end           
    
    mn=zeros(size(LogCoordinates,1),1); % if 'LinearSpiral' is needed please use LinearCoordinates!!
    for bb=1:size(LogCoordinates,1)
        
        mn(bb)=sub2ind([255 255],LogCoordinates(bb,1),LogCoordinates(bb,2));
        if o(mn(bb))==0
            CutIndex=bb;
            break
        end
        
        CutIndex=bb;

    end
    
    Tem=imresize(o,size(InputMap),'nearest');
    TemMap=Tem.*InputMap;
    DownSampled=imresize(TemMap,[255,255],'nearest');
    DownSampled2D=DownSampled.*o;
%     Vector=DownSampled2D(mn(1:CutIndex))';
    Vector=DownSampled2D(mn(1:18402))';
    
end


        
        
    

function out=degree_rotation(f,degree)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by:
%         
%               Hosein M.Golshan (July 21,2011).
%               DSP Research Labratory, Department of Electrical
%               Engineering, University of Guilan, Rasht, Iran.
%               Email: h.golshan@msc.guilan.ac.ir
%                      h.golshan.m@gmail.com
%               
% Discussion:
%               degree_rotation performs clockwise rotation on the input
%               matrix, f.
%               'degree' expresses the amount of rotarion
%               
%               Alert:
%                      The input matrix must be square. Such as 2*2, 3*3, .... 
%              
%               Example: 70" rotation of 'f':
%                        
%                        f=randn(101,101);
%                        o=degree_rotation(f,70);
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             

[m,n]=size(f);
out=zeros(m,n);

if degree>360
    degree=mod(degree,360);
end

if m~=n
    ERROR='ERROR: input matrix must be square'
else
    if mod(m,2)==0
        num=m/2;
    else 
        num=(m-1)/2;
    end
    for i = 1:num
        g1=f(i:end-(i-1),i)';
        g1=g1(end:-1:1);
        g2=f(i,i+1:end-(i-1));
        g3=f(i+1:end-(i-1),end-(i-1));
        g3=g3';
        g4=f(end-(i-1),i+1:end-(i-1)-1);
        g4=g4(end:-1:1);
        g=[g1,g2,g3,g4];
        t=numel(g);
        k=round(degree/(360/t));
        if k>0
           d=zeros(size(g));
           d(k+1:end)=g(1:end-k);
           d(1:k)=g(end-(k-1):end);
           d1=d(1:t/4+1);
           f(i:end-(i-1),i)=d1(end:-1:1);
           f(i,i+1:end-(i-1))=d(t/4+2:2*t/4+1);
           f(i+1:end-(i-1),end-(i-1))=d(2*t/4+2:3*t/4+1);
           d2=d(3*t/4+2:end);
           f(end-(i-1),i+1:end-(i-1)-1)=d2(end:-1:1);
        end
    end
out=f;    
end



function o=SpiralMatching(Input)

Input=double(Input);
A = dlmread('C:\Users\Lab User\Desktop\51.txt');
if min(A(:))==0
    A=A+1;
end

B=[];

for i=2:size(A,1)
    if A(i,:)-A(i-1,:)==0
        continue
    end
    
    B=[B;A(i,:)];
        
end

L=max(A(:))-min(A(:));
D=zeros(L,L);

for n=1:size(B,1)
    
    D(B(n,1),B(n,2))=1;
    
end
D=D(1:255,1:255);

figure; imshow(D,[])
E=imresize(D,[255,9000],'nearest');
figure; imshow(E,[])
ER=imresize(E,[255,255],'nearest');
figure; imshow(ER,[])
o=ER;
G=abs(ER-D);
figure; imshow(G,[])
max(G(:))

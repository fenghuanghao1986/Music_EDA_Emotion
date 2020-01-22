

A = dlmread('C:\Users\Lab User\Desktop\LinearSpiral.txt');
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


% D=[D;zeros(1,255)];
D=D(1:255,1:255);
LinearCoordinates=B;
LinearMap=D;



A = dlmread('C:\Users\Lab User\Desktop\LogSpiral.txt');
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


D=[D;zeros(1,255)];
D=D(1:255,1:255);
LogCoordinates=B;
LogMap=D;

figure; subplot(1,2,1); imshow(LinearMap,[]); subplot(1,2,2); imshow(LogMap,[])
save('LinLogTemplate','LinearMap','LinearCoordinates','LogMap','LogCoordinates')






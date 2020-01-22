
function [o] = Block_Cropper(Input,m,n,sizeORblock)

% By Hosein M. Golshan
% Last Update: May 27, 2016

Input = double(Input);
[x,y] = size(Input);

if m>x || n>y
    o=[];
    disp('the size of block must be smaller than the size of the input');
    return;
end

if strcmp(sizeORblock,'block')
    
   PadRow = mod(x,m);
   PadCol = mod(y,n);

   if PadRow~=0
      Input = [Input;Input(x-(m-PadRow)+1:x,:)];
   end

   if PadCol~=0
      Input = [Input,Input(:,y-(n-PadCol)+1:y)];
   end

   [x1,y1] = size(Input);
   RowSize = x1/m;
   ColSize = y1/n;
   o = cell(m,n);

   for i = 1:m
       for j = 1:n
        
           D = Input(RowSize*(i-1)+1:RowSize*i,...
            ColSize*(j-1)+1:ColSize*j); 
%            o{i,j} = mean(D(:));
           o{i,j} = var(D(:));
%            o{i,j} = range(D(:));
           
       end
   end
   
else
   
   PadRow = mod(x,m);
   PadCol = mod(y,n);
   
   if PadRow~=0
      PadRow1 = m*ceil(x/m)-x; 
      Input = [Input;Input(x-(PadRow1)+1:x,:)];
   end

   if PadCol~=0
      PadCol1 = n*ceil(y/n)-y;
      Input = [Input,Input(:,y-(PadCol1)+1:y)];
   end
   
   [x1,y1] = size(Input);
   RowSize = x1/m;
   ColSize = y1/n;
   o = cell(RowSize,ColSize);

   for i = 1:RowSize
       for j = 1:ColSize
        
           D = Input(m*(i-1)+1:m*i,...
            n*(j-1)+1:n*j); 
%            o{i,j} = mean(D(:));
           o{i,j} = var(D(:));
%            o{i,j} = range(D(:));           
        
       end
   end
   
end

o = cell2mat(o);

% A2=cell2mat(o);  
% figure; subplot(2,2,1); imshow(Input,[])
% subplot(2,2,2); imshow(A2,[]);
% K=abs(A2-Input);
% K1=max(K(:));
% subplot(2,2,[3,4]); imshow(K,[]); title(num2str(K1)) 

        
        





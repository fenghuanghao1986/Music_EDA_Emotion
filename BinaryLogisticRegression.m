
function [W01_t]= BinaryLogisticRegression(train0,train1,percision,InitialWeight)
%%% Binary Logestic Function

%%% Training Phase
train0=double(train0); 
train1=double(train1);

% W01_t = randn(784,1);
% W01_t = InitialWeight*ones(784,1);
W01_t = InitialWeight*ones(size(train0,2),1);

traindimension0=size(train0,1);
traindimension1=size(train1,1);


y = [0*ones(1,traindimension0)'; 1*ones(1,traindimension1)']; 
A = [train0(1:traindimension0,:); train1(1:traindimension1,:)];
eta = 0.1;
alpha=zeros(size(A,1),1);
iii=1;
loopnumber=0;

while (iii==1 || od > 0) & loopnumber<20000
    
    iii=0;
    for i = 1:size(A,1) 
        alpha(i) = mysigmoid(W01_t' * A(i,:)');
    end

    error = eta * A' * (alpha - y);
    W01_t1 = W01_t - error; 

    od = numel(find(error>percision));
    
    W01_t=W01_t1;
    
    loopnumber=loopnumber+1;
end







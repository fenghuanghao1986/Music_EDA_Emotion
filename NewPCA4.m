
function [TrainPro,NewBasis]=NewPCA4(Input,Accuracy)

% Dec. 14, 2015 HG

XTrain=double(Input);

Mean=repmat(mean(XTrain),size(XTrain,1),1);
STD=repmat(std(XTrain),size(XTrain,1),1);
NormalizedTrain=(XTrain-Mean)./STD;

% pca doesn't show the eign vector corresponding to eign value equal to zero!! you can use svd/eig instead.
[EignVector,CompleteTrain,EignValue]=pca(NormalizedTrain); 

Den=sum(EignValue);
error=1;
k=0;

while error>Accuracy || k>numel(EignValue)
    
    k=k+1;
    error=1-(sum(EignValue(1:k))/Den);
    
end

TrainPro=NormalizedTrain*EignVector(:,1:k);
NewBasis=EignVector(:,1:k);




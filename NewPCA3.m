
function [TrainPro,TestPro]=NewPCA3(Train,Test,Accuracy)

% Nov. 3, 2015 HG

XTrain=double(Train);
XTest=double(Test);

Mean=repmat(mean(XTrain),size(XTrain,1),1);
NormalizedTrain=(XTrain-Mean);

Mean=repmat(mean(XTest),size(XTest,1),1);
NormalizedTest=(XTest-Mean);

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
TestPro=NormalizedTest*EignVector(:,1:k);




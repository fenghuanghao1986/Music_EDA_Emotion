
function [TrainPro,TestPro]=CorrectPCA(Train,Test,Accuracy)

% Sep. 19, 2016.

XTrain=double(Train);
XTest=double(Test);

meanTrain = mean(XTrain);
stdTrain = std(XTrain);

Mean=repmat(meanTrain,size(XTrain,1),1);
STD=repmat(stdTrain,size(XTrain,1),1);
NormalizedTrain=(XTrain-Mean)./STD;

Mean=repmat(meanTrain,size(XTest,1),1);
STD=repmat(stdTrain,size(XTest,1),1);
NormalizedTest=(XTest-Mean)./STD;
   
% pca doesn't show the eign vector corresponding to eign value equal to zero!! you can use svd/eig instead.
[EignVector,~,EignValue]=pca(NormalizedTrain);

Den=sum(EignValue);
error=1;
k=0;

while error>Accuracy || k>numel(EignValue)
    
    k=k+1;
    error=1-(sum(EignValue(1:k))/Den);
    
end

TrainPro=NormalizedTrain*EignVector(:,1:k);
TestPro=NormalizedTest*EignVector(:,1:k);







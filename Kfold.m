
function [Train, Test]=Kfold(Input, kfold, SizOfInterest, Return_Fold)

% Example: [Train,Test]=Kfold(randn(10,5),4,8,2);
% Return_Fold: it is an integer value between 1 and kfold that returns the
% specified fold only.

Train = cell(kfold, 1);
Test = cell(kfold, 1);

Input = double(Input(1:SizOfInterest,:));

if mod(size(Input, 1), kfold) ~= 0
    disp('Error: "size(Input(1:SizOfInterest,:),1)" should be devisible by "kfold"!!!')
    Train='Error';
    Test='Error';
    return
end
       
block = size(Input, 1)/kfold;

for k = 1 : kfold
    
    if kfold == 1
        disp('Error: please set "k">1 !!!'); 
        Train='Error';
        Test='Error';
        break; 
    end
    
    if k == 1
        Train(k, 1)={Input(1:(kfold - 1)*block,:)};
        Test(k, 1) = {Input((kfold - 1)*block + 1:end,:)};
        
    elseif k == kfold
        Train(k, 1)={Input(block + 1:end,:)};
        Test(k, 1)={Input(1:block,:)};
        
    else
        Train(k, 1)={[Input(1:(kfold - k)*block,:);Input((kfold - k + 1)*block + 1:end,:)]};
        Test(k, 1)={Input((kfold - k)*block + 1:(kfold - k + 1)*block,:)};
        
    end
    
end

Train = cell2mat(Train(Return_Fold));
Test = cell2mat(Test(Return_Fold));



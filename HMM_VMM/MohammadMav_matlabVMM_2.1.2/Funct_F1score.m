function F1 = Funct_F1score(L, P)
 
%L: true labels
%P: predicted labels
x = confusionmat(L,P); 
if numel(x)==1%%it has only one label
    F1=1
    return
end
%%this is Dr. Mahoor's code
% % x : actual class in rows and predicted class in columns.
% tp = x(2,2);
% fp = x(2,1);
% fn = x(1,2);
% tn = x(1,1);

%%This is Mavadati's code
% x : actual class in rows and predicted class in columns.
tp = x(2,2);
fp = x(1,2);
fn = x(2,1);
tn = x(1,1);
%%
 
precision = tp /(tp + fp);
 
recall = tp / (tp + fn);
 
F1 = 2 * precision * recall / (precision + recall);
 
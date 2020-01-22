%
% Example MKL MultiClass SVM Classifiction
%

close all
clear all
clc
%------------------------------------------------------
% Creating data
%------------------------------------------------------
n=20;
sigma=1.2;
nbclass=3;

x1= sigma*randn(n,2)+ ones(n,1)*[-1.5 -1.5];
x2= sigma*randn(n,2)+ ones(n,1)*[0 2];
x3= sigma*randn(n,2)+ ones(n,1)*[2 -1.5];

% input features and labels
xapp=[x1;x2;x3];
yapp=[1*ones(1,n) 2*ones(1,n) 3*ones(1,n)]';

[n1, n2]=size(xapp);
[xtesta1,xtesta2]=meshgrid([-4:0.1:4],[-4:0.1:4]);
[na,nb]=size(xtesta1);
xtest1=reshape(xtesta1,1,na*nb);
xtest2=reshape(xtesta2,1,na*nb);
xtest=[xtest1;xtest2]';

xapp1 = [xapp ones(size(xapp,1),1)];
xtest1 = [xtest ones(size(xtest,1),1)];

%----------------------------------------------------------
%   Learning and Learning Parameters
%   Parameters are similar to those used for mklsvm
%-----------------------------------------------------------
C = 100;
q = 5;
ypred = LpMKL_MW_2f(xapp,xapp1,yapp,xtest,xtest1,C,nbclass,q);

%------------------------------------------------------------------
%           Plotting the decision function
%-------------------------------------------------------------------
ypredmat=reshape(ypred,na,nb);
contour(xtesta1,xtesta2,ypredmat,[1 2 3]);hold on
style=['x+*'];
color=['bgr'];
hold on
for i=0:nbclass-1
    h=plot(xapp(i*n+1:(i+1)*n,1),xapp(i*n+1:(i+1)*n,2),[style(i+1) color(i+1)]);
    set(h,'LineWidth',2);
end;





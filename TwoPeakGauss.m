% function o = TwoPeakGauss(m1,s1,m2,s2,d1,d2)
% d1,d2 are the size of output
clear all
clc
d1=1:200; d2= 1:300;
m1=20; s1=20; m2=200; s2=15;
r1=m1+s1*randn(100,100);
r2=m2+s2*randn(100,100);
r=r1+r2;
h=imhist(uint8(r));
figure; imhist(uint8(r));
e=h*h';
[x,y]=meshgrid(1:size(e,1),1:size(e,2));
[xq,yq]=meshgrid(d1,d2);
o=interp2(x,y,e,xq,yq,'cubic');
size(o)
figure; surf(o);



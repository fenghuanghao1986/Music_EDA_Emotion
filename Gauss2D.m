function o = Gauss2D(m1,s1,d1,d2)
% d1,d2 are the size of output

r=m1+s1*randn(100,100);
h=imhist(uint8(r));
e=h*h';
[x,y]=meshgrid(1:size(e,1),1:size(e,2));
d1=linspace(1,256,d1); 
d2=linspace(1,256,d2);
[xq,yq]=meshgrid(d2,d1); 
o=interp2(x,y,e,xq,yq,'cubic');
% o=o./sum(o(:));
% figure; surf(o);



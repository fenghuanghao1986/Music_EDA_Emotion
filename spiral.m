%spiral.m
function val = spiral(x,y)

  r = sqrt( x*x + y*y);
  a = atan2(y,x)*2+r;                  

  x = r*cos(a);
  y = r*sin(a);

  val = exp(-x*x*y*y);

   val = 1/(1+exp(-1000*(val)));   


%show.m
n=300;
l = 7;
A = zeros(n);

for i=1:n
for j=1:n
    A(i,j) = spiral( 2*(i/n-0.5)*l,2*(j/n-0.5)*l);
end
 end


imshow(A) %don't know if imshow is in matlab. I used octave.

function o = Sync(xi,xj,p)

% Hosein M. Golshan
% May 10, 2016

% function o = Sync(xi,xj,p,LowPass)
% if LowPass == 1 
% 
%     [num, den] = butter(10, 0.2);        
%     xi = filter(num, den, xi);
%     xj = filter(num, den, xj);
%     
% end
   
A = fft(xi,p);
B = fft(xj,p);

for i = 1:ceil(p/2)
    
    z(i) = real(A(i))*real(B(i))+...
        imag(A(i))*imag(B(i));
    
    if z(i)~=0
        
        D(i) = (real(A(i))*imag(B(i))-real(B(i))...
            *imag(A(i)))/z(i);
        
    else
        
        disp('Signals are synchronous')
        o = 1; % I added this line
        return % I added this line
        
    end
    
end

for i = 1:ceil(p/2)-1
    
    E(i) = abs(D(i+1)-D(i));
    
end

o = 1/(1+mean(E(:))+std(E(:)));



        
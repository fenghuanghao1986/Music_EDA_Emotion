
n = 0:pi/200:2*pi;
k = 0;
x = sin(n);
% y = (1/2)*sin(n+k);
y = cos(n)+sin(2*n);
FFTIndex = FFT_Sync(x,y,length(x)); 
PLVIndex = PLV_Sync(x,y,10);

figure; plot(n,x,'r',n,y,'b');
title(['FFTIndex: ', num2str(FFTIndex), '     PLVIndex: ', num2str(PLVIndex)])

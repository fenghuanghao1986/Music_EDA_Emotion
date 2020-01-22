function [map,t,f,C]=time_frequency(x,fs,fw,mode)
% function [map,t,f,C]=time_frequency(x,fs,fw)
% x = signal
% fs = sampling frequency
% fw = desired frequency range, e.g. 1:1:10 = 1 to 10 Hz in 1 Hz steps
% output 
% map = time frequency map power
% t = time scale
% f = frequency scale
% C = complex map
t=(1:length(x))/fs;
scales=fs./fw;
f=scal2frq(scales,'cmor1.5-2',1/fs);
C=cwt_felix(x,scales,'cmor1.5-2',mode);
map=abs(C);
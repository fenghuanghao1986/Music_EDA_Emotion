function xf = bandpass_fir1(x,f1,f2,fs,fl)
d = fdesign.bandpass('N,F3dB1,F3dB2',fl,f1,f2,fs);
Hd = design(d);
xf = filter(Hd,x);
end

function [plv]=compute_plv_filter(x,y,fw,bw,fl,fs,pr)
%function [plv]=compute_plv_filter(x,y,fw,bw,fl,fs,pr)
plv = zeros(length(fw),size(x,1));
if(pr)
hh = waitbar(0,'computing plv map');
end
for i=1:length(fw)
    xf = bandpass_fir1(x,fw(i)-bw,fw(i)+bw,fs,fl);
    yf = bandpass_fir1(y,fw(i)-bw,fw(i)+bw,fs,fl);
    Cxy = hilbert(xf).*conj(hilbert(yf));
    Cxy = Cxy./abs(Cxy);
    plv(i,:) = abs(mean(Cxy,2))';
    if(pr)
    waitbar(i/length(fw));
    end
end
if(pr)    
close(hh);
end
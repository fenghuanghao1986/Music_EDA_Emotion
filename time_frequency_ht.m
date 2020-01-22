function [C,CS,Call,C0]=time_frequency_ht(x,fw,fs,bw,fl,pr,opt)
% function  [C,CS,Call,C0]=time_frequency_ht(x,fw,fs,bw,fl,pr,opt)
% x= signal
% fw = frequency vector
% fs = sampling rate
% bw = filter width
% fl = filter length
% pr = 0 dont show progress
% opt =0 dont output single trial maps
if(pr)
hh=waitbar(0,'computing map');kk=0;
end
C=zeros(size(x,1),length(fw));
CS=C;
if(opt>0)
Call=zeros(size(C,1),size(C,2),size(x,2));
else
    Call=[];
end
C2=C;
for j=1:size(x,2)
    C0=zeros(size(C));
    for i=1:length(fw)
        f1=fw(i)-bw/2;
        f2=fw(i)+bw/2;
        if(f1<=0)
            f1=fw(i)/2;
            f2=3*fw(i)/2;
        end
        if(f2>=fs)
            f2=fs;
        end
        if(fl>=size(x,1)/3)
            fl=floor(length(x)/3)-1;
        end
        xf=bandpass_fir1(x(:,j),f1,f2,fs,fl);
        C0(:,i)=hilbert(xf);
        if(pr)
        kk=kk+1;
        if(kk>length(fw)*size(x,2)/100)
            kk=0;
            waitbar(((j-1)*length(fw)+i)/length(fw)/size(x,2));
        end
        end
    end
    C=C+abs(C0)/size(x,2);
    C2=C2+abs(C0).^2/size(x,2);
    if(opt>0)
    Call(:,:,j)=C0;
    end
end
if(pr)
close(hh);
end
CS=sqrt(C2-C.^2);
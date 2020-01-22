function [plv]=compute_plv_wavelet(x,y,fw,fs,pr,mode)
[Cx,CS,Callx,C0]=time_frequency_wavelet(x,fw,fs,pr,1,mode);
[Cy,CS,Cally,C0]=time_frequency_wavelet(y,fw,fs,pr,1,mode);

if(ndims(Callx)>2)
% 	Callx=Call(:,:,1:size(x,2));
% 	Cally=Call(:,:,size(x,2)+1:end);
	Callx=Callx./abs(Callx);
	Cally=Cally./abs(Cally);
	plv=abs(mean(Callx.*conj(Cally),3));
else
% 	Callx=Call(:,1:size(x,2));
% 	Cally=Call(:,size(x,2)+1:end);
	Callx=Callx./abs(Callx);
	Cally=Cally./abs(Cally);
% 	plv=abs(mean(Callx.*conj(Cally),2));
    plv=Callx.*conj(Cally);
end
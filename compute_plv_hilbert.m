function [plv]=compute_plv_hilbert(x,y,fw,fs,bw,fl,pr,opt)
[Cx,CS,Callx,C0]=time_frequency_ht(x,fw,fs,bw,fl,pr,opt);
[Cy,CS,Cally,C0]=time_frequency_ht(y,fw,fs,bw,fl,pr,opt);

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
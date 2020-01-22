function AOH_PhaseSync (structSubj)

%% Constants
str_stem 	= structSubj.str_stem;
fn_stem  	= structSubj.fn_stem;
fnroot   	= structSubj.fnroot;
iS       	= structSubj.iS;
sSide    	= structSubj.sSide;
sRecNum		= structSubj.sRecNum;
pathData	= structSubj.pathData;

newFs=2000;
AOH_LoadData

load dg_colormap.mat

edata=edata_orig;
ldata=ldata_orig;

data=[ldata_orig,edata_orig];

i=1;
str=[str_stem ' LFP ' num2str(i) '-'];
i=i+min(size(ldata_orig));
str=[str  num2str(i-1)];

str=[str ' ECOG ' num2str(i) '-'];
i=i+min(size(edata_orig));
str=[str  num2str(i-1)];

fw=[5:2:30,35:5:80,100:20:400];
fw=[5:1:55];

vCond     = [2 3 4 21 22 25 26 27];

figMatTimes=[[5000,3000,3000,5000,5000,10000,10000,10000]' [15000,3000,3000,15000,15000,5000,5000,5000]'];

multWaveLength=[1 2];
figMat=[];
for mm=1:length(multWaveLength)
	for ii=1:length(vCond)
		figMat(mm,ii,1)=vCond(ii);
		figMat(mm,ii,2)=figure;
		figMat(mm,ii,3)=figMatTimes(ii,1);
		figMat(mm,ii,4)=figMatTimes(ii,2);
	end;
end;

% Create event matricies

%[matLFP t before_ms after_ms] = HebbMatEvent (ldata(:,1)', Fs, Response.Cond2, 2000, 10000,'Pow2',1);
%[matECOG t before_ms after_ms] = HebbMatEvent (ldata(:,1)', Fs, Response.Cond2, 2000, 10000,'Pow2',1);


% Create an estimate of instantaneous phase using wavelets

kernal_ms=200;
kernal=ones(Fs*kernal_ms/1000,1);

% The convolution kernal is different for each frequency, and is equal to 
% 2 wavelengths.


nCh=size(data,2);

for ii=1:nCh-1
	for jj=ii+1:nCh
%		kk=(jj-1)*nCh+ii;
%		kk=(jj-2)*nCh+ii;
		kk=(jj-2)*(nCh-1)+ii;
		
		x=squeeze(data(:,ii));
		y=squeeze(data(:,jj));

		[Cxd,CS,Callx,C0]=time_frequency_wavelet(x,fw,Fs,0,1,'CPUtest');
		[Cyd,CS,Cally,C0]=time_frequency_wavelet(y,fw,Fs,0,1,'CPUtest');

		% Create the unit vectors to save the phase information only.
		px=Callx./abs(Callx);
		py=Cally./abs(Cally);

		% Calculate the difference in the phases
		dp=px.*conj(py);
		
		% Free up some memory
		clear Cxd;
		clear Cyd;
		clear Callx;
		clear Cally;
		clear px;
		clear py;
		clear CS;
		clear C0;
		
		% Add phases for a moving time window
		for mm=1:length(multWaveLength)
			kernal = zeros(length(fw),ceil(multWaveLength(mm)*Fs/min(fw)));
			for nn=1:length(fw)
				lenK=ceil(multWaveLength(mm)*Fs/fw(nn));
				kernal(nn,[1:lenK])=1;
			end;		

			dpc=[];
			for ll=1:size(dp,2)
				dpc(:,ll)=conv(dp(:,ll),kernal(ll,:));
			end;
	%		dpc=conv2(dp,kernal);
			%dpc(size(dp,1)+1:end,:)=[]; % unnecessary

			% Discard the direction of the resulting summation, but keep the magnitude.
			dpc=abs(dpc);

			%[matPhase t before_ms after_ms] = HebbMatEvent (dp', Fs, Response.Cond2, 2000, 10000,'Pow2',1);


			% The hard work has been done. Now cycle through conditions.
			for ll=1:length(vCond)
				iCond		=figMat(mm,ll,1);
				F1		=figMat(mm,ll,2);
				before_ms	=figMat(mm,ll,3);
				after_ms	=figMat(mm,ll,4);

				figure(F1);

				% DEFINE THE RESPONSE
				try
					eval(['B=Response.Cond' num2str(iCond) ';']);
				catch
					B=[];
					fprintf(1,'\n** There are no reponses or delay values for condition %d. (b)\n',iCond);
				end;

				B=double(B);
				if (Fs<sf_orig) B=fix(B*Fs/sf_orig); end;			
				Event=B;
				try
					[matPhase t before_ms after_ms] = HebbMatEvent (dpc', Fs, Event, before_ms, after_ms);
				catch
					continue;
				end;
				%plv=abs(squeeze(sum(matPhase,1)));
				plv=(squeeze(mean(matPhase,1)));
				Z=AOH_normalize_plv(plv,plv);

				subplot(nCh-1,nCh-1,kk);

				imagesc(Z);
				imagesc(t,fw,Z);
				caxis ([-3 3]);
				strTitle=[num2str(jj) '.' num2str(ii) ' (' num2str(iCond) '.' num2str(multWaveLength(mm)) ') ' str];
				title(strTitle);
				colormap(cm);colorbar;
				axis xy
			end;		

		end;
		
	end;
end;


for mm=1:length(multWaveLength)
	try % In case not all conditions are present.
		for ll=1:length(vCond)

			iCond		=figMat(mm,ll,1);
			F1		=figMat(mm,ll,2);
			before_ms	=figMat(mm,ll,3);
			after_ms	=figMat(mm,ll,4);

			figure(F1);

			tmpFN=[fullfile('fig','PhaseSync',[fn_stem 'Cond' num2str(iCond) '.' num2str(multWaveLength(mm))  '.fig'])];
			hgsave(F1,tmpFN);
			fprintf(1,'*Save: %s\n',tmpFN);

			opt = struct( 'Height',12,'Width',144,'color','rgb','fontmode','fixed','fontsize',6,'Renderer', 'painters','FontEncoding','adobe','linemode','fixed','linewidth',1);
			formatfig(F1,opt);
			tmpFN=[fullfile('fig','PhaseSync',[fn_stem 'Cond' num2str(iCond) '.' num2str(multWaveLength(mm)) '.png'])];
			print(F1, '-r400', '-painters','-dpng', tmpFN);
			fprintf(1,'*Save: %s\n',tmpFN);
		end;
	catch
	end;
end;
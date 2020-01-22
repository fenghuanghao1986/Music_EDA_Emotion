function AOH_Fig_PhaseStableHilbert(structSubj)
%% AOH_Fig_FFTs.m
%
%
% 2 language & counting
% 3 ipsi finger
% 4 contra finger
% 5 ipsi pronation/supination
% 6 contral pronation/supination
% 21 Lang/Button
% 22 Lang/No-button
% 25 End of Language/Language Finale - for Cond 2
% 26 End of Language/Language Finale - for Cond 21
% 27 End of Language/Language Finale - for Cond 22

%% Constants
str_stem 	= structSubj.str_stem;
fn_stem  	= structSubj.fn_stem;
fnroot   	= structSubj.fnroot;
iS       	= structSubj.iS;
sSide    	= structSubj.sSide;
iRegionLen	= structSubj.iRegionLen;
sRecNum		= structSubj.sRecNum;
pathData	= structSubj.pathData;


plotFreq=[8 50];
plotFreq=[8 54;66 100];
plotFreq=[2 54;66 100];
plotFreq=[4 30];

fw=[4:.25:30];

iLineWidth	= 3;

vColors=[[1 0 0];[0 1 0];[1 0 0];[1 1 0];[1 0 1];[0 0 1];[0 0 0];[0 .5 .8];[.8 .5 0];[.2 .8 .2];[1 0 0];[0 1 0];[1 0 0];[1 1 0];[1 0 1];[0 0 1];[0 0 0];[0 .5 .8];[.8 .5 0];[.2 .8 .2]];
vColorsBase=[[1 0 0];[0 1 0];[1 0 0];[1 1 0];[1 0 1];[0 0 1];[0 0 0];[0 .5 .8];[.8 .5 0];[.2 .8 .2];[1 0 0];[0 1 0];[1 0 0];[1 1 0];[1 0 1];[0 0 1];[0 0 0];[0 .5 .8];[.8 .5 0];[.2 .8 .2]];

Col_fg=[34,139,34]/255; % Forest Green
vColors(3,:)=Col_fg;
vColorsBase(3,:)=Col_fg;

vCond     = [2 3 4 21 22 25];
RunCond	  = [1 1 1 1  1 1];

cmnWin=500;
vAct_ms   = [-cmnWin*4 cmnWin*6;cmnWin+0 cmnWin-0;cmnWin+0 cmnWin-0;-cmnWin*4 cmnWin*6;-cmnWin*4 cmnWin*6; 0 cmnWin*2];
% -cmnWin*4 cmnWin*6 is -2000 before (which is 2000ms after) to 3000ms after, for 1second duration.
vBas_ms   = [cmnWin*2 0;cmnWin*2 0;cmnWin*2 0;cmnWin*2 0;cmnWin*2 0;cmnWin*2 0];
% cmnWin*2 0 is 1000ms before to 0 ms before for 1 second duration.

%% Load raw data
		
newFs=250;
RefMode='BIPOLAR';

AOH_LoadData
Fs

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

bMax=0;
multWaveLength=2;

if ~exist('iEl') iEl=[]; end;

if ~length(iEl)
	iEl=1:size(data,2);
end;


fw=[2:.2:30];
filtBand=[fw(1:end-1)',fw(2:end)'];
filtBand=[fw',fw'+4];
fwLabel=mean(filtBand,2);

kernal = zeros(size(filtBand,1),ceil(multWaveLength*Fs/min(min(filtBand)))); % Samples/cycle
for nn=1:size(filtBand,1)
	
	lenK=ceil(multWaveLength*Fs/filtBand(nn,1));
	%kernal(nn,[1:lenK])=1;
	kernal(nn,[1:lenK])=triang(lenK);
end;		


%% Cycle through the electrodes

nCond=length(find(RunCond));
nEl=length(iEl);

nCh=size(data,2);
F1=figure;


clear ldata_orig;
clear edata_orig;

bandData=zeros(size(data,2),size(data,1),size(filtBand,1));

for i=1:size(filtBand,1)
	[bandData(:,:,i)]=eegfilt(data', Fs, filtBand(i,1), filtBand(i,2));
end;

clear data;

iiEl=0;


for iCycle=iEl
	iiEl=iiEl+1;
	
	
	
		
	% Get analytical signal
	andata=hilbert(squeeze(bandData(iCycle,:,:)));
	px=andata./abs(andata);

	clear andata;

	pxk=[zeros(size(px,1)+size(kernal,2)-1,size(px,2))];

	for qq=1:size(px,2) % Cycle over frequencies within a single permutation using a parallel for loop. 
		pxk(:,qq)=abs(   conv(kernal(qq,:),px(:,qq) ) ) ; 
	end;

	clear px;

	iiCond=0;
	iLeg=1;
	for i=find(RunCond);
		iiCond=iiCond+1;
		%figure(vFigure(ii));
		
		subplot(nCond,nEl,(iiCond-1)*nEl+iiEl);
		
		iCond=vCond(i);

		eval(['B=Response.Cond' num2str(iCond) ';']);
		eval(['Delay=Response.Delay.Cond' num2str(iCond) ';']);
		
		B=double(B);
		if (Fs<sf_orig) B=fix(B*Fs/sf_orig); end;			
		Event=B;

		Delay=double(Delay);
		if (Fs<sf_orig) Delay=fix(Delay*Fs/sf_orig); end;

		if length(Bx);
			try
				Event(Bx)=[];
				Delay(Bx)=[];
			end;
		end;


		before_ms= vAct_ms(i,1);
		after_ms = vAct_ms(i,2);
		[matEvent t before_ms after_ms] = HebbMatEvent (pxk', Fs, B, before_ms, after_ms,'Pow2',1); % Creates a power-of-2 length data epochs
		
		actTitle=sprintf('Cond%d act %d:%dms %d samp',iCond,round(-(before_ms)),round(after_ms),size(matEvent,2));
		
		fprintf('%s %d Cond %d: Length of Activity Epoch: %d ms %d ms, from %d to +%d, %d samples\n',str_stem,iCycle,iCond,round(before_ms+after_ms),round(size(matEvent,2)*1000/Fs),-round(before_ms),round(after_ms),size(matEvent,2));
		
		
		%[muhat,sigmahat,muci,sigmaci] = normfit(matEvent(1,1,:));
		
		if bMax
			tmp_plot=mean(max(matEvent,[],3),1);
		else
			tmp_plot=mean(median(matEvent,3),1);
		end;

		for j=1:size(plotFreq,1)
			A=intersect(find(fwLabel>=plotFreq(j,1)),find(fwLabel<=plotFreq(j,2)));
			semilogy(fwLabel(A),tmp_plot(A),'Color',vColors(1,:),'LineWidth',iLineWidth,'DisplayName',actTitle);hold on;
			strLegend{iLeg}=['Cond ' num2str(iCond)];
			iLeg=iLeg+1;
		end;

		%% BASELINE

		%before_ms= vBas_ms(i,1);
		bsln_after_ms = vBas_ms(i,2); 
		bsln_before_ms = (before_ms+after_ms) - bsln_after_ms; % Makes sure the length of data evaluated is the same.
		
		before = fix(bsln_before_ms*Fs/1000); % datapoints prior to the stimulus that you want (this must be at least 1)
		after  = fix(bsln_after_ms*Fs/1000);  % value above which you don't want (400ms on, 400ms ISI)

		lenEpoch=before+after;

		if log2(lenEpoch)-fix(log2(lenEpoch))>0 %% NOT A ROUND NUMBER, NEED TO FIX 
			lowBound = 2^fix(log2(lenEpoch)); 
			highBound= 2^(fix(log2(lenEpoch))+1);
			if ((abs(lenEpoch-lowBound)/lenEpoch)<.1)
				lenEpoch=lowBound;
			else
				lenEpoch=highBound;
			end;

			before=lenEpoch-after;
			bsln_before_ms= before * 1000/Fs;
		end;

		for j=1:length(Delay)
			epoch = [(B(j)-before+1):(B(j)+after)]-Delay(j);
			matBase(j,:,:)=pxk(epoch,:)';
		end;
		
		bslnTitle=sprintf('Cond%d bsln %d:%dms %d samp',iCond,round(-(bsln_before_ms)),round(bsln_after_ms),size(matBase,2));
		
				
		fprintf('%s %d Cond %d: Length of Baseline Epoch: %d ms %d ms, from %d to +%d, %d samples\n',str_stem,iCycle,iCond,round(bsln_before_ms+bsln_after_ms),round(size(matBase,2)*1000/Fs),-round(bsln_before_ms),round(bsln_after_ms),size(matBase,2));

		if bMax
			tmp_plot=mean(max(matBase,[],3),1);
		else
			tmp_plot=mean(median(matBase,3),1);
		end;
		
		% Plot baseline FFT
		for j=1:size(plotFreq,1)
			A=intersect(find(fwLabel>=plotFreq(j,1)),find(fwLabel<=plotFreq(j,2)));
			semilogy(fwLabel(A),tmp_plot(A),'Color',vColorsBase(3,:),'LineStyle','-.','LineWidth',iLineWidth,'DisplayName',bslnTitle);hold on;
			strLegend{iLeg}=['Cond ' num2str(iCond) ' Baseline'];
			iLeg=iLeg+1;
		end;

		numEpochs=floor(size(pxk,1)/lenEpoch);
		data2=(reshape(pxk( [1:numEpochs*lenEpoch] , :),lenEpoch, numEpochs ,size(pxk,2)));
		
		if bMax
			tmp_plot=mean(squeeze(max(data2,[],1)));
		else
			tmp_plot=mean(squeeze(median(data2,1)));
		end;
		
		clear data2;
		
		for j=1:size(plotFreq,1)
			A=intersect(find(fwLabel>=plotFreq(j,1)),find(fwLabel<=plotFreq(j,2)));
			semilogy(fwLabel(A),tmp_plot(A),'Color','k','LineStyle','-.','LineWidth',iLineWidth,'DisplayName','EntireRecord');hold on;
		end;

		xlabel('Frequency (Hz)');
		ylabel('Log Phase Stability');
		set(gca,'XTick',[4,8,13,[20:10:100]],'YTick',[]);
		grid on;
		axis tight
		xlim([min(min(plotFreq)) max(max(plotFreq))]);

		
		strLegend{iLeg}='Entire record';
		iLeg=iLeg+1;

		A=intersect(find(fwLabel>=13),find(fwLabel<=30));
		maxBeta=(max(tmp_plot(A)));

		axis tight
		ylims=ylim;
		ylims(2)=(maxBeta/.25)+ylims(1);
		ylim(ylims);

		strTitle=[num2str(iCycle) ' (' num2str(iCond) ') ' str];
		title(strTitle);
    	end;
end; %iCycle;

clear plv
clear data

figure(F1);

opt = struct( 'Height',12,'Width',24,'color','rgb','fontmode','fixed','fontsize',6,'Renderer', 'painters','FontEncoding','adobe','linemode','fixed','linewidth',2);
formatfig(F1,opt);

tmpFN=[fullfile('fig','PhaseStable',[fn_stem '.' num2str(multWaveLength) '.' num2str(bMax) '.PhaseStable.Hilbert.Tri.png'])];
print(F1, '-r400', '-painters','-dpng', tmpFN);
fprintf(1,'*Save: %s\n',tmpFN);
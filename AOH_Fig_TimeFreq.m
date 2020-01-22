function AOH_Fig_TimeFreq (structSubj)


%% Constants
str_stem 	= structSubj.str_stem;
fn_stem  	= structSubj.fn_stem;
fnroot   	= structSubj.fnroot;
iS       	= structSubj.iS;
sSide    	= structSubj.sSide;
sRecNum		= structSubj.sRecNum;
pathData	= structSubj.pathData;

bBaseline=1;
colorLims=[-10 10];

%bBaseline=0;
%colorLims=[-3 3];

vCond     = [2 3 4 21 22 25];
RunCond	  = [1 1 1 0  0 0];

%figMatTimes= [[5000,3000,3000,5000,5000,10000,10000,10000]' [15000,3000,3000,15000,15000,5000,5000,5000]'];
%figBaseTimes=[[1050,1050,1050,1050,1050,1050,1050,1050]' -[50,50,50,50,50,50,50,50]'];

figMatTimes= [[5000,5000,5000,5000,5000,10000,10000,10000]' [15000,10000,10000,15000,15000,5000,5000,5000]'];
figBaseTimes=[[1050,1050,1050,1050,1050,1050,1050,1050]' -[250,250,250,250,250,250,250,250]'];

vAct_ms   = figMatTimes;
vBas_ms   = figBaseTimes;

newFs=500;
RefMode='CAR';
RefMode='LOCAL';
RefMode='BIPOLAR';
%RefMode='NONE';
AOH_LoadData
Fs

load dg_colormap.mat

edata=edata_orig;
ldata=ldata_orig;

data=[ldata_orig,edata_orig];


if ~exist('iEl') iEl=[]; end;

if ~length(iEl)
	iEl=1:size(data,2);
end;


i=1;
str=[str_stem ' LFP ' num2str(i) '-'];
i=i+min(size(ldata_orig));
str=[str  num2str(i-1)];

str=[str ' ECOG ' num2str(i) '-'];
i=i+min(size(edata_orig));
str=[str  num2str(i-1)];

fw=[5:2:30,35:5:80,100:20:400];
fw=[5:1:40];
fw=[1:.25:5,5.5:.5:13,14:1:30,32:2:50,70:5:110];
fw=[1:.1:8,8.2:.2:30,31:1:54,66:2:110];
 
%% Cycle through the electrodes

nCond=length(find(RunCond));
nEl=length(iEl);

nCh=size(data,2);
F1=figure;

iiEl=0;
bSubPlot=0;
for iCycle=iEl
		iiEl=iiEl+1;
		iiCond=0;
		for i=find(RunCond);
			iiCond=iiCond+1;
			
			if bSubPlot
				subplot(nCond,nEl,(iiCond-1)*nEl+iiEl); % Conditions x Electrode
			else
				subplot(nEl,nCond,(iiEl-1)*nCond+iiCond);   % Electrode x Condition
			end;
			
			iCond=vCond(i);
			
			% DEFINE THE RESPONSE
			try
				eval(['B=Response.Cond' num2str(iCond) ';']);
				eval(['Delay=Response.Delay.Cond' num2str(iCond) ';']);
			catch
				B=[];
				fprintf(1,'\n** There are no reponses or delay values for condition %d. (b)\n',iCond);
				continue;
			end;

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

			bsln_before_ms= vBas_ms(i,1);
			bsln_after_ms = vBas_ms(i,2); 

			before_base = fix(bsln_before_ms*Fs/1000); % datapoints prior to the stimulus that you want (this must be at least 1)
			after_base  = fix(bsln_after_ms*Fs/1000);  % value above which you don't want (400ms on, 400ms ISI)


			before_ms= vAct_ms(i,1);
			after_ms = vAct_ms(i,2);	

			before = fix(before_ms*Fs/1000); 

			try
				[matX t before_ms after_ms] = HebbMatEvent (squeeze(data(:,iCycle))', Fs, Event, before_ms, after_ms);
				t=t/1000;
			catch
				warning ('HebbMatEvent failed');
				continue;			
			end;

			fprintf(1,'w%d.%d',iCycle,iCond);
			[Cxd,CS,Callx,C0]=time_frequency_wavelet(matX',fw,Fs,0,1,'CPUtest');
			fprintf(1,'.\n');
  
				% PLV IS FREQ,TIME
				
			matBase=[];
			for j=1:length(Delay)
				%epoch = [(Event(j)-before+1):(Event(j)+after)]-Delay(j);
				epoch = [(before-before_base+1):(before+after_base)]-Delay(j);
				matBase(:,:,j)=Callx(epoch,:,j);
			end;

			pow=mean(abs(Callx.*conj(Callx)),3);
			pow_base=mean(abs(matBase.*conj(matBase)),3);

			if bBaseline
				Z=AOH_normalize_plv(pow',pow_base');
			else
				Z=AOH_normalize_plv(pow',pow');
			end;

			% INPUT TO NORMALIZE IS FREQ,TIME
				% Z is FREQ,TIME
				% NEWSTAT is TIME,FREQ
			
			imagesc(t,1:size(Z,1),Z);
			caxis (colorLims);
			
			strTitle=[num2str(iCycle) ' (' num2str(iCond) ') ' str];
			title(strTitle);

			colormap(cm);
			axis xy
			axis normal
			
			set (gca,'YTick',[find(fw==1.0)  find(fw==4.0)  find(fw==8.0)  find(fw==13.0) find(fw==30.0)   find(fw==70.0) find(fw==110.0)]);
			currTicks=get(gca,'YTick');
			strTick=[];iTickCount=[];
			for iTick=currTicks
				if iTick>currTicks(1)
					strTick=[strTick '|'];
				end;
				strTick=[strTick sprintf('%2.0f',fw(iTick))];
			end;
			set (gca,'YTickLabel',strTick);
		end; % cycle condition	

		
	
end; % cycle electrode

tmpFN=[fullfile('fig','TimeFreq',[fn_stem '.CL' num2str(colorLims(2)) '.' num2str(bBaseline) '.' num2str(bSubPlot) '.FreqTime.Fine.' RefMode '.fig'])];

%hgsave(F1,tmpFN);
fprintf(1,'*Save: %s\n',tmpFN);

if bSubPlot				
	opt = struct( 'Height',48,'Width',48,'color','rgb','fontmode','fixed','fontsize',9,'Renderer', 'painters','FontEncoding','adobe','linemode','fixed');
else
	opt = struct( 'Height',96,'Width',12,'color','rgb','fontmode','fixed','fontsize',9,'Renderer', 'painters','FontEncoding','adobe','linemode','fixed');
end;

formatfig(F1,opt);


tmpFN=[fullfile('fig','TimeFreq',[fn_stem '.CL' num2str(colorLims(2)) '.' num2str(bBaseline) '.' num2str(bSubPlot) '.FreqTime.Fine.' RefMode '.png'])];

print(F1, '-r600', '-painters','-dpng', tmpFN);
fprintf(1,'*Save: %s\n',tmpFN);
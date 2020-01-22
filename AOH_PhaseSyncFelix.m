function AOH_PhaseSyncFelix (structSubj)

%matlabpool open 4

%% Constants
str_stem 	= structSubj.str_stem;
fn_stem  	= structSubj.fn_stem;
fnroot   	= structSubj.fnroot;
iS       	= structSubj.iS;
sSide    	= structSubj.sSide;
sRecNum		= structSubj.sRecNum;
pathData	= structSubj.pathData;

nPerm=1000;
%nPerm=0;
alpha=0.05;

colorLims=[-5 5];
bBaseline=1;

newFs=200;
RefMode='CAR';
RefMode='BIPOLAR';
%RefMode='NONE';
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

fw=[5:2:30,35:5:80,100:20:400];
fw=[5:1:40];
fw=[1:.25:5,5.5:.5:13,14:1:30,32:2:50,70:5:110];

fw=[4:.25:20,20.5:.5:40];

fw=[1:.1:8,8.2:.2:30];

vCond     = [2 3 4 21 22 25 26 27];
vCond     = [2 3 4 22];

figMatTimes= [[5000,5000,5000,5000,5000,10000,10000,10000]' [15000,10000,10000,15000,15000,5000,5000,5000]'];
figBaseTimes=[[1050,1050,1050,1050,1050,1050,1050,1050]' -[250,250,250,250,250,250,250,250]'];

vAct_ms   = figMatTimes;
vBas_ms   = figBaseTimes;


multWaveLength=[1];
figMat=[];
for mm=1:length(multWaveLength)
	for ii=1:length(vCond)
		figMat(mm,ii,1)=vCond(ii);
		figMat(mm,ii,2)=figure;
		%figMat(mm,ii,3)=figMatTimes(ii,1);
		%figMat(mm,ii,4)=figMatTimes(ii,2);
	end;
end;

% Create event matricies

%[matLFP t before_ms after_ms] = HebbMatEvent (ldata(:,1)', Fs, Response.Cond2, 2000, 10000,'Pow2',1);
%[matECOG t before_ms after_ms] = HebbMatEvent (ldata(:,1)', Fs, Response.Cond2, 2000, 10000,'Pow2',1);


% Create an estimate of instantaneous phase using wavelets

%kernal_ms=200;
%kernal=ones(Fs*kernal_ms/1000,1);

% The convolution kernal is different for each frequency, and is equal to 
% 2 wavelengths.


nCh=size(data,2);

for ii=1:nCh-1 % This is the column
	
	
	for jj=ii+1:nCh % This is the row.
		
		kk=(jj-1)*(nCh)+ii;
		mm=1;
		for ll=1:length(vCond)

			iCond		=figMat(mm,ll,1);
			F1		=figMat(mm,ll,2);
			%before_ms	=figMat(mm,ll,3);
			%after_ms	=figMat(mm,ll,4);

			% DEFINE THE RESPONSE
			try
				eval(['B=Response.Cond' num2str(iCond) ';']);
				eval(['Delay=Response.Delay.Cond' num2str(iCond) ';']);
			catch ME
				B=[];
				fprintf(1,'\n** There are no reponses or delay values for condition %d. (b)\n',iCond);
				msgString = getReport(ME, 'extended');
				fprintf(1,msgString);
				continue;
				
			end;

			B=double(B);Delay=double(Delay);
			
			% To make a cue-triggered evaluation:
			%B=B-Delay;
			%Delay=Delay.*0;
			
			if (Fs<sf_orig) B=fix(B*Fs/sf_orig); end;			
			Event=B;
			
			
			if (Fs<sf_orig) Delay=fix(Delay*Fs/sf_orig); end;

			if length(Bx);
				try
					Event(Bx)=[];
					Delay(Bx)=[];
				end;
			end;

			

			bsln_before_ms= vBas_ms(ll,1);
			bsln_after_ms = vBas_ms(ll,2); 

			before_base = fix(bsln_before_ms*Fs/1000); % datapoints prior to the stimulus that you want (this must be at least 1)
			after_base  = fix(bsln_after_ms*Fs/1000);  % value above which you don't want (400ms on, 400ms ISI)


			before_ms= vAct_ms(ll,1);
			after_ms = vAct_ms(ll,2);	

			before = fix(before_ms*Fs/1000); 

			
			
			%x=squeeze(data(:,ii));
			%y=squeeze(data(:,jj));
			try
				[matX t before_ms after_ms] = HebbMatEvent (squeeze(data(:,ii))', Fs, Event, before_ms, after_ms);
				[matY t before_ms after_ms] = HebbMatEvent (squeeze(data(:,jj))', Fs, Event, before_ms, after_ms);
				t=t/1000;
			catch
				str=['HebbMatEvent failed ii=' num2str(ii) ' jj=' num2str(jj) ' Num Event=' num2str(length(Event))];
				warning (str);
				continue;			
			end;
			
			
			[Cxd,CS,Callx,C0]=time_frequency_wavelet(matX',fw,Fs,0,1,'CPUtest');
			[Cyd,CS,Cally,C0]=time_frequency_wavelet(matY',fw,Fs,0,1,'CPUtest');

			% Create the unit vectors to save the phase information only.
			px=Callx./abs(Callx);
			py=Cally./abs(Cally);


			% Free up some memory
			%clear Callx;
			%clear Cally;
			%clear Cxd;
			%clear Cyd;
			%clear px;
			%clear py;
			clear CS;
			clear C0;

			% Shuffle trials at this point in the game.
			

			s = RandStream('mt19937ar','Seed',0);
			

			upperPerm=floor((1-alpha/2)*nPerm);
			lowerPerm=ceil((alpha/2)*nPerm);
			ind=[1:size(px,3)]; % First permutation is not a permutation, it is in the proper order.
			for pp=2:nPerm+1 % Real permutations start at index 2.
				ind(pp,:)= randperm(s,size(px,3));
			end;


			% Start the permutation loop.
			baseline_epoch=[(before-before_base+1):(before+after_base)];
			dpc      = [zeros(size(px,1),size(px,2),nPerm+1)];
			dpc_base = [zeros(length(baseline_epoch),size(px,2))];



			for pp=1:nPerm+1
				fprintf(1,'%d.',pp);
				dpc(:,:,pp)=abs(sum( (px(:,:,ind(pp,:)).*conj(py)) ,3));
			end;

			matPLV=(px.*conj(py));
			matBase=[];
			for j=1:length(Delay)
				%epoch = [(Event(j)-before+1):(Event(j)+after)]-Delay(j);
				epoch = baseline_epoch - Delay(j);
				if (~isempty(find(epoch<1)))
					fprintf(1,'\n**=**\n Epoch from %d to %d.\n**=**\n',epoch(1),epoch(end));
					strWarn=['Epoch too early ' num2str(jj) '.' num2str(ii) ' (Cond' num2str(iCond) '.Trial' num2str(j) ') ' str];
					[before_ms,after_ms,bsln_before_ms,bsln_after_ms]
					[before_base after_base,before,Delay(j)]
					epoch=epoch-epoch(1)+1;
					fprintf(1,'Epoch from %d to %d.\n',epoch(1),epoch(end));
					epoch=[epoch(1):epoch(end)];
					fprintf(1,'Epoch from %d to %d.\n',epoch(1),epoch(end));
					warning (strWarn);
				end;
				try
					matBase(:,:,j)=matPLV(epoch,:,j);
				catch ME
					[epoch(1) epoch(end)]
					rethrow(ME);
				end;
			end;
			dpc_base=abs(sum( matBase ,3));

			fprintf(1,'\n',pp);
			
			plv=squeeze(dpc(1:length(t),:,1)); % PLV(TIME,FREQ)
			

			if bBaseline
				Z=AOH_normalize_plv(plv',dpc_base');
			else
				Z=AOH_normalize_plv(plv',plv');
			end;

				% INPUT TO NORMALIZE IS FREQ,TIME
				% Z is FREQ,TIME
				% NEWSTAT is TIME,FREQ

			if (nPerm)
                		plv_stat=squeeze(dpc(1:length(t),:,2:size(dpc,3))); %PLV_STAT(TIME,FREQ,PERMUTATION)
				newstat=logical(zeros(size(plv))); % NEWSTAT(TIME,FREQ)	
				stat=[];
				stat2=[];
				for oo=1:size(plv,2) % CYCLE OVER FREQ
					stat=squeeze(plv_stat(:,oo,:))'; % CHOOSE A FREQUENCY
						% STAT (TIME,PERMUTATION)
					stat2=sort(stat,'ascend'); % FOR EACH TIME COLUMN, SORT THE PERMUTATIONS
						% STAT2 (TIME,PERMUTATION) - SORTED.
					data_tmp=plv(:,oo); % CHOOSE A FREQUENCY
						% DATA (TIME,1)
					ck=(data_tmp>stat2(upperPerm,:)')+(data_tmp<stat2(lowerPerm,:)');
						% CREATE A VECTOR OF 0'S AND 1'S THAT INDICATE WHERE THE DATA IS GREATER OR LESS
						% THAN THE 97TH OR 3RD VALUE OF THE SORTED PERMUTATION ARRAY.
					newstat(:,oo)=ck;
						% STORE THIS VECTOR OF 0'S AND 1'S 
				end;
				Z=Z.*newstat';
			end;

			figure(F1);
			
			kk=(jj-1)*(nCh)+ii;
			subplot(nCh,nCh,kk);

			%imagesc(t,fw,Z);
			imagesc(t,1:size(Z,1),Z);
			caxis (colorLims);
			
			strAlpha=sprintf('%1.2f',alpha);
			strTitle=[num2str(jj) '.' num2str(ii) ' (' num2str(iCond) '.' num2str(multWaveLength(mm)) ') ' strAlpha ' ' str];
			title(strTitle);
			colormap(cm);
			%colorbar 'SouthOutside' 
			axis xy
			axis normal
			
			set (gca,'YTick',[find(fw==1.0)  find(fw==4.0)  find(fw==8.0)  find(fw==13.0) find(fw==30.0)  find(fw==40.0)  find(fw==80.0) find(fw==110.0)]);
			currTicks=get(gca,'YTick');
			strTick=[];iTickCount=[];
			for iTick=currTicks
				if iTick>currTicks(1)
					strTick=[strTick '|'];
				end;
				strTick=[strTick sprintf('%2.0f',fw(iTick))];
			end;
			set (gca,'YTickLabel',strTick);
			

			if (jj==ii+1) % THIS WILL MAKE SURE THE POWER
			
				pow = Callx.*conj(Callx);	

				matBase=[];
				for j=1:length(Delay)
					%epoch = [(Event(j)-before+1):(Event(j)+after)]-Delay(j);
					epoch = [(before-before_base+1):(before+after_base)]-Delay(j);
					if (~isempty(find(epoch<1)))
						fprintf(1,'\n**=pow=**\n Epoch from %d to %d.\n**=**\n',epoch(1),epoch(end));
						strWarn=['Epoch too early ' num2str(jj) '.' num2str(ii) ' (Cond' num2str(iCond) '.Trial' num2str(j) ') ' str];
						[before_ms,after_ms,bsln_before_ms,bsln_after_ms]
						[before_base after_base,before,Delay(j)]
						epoch=epoch-epoch(1)+1;
						fprintf(1,'Epoch from %d to %d.\n',epoch(1),epoch(end));
						epoch=[epoch(1):epoch(end)];
						fprintf(1,'Epoch from %d to %d.\n',epoch(1),epoch(end));
						warning (strWarn);
					end;
					try
						matBase(:,:,j)=pow(epoch,:,j);
					catch ME
						[epoch(1) epoch(end)]
						rethrow(ME);
					end;					
				end;				
				
				%pow2=zeros(size(pow));
				%for pp2=1:size(pow,2) % cycle over freq and normalize wrt baseline inside each trial
				%	[meanTrial stdTrial stdMean] = AverageTrials (squeeze(pow(:,pp2,:)), CueWin, fix(rest_ms*Fs/1000), fix(restshift_ms*Fs/1000));
				%	pow2(:,pp2,:)=(normalize_param(squeeze(pow(:,pp2,:))',meanTrial,stdTrial))';
				%end;

				pow=mean(pow,3)';
				matBase=mean(matBase,3)';

				if bBaseline
					Z=AOH_normalize_plv(pow,matBase);
				else
					Z=AOH_normalize_plv(pow,pow);
				end;

				kk=(jj-2)*(nCh)+ii;
				subplot(nCh,nCh,kk);


				%imagesc(t,fw,Z);
				imagesc(t,1:size(Z,1),Z);

				caxis (colorLims);
				strTitle=['Pow.' num2str(ii) ' (' num2str(iCond) '.' num2str(multWaveLength(mm)) ') ' str];
				title(strTitle);
				colormap(cm);
				%colorbar 'SouthOutside' 
				axis xy
				axis normal

				set (gca,'YTick',[find(fw==1.0)  find(fw==4.0)  find(fw==8.0)  find(fw==13.0) find(fw==30.0)  find(fw==40.0)  find(fw==80.0) find(fw==110.0)]);
				currTicks=get(gca,'YTick');
				strTick=[];iTickCount=[];
				for iTick=currTicks
					if iTick>currTicks(1)
						strTick=[strTick '|'];
					end;
					strTick=[strTick sprintf('%2.0f',fw(iTick))];
				end;
				set (gca,'YTickLabel',strTick);
				
			end;
			
			%try
			%	[matPhase t before_ms after_ms] = HebbMatEvent (dpc', Fs, Event, before_ms, after_ms);
			%catch
			%	continue;
			%end;
			%plv=abs(squeeze(sum(matPhase,1)));
			%plv=(squeeze(mean(matPhase,1)));
			
			if (ii==(nCh-1)&&(jj==nCh))

				pow = Cally.*conj(Cally);

				matBase=[];
				for j=1:length(Delay)
					%epoch = [(Event(j)-before+1):(Event(j)+after)]-Delay(j);
					epoch = [(before-before_base+1):(before+after_base)]-Delay(j);
					if (~isempty(find(epoch<1)))
						fprintf(1,'\n**=pow2=**\n Epoch from %d to %d.\n**=**\n',epoch(1),epoch(end));
						strWarn=['Epoch too early ' num2str(jj) '.' num2str(ii) ' (Cond' num2str(iCond) '.Trial' num2str(j) ') ' str];
						[before_ms,after_ms,bsln_before_ms,bsln_after_ms]
						[before_base after_base,before,Delay(j)]
						epoch=epoch-epoch(1)+1;
						fprintf(1,'Epoch from %d to %d.\n',epoch(1),epoch(end));
						epoch=[epoch(1):epoch(end)];
						fprintf(1,'Epoch from %d to %d.\n',epoch(1),epoch(end));
						warning (strWarn);
					end;
					try
						matBase(:,:,j)=pow(epoch,:,j);
					catch ME
						[epoch(1) epoch(end)]
						rethrow(ME);
					end;					
				end;				
				
				%pow2=zeros(size(pow));
				%for pp2=1:size(pow,2) % cycle over freq and normalize wrt baseline inside each trial
				%	[meanTrial stdTrial stdMean] = AverageTrials (squeeze(pow(:,pp2,:)), CueWin, fix(rest_ms*Fs/1000), fix(restshift_ms*Fs/1000));
				%	pow2(:,pp2,:)=(normalize_param(squeeze(pow(:,pp2,:))',meanTrial,stdTrial))';
				%end;

				pow=mean(pow,3)';
				matBase=mean(matBase,3)';

				if bBaseline
					Z=AOH_normalize_plv(pow,matBase);
				else
					Z=AOH_normalize_plv(pow,pow);
				end;

				subplot(nCh,nCh,nCh^2);

				%imagesc(t,fw,Z);
				imagesc(t,1:size(Z,1),Z);

				caxis (colorLims);
				strTitle=['Pow.' num2str(jj) ' (' num2str(iCond) '.' num2str(multWaveLength(mm)) ') ' str];
				title(strTitle);
				colormap(cm);
				%colorbar 'SouthOutside' 
				axis xy
				axis normal

				set (gca,'YTick',[find(fw==1.0)  find(fw==4.0)  find(fw==8.0)  find(fw==13.0) find(fw==30.0)  find(fw==40.0)  find(fw==80.0) find(fw==110.0)]);
				currTicks=get(gca,'YTick');
				strTick=[];iTickCount=[];
				for iTick=currTicks
					if iTick>currTicks(1)
						strTick=[strTick '|'];
					end;
					strTick=[strTick sprintf('%2.0f',fw(iTick))];
				end;
				set (gca,'YTickLabel',strTick);


				subplot(nCh,nCh,nCh);
				mat=zeros(size(Z));
				imagesc(t,fw,mat);
				caxis (colorLims);
				colormap(cm);
				colorbar 'SouthOutside' 
				set (gca,'YTick',[]);
				set (gca,'XTick',[]);				
			end;

		end;		

		
	end;
end;


for ll=1:length(vCond)
	try % In case not all conditions are present.
		iCond		=figMat(mm,ll,1);
		F1		=figMat(mm,ll,2);

		figure(F1);

		tmpFN=[fullfile('fig','PhaseSyncFelix',[fn_stem '.Cond' num2str(iCond) '.Stat.' RefMode '.CL' num2str(colorLims(2)) '.' num2str(bBaseline) '.' num2str(nPerm) '.PhSyncFelix'])];
		
		
		%hgsave(F1,[tmpFN '.fig']);
		
		fprintf(1,'*Save: %s\n',tmpFN);

		opt = struct( 'Height',12,'Width',144,'color','rgb','fontmode','fixed','fontsize',6,'Renderer', 'painters','FontEncoding','adobe','linemode','fixed','linewidth',1);
		formatfig(F1,opt);

		print(F1, '-r400', '-painters','-dpng', [tmpFN '.png']);
		
		print(F1, '-r400', '-painters','-depsc', [tmpFN '.eps']);
		
		
		fprintf(1,'*Save: %s\n',[tmpFN '.png']);
	catch ME
		
		tmpFN=[fullfile('fig','PhaseSyncFelix',[fn_stem '.Cond' num2str(iCond) '.Stat.' num2str(multWaveLength(mm)) '.' RefMode '.CL' num2str(colorLims(2)) '.' num2str(bBaseline) '.' num2str(nPerm) '.PhSyncFelix.png'])];
		str=['Could not save figure (' tmpFN '). Cond ' num2str(iCond) ];
		warning(str);
		msgString = getReport(ME);
		warning(msgString);
	end;
end;
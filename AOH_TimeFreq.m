function [map,t,f,C, vSamples]=AOH_TimeFreq(x,fs,fw,varargin)
% function [map,t,f,C]=AOH_TimeFreq(x,fs,fw)
% x = signal
% fs = sampling frequency
% fw = desired frequency range, e.g. 1:1:10 = 1 to 10 Hz in 1 Hz steps
% output 
% map = time frequency map power
% t = time scale
% f = frequency scale
% C = complex map

timeStart=now;

SAoption=struct(varargin{:});

if isfield(SAoption,'mode')
	mode=SAoption.mode;
else
	mode='wavelet';
end;

t=(1:length(x))/fs;

switch mode
	case 'wavelet'
		fw=fw/2;
		scales=fs./fw;
		f=scal2frq(scales,'cmor1.5-2',1/fs);
		vSamples=1:length(x);
		C=cwt(x,scales,'cmor1.5-2');
		map=abs(C);
		
	case 'spectrogram'
		spectral_window_ms=512;
		%if fw(1)<30
		%	spectral_window_ms=512; % milliseconds
		%else
		%	spectral_window_ms=256; % milliseconds
		%end
		spectral_window=fix(spectral_window_ms*fs/1000);
		iTemp=floor(spectral_window/2);
		
		hannWindow=hann(spectral_window);
		vSamples=iTemp:40:(length(x)-iTemp); % Calculate every 20ms
		tempMap = zeros(length(fw),length(vSamples));
		progress=[.1:.1:1];
		percentiles=progress*length(vSamples);
		percentiles_text=progress;
		
		
		%% CREATE PARFOR PARALLEL PROCESSING HERE (MUST REMOVE THE PROGRESS SECTION)
		for m=1:length(vSamples)
			[pds,f] = pwelch(x([vSamples(m)-(iTemp-1):vSamples(m)+iTemp]),hannWindow,[],fw,fs);
			tempMap(:,m)=pds;
			
			%% REMOVE THIS FOR THE PARALLEL PROCESSING:
			if m>percentiles(1)
				timeProgress=now;
				a=datevec(timeProgress-timeStart);
				Seconds = a(6) + 60*a(5) + 60*60*a(4) + 24*60*60*a(3);
				%TotalTime=Seconds/percentiles_text(1);
				RemainingTime = Seconds*(1/percentiles_text(1) - 1);
				fprintf(1,'%2.1f prcnt. %d minutes or %2.1f hours to go\n',(percentiles_text(1)*100),round(RemainingTime/60),(RemainingTime/(60*60)));
				percentiles(1)=[];
				percentiles_text(1)=[];
			end;
			%% END REMOVE FOR PARALLEL PROCESSING
		end;
		
		map=tempMap;
		%newT=1:(length(x)-(spectral_window-1));
		%map     = zeros(length(fw),length(x));
		%tmpTimeVec = zeros(length(x),1);
		%
		%for ii=1:size(map,1)
		%	tmpTimeVec=tmpTimeVec*0;
		%	tmpTimeVec(vSamples)=tempMap(ii,:);
		%	map(ii,iTemp:(length(x)-iTemp)) = interp1(vSamples,tmpTimeVec(vSamples),newT);
		%end;
		
		C=[];
	otherwise
		error ('Unknown mode')
end;

timeEnd=now;
a=datevec(timeEnd-timeStart);
Seconds = a(6) + 60*a(5) + 60*60*a(4) + 24*60*60*a(3);
fprintf(['AOH_TimeFreq  Time elapsed: ' num2str(ceil(Seconds)) ' seconds\n']);
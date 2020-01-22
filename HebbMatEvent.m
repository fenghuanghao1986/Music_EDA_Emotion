function [matEvent t before_ms after_ms] = HebbMatEvent (Data1, samplerate, Events, before_ms, after_ms, varargin)
% function matEvent = HebbMERPlotEPs (Data1, samplerate, Events, before_ms, after_ms)

%display ('MatEvent');
%size(Data1)

SAoption=struct(varargin{:});

bPow2=0;
if isfield(SAoption,'Pow2')
	bPow2=SAoption.Pow2;
end;
    
before = fix(before_ms*samplerate/1000); % datapoints prior to the stimulus that you want (this must be at least 1)
after  = fix(after_ms*samplerate/1000);  % value above which you don't want (400ms on, 400ms ISI)

%[before after]
%ratios=[before after]./(before+after)

%before=-before


if bPow2
	lenEpoch=before+after;
	
	if log2(lenEpoch)-fix(log2(lenEpoch))>0
		lowBound = 2^fix(log2(lenEpoch));
		highBound= 2^(fix(log2(lenEpoch))+1);
		if ((abs(lenEpoch-lowBound)/lenEpoch)<.2)
			lenEpoch=lowBound;
		else
			lenEpoch=highBound;
		end;
	
		%lenEpoch

		after=lenEpoch-before;
		after_ms= after * 1000/samplerate;

	end;
	
end;

%[before after length(Events)]
for i=1:length(Events)
	epoch = (Events(i)-before+1):(Events(i)+after);
	if (ndims(Data1)==1)
		tempMatrix1(i,:)=Data1(1,epoch);
	elseif (ndims(Data1)==2)
		tempMatrix1(i,:,:)=Data1(:,epoch);
	else
		error('Too many dimensions!');
	end;
end;



matEvent=squeeze(tempMatrix1);
t=([-before_ms+1000/samplerate:1000/samplerate:after_ms]);

%[length(epoch) length(t)]
%size(matEvent)
function [LFPdata ECOGdata AUDIOdata EMGdata ACCdata BUTTONdata structFS LFPlodata LFPhidata] = AOHPreProcess (matData, dbs_info, newFs, bPreFilt)

timeStart=now;
bQuiet=0;

structFS.orig=dbs_info.samplefreq;

[A,B]=size(matData);
if A<B 
	% data is channels x time -> fix to be time x channel
	matData=matData';
	if ~bQuiet fprintf(1,'Transposing data..\n'); end;
else
	% data is time x channels
	
end;

if bPreFilt
	fprintf(1,'AOHPreProcess: Low pass filtering (%dHz).\n',fix(structFS.orig/4));
	matData=aoh_lowpassfilter(matData,structFS.orig,fix(structFS.orig/4));
else
	fprintf(1,'AOHPreProcess: NO filtering.\n');
end;

if newFs<structFS.orig
    fprintf(1,'AOHPreProcess: Resampling data.\n');
	[matData newFs] = aoh_mer_downsample(matData,structFS.orig,newFs);
else
    fprintf(1,'AOHPreProcess: NOT Resampling data.\n');
end;


structFS.new =newFs;
structFS.LFP =newFs;
structFS.ECOG =newFs;
structFS.AUDIO =structFS.orig;
structFS.EMG =structFS.orig;
structFS.ACC =structFS.orig;
structFS.BUTTON =structFS.orig;

LFPdata=matData(:,dbs_info.elec.LFP);
if isfield(dbs_info.elec,'LFPlow')
    LFPlodata=matData(:,dbs_info.elec.LFPlow);
    LFPhidata=matData(:,dbs_info.elec.LFPhigh);
end

if isfield(dbs_info.elec,'ECOG')
	ECOGdata=matData(:,dbs_info.elec.ECOG);
else
	ECOGdata=[];
end;

if isfield (dbs_info.elec,'Audio')
	AUDIOdata=matData(:,dbs_info.elec.Audio);
else
	AUDIOdata=[];
end;

if isfield (dbs_info.elec,'EMG')
	EMGdata=matData(:,dbs_info.elec.EMG);
else
	EMGdata=[];
end;


if isfield (dbs_info.elec,'Accelerometer')
	ACCdata=matData(:,dbs_info.elec.Accelerometer);
else
	ACCdata=[];
end;

if isfield (dbs_info.elec,'Button')
	BUTTONdata=matData(:,dbs_info.elec.Button);
else
	BUTTONdata=[];
end;

%if structFS.new<structFS.orig
%	LFPdata=aoh_mer_downsample(LFPdata,structFS.orig,structFS.new);
%	ECOGdata=aoh_mer_downsample(ECOGdata,structFS.orig,structFS.new);
%end;

timeEnd=now;
a=datevec(timeEnd-timeStart);
Seconds = a(6) + 60*a(5) + 60*60*a(4) + 24*60*60*a(3);
fprintf(['AOHPreProcess  Time elapsed: ' num2str(ceil(Seconds)) ' seconds\n']);
% Script AOH_LoadData.m

%%%% Pick a data file
%%%% ================

fprintf(1,'%s\n',fn_stem);
%load (fullfile(fnroot,[fn_stem '.mat']),'dbs_info','iStim','iStimLabel','iStimCode');
load (fullfile(fnroot,[fn_stem '.mat']));

%%%% Define Region Length for breaking up behavioural blocks
%%%% =======================================================

try
	vRegionSubj = dbs_info.iRegionLength;
catch
	warning ('dbs_info.iRegionLength undefined. Using standard.');
	
	if strcmp(dbs_info.Amp,'AO')
		vRegionSubj=12; % 12 for AO/micro data
		
	elseif strcmp(dbs_info.Amp,'SYNAMPS')
		vRegionSubj=14; % 14 for SYnamps/DBS data		
		
	else
		error ('Unknown file type');
	end;
end;

%%%% Define filenames
%%%% ================

%fn_stem=[dbs_info.subject '_' dbs_info.side];

% Load the response time stamps
%fn=fullfile(pathData,'response',[fn_stem '_' lower(dbs_info.Amp(1,1:2)) '_Response.mat']);
fn=fullfile(pathData,'response',[fn_stem '_Response.mat']);



%%%% Extract LFP's and ECOG, as well as behaviour data
%%%% =================================================

bLFPextrabands=0;
if isfield(dbs_info,'elec')
	vLFP  = dbs_info.elec.LFP;
	vECOG = dbs_info.elec.ECOG;
	vHL   = dbs_info.elec.HIGHLEVEL;
    
    vLFPlow=dbs_info.elec.LFPlow;
    vLFPhigh=dbs_info.elec.LFPhigh;
    bLFPextrabands=1;
else
	error ('Missing elec field from dbs_info struct');
end;

if strcmp(dbs_info.Amp,'AO')
	if length(dbs_info.MainBlockTitle)		
		eval(['matData=data_' dbs_info.MainBlockTitle ';']);
		%eval(['clear data_' dbs_info.MainBlockTitle ';']);
	else
		eval(['matData=data;']);
		%eval(['clear data;']);
	end;
elseif strcmp(dbs_info.Amp,'SYNAMPS')
	matData=dbs_data;
	%clear dbs_data;
else
	error ('Unknown file type');
end;

if ~newFs
	newFs=dbs_info.samplefreq;
end;

[LFPdata ECOGdata AUDIOdata EMGdata ACCdata BUTTONdata structFS LFPlodata LFPhidata] = AOHPreProcess (matData, dbs_info, newFs, 0);


sf_orig	= structFS.orig;
Fs	= structFS.LFP;


%%%% Handle cases where there are multiple arrays of electrodes, and bipolar re-reference
%%%% ====================================================================================

if isfield (dbs_info.elec,'LFPx')
	if isfield (dbs_info.elec.LFPx,'nArrays')
		nLFPArrays=dbs_info.elec.LFPx.nArrays;
	else
		nLFPArrays=1;
	end;
else
	nLFPArrays=1;
end;

if isfield (dbs_info.elec,'ECOGx')
	if isfield (dbs_info.elec.ECOGx,'nArrays')
		nECOGArrays=dbs_info.elec.ECOGx.nArrays;
	else
		nECOGArrays=1;
	end;
else
	nECOGArrays=1;
end;

switch(RefMode)
	
	case {'CAR'}
		% Common reference average across channels for each time point.
		% Use mean across the channels, should be able to create an array
		% with one command then subtract that array. 
		% Be careful not to include the rejected channels in the calculation of the mean.
		fprintf(' =========================================================================\n');
		fprintf(' COMMON AVERAGE REFERENCE THE DATA\n');
		fprintf(' =========================================================================\n\n');
		MeanMatrix=mean([LFPdata,ECOGdata],2);
		ldata_orig=LFPdata -repmat(MeanMatrix,1,size(LFPdata,2));
		edata_orig=ECOGdata-repmat(MeanMatrix,1,size(ECOGdata,2));

	case {'LOCAL'}
		% Common reference average across channels for each time point.
		% Use mean across the channels, should be able to create an array
		% with one command then subtract that array. 
		% Be careful not to include the rejected channels in the calculation of the mean.
		fprintf(' =========================================================================\n');
		fprintf(' *LOCAL* COMMON AVERAGE REFERENCE THE DATA\n');
		fprintf(' =========================================================================\n\n');
		MeanMatrix=mean([LFPdata],2);
		ldata_orig=LFPdata -repmat(MeanMatrix,1,size(LFPdata,2));
		MeanMatrix=mean([ECOGdata],2);
		edata_orig=ECOGdata-repmat(MeanMatrix,1,size(ECOGdata,2));
	
	case {'BIPOLAR'}
	
		fprintf(' =========================================================================\n');
		fprintf(' BIPOLAR REFERENCE THE DATA\n');
		fprintf(' =========================================================================\n\n');
		if nLFPArrays>1
			ldata_orig=[diff(LFPdata(:,dbs_info.elec.LFPx.Right)')',diff(LFPdata(:,dbs_info.elec.LFPx.Left)')';];			
		else
			ldata_orig=diff(LFPdata')';
		end;

		if nECOGArrays>1
			try
				edata_orig=[diff(ECOGdata(:,dbs_info.elec.ECOGx.Left.Row1)')',diff(ECOGdata(:,dbs_info.elec.ECOGx.Left.Row2)')';];			
			catch
				try
				    edata_orig=[diff(ECOGdata(:,dbs_info.elec.ECOGx.Right.Row1)')',diff(ECOGdata(:,dbs_info.elec.ECOGx.Right.Row2)')';];			
				catch
				    error('!');
				end;
			end;
		else
			edata_orig=diff(ECOGdata')';
		end;
        
        
        if bLFPextrabands

            ldata_lo_orig=diff(LFPlodata')';
            ldata_hi_orig=diff(LFPhidata')';

        end;
        
        
	otherwise
		fprintf(' =========================================================================\n');
		fprintf(' DO NOT RE-REFERENCE THE DATA\n');
		fprintf(' =========================================================================\n\n');

		ldata_orig=LFPdata;
		edata_orig=ECOGdata;
end;

%%%% Downsample the data: This is now performed in AOHPreProcess script.
%%%% ===================

%Fs=dbs_info.samplefreq;
%sf_orig=Fs;

%sf_new = Fs_DownSample;


%if sf_new<sf_orig
%	fprintf(1,'Downsampling data to %d Hz for Wavelets.\n',sf_new);
%	ldata = aoh_mer_downsample(ldata_orig,sf_orig,sf_new);
%	edata = aoh_mer_downsample(edata_orig,sf_orig,sf_new);
%	Fs=sf_new;
%end;



try 

    %%%% This section may not fly for raw data.
    
    %%%% Load response time stamps
    %%%% =========================

    load (fn,'Response');
    
    %%%% Define the behavioural task blocks
    %%%% ==================================

    [iEdge,iRegion] = DefineCuePre(iStim,iStimCode,vRegionSubj,sf_orig);

    % iBreak is a marker where only data AFTER iBreak is used.
    iBreak=[];
    if (isfield(dbs_info,'iBreak'))
        iBreak=dbs_info.iBreak;
        fprintf(1,'\n***************\n---------------\n USING iBREAK!\n---------------\n***************\n');
    end;

    iCond=2; % Pick a behaviour code
    [B] = DefineCue(iCond,iStim,iStimLabel,iEdge,iRegion);
    Bx=[]; % Identify tasks to EXCLUDE
    if (length(iBreak))
        Bx=find(B<iBreak); % EXCLUDE THESE TASKS
    end;

    if (Fs<sf_orig) B=fix(B*Fs/sf_orig); end;			
    Cue=B;

    if length(Bx);
        try
            fprintf(1,'\n***\n*** USING iBREAK!\n***\n***\n');
            Cue(Bx)=[];
        end;
    end;

    if ~length(Cue)
        fprintf(1,'There are no events for condition %d. Skipping.\n',iCond);
    end;

    %%%% Create plot of behavioural time stamps
    %%%% ======================================

    % For iRegion, 2.0 is Language WITH BUTTON, and 2.5 is Language WITHOUT BUTTON
    plot (iRegion,'LineWidth',4)
    hold on;
    plot (iStim,'LineWidth',1,'Color','r')
    hold on;



    %%%% =========================

    plot (Response.Cond2,2.8,'Marker','.','MarkerSize',6,'Color','g'); % Time stamps for the behavioral RESPONSE
    plot (Cue,2.8,'Marker','.','MarkerSize',6,'Color','r'); % Time stamps for the CUE

    plot (Response.Cond21,2.1,'Marker','.','MarkerSize',6,'Color','g'); % Time stamps for the behavioral RESPONSE
    plot (Response.Cond22,2.6,'Marker','.','MarkerSize',6,'Color','g'); % Time stamps for the behavioral RESPONSE
    plot (Response.Cond3,3.1,'Marker','.','MarkerSize',6,'Color','g'); % Time stamps for the behavioral RESPONSE
    plot (Response.Cond4,4.1,'Marker','.','MarkerSize',6,'Color','g'); % Time stamps for the behavioral RESPONSE

    xlabel (['Samples (*(green)=Response Times, *(red) = Cues) Fs = ' num2str(sf_orig) 'Hz']);
    ylabel ('Behavioural Code');
    title (['Subject ' dbs_info.subject ' Side ' dbs_info.side ' Amplifier ' dbs_info.Amp]);
end;
clc
clear all;
close all;
workingFolder='C:\Users\Lab User\Documents\MATLAB\9subj_data\';

sub.name = {'d10a','j11a','kar','kar',...
    'm12a','o11a','o11a','s10a',...
    's10a','thl','thl','tik','tru','tru'};
sub.amp =  {'sy','sy','ao','sy',...
    'sy','sy','ao','ao',...
    'sy','ao','ao','sy','ao','ao'};
sub.bilt = {'bi','bi','lt','lt','bi','bi',...
    'lt','lt','lt','lt','rt','lt','lt','rt'};

for subject=1 
    load([workingFolder,sub.name{subject},'\data\pdbeep\',...
        sub.name{subject},'_',sub.bilt{subject},'_',sub.amp{subject},'_small.mat']);
    begDelay=-2*dbs_info.samplefreq;
    sampleTime=10*dbs_info.samplefreq;       
    timeRange=int32([begDelay+1:begDelay+sampleTime]);
    baselineLength=2*dbs_info.samplefreq;

%     for electrode=1:size(LFPdata_bipolar,2)
    for LFP_electrode=4
        for ECOG_electrode=1
            for trial=1:length(Response.Cond2)
                LFP_signal=LFPdata_bipolar...
                    (Response.Cond2(trial)+timeRange-int32(Response.Delay.Cond2(trial)),LFP_electrode);
                ECOG_signal=ECOGdata_bipolar...
                    (Response.Cond2(trial)+timeRange-int32(Response.Delay.Cond2(trial)),ECOG_electrode);
                [plv]=compute_plv_filter(LFP_signal,ECOG_signal,fw,bw,fl,fs,pr)
            
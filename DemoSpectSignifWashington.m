
% DemoSpectSignif
% Hosein M. Golshan
% Last Update: Jul 21 2016

clear all;
close all;
clc

% DataFile = {'d10a_bi_sy_small.mat', 'j11a_bi_sy_small.mat', 'kar_lt_sy_small.mat' , ...
%              'o11a_bi_sy_small.mat', 's10a_lt_sy_small.mat', 'thl_lt_ao_small.mat', ...
%              'tik_lt_sy_small.mat', 'tru_lt_ao_small.mat'};
% name = {'d10a','j11a','kar','o11a','s10a','thl','tik','tru'};
DataFile = {'thl_lt_ao_small.mat', ...
             'tik_lt_sy_small.mat', 'tru_lt_ao_small.mat'};
name = {'thl','tik','tru'};

Task = {'Button','Speech'};

TimeRange = [-3, 2];
FreqRange = 10: 0.5: 80;
Method = 'Wavelet';
FilMode = 'First';
Normalization = 'Adaptive';
MapCol = 'cm';

% for i = 1 : length(DataFile)
%     for k = 1 : length(TaskName)
%         for j = 1 : 3
%              Spect = DBSSpectPlot2_Washington(DataFile{i}, name, j,  ... 
%                         'LFP', TimeRange, FreqRange, ...
%                         Method, FilMode, Normalization, MapCol, Task{k})
%         end
%     end
% end

for i = 1 : length(DataFile)
    for k = 1 : length(Task)
        for j = 1 : 3 % each subject includes 3 Bipolar signals.
             Spect = DBSSpectPlot2_Washington(DataFile{i}, name{i}, j,  ... 
                        'ECoG', TimeRange, FreqRange, ...
                        Method, FilMode, Normalization, MapCol, Task{k});
        end
    end
end

    
    
    
    
    
    
    
    
    
function [p_values statistically_significant corrected_significance_level] = ...
	SL_bootstrap_significance_test (...
		signal,Fs,ms_bin_width,significance_level,dim);
%% Bootstrap randomization method for a sign-test to determine
%% significance from the baseline.
%
% Plus-Minus Significance Test for significance of Data its baseline
% For use in a single patient, single channel, over many repeated events
% Is not valid to compare between conditions, channels, or patients
%
% Written by Adam Hebb, April 1, 2007
% Updated for 2-dimensions April 11, 2007; April 20, 2007
% Heavily updated/practically re-written by Joshua Nedrud March 29th, 2013
%
%% Parameters: 
%  signal (time,...) -> must be in this format
%    data_points: Values at each time point for each event
%    Trials:     Events, repetitions of the same code at different times
% 
% Fs = sampling frequency
% ms_bin_width = width of independent sections for the signal
% 
% dim = dimension over which to compute the bootstrap sign test
%
% significance_level: p value (0.05, 0.025)
%
%% Returns:
% p_values   : this is a (n_points) matrix that stores the p value for
%             each time point of the Signal
%
% signindex : this is a (n_points) matrix that stores a binary value whether the 
%             valued response at each time point is statistically significant
%             based on the given value, significance_level parameter.
%
% Reference: Greenblatt and Pflieger, Randomization-based hypothesis testing 
%            from event-related data, Brain Topogr. 16(4) 225-232, 2004.
%

signal_dims = ndims(signal);
signal_size = size(signal);
n_trials = signal_size(dim);
% delete the dimension over which we run the bootstrap
if(signal_dims==2)
	signal_size(dim) = 1;
else
	signal_size(dim) = [];
end

fprintf(' *********************************\n');
fprintf('  SL_bootstrap_sign_test Function\n');
fprintf(' *********************************\n');
fprintf([' In order to achieve a Significance Level of',...
	' %.4f with %d comparisons\n'], ...
	significance_level,n_trials);

warning(['currently significance level correction ',...
	'only happens in the time dimension, ',...
	'consider uncommenting code for more conservative statistics'])
n_blobs = signal_size(1)/(ms_bin_width*Fs/1000);
% fprintf('Currently significance correction happens on all dimensions');
% warning(['However, blob size correction only happens in the time dimension,'...
% 	'add blob size correction features for other dimensions to speed up'...
% 	'calculations and obtain better suited corrections')
% time_bin_width = ms_bin_width*Fs/1000;
% % add other independent blob corrections here
% blob_size = time_bin_width; % multiply blob size by frequency depencence?
% n_blobs = prod(signal_size)/blob_size;

corrected_significance_level=significance_level/n_blobs;
n_boot_strap=ceil(5*(1/corrected_significance_level)/1000)*1000;

fprintf(' We will need %d number of boot strap repetitions.\n',n_boot_strap);
warning (['Sign test is not baselining the data. ',...
	'Suggest baselining when performing sign test.']);

% let the user know how far along we are
h = waitbar(0,'Initializing bootstraps...');

% Calculate the mean over all trials for the original signal
orig_mean_g = gpuArray(squeeze(mean(signal,dim))); % produces a column vector
abs_orig_mean_g = abs(orig_mean_g);

fprintf(' ..Starting the bootstraps.\n');
N=round(n_trials/2); % This is how many trials will be multiplied by -1.

% in order to reduce memory usage, sample a random sign test mean for
% each time point if the random mean is greater than the orig_mean_g and
% add it to a cumulative vector
signal_rand_select = repmat({':'},1,signal_dims);
n_positive_sign_test_g = gpuArray(uint32(zeros(signal_size)));

% get it to run on the gpu
signal_g = gpuArray(signal);
for i = 1:n_boot_strap
	signal_rand_select{dim} = sort(randperm(n_trials,N));
	abs_random_mean_g = abs(orig_mean_g - ...
		2*squeeze(sum(signal_g(signal_rand_select{:}),dim))/n_trials);
	n_positive_sign_test_g = n_positive_sign_test_g + uint32(abs_random_mean_g...
		>= abs_orig_mean_g);
	if(~mod(i,100))
		waitbar(i/n_boot_strap,h,'Processing boostrap tests...')
	end
end;

close(h)

p_values = double(gather(n_positive_sign_test_g))/n_boot_strap;
statistically_significant = p_values <= corrected_significance_level;
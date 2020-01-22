function SL_event_spectrographs(recording,task,event,...
	Fw,epoch_window,baseline_window,clims,bootstrap_bin_width,p_value)
% creates a event spectrograph image from the desired subject

SL_check_working_directory();
SL_load_event_data(subject,signal,event);
lfp_bipolar = diff(lfp_orig,1,2);

%% Create event spectrograms
[~,~,Call]=SL_time_frequency_wavelet2(lfp_bipolar,Fs,Fw);
Call_abs=abs(Call);

[t event_normalized_mean event_epoch_normalized_all] = ...
	SL_normalized_event_epochs(Call_abs,...
	button_i,epoch_window,baseline_window,Fs);

% finds zero without us having to worry about matrix starting at 1
epoch_t0 = find(t == 0);
% convert milliseconds to event epoch samples
baseline_window_i = SL_window_ms_2_window_i(baseline_window,Fs) + epoch_t0;

% now normalize each mean for proper display
event_normalized_mean_normalized = SL_normalize_signal(event_normalized_mean,...
	event_normalized_mean(baseline_window_i(1):baseline_window_i(2),:));

% grab the button press ratio
[~, event_button_press] = SL_extract_event_epochs(button_press,button_i,epoch_window,Fs);
event_button_press_ratio=mean(squeeze(event_button_press),2);

% visualize the results
SL_visualize_spectrogram(t,Fw,event_normalized_mean_normalized,clims,...
	subject,'extra_subplots',1)
plot_number = size(event_normalized_mean_normalized,3)+1;
subplot(plot_number,1,plot_number);
plot(t*1000,event_button_press_ratio);
set(gca, 'xlim', [min(t) max(t)]*1000);
xlabel('Time (ms)');
ylabel('Ratio of events with Button Down');

%% compute the bootstrap statistics
[event_p_values statistically_significant corrected_sig_level] = ...
	SL_bootstrap_sign_test(event_epoch_normalized_all,Fs,...
		bootstrap_bin_width,p_value, ndims(event_epoch_normalized_all));

% visualize the results
SL_visualize_spectrogram(t,Fw,...
	event_normalized_mean_normalized.*statistically_significant,...
	clims,subject,'extra_subplots',1)
plot_number = size(event_normalized_mean_normalized,3)+1;
subplot(plot_number,1,plot_number);
plot(t*1000,event_button_press_ratio);
set(gca, 'xlim', [min(t) max(t)]*1000);
xlabel('Time (ms)');
ylabel('Ratio of events with Button Down');
Git repository management for enterprise teams powered by Atlassian Stash
Atlassian Stash v2.8.3DocumentationContact SupportRequest a featureAboutContact Atlassian
Atlassian

clc
clear all
close all
%%% 
%% load data
disp('Loading Data...')
qsensor = 'q1'; % 'q2', 'q2'
% change event number: event_2, event_3, event_5, event_1
event = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_1\event_1_', qsensor]);
event = event.output; 
% event = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_2\event_2_', qsensor]);
% event = event.output;
% event = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_3\event_3_', qsensor]);
% event = event.output
% event = load(['D:\event_based_emotion_redo\Figures_spectrogram_64_raw\Event_5\event_5_', qsensor]);
% event = event.output;

%% filter
[b,a] = butter(5,0.1);
event = filter(b,a,event')';

%% pull each row and calculate 6 statistics
StatSave = zeros(size(event, 1), 6);

N = 1440;

for i = 1 : size(event, 1)
    
%     x = event(i, :);
%     StatSave(i, 1) = me
%     StatSave(i, 2) = ..
%     .
%     .
%     
    S = event(i, :);
    mu = mean(S);
    sigma = std(S);
    SB = (S - mu)/ sigma;
    delta = abs(S - [0, S(1: end-1)]);
    delta = mean(delta(2: end));
    deltaB = abs(SB - [0, SB(1: end-1)]);
    deltaB = mean(deltaB(2: end));
    gama = abs(S - [0, 0, S(1: end-2)]);
    gama = mean(gama(3: end));
    gamaB = abs(SB - [0, 0, SB(1: end-2)]);
    gamaB = mean(gamaB(3: end));   
    StatSave(i, 1) = mu;
    StatSave(i, 2) = sigma;
    StatSave(i, 3) = delta;
    StatSave(i, 4) = deltaB;
    StatSave(i, 5) = gama;
    StatSave(i, 6) = gamaB;
    

end



%% save

% if qsensor == 'q1';
%     save('D:\event_based_emotion_redo\6_features\event_1_q1_6_features');
% else
%     save('D:\event_based_emotion_redo\6_features\event_1_q2_6_features');
% end

% if qsensor == 'q1';
%     save('D:\event_based_emotion_redo\6_features\event_2_q1_6_features');
% else
%     save('D:\event_based_emotion_redo\6_features\event_2_q2_6_features');
% end
% 
% if qsensor == 'q1';
%     save('D:\event_based_emotion_redo\6_features\event_3_q1_6_features');
% else
%     save('D:\event_based_emotion_redo\6_features\event_3_q2_6_features');
% end
% 
if qsensor == 'q1';
    save('D:\event_based_emotion_redo\6_features\event_5_q1_6_features');
else
    save('D:\event_based_emotion_redo\6_features\event_5_q2_6_features');
end


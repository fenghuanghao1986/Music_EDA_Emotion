
function HowardVectorization(event, qsensor)

% event = 1 , 2, ..., 5
% qsensor = 1, 2
% event = 1;
% event = 2;
% event = 3;
% event = 4;
event = 5;

qsensor = 1;
% qsensor = 2;


output = [];
for i = 1 : 64
    
    load(['D:\event_based_emotion_redo\Figures_spectrogram_64_cmorlet\Event_', ...
    num2str(event), '\subject_',num2str(i),'_event_',num2str(event),'_q', num2str(qsensor)]); 
    
    if qsensor == 1
        Temp = saved_q1_spect_event_m_clip;
    else
        Temp = saved_q2_spect_event_m_clip;
    end
        
    Temp = imresize(Temp, [size(Temp,1), size(Temp,2)], 'bicubic');
    Temp1 = reshape(Temp',1,size(Temp,1)*size(Temp,2));
    
    output = [output; Temp1];
    
end

save(['D:\event_based_emotion_redo\Figures_spectrogram_64_cmorlet\Event_', num2str(event), ...
        '\event_', num2str(event),'_q', num2str(qsensor)], 'output'); 
    
    
    

function HowardVectorization(, qsensor)

% event = 1 , 2, ..., 5
% qsensor = 1, 2

output = [];
for i = 1 : 32
    
    load(['C:\Users\Lab User\Desktop\Figures_spectrogram_currectVersion (1)\Event_', ...
    num2str(event), '\subject_',num2str(i),'_event_',num2str(event),'_q', num2str(qsensor)]); 
    
    if qsensor == 1
        Temp = saved_q1_spect_expression_m_clip;
    else
        Temp = saved_q2_spect_expression_m_clip;
    end
        
    Temp = imresize(Temp, [size(Temp,1), 40], 'bicubic');
    Temp1 = reshape(Temp',1,size(Temp,1)*size(Temp,2));
    
    output = [output; Temp1];
    
end

save(['C:\Users\Lab User\Desktop\Figures_spectrogram_currectVersion (1)\Event_', num2str(event), ...
        '\event_', num2str(event),'_q', num2str(qsensor)], 'output'); 
    
    
    
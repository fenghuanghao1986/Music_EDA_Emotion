
function HowardVectorization_expression(expression, qsensor)

% event = 1 , 2, ..., 5
% qsensor = 1, 2
% event = 1;
% event = 2;
% event = 3;
% event = 4;
% event = 5;


expression = 'Hat';
% expression = 'Negative';
% expression = 'Smile_1';
% expression = 'Smile_2';
% expression = 'Smile_3';
% expression = 'Neutral';



% qsensor = 1;
qsensor = 2;


output = [];
cnt = 0;
for i = 1 : 27
% for i = 5
    
    address = ['D:\Howard_Feng\georgia_tech\espression_test\Expression\Expression_', ...
    expression, '\subject_',num2str(i), '_expression_', expression, '_q', num2str(qsensor),'.mat'];
    
    if exist(address, 'file')
        load(address);
        cnt = cnt + 1
    else
        continue;
    end
    
%     load(['D:\Howard_Feng\georgia_tech\espression_test\Expression\Expression_', ...
%     expression, '\subject_',num2str(i), '_expression_', expression, '_q', num2str(qsensor)]); 
    
    if qsensor == 1
        Temp = saved_q1_spect_expression_m_clip;
    else
        Temp = saved_q2_spect_expression_m_clip;
    end
        
    Temp = imresize(Temp, [size(Temp,1), size(Temp,2)], 'bicubic');
    Temp1 = reshape(Temp',1,size(Temp,1)*size(Temp,2));
    
    output = [output; Temp1];
    size(output)
    
end

save(['D:\Howard_Feng\georgia_tech\espression_test\Expression\Expression_', ...
    expression, '\expression_', expression, '_q', num2str(qsensor)], 'output'); 
    
    
    
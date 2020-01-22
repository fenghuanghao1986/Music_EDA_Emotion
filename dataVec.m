function dataVec()

output = [];
cnt = 0;

for i = 1: 8
    
    % lab path
%     address = ['D:\Howard_Feng\NAO_Music_Autism_Project\EDA_Process\C_Morlet_SVM\warmup_14_33\', num2str(i), '.mat'];
    % alienware path
    address = ['D:\LabWork\ThesisProject\Music_Autism_Robot\EDA_Process\C_Morlet_SVM\ASD0\', num2str(i), '.mat'];
    % surface path
%     address = ['C:\Users\fengh\pythonProject\NAO_Autism_Music_Project\EDA_Process\C_Morlet_SVM\warmup\', num2str(i), '.mat'];

    if exist(address, 'file')
        load(address);
        cnt = cnt + 1
    else
        continue;
    end
    
    temp = imresize(saveClip, [size(saveClip, 1), size(saveClip, 2)], 'bicubic');
    temp1 = reshape(temp', 1, size(temp, 1) * size(temp, 2));
    
    output = [output; temp1];
    size(output)
    
end

% lab path
% save('D:\Howard_Feng\NAO_Music_Autism_Project\EDA_Process\C_Morlet_SVM\vec_warm1', 'output');
% alienware path
save('D:\LabWork\ThesisProject\Music_Autism_Robot\EDA_Process\C_Morlet_SVM\vec_ASD0', 'output');
% Surface path
% save('C:\Users\fengh\pythonProject\NAO_Autism_Music_Project\EDA_Process\C_Morlet_SVM\vec_warm', 'output');


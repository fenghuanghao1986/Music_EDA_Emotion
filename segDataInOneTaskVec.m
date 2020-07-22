function dataVec()
% %% game segmentation
% 
% for i = 1: 10
%     
%     output = [];
%     cnt = 0;
% 
%     for j = 1:29
%         
%         fileName = ['E:\EDA_Process\C_Morlet_SVM\segData\game_seg\', ...
%             num2str(j), '_', num2str(i), '.mat'];
%         
%         if exist(fileName, 'file')
%             matData = load(fileName);
%         else
%             continue;
%         end    
%     
%         temp = imresize(matData.saveClip, [size(matData.saveClip, 1), size(matData.saveClip, 2)], 'bicubic');
%         temp1 = reshape(temp', 1, size(temp, 1) * size(temp, 2));
% 
%         output = [output; temp1];
%         size(output)
%     end   
%     
%     save(['E:\EDA_Process\C_Morlet_SVM\vec_game_seg_', num2str(i)], 'output');
%     
% end
% 
% %% intervention segmentation
% 
% for i = 1: 12
%     
%     output = [];
%     cnt = 0;
% 
%     for j = 1:29
%         
%         fileName = ['E:\EDA_Process\C_Morlet_SVM\segData\inter_seg\', ...
%             num2str(j), '_', num2str(i), '.mat'];
%         
%         if exist(fileName, 'file')
%             matData = load(fileName);
%         else
%             continue;
%         end    
%     
%         temp = imresize(matData.saveClip, [size(matData.saveClip, 1), size(matData.saveClip, 2)], 'bicubic');
%         temp1 = reshape(temp', 1, size(temp, 1) * size(temp, 2));
% 
%         output = [output; temp1];
%         size(output)
%     end   
%     
%     save(['E:\EDA_Process\C_Morlet_SVM\vec_inter_seg_', num2str(i)], 'output');
%     
% end


%% warmup segmentation intro
clc;
clear all;

for i = 1: 30
    
    output = [];
    cnt = 0;
    
    for j = 1: 10

        address = ['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\inter\listen\', num2str(i), '_', num2str(j), '_1', '.mat'];

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
    
    save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\inter\vec_inter_listen', num2str(i)], 'output');

end

%% warmup segmentation linten
clc;
clear all;

for i = 1: 30
    
    output = [];
    cnt = 0;
    
    for j = 1: 10

        address = ['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\inter\play\', num2str(i), '_', num2str(j), '_2', '.mat'];

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
    
    save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\inter\vec_inter_play', num2str(i)], 'output');

end

%% warmup segmentation play
clc;
clear all;

for i = 1: 30
    
    output = [];
    cnt = 0;
    
    for j = 1: 10

        address = ['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\inter\feedback\', num2str(i), '_', num2str(j), '_3', '.mat'];

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
    
    save(['E:\EDA_Process\CMorlet_SVM_EDA\segDataInOneTask\inter\vec_inter_feedback', num2str(i)], 'output');

end
           
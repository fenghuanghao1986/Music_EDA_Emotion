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


%% warmup segmentation
clc;
clear all;

output = [];

for i = 1: 29
    
    row2 = [];
    cnt = 0;
    
    for j = 1: 10

        address = ['E:\EDA_Process\C_Morlet_SVM\segDataInOneTask\warmup\intro\', num2str(i), '_', num2str(j), '_1', '.mat'];

        if exist(address, 'file')
            load(address);
            cnt = cnt + 1
        else
            continue;
        end

        row = imresize(saveClip, [size(saveClip, 1), size(saveClip, 2)], 'bicubic');
        row1 = reshape(row', 1, size(row, 1) * size(row, 2));

        row2 = [row2; row1];
        size(row2)

    end
    
%     temp = imresize(row2, [size(row2, 1), size(row2, 2)], 'bicubic');
%     temp1 = reshape(temp', 1, size(temp, 1) * size(temp, 2));

    output = [output; row2];
    size(output)
end
        
save('E:\EDA_Process\C_Morlet_SVM\vec_warm_intro', 'output');
   
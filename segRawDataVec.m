function dataVec()
%% game segmentation

for i = 1: 10
    
    output = [];
    cnt = 0;

    for j = 1:29
        
        fileName = ['E:\EDA_Process\C_Morlet_SVM\segRawData\game_seg\', ...
            num2str(j), '_', num2str(i), '.mat'];
        
        if exist(fileName, 'file')
            matData = load(fileName);
        else
            continue;
        end    
    
        temp = imresize(matData.saveClip, [size(matData.saveClip, 1), size(matData.saveClip, 2)], 'bicubic');
        temp1 = reshape(temp', 1, size(temp, 1) * size(temp, 2));

        output = [output; temp1];
        size(output)
    end   
    
    save(['E:\EDA_Process\C_Morlet_SVM\vec_game_seg_', num2str(i)], 'output');
    
end

%% intervention segmentation

for i = 1: 10
    
    output = [];
    cnt = 0;

    for j = 1:29
        
        fileName = ['E:\EDA_Process\C_Morlet_SVM\segRawData\inter_seg\', ...
            num2str(j), '_', num2str(i), '.mat'];
        
        if exist(fileName, 'file')
            matData = load(fileName);
        else
            continue;
        end    
    
        temp = imresize(matData.saveClip, [size(matData.saveClip, 1), size(matData.saveClip, 2)], 'bicubic');
        temp1 = reshape(temp', 1, size(temp, 1) * size(temp, 2));

        output = [output; temp1];
        size(output)
    end   
    
    save(['E:\EDA_Process\C_Morlet_SVM\vec_inter_seg_', num2str(i)], 'output');
    
end


%% warmup segmentation

for i = 1: 10
    
    output = [];
    cnt = 0;

    for j = 1:29
        
        fileName = ['E:\EDA_Process\C_Morlet_SVM\segRawData\warm_seg\', ...
            num2str(j), '_', num2str(i), '.mat'];
        
        if exist(fileName, 'file')
            matData = load(fileName);
        else
            continue;
        end    
    
        temp = imresize(matData.saveClip, [size(matData.saveClip, 1), size(matData.saveClip, 2)], 'bicubic');
        temp1 = reshape(temp', 1, size(temp, 1) * size(temp, 2));

        output = [output; temp1];
        size(output)
    end   
    
    save(['E:\EDA_Process\C_Morlet_SVM\vec_warm_seg_', num2str(i)], 'output');
    
end
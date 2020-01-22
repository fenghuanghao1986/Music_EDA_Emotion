clear;
clc;
warning off

time_data = 'D:\event_based_emotion_redo\selected_time_stemp.csv';

raw_data_path = 'D:\event_based_emotion_redo\refined_raw_data';

entire_time_stemps = csvread(time_data);

time_stemps = entire_time_stemps(:,2:6);

time_size = size(time_stemps);

fileType = '*.csv';

dd = dir(fullfile(raw_data_path, fileType));

fileNames = {dd.name}; 

num = numel(fileNames);

data = cell(num, 2);
data(:,1) = regexprep(fileNames, '.csv','');

znorm_q1_filter = cell(num, 1);
znorm_q2_filter = cell(num, 1);
event_m_q1_spect = cell(num, 5);
event_m_q2_spect = cell(num, 5);

saved_q1_spect_event_m_clip = [];
saved_q2_spect_event_m_clip = [];

% resize_val = [42, 81, 136, 145, 176];
resize_val = [42 * 32, 40 * 32, 56 * 32, 10 * 32, 32 * 32];


% target_event = [2, 3, 5];

% scale_range = 1: 64;
% 
% Freq_range = 10:0.3:100;
% 
% fw = Freq_range / 2;
% scale_range = 32 ./ fw;

scale_range = 1:100;

mkdir('D:\event_based_emotion_redo', 'Figures_spectrogram_32_cmorlet');

save_path = 'D:\event_based_emotion_redo\Figures_spectrogram_32_cmorlet\';


for file_num = 1: numel(fileNames)
    
    data{file_num, 2} = dlmread(fullfile(raw_data_path, fileNames{file_num}));
    
    fprintf('reading q sensor data\n');
    
    q1_data = data{file_num, 2}(:, 4);
    q2_data = data{file_num, 2}(:, 7);
    q1_data_size = size(q1_data);
    q2_data_size = size(q2_data);
           
    [znorm_q1, mu_q1, sigma_q1] = zscore(q1_data);
    [znorm_q2, mu_q2, sigma_q2] = zscore(q2_data);
    
    fprintf('Znorm done for subject %d on both sensors\n', file_num);
    
    znorm_q1_filter{file_num} = medfilt1(znorm_q1.', 20);
    znorm_q2_filter{file_num} = medfilt1(znorm_q2.', 20);
    
    current_frame = 1;
    
    for event_num = 1:1:5
        
        mkdir('D:\event_based_emotion_redo\Figures_spectrogram_32_cmorlet',...
            sprintf('Event_%d', event_num));
        
        fprintf('Loading event %d data\n', event_num);
                
        next_frame = time_stemps(file_num, event_num) * 32;
        
        event_m_q1_plot = znorm_q1_filter{file_num}(current_frame: next_frame);
        event_m_q2_plot = znorm_q2_filter{file_num}(current_frame: next_frame);
        
        event_m_q1 = abs(cwt(znorm_q1_filter{file_num}(current_frame: next_frame), scale_range,...
            'cmor1.5-2'));
        event_m_q2 = abs(cwt(znorm_q2_filter{file_num}(current_frame: next_frame), scale_range, ...
            'cmor1.5-2'));

%         event_m_q1_spect{file_num, event_num} = imresize(event_m_q1, [100, resize_val(event_num)], ...
%             'bicubic');
%         event_m_q2_spect{file_num, event_num} = imresize(event_m_q2, [100, resize_val(event_num)],...
%             'bicubic');
        
        event_m_q1_spect{file_num, event_num} = imresize(event_m_q1, [100, resize_val(2)], ...
            'bicubic');
        event_m_q2_spect{file_num, event_num} = imresize(event_m_q2, [100, resize_val(2)],...
            'bicubic');
        
        BEpoch = 1: 10;
        BaseMat_1 = (event_m_q1_spect{file_num, event_num}(:, BEpoch))';
        BaseMean_1 = repmat(mean(BaseMat_1)', 1, size(event_m_q1_spect{file_num, event_num}, 2));
        BaseStd_1 = repmat(std(BaseMat_1)', 1, size(event_m_q1_spect{file_num, event_num}, 2));
        event_m_q1_spect{file_num, event_num} = (event_m_q1_spect{file_num, event_num} - BaseMean_1) ./ BaseStd_1;
        
        
        BEpoch = 1: 10;
        BaseMat_2 = (event_m_q2_spect{file_num, event_num}(:, BEpoch))';
        BaseMean_2 = repmat(mean(BaseMat_2)', 1, size(event_m_q2_spect{file_num, event_num}, 2));
        BaseStd_2 = repmat(std(BaseMat_2)', 1, size(event_m_q2_spect{file_num, event_num}, 2));
        event_m_q2_spect{file_num, event_num} = (event_m_q2_spect{file_num, event_num} - BaseMean_2) ./ BaseStd_2;
        
        save_folder = ...
            sprintf('D:\\event_based_emotion_redo\\Figures_spectrogram_32_cmorlet\\Event_%d\\', event_num);
        
        q1_save_name = sprintf('subject_%d_event_%d_q1.mat', file_num, event_num);
        q2_save_name = sprintf('subject_%d_event_%d_q2.mat', file_num, event_num);
        
        saved_q1_spect_event_m_clip = event_m_q1_spect{file_num, event_num};
        saved_q2_spect_event_m_clip = event_m_q2_spect{file_num, event_num};
        
        save(fullfile(save_folder, q1_save_name), 'saved_q1_spect_event_m_clip');
        save(fullfile(save_folder, q2_save_name), 'saved_q2_spect_event_m_clip');
                
        current_frame = next_frame + 1;
      
        id1 = figure;
        
        hold on
        grid on
        
        subplot(2,1,1);
        plot(event_m_q1_plot(2:end), 'r');
        title(sprintf('subject %d event %d, q1, znorm filt data', file_num, event_num));
        subplot(2,1,2);
        imagesc(event_m_q1_spect{file_num, event_num});
        title(sprintf('subject%d event %d, q1, spectrogram data', file_num, event_num));
        xlabel('frame(1/32)s');
        ylabel('EDA(us)');
        
        saveas(id1, strcat(save_folder, sprintf('subject_%d_event_%d_q1_%s.fig', ...
            file_num, event_num, fileNames{file_num})));
        saveas(id1, strcat(save_folder, sprintf('subject_%d_event_%d_q1_%s.png', ...
            file_num, event_num, fileNames{file_num})));

        id2 = figure;
        
        hold on
        grid on
        
        subplot(2,1,1);
        plot(event_m_q2_plot(2:end), 'r');
        title(sprintf('subject %d event %d, q2, znorm filt data', file_num, event_num));
        subplot(2,1,2);
        imagesc(event_m_q2_spect{file_num, event_num});
        title(sprintf('subject%d event %d, q2, spectrogram data', file_num, event_num));
        xlabel('frame(1/32)s');
        ylabel('EDA(us)');
        
        saveas(id2, strcat(save_folder, sprintf('subject_%d_event_%d_q2_%s.fig',...
            file_num, event_num, fileNames{file_num})));
        saveas(id2, strcat(save_folder, sprintf('subject_%d_event_%d_q2_%s.png',...
            file_num, event_num, fileNames{file_num})));

        close all;

        fprintf('Subject %d event %d both sensors figure saved\n', file_num, event_num);
        
        event_m_q1 = [];
        event_m_q2 = [];
        saved_q1_spect_event_m_clip = [];
        saved_q2_spect_event_m_clip = [];
        event_m_q1_plot = [];
        event_m_q2_plot = [];
                
    end
    
    last_frame{file_num, :} = next_frame;
    
    znorm_q1 = [];
    znorm_q2 = [];
    q1_data_size = [];
    q2_data_size = [];
        
end

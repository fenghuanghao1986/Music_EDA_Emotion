save_path = 'D:\Howard_Feng\georgia_tech\time_stemp\G_Tech_Data_Analysis\whole_data\Figures_spectrogram_range64_filter32\';


for col = 1:5
    
    save_folder = ...
            sprintf('D:\\Howard_Feng\\georgia_tech\\time_stemp\\G_Tech_Data_Analysis\\whole_data\\Figures_spectrogram_range64_filter32\\Event_%d\\', col);    sum_for_one_event = zeros(100,1440);
    average_for_event_m = zeros(100,1440);
    
    for row = 1:66
        
        sum_for_one_event = event_m_q1_spect{row, col} + event_m_q2_spect{row, col} + sum_for_one_event;
    
    end
    
    
    average_for_event_m = sum_for_one_event / 66;
    
    save(fullfile(save_folder, sprintf('all_q1_and q2_sum_for event_%d', col)), 'sum_for_one_event');
    save(fullfile(save_folder, sprintf('all_q1_and q2_average_for event_%d', col)), 'average_for_event_m');
        
    id3 = figure;
    
    hold on
    grid on
    
    plot(average_for_event_m);
    imagesc(average_for_event_m);
    axis([0 1440 0 100]); 

    save_folder = ...
            sprintf('D:\\Howard_Feng\\georgia_tech\\time_stemp\\G_Tech_Data_Analysis\\whole_data\\Figures_spectrogram_range64_filter32\\Event_%d\\', col);
    saveas(id3, strcat(save_folder, sprintf('event_%d_average.fig', col)));
    
    
%     id4 = figure;
%     
%     hold on
%     grid on
%     
%     plot(sum_for_one_event);
%     imagesc(sum_for_one_event);
%     axis([0 1440 0 100]); 
% 
%     save_folder = ...
%             sprintf('D:\\Howard_Feng\\georgia_tech\\time_stemp\\G_Tech_Data_Analysis\\whole_data\\Figures_spectrogram_range64_filter32\\Event_%d\\', col);
%     saveas(id4, strcat(save_folder, sprintf('event_%d_sum.fig', col)));
%     
    
    close all;
    
end

    
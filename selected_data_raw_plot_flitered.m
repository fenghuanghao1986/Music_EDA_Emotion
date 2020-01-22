clc;
clear;
warning off

time_file = 'D:\Howard_Feng\georgia_tech\espression_test\all_expression_time_stemp.csv';
select_data_path = 'D:\Howard_Feng\georgia_tech\espression_test\select_data';
fileType = '*.csv';

dd = dir(fullfile(select_data_path, fileType));
fileNames = {dd.name};
num = numel(fileNames);

whole_file = csvread(time_file);

time_mtrx = whole_file(1:27, 2:51);
loop_selection = whole_file(49: 76, 2: 7);

data = cell(num, 2);
data(:,1) = regexprep(fileNames, '.csv','');

znorm_q1_filter = cell(num, 1);
znorm_q2_filter = cell(num, 1);

scale_range = 1:100;
mkdir('D:\Howard_Feng\georgia_tech\espression_test\raw');


save_folder = ...
  sprintf('D:\\Howard_Feng\\georgia_tech\\espression_test\\raw\\');
                
% 
% for i = 1: 15
%     for n = 1:7
%         frame_length(i, n) = time_mtrx(i, 2*n) - time_mtrx(i, 2*n-1);
%     end
% end

for file_num = 1: numel(fileNames)
    
    data{file_num, 2} = dlmread(fullfile(select_data_path, fileNames{file_num}));
    fprintf('reading q sensor data\n');
    q1_data = data{file_num, 2}(:, 4);
    q2_data = data{file_num, 2}(:, 7);
    
%     [znorm_q1, mu_q1, sigma_q1] = zscore(q1_data);
%     [znorm_q2, mu_q2, sigma_q2] = zscore(q2_data);
    
    [znorm_q1, mu_q1, sigma_q1] = zscore(q1_data);
    [znorm_q2, mu_q2, sigma_q2] = zscore(q2_data);
    
    fprintf('Znorm done for subject %d on both sensors\n', file_num);
    
    znorm_q1_filter{file_num} = medfilt1(znorm_q1.', 1);
    znorm_q2_filter{file_num} = medfilt1(znorm_q2.', 1); 
    
     id1 = figure;
        hold on
                grid on
                
                subplot(2,1,1);
                plot(znorm_q1_filter{file_num}(2:end), 'r');
                title(sprintf('subject %d , q1, znorm filt data', file_num));
                subplot(2,1,2);
                plot(znorm_q2_filter{file_num}(2:end), 'b')
                title(sprintf('subject %d , q2, znorm filt data', file_num));
                xlabel('frame(1/32)s');
                ylabel('EDA(us)');
                
                saveas(id1, strcat(save_folder, sprintf('subject_%d_expression_q1_q2_%s.tif', ...
                    file_num, fileNames{file_num})));
               
             
    
    
 
end

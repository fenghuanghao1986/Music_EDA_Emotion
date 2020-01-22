
% DemoSpectSignif
% Hosein M. Golshan
% Last Update: Jul 21 2016

DataFile = {'O14AJ_20141103', 'O14AK_20141210'};
ResponseFile = {'O14AJ_20141103_response', 'O14AK_20141210_response'};
% DataFile = {'A15K_20150511', 'J15M_20150608' , 'O14AJ_20141103', 'O14AK_20141210'};
% ResponseFile = {'A15K_20150511_response', 'J15M_20150608_response' , 'O14AJ_20141103_response', 'O14AK_20141210_response'};

TaskName = {'PCS_button_press','PCS_reach','AudioEvents', 'VideoEvents'};
% TaskName = {'PCS_reach', 'PCS_button_press'};

TimeRange = [-3, 2];
FreqRange = 10: 0.5: 30;
BaseRange = [-1.1, -0.1];
Method = 'Wavelet';
FilMode = 'First';
Normalization = 'Adaptive';
MapCol = 'cm';

CHLFP =  [1, 2; 2, 3; 3, 4; 5, 6; 6, 7; 7, 8];
for i = 1 : length(DataFile)
    for k = 1 : length(TaskName)
        for j = 1 : size(CHLFP, 1)
             CH = CHLFP(j, :);
             Spect = DBSSpectPlot2(DataFile{i}, ResponseFile{i}, TaskName{k},... 
                     CH(1), CH(2), 'LFP', TimeRange, FreqRange, BaseRange, ...
                     Method, FilMode, Normalization, MapCol); 
        end
    end
end

% CHECoG = [1, 2; 2, 3; 3, 4; 5, 6; 6, 7; 7, 8; 1, 5; 2, 6; 3, 7; 4, 8];
% for i = 1 : length(DataFile)
%     for k = 1 : length(TaskName)
%         for j = 1 : size(CHECoG, 1)
%              CH = CHECoG(j, :);
%              Spect = DBSSpectPlot2(DataFile{i}, ResponseFile{i}, TaskName{k},... 
%                      CH(1), CH(2), 'ECoG', TimeRange, FreqRange, BaseRange, ...
%                      Method, FilMode, Normalization, MapCol);
%         end
%     end
% end


    
    
    
    
    
    
    
    
    
    
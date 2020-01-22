clc;
clear;
warning off

% Pre-process data location 
% remember to change folder if change machine
% Ailienware path
dataPath = ...
    'D:\LabWork\ThesisProject\Music_Autism_Robot\EDA_Process\C_Morlet_SVM\game';
fileType = ...
    '*.csv';
timeFilePath = ...
    'D:\LabWork\ThesisProject\Music_Autism_Robot\EDA_Process\C_Morlet_SVM';
% Lab path
% dataPath = ...
%     'D:\Howard_Feng\NAO_Music_Autism_Project\EDA_Process\C_Morlet_SVM\game';
% fileType = ...
%     '*.csv';
% timeFilePath = ...
%     'D:\Howard_Feng\NAO_Music_Autism_Project\EDA_Process\C_Morlet_SVM';
% Surface path
% dataPath = ...
%     'C:\Users\fengh\pythonProject\NAO_Autism_Music_Project\EDA_Process\C_Morlet_SVM\game';
% fileType = ...
%     '*.csv';
% timeFilePath = ...
%     'C:\Users\fengh\pythonProject\NAO_Autism_Music_Project\EDA_Process\C_Morlet_SVM';

timeFileName = 'game_time.csv';

% create a data structure called dd by using dir()
dd = dir(fullfile(dataPath, fileType));
% get all names from dd.name
fileNames = {dd.name};
% get all file numbers for later loop times in order to go through all
% files by go through all names
num = numel(fileNames);

% create an empty num by 2 size cell
data = cell(num, 2);
% first col save all names
data(:,1) = regexprep(fileNames, '.csv', '');
% create an empty num by 1 size cell for save all normalized and filtered
% data
znormFilter = cell(num, 1);
% create a scale range for resizing and create spectrum mrtx
scaleRange = 1:100;

% open the warmup timestemp file and select start and end in the main loop
timeFileOpen = fopen(fullfile(timeFilePath, timeFileName));
timeMtx = textscan(timeFileOpen, '%s%s%s', 'delimiter', ',', 'CollectOutput', true);
t = timeMtx{1};

% start the loop for saving all mat files and ready for vetorization
for fileNum = 1: num
    
    startTime = '0:0.0';
    endTime = '0:0.0';
        
    znormQ = [];
    znormCWT = [];
    znormFilter = [];
    znormCWTSpect = [];
    muQ = [];
    sigmaQ = [];
    saveClip = [];
    tempCell = [];
    tempCellMtx = [];
    tempMtx = [];
    warmData = [];
    r = 0;
    c = 0;
    BEpoch = [];
    BaseMat = [];
    BaseMean = [];
    BaseStd = [];
    tempOpen = [];
    gameData = [];
    
    % save all numerical data in second col
%     data{fileNum, 2} = dlmread(fullfile(dataPath, fileNames{fileNum}));
    startTime = char(t(fileNum, 2));
    endTime = char(t(fileNum, 3));
    startIdx = 0;
    endIdx = 0;
    
    tempOpen = fopen(fullfile(dataPath, fileNames{fileNum}));
    tempCell = textscan(tempOpen, '%s%s%s%s%s%s%s%s', 'delimiter', ',', 'CollectOutput',true);
    tempCellMtx = [tempCell{:}];
    [r,c] = size(tempCellMtx);
    tempMtx = cell(r, 2);
    tempMtx(:, 1) = tempCellMtx(:, 1);
    tempMtx(:, 2) = tempCellMtx(:, 7);
    
    for i = 1: r
        
        if char(tempMtx(i, 1)) == startTime
            startIdx = i;
            continue
        end
        
        if char(tempMtx(i, 1)) == endTime
            endIdx = i;
            break
        end
    end
    
    for j = 1: (endIdx - startIdx)
        
        gameData(j, 1) = str2double(char(tempMtx(startIdx + j, 2)));
        
    end    
    
    fprintf('Reading CSV data number %d ...\n', fileNum);
    % do the znorm for all eda data and save in znorm, mu, and sigma
    [znormQ, muQ, sigmaQ] = zscore(gameData);
    fprintf('Znorm done for file %d... \n', fileNum);
    
    % after znorm, do med filter to it, and save in znormFilter
    znormFilter = medfilt1(znormQ.', 1);
    % do the cwt using cmor1.5-2
%     znormCWT = abs(cwt(znormFilter, scaleRange, 'cmor1.5-2'));
    % resize all data as spectrum in 100* 32
    znormCWTCubic = imresize(znormFilter, [1000, 320], 'bicubic');
    % more process to the spectrum
%     BEpoch = 1: 10;
%     BaseMat = (znormCWTCubic(:, BEpoch))';
%     BaseMean = repmat(mean(BaseMat)', 1, size(znormCWTCubic,2));
%     BaseStd = repmat(std(BaseMat)', 1, size(znormCWTCubic, 2));
%     znormCWTSpect = (znormCWTCubic - BaseMean) ./ BaseStd;
    
    % save all the mat files
    % Lab path
%     saveFolder = ...
%         sprintf('D:\\Howard_Feng\\NAO_Music_Autism_Project\\EDA_Process\\C_Morlet_SVM\\game\\');
%     Alienware path
    saveFolder = ...
        sprintf('D:\\LabWork\\ThesisProject\\Music_Autism_Robot\\EDA_Process\\C_Morlet_SVM\\game_raw\\');
    % Surface path
%     saveFolder = ...
%         sprintf('C:\\Users\\fengh\\pythonProject\\NAO_Autism_Music_Project\\EDA_Process\\C_Morlet_SVM\\game\\');
    
    saveName = ...
        sprintf('%d.mat', fileNum);
    saveClip = znormCWTCubic;
    
    save(fullfile(saveFolder, saveName), 'saveClip')
    
%     id = figure;
%     hold on 
%     grid on
%     
%     subplot(2,1,1);
%     plot(znormFilter, 'r');
%     title(sprintf('File #%d, znorm filtered data plot', fileNum));
%     subplot(2,1,2);
%     imagesc(znormCWTSpect);
%     title(sprintf('File #%d, data spectrogram', fileNum));
%     xlabel('frame(1/32)s');
%     ylabel('EDA(us)');
%     
%     saveas(id, strcat(saveFolder, sprintf('File #%d figure.fig', fileNum)));
%     saveas(id, strcat(saveFolder, sprintf('File #%d figure.tif', fileNum)))
%     close all;

    
end

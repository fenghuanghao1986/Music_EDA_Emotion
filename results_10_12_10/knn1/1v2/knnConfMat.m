filePattern = fullfile('*.mat');
matFiles = dir(filePattern);
confMat = {};
for i = 1: length(matFiles)
    baseName = fullfile(matFiles(i).name);
    data = load(baseName, 'ConfMatKNN');
    confMat{i} = data.ConfMatKNN;
end


function TransparentView2(Input, Name,  Alpha, TimeRange, FreqRange)

% Hosein M. Golshan
% Last Update: Mon Jul 11 2016
% FilMode: 'First' / 'Last'

% TransparentView2(j11aButton, 'j11aButton',  0.5, [-1,1], [10,80])
% TransparentView2(j11aSpeech, 'j11aSpeech',  0.5, [-1,1], [10,80])
% TransparentView2(A15KButton, 'A15KButton',  0.15, [-1,1], [10,80])
% TransparentView2(A15KSpeech, 'A15KSpeech',  0.15, [-1,1], [10,80])

TimeRange = TimeRange(end:-1:1); % Weird!!! check axis labels, if fixed, remove this line

figure; 
image(Input(:,:,1:3));

for i = 2 : size(Input, 3) / 3
    
    hold on
    Temp = imagesc(Input(:, :, 3*(i-1)+1 : 3*i));
    set(Temp, 'AlphaData', Alpha);
    
end

% Set Time & Frequency Axes
xRange = linspace(1, size(Input, 2), 5);
xLabel = cell(1, length(xRange));
TimeLabel = linspace(TimeRange(1), TimeRange(end), 5);
for i = 1 : length(xRange)
     xLabel{i} = num2str(TimeLabel(i));
end

xLabelnew = cell(1, length(xRange));
for ii = 1 : length(xRange)   
    xLabelnew{ii} = xLabel{length(xRange) - ii + 1};    
end

yRange = linspace(1, size(Input,1) , 5);
yLabel = cell(1, length(yRange));
freqLabel = linspace(FreqRange(1), FreqRange(end), 5);
for i = 1 : length(yRange)
     yLabel{i} = num2str(freqLabel(i));
end

yLabelnew = cell(1, length(yRange));
for ii = 1 : length(yRange)   
    yLabelnew{ii} = yLabel{length(yRange) - ii + 1};    
end

set(gca,'XTick',xRange);
set(gca,'XTickLabel',xLabelnew);
set(gca,'YTick',yRange);
set(gca,'YTickLabel',yLabelnew);
xlabel('Time (s)');
ylabel('Frequency (Hz)')
title(Name);













function output = DevidetoBands(Input)

f = double(Input);
Min = min(f(:));
f = f + abs(Min);
Max = max(f(:));
f = f * 255 / Max;

output = 127*ones(size(f));
output( find(f <= min(f(:)) + 90 )) = min(f(:));
output( find(f >= max(f(:)) - 90 )) = max(f(:));

% figure; imshow(uint8(output))








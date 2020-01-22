
function [DCTLargestCoef, DCTCoef, output] = DCT_Compress(Input, percent)

Input = double(Input);

A = dct2(Input);

[Val, Ind] = sort(abs(A(:)));
TruncInd = Ind(1:round(percent*size(Input(:))));

A(TruncInd) = 0;
DCTCoef = A;
TruncatedCoef = Ind(round(percent*size(Input(:))) + 1 : end);
DCTLargestCoef = A(TruncatedCoef);

output = idct2(A);

% figure; subplot(1,2,1); imshow(Input,[]);
% subplot(1,2,2); imshow(output,[]);


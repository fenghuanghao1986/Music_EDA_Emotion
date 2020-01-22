
function PLV = PLV_Sync(Input1,Input2,Percent)

% since the calculation of the hilbert transform requires integration over
% infinite time; 10% of the calculated instantaneous values are discarded
% on each side of every window
% discard 10%


if size(Input1)~=size(Input2)
    PLV = [];
    disp('The inputs must be of the same size ...')
    return;
end

if size(Input1,1)>1 && size(Input,2)>1
    PLV = [];
    disp('This function can extract the PLV for 1D signals ...');
    return
end

Input1 = double(Input1);
Input2 = double(Input2);

h1 = hilbert(Input1);
h2 = hilbert(Input2);
[phase1] = unwrap(angle(h1));
[phase2] = unwrap(angle(h2));

perc10w = floor(numel(h1)/Percent);
phase1 = phase1(perc10w:end-perc10w);
phase2 = phase2(perc10w:end-perc10w);

n = 1;
m = 1;
RP = n*phase1-m*phase2;
PLV = abs(sum(exp(1i*RP))/length(RP));





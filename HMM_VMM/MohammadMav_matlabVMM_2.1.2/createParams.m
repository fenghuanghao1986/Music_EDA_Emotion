global T;
ab = alphabet(char(64+(1:2^T))); % or 65 + (1:2^T)
ALGS = {'LZms', 'LZ78', 'PPMC', 'DCTW', 'BinaryCTW', 'PST'};
% 2. testing all algs; param values ~match "best" values for text data (see
% tbl.8 in VMM paper)

paramsTD.ab_size = size(ab);
paramsTD.d = 24;
paramsTD.m = 2;
paramsTD.s = 8;
paramsTD.pMin = 0.006;
paramsTD.alpha= 0;
paramsTD.gamma = 0.0006;
paramsTD.r = 1.05;
paramsTD.vmmOrder = paramsTD.d;

paramsASD.ab_size = size(ab);
paramsASD.d = 24;
paramsASD.m = 2;
paramsASD.s = 8;
paramsASD.pMin = 0.006;
paramsASD.alpha= 0;
paramsASD.gamma = 0.0006;
paramsASD.r = 1.05;
paramsASD.vmmOrder = paramsASD.d;


% % paramsASDF.ab_size = size(ab);
% % paramsASDF.d = 12;
% % paramsASDF.m = 2;
% % paramsASDF.s = 8;
% % paramsASDF.pMin = 0.006;
% % paramsASDF.alpha= 0;
% % paramsASDF.gamma = 0.0006;
% % paramsASDF.r = 1.05;
% % paramsASDF.vmmOrder = paramsASDF.d;
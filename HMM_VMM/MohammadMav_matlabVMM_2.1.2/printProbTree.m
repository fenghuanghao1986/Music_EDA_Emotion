% A simple hands-on tutorial
% Browse the code to get the basics of how-to utilize this VMM tool

clear all

global T

verbose = 0;
m = 0;
k =18; % smoothing factor
delay = 0; %starting point delay in coding

T = 2;
m = m + 1;
n = 0;
ds = 18;
k = ds;
n = n + 1;
epis = 1; % FF = 1, SF = 2, RE = 3;
[seqTD, seqASD]=readDataSeqKdx(ds, T, epis, k, delay);

createParams;

% use AB with size = 5
disp('---------------------------------------------------');
if (verbose == 1), disp('working with AB={A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P }'); end
disp('---------------------------------------------------');
s = 3;
% 3. run each of the VMM algorithms
if (verbose == 1), disp(sprintf('Working with %s', 'PPMC' )); end
%     disp('--------')
jVmmASD_full = vmm_createNew(map(ab, seqASD),  ALGS{s}, paramsASD);
jVmmTD_full = vmm_createNew(map(ab, seqTD),  ALGS{s}, paramsTD);
for b=1:(size(ab) - 1)
p =[];
for a=1:(size(ab)-1)
disp(sprintf('Pr(%s|%s) = %f \n', num2str(a), num2str([b]), vmm_getPr(jVmmASD_full,a, [b] )));
p=[p, vmm_getPr(jVmmASD_full,a, [b])];
end
disp(sprintf('Pr(%s|%s) = %f\n', 'All', num2str([b]), sum(p)));
end
% disp(sprintf('Pr(B | A) = %f', vmm_getPr(jVmm, mapS(ab,'B'), mapS(ab,'A'))));


function [index1nm] = nbt_n_m_detection(phase1,phase2,n,m)


RP = n*phase1-m*phase2;
%--- 
% distribution of the cyclic relative phase
CRP = mod(RP,2*pi);
Nbins = 100;
range = linspace(-pi,pi,Nbins);
dCRP = hist(CRP,range);
dCRP = dCRP/length(CRP);
% figure
% bar(range,dCRP)
% axis tight
% the estimate of this index strongly depends on the number of bins used
% for computation of the histogram.

%% 1. Index1: n:m synchronization index based on the Shannon entropy
S = entropy(dCRP); % entropy of the distribution of the cyclic relative phase
Smax = log(length(dCRP));
index1nm = (Smax-S)/Smax;
% 0<=Index1nm<=1
% if Index1nm=0 --> uniform distribution (no synchronization)
% if Index1nm=1 --> Dirac-like distribution (perfect synchronization)



% 
% function [index1nm,index2nm, index3nm] = nbt_n_m_detection(phase1,phase2,n,m)
% RP = n*phase1-m*phase2;
% %--- 
% % distribution of the cyclic relative phase
% CRP = mod(RP,2*pi);
% Nbins = 100;
% range = linspace(-pi,pi,Nbins);
% dCRP = hist(CRP,range);
% dCRP = dCRP/length(CRP);
% figure
% bar(range,dCRP)
% axis tight
% % the estimate of this index strongly depends on the number of bins used
% % for computation of the histogram.
% %% 1. Index1: n:m synchronization index based on the Shannon entropy
% S = entropy(dCRP); % entropy of the distribution of the cyclic relative phase
% Smax = log(length(dCRP));
% index1nm = (Smax-S)/Smax;
% % 0<=Index1nm<=1
% % if Index1nm=0 --> uniform distribution (no synchronization)
% % if Index1nm=1 --> Dirac-like distribution (perfect synchronization)
% %% 2. Index2: based on the conditional probability
% Nint = 10;
% int_m = linspace(0,2*pi*m,Nint);
% for j = 1:Nint-1
%         int1 = int_m(j);
%         int2 = int_m(j+1);
%         [theta index] = find(mod(phase1,2*pi*m)<=int2 & mod(phase1,2*pi*m)>=int1);
%         M = length(theta);
%         ni = mod(phase2(index),2*pi*n);
%         sum(exp(i*ni/n))/M;
%         expM(j) = sum(exp(i*ni/n))/M;
%         if isnan(expM(j))            
%             expM(j) = 0;
%         end
% end
% index2nm = sum(abs(expM))/Nint;
% % abs(r_int) = 1 indicates complete dependence between the two phases 
% % abs(r_int) = 0 indicates no dependence at all
% % --- average over all bins:
% % index2nm measures the conditional probability for phase2 to have a
% % certain value provided phase1 in a certain bin 
% % find n and m we try different values and pick up those that give larger
% % indices
% %% 3. Index3 Intensity of the first Fourier mode of the distribution 
% % it also varies from 0 to 1. The advantage of this index is that its
% % computation involves no parameters
% index3nm = sqrt((mean(cos(dCRP)).^2) +mean((sin(dCRP))).^2);
% 

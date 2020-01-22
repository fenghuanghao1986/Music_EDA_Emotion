function [jVmm]=CreateVmmKfold(seq,alg,loso,params,Kfold)

% creates a VMM using algorithm alg(params) and training sequence 'seq'
%
% [jVmm]=CreateVmm(seq,alg,params)
%
% param seq - a char sequence (string)
% param alg - the name of the VMM algorithm; one of the followings:
%       {'LZms', 'LZ78', 'PPMC', 'DCTW', 'BinaryCTW', 'PST'}
% param params - a struct with the relevant algorithm parameters:
%       LZms - ab_size, m, s
%       LZ78 - ab_size
%       PPMC - ab_size, d
%       DCTW - ab_size, d
%       BinaryCTW - ab_size, d
%       PST - ab_size,  pMin, alpha,  gamma,  r,  d
%
% usage example:
% params.ab_size = 127
% params.d = 5
% jVmm = vmm_create('abracadabra', 'PPMC', params)
% vmm_getPr(jVmm,double('a'),'br')
% vmm_logEval(jVmm,'abracadabra')
% ---
% % another running option:
%
% ab = alphabet('abracadabra');
% params.ab_size = size(ab);
% params.d = 5
%
% jVmm = vmm_create(map(ab,'abracadabra'), 'PPMC', params)
% vmm_getPr(jVmm, map(ab, 'a'), map(ab, 'br'))
% vmm_logEval(jVmm,map(ab,'abracadabra'))
%
% See also "simple_runner.m"
% --
% This matlab wrapper for the java VMM package was co-writen by Dotan Di
% Castro and Ron Begleiter. For more details visit
% http://www.cs.technion.ac.il/~ronbeg/vmm/
%--------------------------------------------------------------------------

if strcmp(alg, 'LZms')
    jVmm = javaObject('vmm.algs.LZmsPredictor');
    javaMethod('init',jVmm,params.ab_size,params.m,params.s);
elseif strcmp(alg, 'PPMC')
    jVmm = javaObject('vmm.algs.PPMCPredictor');
    javaMethod('init',jVmm,params.ab_size,params.d);
elseif strcmp(alg, 'DCTW')
    jVmm = javaObject('vmm.algs.DCTWPredictor');
    javaMethod('init',jVmm,params.ab_size,params.d);
elseif strcmp(alg, 'BinaryCTW')
    jVmm = javaObject('vmm.algs.BinaryCTWPredictor');
    javaMethod('init',jVmm,params.ab_size,params.d);
elseif strcmp(alg, 'LZ78')
    jVmm = javaObject('vmm.algs.LZ78Predictor');
    javaMethod('init',jVmm,params.ab_size);
elseif strcmp(alg, 'PST')
    jVmm = javaObject('vmm.algs.PSTPredictor');
    javaMethod('init',jVmm, params.ab_size, params.pMin, params.alpha, params.gamma, params.r, params.d);
else
    error('ILL alg. name');
end

indx = randperm(length(seq));
indx(find(indx == loso)) = [];
indx = indx(1:Kfold);


% for i= indx
%     seqTmp= num2str(seq{i}.se);
%     jSeq = java.lang.String(seqTmp);
%     javaMethod('learn',jVmm, jSeq);
%     
% end

n = 0;
if strcmp(alg, 'LZms')
    
    for i= indx
        n = n + 1;
        seqTmp= num2str(seq{i}.se);
        jSeq = java.lang.String(seqTmp);
        if (n == 1)
            %                 'learn'
            javaMethod('learn',jVmm, jSeq);
        else
            %                 'update'
            javaMethod('update',jVmm, jSeq);
        end
        
    end
else
    for i= indx
        seqTmp= num2str(seq{i}.se);
        jSeq = java.lang.String(seqTmp);
        javaMethod('learn',jVmm, jSeq);
    end
end



function [Sigma,Alpsup,w0,pos,history,obj,status] = mklsvm_LqNorm2(K,yapp,C,q,option,verbose)

% Outputs
%
% Sigma         : the weigths
% Alpsup        : the weigthed lagrangian of the support vectors
% w0            : the bias
% pos           : the indices of SV
% history        : history of the weigths
% obj           : objective value
% status        : output status (sucessful or max iter)
[n] = length(yapp);
if ~isempty(K)
    if size(K,3)>1
        nbkernel=size(K,3);
        if option.efficientkernel==1
            K = build_efficientK(K);
        end;
    elseif option.efficientkernel==1 & isstruct(K);
        nbkernel=K.nbkernel;     
    end;
else
    error('No kernels defined ...');
end;

if ~isfield(option,'nbitermax');
    nloopmax=1000;
else
    nloopmax=option.nbitermax;
end;
if ~isfield(option,'algo');
    option.algo='svmclass';
end;
if ~isfield(option,'seuil');
    seuil=1e-12;
else
    seuil=option.seuil;
end
if ~isfield(option,'seuilitermax')
    option.seuilitermax=20;
end;
if ~isfield(option,'seuildiffsigma');
    option.seuildiffsigma=1e-5;
end
if ~isfield(option,'seuildiffconstraint');
    option.seuildiffconstraint=0.05;
end

if ~isfield(option,'lambdareg');
    lambdareg=1e-10;
    option.lambdareg=1e-10;
else
    lambdareg=option.lambdareg;
end


if ~isfield(option,'numericalprecision');
    option.numericalprecision=0;
end;

if ~isfield(option,'verbosesvm');
    verbosesvm=0;
    option.verbosesvm=0;
else
    verbosesvm=option.verbosesvm;
end

if ~isfield(option,'sigmainit');
    Sigma=ones(1,nbkernel)/nbkernel;
else
    Sigma=option.sigmainit ;
    ind=find(Sigma==0);
end;


if isfield(option,'alphainit');
    alphainit=option.alphainit;
else
    alphainit=[];
end;




%--------------------------------------------------------------------------------
% Options used in subroutines
%--------------------------------------------------------------------------------
if ~isfield(option,'goldensearch_deltmax');
    option.goldensearch_deltmax=1e-1;
end
if ~isfield(option,'goldensearchmax');
    optiongoldensearchmax=1e-8;
end;
if ~isfield(option,'firstbasevariable');
    option.firstbasevariable='first';
end;

%------------------------------------------------------------------------------%
% Initialize
%------------------------------------------------------------------------------%
kernel       = 'numerical';
span         = 1;
nloop = 0;
loop = 1;
status=0;


%%% Initialization
p = q/(q-2);
Sigmaold = ((size(K,3))^(-1/p))*ones(size(K,3),1);
Sigma = Sigmaold;
kerneloption.matrix = sumKbeta(K,1./Sigmaold);
[xsup,Alpsup,w0,pos,aux,aux,obj] = svmclass([],yapp,C,lambdareg,kernel,kerneloption,verbosesvm,span,alphainit);
history = obj;
while loop & (nloop < nloopmax)
%tic
    for i = 1:length(Sigma)
        Sigma(i) = (Alpsup' * K(pos,pos,i) * Alpsup)^(1/(p+1));
    end
    Sigma = Sigma/norm(Sigma,p);
    
    kerneloption.matrix = sumKbeta(K,1./Sigma);
    [xsup,Alpsup,w0,pos,aux,aux,obj] = svmclass([],yapp,C,lambdareg,kernel,kerneloption,verbosesvm,span,alphainit);
    
    history = [history obj];
    
    gap_Sigma = abs(Sigma - Sigmaold);
    Sigmaold = Sigma;
    
    if (gap_Sigma'*gap_Sigma) < option.seuildiffsigma
        loop = 0;
    end
    
    nloop = nloop+1;
%toc    
end

Sigma = 1./Sigma;





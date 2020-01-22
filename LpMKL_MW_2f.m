function [ypred,HoseinTimeTrain,HoseinTimeTest] = LpMKL_MW_2f(xapp,xapp1,yapp,xtest,xtest1,C,nbclass,q)

lambda = 1e-7;
verbose = 1;
options.algo='svmclass';
options.seuildiffsigma=1e-4;
options.seuildiffconstraint=0.1;
options.seuildualitygap=1e-2;
options.goldensearch_deltmax=1e-1;
options.numericalprecision=1e-8;
options.stopvariation=1;
options.stopKKT=1;
options.stopdualitygap=1;
options.firstbasevariable='first';
options.nbitermax=500;
options.seuil=0.;
options.seuilitermax=10;
options.lambdareg = 1e-6;
options.miniter=0;
options.verbosesvm=0;
options.efficientkernel=0;
%------------------------------------------------------------

kernelt={'gaussian' 'poly' };
kerneloptionvect={[0.01;0.05;0.1;0.5;1;2;8;16;32] [1;2;3]};
variablevec={'all' 'all'};

[nbdata,dim]=size(xapp);
[kernel,kerneloptionvec,variableveccell]=CreateKernelListWithVariable(variablevec,dim,kernelt,kerneloptionvect);
[Weight,InfoKernel]=UnitTraceNormalization(xapp,kernel,kerneloptionvec,variableveccell);

[nbdata1,dim1]= size(xapp1);
[kernel1,kerneloptionvec1,variableveccell1]=CreateKernelListWithVariable(variablevec,dim1,kernelt,kerneloptionvect);
[Weight1,InfoKernel1]=UnitTraceNormalization(xapp1,kernel1,kerneloptionvec1,variableveccell1);

 K = mklkernel_2f(xapp,xapp1,InfoKernel,Weight,options);
 K1 = mklkernel_2f(xapp1,xapp1,InfoKernel1,Weight1,options);
 K = cat(3,K,K1);

%---------------------Learning & Training & Testing----------------
vote=zeros(size(xtest,1),nbclass);
ct = 0;

% tic   % Hsein *******************
HoseinNumerator=0;

for i=1:nbclass-1
    for j=i+1:nbclass
        
        HoseinNumerator=HoseinNumerator+1;
        
        tic
        ct = ct + 1;
        %%%%% Arranging training data
        indi=find(yapp==i);
        indj=find(yapp==j);
        yone=[ones(length(indi),1);-ones(length(indj),1)];
        Kaux = K([indi  ;indj],[indi; indj],:);
        
        %%%%% Solving MKL based SVM with Multiple Kernel Weight Vectors
        
        if q == 1 
               [beta,w,b,posw,story,obj] = mklsvm(Kaux,yone,C,options,verbose);
            elseif ((q>1) & (q<2))
                p = q/(2-q);
                [beta,w,b,posw,story,obj] = mklsvm_LpNorm(Kaux,yone,C,p,options,verbose);
            else
                [beta,w,b,posw,story,obj] = mklsvm_LqNorm2(Kaux,yone,C,q,options,verbose);
        end
        
        % [beta,w,b,posw,story,obj] = mklsvm(Kaux,yone,C,options,verbose);
        aux=[indi;indj];
        posw=aux(posw);
        
        HoseinTimeTrain(HoseinNumerator)= toc;
        
        %%%%% Testing 
        
        tic 
        
        Kt=mklkernel_2f(xtest,xtest1,[InfoKernel InfoKernel1],[Weight Weight1],options,xapp(posw,:),xapp1(posw,:),beta);
        ypred = Kt*w+b;
        
        indi=find(ypred>=0);
        indj=find(ypred<0);
        vote(indi,i)=vote(indi,i)+1;
        vote(indj,j)=vote(indj,j)+1;
        
        HoseinTimeTest(HoseinNumerator)= toc;
        
        
        
    end
end

HoseinTimeTrain = sum(HoseinTimeTrain(:));
HoseinTimeTest = sum(HoseinTimeTest(:));

[maxi,ypred]=max(vote');
ypred=ypred';


% toc  % Hsein *******************











function K=mklkernel_2f(xapp,xapp1,InfoKernel,Weight,options,xsup,xsup1,beta)

if nargin <6
    xsup=xapp;
    beta=[];


    for k=1:length(Weight)

        Kr=svmkernel(xapp(:,InfoKernel(k).variable),InfoKernel(k).kernel,InfoKernel(k).kerneloption, xsup(:,InfoKernel(k).variable));

        Kr=Kr*Weight(k);
%         if options.efficientkernel
%             Kr=build_efficientK(Kr);
%         end;

        K(:,:,k)=Kr;


    end;
else
    ind=find(beta);
    L = length(find(ind<length(beta)/2 + 1));
        
    K=zeros(size(xapp,1),size(xsup,1));
    for i=1:L;
        k=ind(i); 
        Kr=svmkernel(xapp(:,InfoKernel(k).variable),InfoKernel(k).kernel,InfoKernel(k).kerneloption, xsup(:,InfoKernel(k).variable));
        Kr=Kr*Weight(k);
        K=K+ Kr*beta(k);
    end;
    
    for i=L+1:length(ind);
        k=ind(i); 
        Kr=svmkernel(xapp1(:,InfoKernel(k).variable),InfoKernel(k).kernel,InfoKernel(k).kerneloption, xsup1(:,InfoKernel(k).variable));
        Kr=Kr*Weight(k);
        K=K+ Kr*beta(k);
    end;

end;
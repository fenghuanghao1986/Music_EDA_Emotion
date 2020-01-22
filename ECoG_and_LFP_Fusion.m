
% By Hosein M.Golshan
% Last Update: Jun. 27, 2016

clear all
close all
clc

% load('J15MLabelsDataLFP');
load('O14AJLabelsDataLFP');
% load('O14AKLabelsDataLFP');
% load('A15KLabelsDataLFP');

SVM_LFP = FinalLabelsSVM;
MKL_LFP = FinalLabelsMKL;
clear FinalLabelsSVM FinalLabelsMKL InterestedTasks SampNumb

% load('J15MLabelsDataECoG');
load('O14AJLabelsDataECoG');
% load('O14AKLabelsDataECoG');
% load('A15KLabelsDataECoG');

SVM_ECoG = FinalLabelsSVM;
MKL_ECoG = FinalLabelsMKL;

%% Fusion Phase

NewMKLLabels= zeros(3*numel(InterestedTasks),SampNumb);
NewSVMLabels= zeros(3*numel(InterestedTasks),SampNumb);

for j = 1:SampNumb
    
    for i = 1:numel(InterestedTasks)
    
        TempLabel = SVM_LFP(3*(i-1)+1:3*i, j);
        TempLabel1 = SVM_ECoG(3*(i-1)+1:3*i, j);
        
        for k = 1:numel(InterestedTasks)
            ww = numel(find(TempLabel==k));
            if ww>1
                TempLabel = k*ones(3,1);
                break
            end
        end
        
        if ww<=1
%            if Synchronization==1 
%                TempLabel = TempLabel(MostLikelyCh)*ones(3,1);
%            else
%                TempLabel = TempLabel(1)*ones(3,1);
%            end
           
           x = zeros(1,3);
           for dd = 1:3
               x(dd) = numel(find(TempLabel1 == TempLabel(dd)));
           end
           
           [vv, ii] = max(x);
           TempLabel = TempLabel(ii)*ones(3,1);
               
        end            
        NewSVMLabels(3*(i-1)+1:3*i, j)=TempLabel;

% **************************************************************************  

        TempLabel2 = MKL_LFP(3*(i-1)+1:3*i, j);
        TempLabel22 = MKL_ECoG(3*(i-1)+1:3*i, j);
        
        for k = 1:numel(InterestedTasks)
            ww2 = numel(find(TempLabel2==k));
            if ww2>1
                TempLabel2 = k*ones(3,1);
                break
            end
        end
        
        if ww2<=1
%             if Synchronization==1
%                 TempLabel2 = TempLabel2(MostLikelyCh)*ones(3,1);
%             else
%                 TempLabel2 = TempLabel2(1)*ones(3,1);
%             end
           
           x = zeros(1,3);
           for dd = 1:3
               x(dd) = numel(find(TempLabel22 == TempLabel2(dd)));
           end
           
           [vv, ii] = max(x);
           TempLabel2 = TempLabel2(ii)*ones(3,1);
           
        end
           
        NewMKLLabels(3*(i-1)+1:3*i, j) = TempLabel2;
        
    end
    
end


%% New Quantitative Assessments

% ******************************************
% If there is any bug, just replace them
TeLa2 = [];
for uu = 1:numel(InterestedTasks)
    TeLa2 = [TeLa2; uu*ones(3,1)];
end
% TeLa2 = [ones(3,1);2*ones(3,1);3*ones(3,1);4*ones(3,1);5*ones(3,1)];
% ******************************************

NewLabelDif_SVM = NewSVMLabels - repmat(TeLa2,1,SampNumb);
NewLabelDif_MKL = NewMKLLabels - repmat(TeLa2,1,SampNumb);

NewSVMAccuracy = 100*numel(find(NewLabelDif_SVM==0))/(numel(NewLabelDif_SVM));
NewMKLAccuracy = 100*numel(find(NewLabelDif_MKL==0))/(numel(NewLabelDif_MKL));

% Confusion Matrix for the new implementation
NewLaSVM = zeros(numel(InterestedTasks),SampNumb);
NewLaMKL = zeros(numel(InterestedTasks),SampNumb);

for z2 = 1:SampNumb
    
    for z1 = 1:numel(InterestedTasks)
         
        NewLaSVM(z1,z2) = NewSVMLabels(3*(z1-1)+1,z2);
        NewLaMKL(z1,z2) = NewMKLLabels(3*(z1-1)+1,z2);
        
    end
    
end      

ConfMatSVM_N = zeros(numel(InterestedTasks),numel(InterestedTasks));
ConfMatMKL_N = zeros(numel(InterestedTasks),numel(InterestedTasks));

for p = 1:SampNumb
    
    TempSVMLa = NewLaSVM(:,p);
    TempMKLLa = NewLaMKL(:,p);
    
    for p1 = 1:numel(InterestedTasks)
        
        for p2 = 1:numel(InterestedTasks)
            
            ConfMatSVM_N(p1,p2) =  ConfMatSVM_N(p1,p2) + numel(find(TempSVMLa(p1)==p2));
            ConfMatMKL_N(p1,p2) =  ConfMatMKL_N(p1,p2) + numel(find(TempMKLLa(p1)==p2));
            
        end
        
    end
    
end

ConfMat_SVM_N = round(100*(ConfMatSVM_N/SampNumb)); 
ConfMat_MKL_N = round(100*(ConfMatMKL_N/SampNumb));   

disp(['NewSVMAccuracy: ', num2str(NewSVMAccuracy)])
disp(['NewMKLAccuracy: ', num2str(NewMKLAccuracy)])




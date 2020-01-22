load('C:\Users\CV_Lab\Downloads\Part1_NaoTalking_TD_ASD_VMM_Classifications_fewSeqsPerSubj_D_1.mat')
TrueLab = [zeros(size(Classification_TD,1),1) ;ones(size(Classification_ASD,1),1)]
PredLab = double([~Classification_TD ; Classification_ASD])

x = confusionmat(TrueLab,PredLab); 
Acc = sum(diag(x))/sum(x(:));
F1 = Funct_F1score(TrueLab, PredLab)

load('C:\Users\CV_Lab\Downloads\Part1_KidTalking_TD_ASD_VMM_Classifications_fewSeqsPerSubj_D_1.mat')
TrueLab = [zeros(size(Classification_TD,1),1) ;ones(size(Classification_ASD,1),1)]
PredLab = double([~Classification_TD ; Classification_ASD])

x = confusionmat(TrueLab,PredLab); 
Acc = sum(diag(x))/sum(x(:));
F1 = Funct_F1score(TrueLab, PredLab)
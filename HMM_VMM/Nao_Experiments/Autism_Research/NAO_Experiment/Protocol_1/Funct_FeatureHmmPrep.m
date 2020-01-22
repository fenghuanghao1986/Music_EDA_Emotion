function [Feat_Tot, ClassLable_Tot] = Funct_FeatureHmmPrep(Features,Labels);
%%load two structure and place them into two matrices in order to come up with new features.    

ClassLable_Tot= [];
    Feat_Tot=[];
    NumSeg = size(Features,2);
    for (i_seg = 1:NumSeg)
        ClassLable_Tot = [ClassLable_Tot ;Labels{i_seg}];
        Feat_Tot = [Feat_Tot ;Features{i_seg}];
    end
    
end

function [seqKdx3 seqKdx12]=readDataSeqKdxToAlphabet(ds, T, epis)
% [seqTD, seqASD]=readDataSeq(ds, T)


load gaze_data_1_152.mat data
warning OFF
% ds = 10;
% T = 4;
% O = 2^T;  % number of the outcomes

m = 0; n = 0;
    for i =[1:27,30:58]
        
        if (data(i).kdx > 0 & data(i).kdx < 3)
            n = n + 1;
%             st1(n) = i;
            tmp  = [data(i).gaze(data(i).epis == epis)]'; tmp(tmp == 120) = 1; tmp(tmp == 0) = 1; tmp(tmp == 40) = 0; tmp(tmp == 80) = 1;
            tmp = tmp(1:ds:end)';
            seqKdx12{n}.se = char(signal2phrase(tmp, T, 0)+64);
            seqKdx12{n}.sn = data(i).sn;
            seqKdx12{n}.kdx = data(i).kdx;
            
        elseif data(i).kdx == 3
            m = m + 1;
%             st2(m) = i;
            tmp  = [data(i).gaze(data(i).epis == epis)]'; tmp(tmp == 120) = 1;  tmp(tmp == 0) = 1;tmp(tmp == 40) = 0; tmp(tmp == 80) = 1;
            tmp = tmp(1:ds:end)';
            seqKdx3{m}.se = char(signal2phrase(tmp, T, 0)+64);
            seqKdx3{m}.sn = data(i).sn;
            seqKdx3{m}.kdx = data(i).kdx;
            
            else
            data(i).kdx;
            
        end
    end




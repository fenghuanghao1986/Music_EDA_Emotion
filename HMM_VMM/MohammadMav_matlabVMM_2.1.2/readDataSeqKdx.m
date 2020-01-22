
function [seqKdx3 seqKdx12]=readDataSeqKdx(ds, T, epis, k, delay)
% [seqTD, seqASD]=readDataSeq(ds, T)

delay = delay +1;
load lisa_data_1_152_updated_April2012.mat data
warning OFF
% ds = 10;
% T = 4;
% O = 2^T;  % number of the outcomes

m = 0; n = 0;
for i =[1:8, 10:24, 26:27,30:43, 45:58] %[1:58]
%     [1:8, 10:24, 26:27,30:43, 45:58] % previously we used these indices.
%     
    
    if (data(i).kdx > 0 & data(i).kdx < 3)
        n = n + 1;
        %             st1(n) = i;
        tmp  = [data(i).gaze(data(i).epis == epis)]'; tmp(tmp == 120) = 1; tmp(tmp == 0) = 1; tmp(tmp == 40) = 0; tmp(tmp == 80) = 1;
        tmp = tmp';
        if k > 1
            tmp = smooth(tmp,k);
            tmp(find(tmp < .5)) = 0;
            tmp(find(tmp > .5)) = 1;
        end
        tmp = tmp(delay:ds:end);
        seqKdx12{n}.se = signal2phrase(tmp, T, 0);
        seqKdx12{n}.sn = data(i).sn;
        seqKdx12{n}.kdx = data(i).kdx;
        
    elseif data(i).kdx == 3
        m = m + 1;
        %             st2(m) = i;
        tmp  = [data(i).gaze(data(i).epis == epis)]'; tmp(tmp == 120) = 1;  tmp(tmp == 0) = 1;tmp(tmp == 40) = 0; tmp(tmp == 80) = 1;
        tmp = tmp';
        if k > 1
            tmp = smooth(tmp,k);
            tmp(find(tmp < .5)) = 0;
            tmp(find(tmp > .5)) = 1;
        end
        tmp = tmp(delay:ds:end);
        seqKdx3{m}.se = signal2phrase(tmp, T, 0);
        seqKdx3{m}.sn = data(i).sn;
        seqKdx3{m}.kdx = data(i).kdx;
        
    else
        data(i).kdx;
        
    end
end




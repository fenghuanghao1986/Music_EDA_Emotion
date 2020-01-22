
function stringOut = signal2pattern(data, T, startTime)
% stringOut = signal2pattern(data, T, startTime)

stringOut = [];
pattern = zeros(2^T, T);

for i = 0:2^T-1
    a = dec2bin(i);
    for c = 0:length(a)-1      
        pattern(i+1,end-c) = str2num(a(end-c));
    end
end

% % pattern(1,:) = [0 0 0];
% % pattern(2,:) = [0 0 1];
% % pattern(3,:) = [0 1 0];
% % pattern(4,:) = [0 1 1];
% % pattern(5,:) = [1 0 0];
% % pattern(6,:) = [1 0 1];
% % pattern(7,:) = [1 1 0];
% % pattern(8,:) = [1 1 1];
% %
phrase(1:2^T) = 1:2^T;

for i = 1+startTime:T:(length(data)-mod(length(data),T) - T)
    for j =1:size(pattern,1)
        aa = data(i:i+T-1)';
        bb = pattern(j,:);
        if all((aa == bb))
            stringOut = [stringOut,phrase(j)];
        end
        
    end
end





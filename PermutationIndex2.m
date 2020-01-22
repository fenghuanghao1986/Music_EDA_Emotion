
function [Per_IndexH1, Per_IndexH2] = PermutationIndex2(Input, Terminate)

% Hosein M. Golshan
% Last Update: Jul 15, 2016

warning off

Terminate = Terminate * 2;
z = numel(Input);

if mod(z,2) ~= 0
    z = z - 1;
end

Half1 = Input(1 : z / 2);
Half2 = Input(z / 2 + 1 : z); 

Index1 = nchoosek(Half1, z / 2);
Index2 = nchoosek(Half2, z / 2);

IndexH1 = [];
IndexH2 = [];

for i = 1 : z / 2 - 1
    
    TempIndex1 = nchoosek(Half1, i);
    TempIndex2 = nchoosek(Half2, z / 2 - i);
        
    r1 = [];
    r2 = [];
    
    for j = 1 : size(TempIndex1, 1)
        
        k1 = TempIndex1(j, :);
        
        for m = 1 : size(TempIndex2, 1)
            
            TemMem = zeros(1, z);
            Temr1 = [k1, TempIndex2(m, :)];
            r1 = [r1; Temr1];
            TemMem(Temr1) = 1;
            r2 = [r2; find(TemMem ~= 1)];
            
            if size(r1, 1) > Terminate
                break
            end
        
        end
        
        if size(r1, 1) > Terminate
            break
        end
        
    end
        
    IndexH1 = [IndexH1; r1];
    IndexH2 = [IndexH2; r2];
    
    if size(r1, 1) > Terminate
        IndexH1 = IndexH1(1: min(Terminate, size(IndexH1,1)), :);
        IndexH2 = IndexH2(1: min(Terminate, size(IndexH2,1)), :);
        break
    end
           
end

Per_IndexH1 = [Index1 ; IndexH1];
Per_IndexH2 = [Index2 ; IndexH2];

% Per_Index = [Per_IndexH1, Per_IndexH2];
% Per_Index = Per_Index(1 : size(Per_Index, 1) / 2 + 1, :);
% disp(num2str(size(Per_Index)))

Per_IndexH1 = Per_IndexH1(1 : size(Per_IndexH1, 1) / 2 + 1, :);
Per_IndexH2 = Per_IndexH2(1 : size(Per_IndexH2, 1) / 2 + 1, :);
    





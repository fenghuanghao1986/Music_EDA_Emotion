
Index=[1 3 2 5 6 6 9 9 8 11 11 11 14 13 13];

for i = 1:15
    
    if DataSetTest{Index(i),2}==TempDataSet{i,2}
        disp('right second column')
    else 
        disp('wrong second column')
    end
    
    if DataSetTest{i,1}==TempDataSet{i,1}
        disp('right first column')
    else
        disp('wrong first column')
    end
    
end
        
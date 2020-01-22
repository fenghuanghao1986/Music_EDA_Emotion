clear all
epis = 1;
ds = 18;
T = 4;
[seqKdx3, seqKdx12]=readDataSeqKdxToAlphabet(ds, T, epis);

disp(seqKdx3{1}.se)


str = ['This is the matrix1:  0'];
str2 =['11111111111111111111111'];
strm=[str;str2];

fName = 'str_and_mat.txt';         %# A file name
fid = fopen(fName,'w');            %# Open the file
for i=1:2

  fprintf(fid,'%s \n',strm(i,:));       %# Print the string
  
end

  fclose(fid);                     %# Close the file

% 
% str = ['This is the matrix1:  0'];
% str2 =['11111111111111111111111'];
% strm=[str;str2];
% 
% for i=1:2
%     
%   fName = 'str_and_mat.txt';         %# A file name
%   fid = fopen(fName,'w');            %# Open the file
%   if fid ~= -1
%      fprintf(fid,'%s\r\n',strm(i,:));       %# Print the string
%      fclose(fid);                     %# Close the file
%   end 
%   
% end
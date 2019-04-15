function B_write_btl(B)
%B_write_btl - Write bottle structure to file 
%
%Syntax:  B_write_btl(B)
%  B is the structure out of B_read_btl_txtfile 
%    (B.filename, B.data: cell array of bottle data)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 16-Feb-2004 CL

% Modified by Gordana Lazin so it can handle file names that include path
% March 29, 2017

backslash=strfind(B.filename,'\'); 

% create new file name for the output file that has QC prefix
if (length(backslash))>0
    path=B.filename(1:backslash(end)); %path where to put the file
    sfn=backslash(end)+1; % start of the file names is after the last backslash
    qcfn=['QC_', B.filename(sfn:end)]; % filename without a path
else
    qcfn=B.filename;
end
    
fid = fopen([qcfn(1:end-4) '.txt'],'wt'); % just to make sure it is a text file
for i=1:size(B.data,1)
    lin = [];
    for j=1:size(B.data,2)
        lin = [lin sprintf('%s;',B.data{i,j})];
    end
    fprintf(fid,'%s\n',lin(1:end-1));
end
fclose(fid);
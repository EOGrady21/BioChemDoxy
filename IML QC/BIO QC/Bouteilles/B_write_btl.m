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

fid = fopen(['QC_' B.filename(1:end-4) '.txt'],'wt');
for i=1:size(B.data,1)
    lin = [];
    for j=1:size(B.data,2)
        lin = [lin sprintf('%s;',B.data{i,j})];
    end
    fprintf(fid,'%s\n',lin(1:end-1));
end
fclose(fid);
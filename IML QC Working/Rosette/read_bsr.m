function R = read_bsr(filename)
%READ_BSR - Reads a CTD BSR-file out of Seabird bottle treatment 
%
%Syntax:  R = read_bsr(filename)
% filename is the name of the BSR file between quotes (ex:'temp.bsr')
% R is a structure array with fields
%   R.filename: Profile filename
%   R.scan: Profile scan number (start and end)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%February 2000; Last revision: 11-Feb-2000 

%Header initialization
R.filename=[]; 	%Filename with ASCII data

%Data initialization
R.scan=[];			%Scan number

%Read BSR 
disp(filename)
h=textcell(filename);
R.filename=filename;
for i=1:length(h)
   [a,b]=strtok(h{i},',');
   R.scan(i,1)=str2num(a);
   R.scan(i,2)=str2num(b(2:end));
end


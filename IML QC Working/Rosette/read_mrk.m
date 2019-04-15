function R = read_mrk(filename)
%READ_MRK - Reads a CTD MRK-file out of Seabird bottle treatment 
%
%Syntax:  R = read_mrk(filename)
% filename is the name of the MRK file between quotes (ex:'temp.mrk')
% R: structure array with fields
%   R.filename: Profile filename
%   R.header: Profile header
%   R.p: Profile pressure
%   R.scan: Profile scan number

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%February 2000; Last revision: 11-Feb-2000 

%Header initialization
R.filename=[]; 	%Filename with ASCII data
R.header=[];		%Header

%Data initialization
R.p=[];				%Pressure (dbar)
R.scan=[];			%Scan number

%Open file 
file=textcell(filename);
R.filename=filename;

%Read header lines
R.header=char(file{1:2});


%Assign values to various field names
name=[];
n=R.header(2,:);
i=0;
while ~isempty(deblank(n))
   i=i+1;
   [a,b]=strtok(n);
   name{i}=fliplr(deblank(fliplr(a)));
   n=fliplr(deblank(fliplr(b)));
end   

I=strmatch('mark number',file);
I=I+1;

% Read data
for i=1:length(I)
   line=sscanf(char(file(I(i))),'%f');
   try
   	R.scan(i)=line(strmatch('Scan',name));
   catch
      R.scan(i)=-99;
      if i==1, disp(['No scan number in ' R.filename]), end
   end
   try
      R.p(i)=line(strmatch('Pressure',name));
   catch
      R.p(i)=-99;
      if i==1, disp(['No pressure in ' R.filename]), end
   end
end  

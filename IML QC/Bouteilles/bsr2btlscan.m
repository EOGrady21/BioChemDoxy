function bsr2btlscan(R)
%BSR2BTLSCAN - Writes a list of bottle start and end scans from BSR files
%
%Syntax:  bsr2btlscan(S)
% R is the BSR structure array.
% If R is undefined, R=create_S('bsr','seabird').
%
% A btlscan.txt file is created with columns:
%   1. Bottle number 
%   2. Filename (without extension)
%   3. Pressure depth of bottle (db)
%   4. Start scan of bottle event
%   5. End scan of bottle event

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2000; Last revision: 11-Feb-2000 CL

%Nargin
if nargin==0
   R=create_S('bsr','sbe_bsr');
end

%Open btlscan.txt
fid=fopen('btlscan.txt','wt');

%Bottle scan range
for i=1:size(R,2)
   %bottle scan
   for j=1:size(R(i).scan,1);
      fprintf(fid,'%.0f	%s	%.1f	%.0f	%.0f\n',j,R(i).filename(1:end-4),...
         -99,R(i).scan(j,1),R(i).scan(j,2));
   end
end   

%Close btlscan.txt
fclose(fid);
   
   

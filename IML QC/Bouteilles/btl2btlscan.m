function btl2btlscan(R)
%BTL2BTLSCAN - Writes a list of bottle start and end scans from ROS files
%
%Syntax:  btl2btlscan(S)
% R is the ROS structure array.
% If R is undefined, R=create_S('btl','seabird').
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
   B=create_S('btl','sbe_btl');
end

%Open btlscan.txt
fid=fopen('btlscan.txt','wt');

%Bottle scan range
for i=1:size(B,2)
   %bottle scan
   R=B(i).btl.data;
   names=fieldnames(R);
   l=size(eval(['R.' names{1}]),1);
   k=0;
   for j=l:-1:1
      k=k+1;
      if ~isempty(strmatch('CNTR',names)) & ~isempty(strmatch('PRES',names)) & size(R.CNTR_01,2)>2
         fprintf(fid,'%.0f	%s	%.1f	%.0f	%.0f\n',k,B(i).filename(1:end-4),...
            R.PRES_01(j,1),R.CNTR_01(j,3),R.CNTR_01(j,4));
      else
         fprintf(fid,'%.0f	%s	%.1f	%.0f	%.0f\n',k,B(i).filename(1:end-4),...
            R.PRES_01(j,1),-99,-99);
	   end         
   end
end   

%Close btlscan.txt
fclose(fid);
   
   

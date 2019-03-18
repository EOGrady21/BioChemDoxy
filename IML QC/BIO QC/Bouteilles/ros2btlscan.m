function ros2btlscan(R)
%ROS2BTLSCAN - Writes a list of bottle start and end scans from ROS files
%
%Syntax:  ros2btlscan(S)
% R is the ROS structure array.
% If R is undefined, R=create_S('ros','seabird').
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
   R=create_S('ros','sbe_ros');
end

%Open btlscan.txt
fid=fopen('btlscan.txt','wt');

%Bottle scan range
for i=1:size(R,2)
   if ~isempty(R(i).filename)
   %bottle scan
   dscan=R(i).scan(2:end)-R(i).scan(1:end-1);
   I=[[1;find(dscan>1)+1] [find(dscan>1);length(R(i).scan)]];
   for j=1:size(I,1);
      fprintf(fid,'%.0f	%s	%.1f	%.0f	%.0f\n',j,R(i).filename(1:end-4),...
         nanmedian(R(i).p(I(j,1):I(j,2))),R(i).scan(I(j,1)),R(i).scan(I(j,2)));
   end
   end
end   

%Close btlscan.txt
fclose(fid);
   
   

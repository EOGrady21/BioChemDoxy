function R = read_ros(filename)
%READ_ROS - Reads a CTD ROS-file out of Seabird bottle treatment 
%
%Syntax:  R = read_ros(filename)
% filename is the name of the ROS file between quotes (ex:'temp.ros')
% R: structure array with fields
%   R.filename: Profile filename
%   R.header: Profile header
%   R.p: Profile pressure
%   R.scan: Profile scan number
%   R.t: Profile temperature
%   R.c: Profile conductivity
%
%M-files required: ODF tools (readasciidata)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%February 2000; Last revision: 11-Feb-2000 

%Modifications
% - skip readasciidata.dll to read data in files (no longer works in R2007a)
%CL, 28-Jun-2007

%Header initialization
R.filename=[]; 	%Filename with ASCII data
R.header=[];		%Header

%Data initialization
R.p=[];				%Pressure (dbar)
R.scan=[];			%Scan number
R.t=[];
R.c=[];

%Open file 
disp(filename)
fid=fopen(filename,'r');
R.filename=filename;

%Read header lines
c=1;
header{c}=fgetl(fid);
while isempty(findstr(header{c},'*END*'))	
	c=c+1;      
   header{c}=fgetl(fid);
end
R.header=header;
header=char(header);
I=strmatch('  ',header);
J=setdiff((1:size(header,1)),I);
R.header=R.header(J);
header=char(header(J,:));
l=size(header,1);
ll=size(header,2);

%Close file
fclose(fid);

%Assign values to various field names
I=strmatch('# name',header);
for i=1:length(I)
   name(i,:)=sscanf(header(I(i),:),'%*s %*s %*s %*s %3s/');
end   

%Get nquan
I=strmatchi('# nquan',header);
eval([R.header{I}(2:end) ';']);

%get nvalues
I=strmatchi('# nvalues',header);
eval([R.header{I}(2:end) ';']);

%get bad_flag
%I=strmatchi('# bad_flag',header);
%[a,b]=strtok(R.header{I},'=');
bad_flag=str2num('-9.990e-29');

%get data
form = zeros(1, nquan);
form = num2str(form);
form = strrep(form, '0', '%f');
h = textread(R.filename,'%s','delimiter','\n','headerlines',c);
data=str2num(char(h));
%data = readasciidata(nvalues, nquan, form, R.filename, c);

%Set data=bad_flag to NaN
data(data>bad_flag+bad_flag/1e4 & data<bad_flag-bad_flag/1e4)=nan;

% Read data
I=strmatch('pr',name);
if isempty(I), I=strmatch('de',name); end
if isempty(I), error('No pressure or depth channel'); end
R.p=data(:,I);

I=strmatch('sc',name);
if isempty(I), R.scan=(1:length(R.p));
else, R.scan=data(:,I); end

I=strmatch('t0',name);
if isempty(I), R.t=(1:length(R.p));
else, R.t=data(:,I); end

I=strmatch('c0',name);
if isempty(I), R.c=(1:length(R.p));
else, R.c=data(:,I); end


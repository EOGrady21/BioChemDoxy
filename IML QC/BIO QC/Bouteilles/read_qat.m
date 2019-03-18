function Q=read_qat(filename)
%READ_QAT - Read data from a QAT-file (from BIO).
%
%Syntax:  Q=read_qat(filename)
% filename is the name of the QAT file between quotes (ex:'temp.qat')
% Q is a qat structure with the following fields
%   Q.filename -> QAT filename
%   Q.cruiseid -> Cruise number 
%   Q.sample -> Unique sample number
%   Q.station -> Station number
%   Q.lat -> Latitude
%   Q.lon -> Longitude
%   Q.time -> UTC date and time
%   Q.pres -> Pressure (dbar)
%   Q.temp -> Temperature (IPTS-68)
%   Q.cndc -> Conductivity (S/m)
%   Q.psal -> Salinity
%   Q.sigt -> Sigma-t
%
% Note: Order of variables may change.
%
%Toolbox required: Seawater

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%December 1999; Last revision: 17-Dec-1999 CL

%open file
fid=fopen(filename,'r');
Q.filename=filename;

%read file
n=0;
while feof(fid)==0
   n=n+1;
   data{n,1}=fgetl(fid);
end

%comma
for i=1:size(data,1)
   line=char(data{i});
   c=findstr(line,',');
   Q.sample(i)=str2num(line(c(5)+1:c(6)-1));
   Q.station{i}=line(c(1)+1:c(2)-1);
	Q.lat(i)=str2num(line(c(2)+1:c(3)-1));
	Q.lon(i)=str2num(line(c(3)+1:c(4)-1));
   Q.time{i}=date_c([line(c(6)+3:c(7)-2) ' ' line(c(7)+3:c(8)-2)],'mm/dd/yyyy');
	Q.pres(i)=str2num(line(c(14)+1:c(15)-1));
	Q.temp(i)=str2num(line(c(13)+1:c(14)-1));
	Q.cndc(i)=str2num(line(c(15)+1:c(16)-1));
	Q.psal(i)=str2num(line(c(11)+1:c(12)-1));
   Q.sigt(i)=sw_dens(Q.psal(i),Q.temp(i),0)-1000;
end

%close file
fclose(fid);
   
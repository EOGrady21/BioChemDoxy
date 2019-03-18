function i=filtindex(pres,Qpres,sigt,Qsigt);
%FILTINDEX - Determines the window size of the median filter in order to reduce density inversion 
%
%Syntax:  i = filtindex(pres,Qpres,sigt,Qsigt)
% pres is a vector of pressure data
% Qpres is a vector of pressure quality flag
% sigt is a vector of sigma-T data
% Qsigt is a vector of sigma-T quality flag
% i is the window size
%
%Toolbox required: Signal Processing
%M-files required: medfilt1_cl

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%November 1999; Last revision: 05-Nov-1999 CL

%Initial parameters
J=0;
i=3;

%Remove doubtful pressure and sigma-T
I=find((Qpres==1 | Qpres==5) & (Qsigt==1 | Qsigt==5));
pres=pres(I);
sigt=sigt(I);

if ~isempty(pres)
%Mean sampling interval in dbar
dpres=median(diff(pres));
if isempty(dpres)
    dpres=1;
end

%Maximum window length
maxi=10/dpres;
maxi=min(maxi,41);
mdsigt=max(0.01,dpres*0.01/0.2);

%Minimum window length
while ~isempty(J) & i<maxi
   i=i+2;
   fsigt=medfilt1_CL(sigt,i);
   dsigt=fsigt(2:end)-fsigt(1:end-1);
   %J=find(dsigt<-0.01);
	J=find(dsigt<-mdsigt);
end
end
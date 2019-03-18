function t68=sw_t68(t90)
%SW_T68  Converts temperature from ITS-90 to IPTS-68
%
%Synthax: t68=sw_t68(t90)
% t68 : temperature (IPTS-68)
% t90 : temperature (ITS-90)
%Additional routine to seawater package

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%June 1999; Last revision: 18-Jun-1999 CL

t68=t90*1.00024;
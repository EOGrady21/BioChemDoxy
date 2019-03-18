function table=std2table(S)
%STD2TABLE - Convert STD structure to table 
%
%Syntax:  table = std2table(S)
% S is the input STD structure
% table is a table of data with pressure, temperature and salinity values. 
%  1. S.pres: pressure
%  2. S.Qpres: pressure quality flag
%  3. S.temp: temperature
%  4. S.Qtemp: temperature quality flag
%  5. S.psal: salinity
%  6. S.Qpsal: salinity quality flag
%  7. S.QCFF: global quality flag
%
% This table is useful to check data (open table)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%November 1999; Last revision: 16-Nov-1999 CL

table=[S.pres S.Qpres S.temp S.Qtemp S.psal S.Qpsal S.sigt S.Qsigt S.QCFF/100];
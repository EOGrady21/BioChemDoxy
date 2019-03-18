function [S_new,I]=remove_erroneous(S,opt)
%REMOVE_ERRONEOUS - Removes erroneous and missing data from the STD-structure 
%
%Syntax:  [S_new,I] = remove_erroneous(S,opt)
% S is the STD-structure with quality flag included.
% S_new is the STD-structure with erronous and missing values eliminated.
% I indices of data kept.
% opt controls the type of data treated
%  opt=1: Qpres~=4,9;  (only pressure data)
%  opt=2: Qtemp~=4,9;  (only temperature data)
%  opt=3: Qpsal~=4,9;  (only salinity data)
%  opt=4: Qsigt~=4,9;  (only sigma-T data)
%  opt=5: Qpres~=4,9; Qtemp~=4,9;  (pressure and temperature data)
%  opt=6: Qpres~=4,9; Qpsal~=4,9;  (pressure and salinity data)
%  opt=7: Qpres~=4,9; Qsigt~=4,9;  (pressure and sigma-T data)
%  opt=8: Qpres~=4,9; Qtemp~=4,9; Qpsal=4,9; (pressure, temperature and salinity data)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 23-Nov-1999 CL

S_new=S;

switch opt
case 1
   I=find(S.Qpres~=4 & S.Qpres~=9);
case 2
   I=find(S.Qtemp~=4 & S.Qtemp~=9);
case 3
   I=find(S.Qpsal~=4 & S.Qpsal~=9);
case 4
	I=find(S.Qsigt~=4 & S.Qsigt~=9);   
case 5
   I=find(S.Qpres~=4 & S.Qpres~=9 & S.Qtemp~=4 & S.Qtemp~=9);
case 6
   I=find(S.Qpres~=4 & S.Qpres~=9 & S.Qpsal~=4 & S.Qpsal~=9);
case 7
   I=find(S.Qpres~=4 & S.Qpres~=9 & S.Qsigt~=4 & S.Qsigt~=9);
case 8
   I=find(S.Qpres~=4 & S.Qpres~=9 & S.Qtemp~=4 & S.Qtemp~=9 & S.Qpsal~=4 & S.Qpsal~=9);
end

S_new.pres =S.pres(I);
S_new.Qpres=S.Qpres(I);
S_new.deph =S.deph(I);
S_new.Qdeph=S.Qdeph(I);
S_new.temp =S.temp(I);
S_new.Qtemp=S.Qtemp(I);
S_new.psal =S.psal(I);
S_new.Qpsal=S.Qpsal(I);
S_new.sigt =S.sigt(I);
S_new.Qsigt=S.Qsigt(I);
S_new.QCFF=S.QCFF(I);
if isfield(S,'cndc'), S_new.cndc=S.cndc(I); end
if isfield(S,'dpdt'), S_new.dpdt=S.dpdt(I); end
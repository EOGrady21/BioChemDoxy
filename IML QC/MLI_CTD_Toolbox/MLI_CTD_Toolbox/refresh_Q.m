function S=refresh_Q(S)
%REFRESH_Q - Refresh quality flags of related variables. 
%
%Syntax:  S = refresh_Q(S)
% Quality fags are updated according to physical links between variable.
% S is the STD-structure with quality flag.
% 
%Example: if a QPSAL=3, then QSIGT=3

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 13-Sep-1999 CL
%
%Modifications:
% - flag 2 added (inconsistent with others)
% cl, 12-juin-2006

%Local Q
S.Qdeph(S.Qpres==5)=5;
S.Qdeph(S.Qpres==4)=4;
S.Qpsal(S.Qpres==4 & S.Qpsal<4)=4;
S.Qsigt(S.Qpres==4 & S.Qsigt<4)=4;
S.Qdeph(S.Qpres==3)=3;
S.Qpsal(S.Qpres==3 & S.Qpsal<3)=3;
S.Qsigt(S.Qpres==3 & S.Qsigt<3)=3;
S.Qpsal(S.Qtemp==4 & S.Qpsal<4)=4;
S.Qsigt(S.Qtemp==4 & S.Qsigt<4)=4;
S.Qpsal(S.Qtemp==3 & S.Qpsal<3)=3;
S.Qsigt(S.Qtemp==3 & S.Qsigt<3)=3;
S.Qsigt(S.Qpsal==4 & S.Qsigt<4)=4;
S.Qsigt(S.Qpsal==3 & S.Qsigt<3)=3;
S.Qpsal(S.Qtemp==5 & S.Qpsal==1)=5;
S.Qsigt(S.Qtemp==5 & S.Qsigt==1)=5;
S.Qsigt(S.Qpsal==5 & S.Qsigt==1)=5;
S.Qdeph(S.Qpres==2)=2;
S.Qpsal(S.Qpres==2 & S.Qpsal<2)=2;
S.Qpsal(S.Qtemp==2 & S.Qpsal<2)=2;
S.Qsigt(S.Qpres==2 & S.Qsigt<2)=2;
S.Qsigt(S.Qpsal==2 & S.Qsigt<2)=2;

S.Qtemp(isnan(S.temp))=9;
S.Qpres(isnan(S.pres))=9;
S.Qdeph(isnan(S.deph))=9;
S.Qpsal(isnan(S.psal))=9;
S.Qsigt(isnan(S.sigt))=9;   

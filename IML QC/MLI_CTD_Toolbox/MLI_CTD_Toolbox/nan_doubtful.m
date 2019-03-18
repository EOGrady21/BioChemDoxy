function S=nan_doubtful(S)
%NAN_DOUBTFUL - Doubtful, erroneous and missing data in STD structure are replaced by NaN. 
%
%Syntax:  S = nan_doubtful(S)
% S is the STD-structure with quality flag included.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 14-Sep-1999 CL

for i=1:size(S,2)
   if isempty(S(i).dpdt), S(i).dpdt=S(i).pres*nan; end
	S(i).pres(S(i).Qpres==3 | S(i).Qpres==4 |  S(i).Qpres==9)=nan;
   S(i).deph(S(i).Qdeph==3 | S(i).Qdeph==4 |  S(i).Qdeph==9)=nan;
   S(i).temp(S(i).Qtemp==3 | S(i).Qtemp==4 |  S(i).Qtemp==9)=nan;
   S(i).psal(S(i).Qpsal==3 | S(i).Qpsal==4 |  S(i).Qpsal==9)=nan;
   S(i).sigt(S(i).Qsigt==3 | S(i).Qsigt==4 |  S(i).Qsigt==9)=nan;
end

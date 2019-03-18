function S=replace_erroneous(S_old,S_new,I)
%REPLACE_ERRONEOUS - Replaces erroneous and missing data in the STD-structure. 
%
%Syntax:  S = replace_erroneous(S_old,S_new,I)
% S_old is the STD-structure before remove_erroneous.
% S_new is the STD-structure after remove_erroneous.
% I: S_old(I)=S_new. I is found obtained by remove_erroneous.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 23-Nov-1999 CL

S=S_old;
if ~isempty(I)
	S.Qpres(I)=S_new.Qpres;
	S.Qdeph(I)=S_new.Qdeph;
   S.Qtemp(I)=S_new.Qtemp;
	S.Qpsal(I)=S_new.Qpsal;
   S.Qsigt(I)=S_new.Qsigt;
 	S.QCFF(I)=S_new.QCFF;   
end

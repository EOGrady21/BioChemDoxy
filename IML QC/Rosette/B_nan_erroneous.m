function S=B_nan_erroneous(S)
%B_NAN_ERRONEOUS - Erroneous data in bottle-structure are replaced by NaN. 
%
%Syntax:  S = B_nan_erroneous(S)
% S is the bottle-structure with quality flag included.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 29-Jan-2004 CL

%Modifications:
% - ajout des variables pH et alky
% CL, 19-Nov-2009

names={'pres';'temp';'psal';'doxy';'cphl';'ntrz';'ntri';'phos';'slca';'phph';'alky'};
for i=1:size(S,2)
  for j=1:size(names,1)
     eval(['S(i).' names{j} '(S(i).Q' names{j} '==4)=nan;']);
  end
end

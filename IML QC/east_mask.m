function h=east_mask
%EAST_MASK  Land mask of eastern Canada
%
%Syntax:  east_mask
%
%Mat-file required: east_mask

%Author: Caroline Lafleur a/s Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%November 1998; Last revision:

% Modifications
% -Changement de la couleur de la terre. Ancienne couleur [0.9 0.8 0.7].
% Nouvelle couleur [230 223 204]/256
% CL, 23-May-2006

load east_mask
I=find(isnan(x0)==1);
l_start=I+1;
l_end=[I(2:length(I))-1; length(x0)];
l=length(l_start);

for i=1:l
   h=patch(x0(l_start(i):l_end(i)),y0(l_start(i):l_end(i)),[230 223 204]/256);
   set(h,'EdgeColor','k');
end
zoom reset
set(gca,'DataAspectRatio',[1.5 1 1],'Box','on')

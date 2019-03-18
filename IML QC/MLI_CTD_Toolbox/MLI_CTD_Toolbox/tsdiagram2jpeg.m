function tsdiagram2jpeg(S,Q,filename)
%TSDIAGRAM2JPEG - Writes a TS diagram in JPEG format
%
%Syntax:  tsdiagram2jpeg(S,Q)
%         tsdiagram2jpeg(S,Q,filename)
% S is the QDF-structure
% Q is the STD-structure
% filename is the name of the jpeg file. If ignored filename=['TS' cruise_number]); 
%
%M-files required: ts_diagram_dot

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca 
%December 1999; Last revision: 15-Dec-1999


for i=1:size(Q,2)
   QQ(i)=nan_doubtful(Q(i));
end

figure(1), clf, ts_diagram_dot(cat(1,QQ.psal),cat(1,QQ.temp));
if nargin==2
   cruiseno=char(getvalue(S(1),'Cruise_Number'));
   printjpg(['TS_' cruiseno(3:end)]);
else
   title(filename,'Interpreter','none')
   printjpg(filename)
end

function printjpg(filename)
%PRINTJPG  Print as a 5.5 x 4 inch jpeg file
%
%Syntax:  printjpg(filename)
%where filename is between single quotes
%
%Example  printjpg('rivsum')

%Author: Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%February 1999; Last revision: 24-Feb-1999

set(gcf,'units','normalized')

%set(gcf,'position',[0    0.0391    1.0000    0.8724])
%pause(2)
%eval(['print -dmeta ' filename '.wmf'])
%pause(1)
%close
%pause(1)

set(gcf,'units','inches');
set(gcf,'PaperPosition',[0 0 6 4.5])
eval(['print -djpeg -r100 '  filename])

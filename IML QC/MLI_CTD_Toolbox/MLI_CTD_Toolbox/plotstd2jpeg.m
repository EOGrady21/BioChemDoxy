function plotstd2jpeg(S,Q)
%PLOTSTD2JPEG - Writes STD profiles in JPEG format
%
%Syntax:  plotstd2jpeg(S,Q)
% S is the ODF-structure
% Q is the STD-structure
%
%M-files required: plot_std

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca 
%December 1999; Last revision: 15-Dec-1999

for i=1:size(Q,2)
   [filenames{1:size(S,2)}]=deal(S.filename);
   I=strmatchi(Q(i).filename,filenames);
  	SS(i)=updateodf(S(I));
   QQ(i)=nan_doubtful(Q(i));
   QQ(i).filename=char(SS(i).ODF_Header.File_Spec);
   plot_std(QQ(i)), printjpg(Q(i).filename(1:end-4))
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
orient portrait
set(gcf,'units','inches');
set(gcf,'PaperPosition',[0 0 6 4.5])
eval(['print -djpeg -r100 '  filename])

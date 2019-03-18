function I = strmatchi(str,strs,flag)
%STRMATCHI  Same as strmatch but ignoring case
%
%Syntax:  I = strmatchi(str,strs,flag)
%Type "help strmatch" for more details about the input arguments

%Author: Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%November 1998; Last revision: 19-Nov-1998

if nargin==2
   I = strmatch(lower(str),lower(strs));
elseif nargin==3
   I = strmatch(lower(str),lower(strs),flag);
else
   error('Must have at least two input arguments')
end


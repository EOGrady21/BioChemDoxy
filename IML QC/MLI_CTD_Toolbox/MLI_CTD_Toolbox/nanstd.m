function y=nanstd(x)
%NANSTD  Standard deviation ignoring NaNs 
%
%Syntax: y=nanstd(x)
% x is a matrix and y its standard deviation ignoring NaN

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%June 1999; Last revision: 18-Jun-1999 CL

[m,n]=size(x);
if m==1, x=x(:); m=n; n=1; end
y=repmat(nan,1,n);
for i=1:n
  I=find(~isnan(x(:,i)));
  if ~isempty(I)
     y(i)=std(x(I,i));
  end
end
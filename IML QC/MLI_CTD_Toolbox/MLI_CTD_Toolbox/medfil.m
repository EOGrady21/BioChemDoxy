function Z = medfil(z,q)
%MEDFIL - Median filtering of STD profiles
%
%Syntax: Z = medfil(z,q)
% z could be a vector or a matrix
% q data window width (odd)
% Z is the smoothed profile
%
% ref: SY, Alexander (1985) An alternative editing technique for 
%        oceanographic data,Deep-Sea Research, vol 32, no 12, 1591-1599

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%November 1999; Last revision: 05-Nov-1999 CL

if size(z,1)==1, z =z(:); end
lz = size(z,1);
k = (q-1)/2;
Z(1:k,:) = z(1:k,:);
for i = k+1:lz-k
   Z(i,:) = median(z(i-k:i+k,:));
end
Z(lz-k+1:lz,:) = z(lz-k+1:lz,:);

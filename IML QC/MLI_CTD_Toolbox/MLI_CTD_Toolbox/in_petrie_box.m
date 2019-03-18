function inbox = in_petrie_box(lat,lon,P)
%IN_PETRIE_BOX - Finds the Petrie box number for each STD in (lat,lon)
%
%Syntax:  inbox = in_petrie_box(lat,lon)
% lat: vector of CTD latitudes
% lon: vector of CTD longitudes
% inbox: Petrie's box number
%
%MAT-files required:  Petrie

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 08-Sep-1999

%load Petrie
%load Scotian_Shelf
%P=[P SS];
box=cat(1,P.box);

for i=1:length(box)
   in(i)=inpolygon(lon,lat,P(i).lon,P(i).lat);
end
inbox=box(in>0);
if length(inbox)>1
    %inbox=inbox(1);
end


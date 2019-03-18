function P=TS_deepwater(S)
%TS_DEEPWATER - Deep water mass temperature and salinity properties
%
%Syntax:  P = TS_deepwater(S)
% S is the STD-structure.
% P is the deep water mass structure similar to S
%  The structure consists of means of temperature and salinity
%  at depths 300, 350, 400, 450, 500, and 550 ± 5 m.
%	This structure is used by the quality control procedure
%	test 4.2: Annual Deep Water Consistency.
%
%M-files required: TS_deepwater

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%november 1999; Last revision: 16-Nov-1999 CL

%Depths in terms of pressures
p=(300:50:550);
dp=5;

%Loop over profile of S
for i=1:size(S,2)
   %P structure
	P(i).filename=S(i).filename;
	P(i).cruiseid=S(i).cruiseid(3:end);
	P(i).lat=S(i).lat;
	P(i).lon=S(i).lon;
	P(i).time=S(i).time;
   
   %Replace doubtful values by nan
   T=nan_doubtful(S(i));
   
   %Find pressure intervals in profile
   for j=1:length(p)
      I=find(T.pres>=p(j)-5 & T.pres<=p(j)+5);
      if (nanmax(T.pres(I))-nanmin(S(i).pres(I))) > 2/3*10
         P(i).pres(j,1)=p(j);
         P(i).temp(j,1)=nanmean(T.temp(I));
         P(i).psal(j,1)=nanmean(T.psal(I));
      else
         P(i).pres(j,1)=p(j);
         P(i).temp(j,1)=nan;
         P(i).psal(j,1)=nan;
      end
   end
   ind(i)=min(isnan(P(i).temp));  
end

%Keep profile with values~=nan
P=P(ind==0);

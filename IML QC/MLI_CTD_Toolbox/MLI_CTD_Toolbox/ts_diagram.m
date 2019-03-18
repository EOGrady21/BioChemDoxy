function ts_diagram(s,t,p,dsigma,xlim,ylim);
%TS_DIAGRAM - Basic TS diagram with selected density contours.
%
%Syntax: ts_diagram(s,t)
%			ts_diagram(s,t,p)
%			ts_diagram(s,t,p,dsigma)
%			ts_diagram(s,t,p,dsigma,xlim,ylim)
%Draws contours lines of density anomaly with dsigma(kg m-3) 
%spacing (default 1.0) at pressure p (default p=0) (dbars),
%given a salinity s(psu) vector and a temperature t(°C) vector.
%Default xlim and ylim are from min(data)-1 to max(data)+1
%
%Toolbox required: Seawater

%Author: Caroline Lafleur a/s Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Department of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%September 1998; Last revision: 29-Oct-1999 

%Denan data
I=find(isnan(t)==0 & isnan(s)==0);
t=t(I);
s=s(I);

%Checking variables
Xlim=[floor(min(s))-1 ceil(max(s))+1];
if isempty(Xlim) | isnan(mean(Xlim)), Xlim=[25 33]; end
Ylim=[floor(min(t))-1 ceil(max(t))+1];

switch nargin
case 2, p=0; dsigma=1; xlim=Xlim; ylim=Ylim;
case 3, dsigma=1; xlim=Xlim; ylim=Ylim;
case 4, xlim=Xlim; ylim=Ylim;
case 5, ylim=Ylim; 
case 6,
otherwise, error('2, 3 or 4 input variables needed')   
end
sigma=[0:dsigma:30];

%Grid points for sigma contours
try
   Sg=xlim(1)+[0:50]/50*(xlim(2)-xlim(1));
   Tg=ylim(1)+[0:50]'/50*(ylim(2)-ylim(1));

%Sigma-T
	SG=sw_dens(ones(size(Tg))*Sg,Tg*ones(size(Sg)),p)-1000;

%Contour of constant lines
	[c,h]=contour(Sg,Tg,SG,sigma,'k'); hold on
	set(gca,'XLim',xlim,'YLim',ylim,...
  	'XMinorTick','on','YMinorTick','on');
	hh=clabel(c,h,[0:1:30]);
	set(h,'color',[1 1 1]*0.75)
	set(hh,'FontSize',7,'color',[1 1 1]*0.75)
end

xlabel('Salinity'); ylabel('Temperature (°C)');
title(['TS-Diagram at ' num2str(p) ' dbar'],'FontSize',9);

%Data
hl2=plot(s,t,'m'); hold off
function B_plot_tsoc(S)
%B_PLOT_TSOC - Plots bottle temperature, salinity, dissolved oxygen and chlorophyll profiles on the same graph (4 different x-axes). 
%
%Syntax:  B_plot_tsoc(S)
% S is the bottle-structure
% Fields used:
%  S.deph: depth (m)
%  S.temp: temperature (oC)
%  S.Qtemp: Q temperature
%  S.psal: salinity
%  S.Qpsal: Q salinity
%  S.doxy: dissolved oxygen (ml/l)
%  S.Qdoxy: Q dissolved oxygen
%  S.cphl: chlorophyll (mg/m³)
%  S.Qcphl: Q chlorophyll
%  S.lat: start latitude (degrees)
%  S.lon: start longitude (degrees)
%  S.time_start: start date and time 
%  S.timezone: GMT
%  S.station: station number
%  S.sounding: sounding (m)
%
%Mat-Files required: gsl_bathy.mat

%Author: Caroline Lafleur a/s Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Department of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%February 2004; Last revision: 05-Feb-2004 CL

clf
set(gcf,'units','normal',...
   'NextPlot','add')
c1=get(gcf,'color');

%First axes: Salinity
hl1=line(S.psal,S.deph,'Color','k');
try
tx1=text(unique(S.psal(S.psal==max(S.psal))),unique(S.deph(S.deph==max(S.deph))),...
   'S','FontWeight','bold','Color','k','HorizontalAlignment','left',...
   'VerticalAlignment','bottom');
end
ax1=gca;
lx=get(ax1,'XLim');
ly=get(ax1,'YLim'); ly(1)=0;
try, 
   dlx=lx(2)-lx(1);
   if dlx<2, lx(1)=lx(1)-1; lx(2)=lx(2)+1; end
end
set(ax1,'Position',[0.34 0.2 0.53 0.65],...
   'XColor','k','YColor','k',...
   'YDir','reverse',...
   'XMinorTick','on','YMinorTick','on',...
   'XLim',lx,'YLim',ly);
xlabel('Salinity'); ylabel('Depth (m)');
pos1=get(ax1,'Position'); 
%grid on

%Second axes: Temperature
ax2=axes('Position',pos1,...
   'XAxisLocation','top','YAxisLocation','right',...
   'Color','none','XColor','r','YColor','r',...
   'YDir','reverse','YLim',ly,'YTickLabel',' ',...
   'XMinorTick','on','YMinorTick','on');
xlabel('Temperature (°C)'); 

hl2=line(S.temp,S.deph,'Color','r','Parent',ax2);
try
tx2=text(S.temp(S.deph==max(S.deph)),S.deph(S.deph==max(S.deph)),...
   'T','FontWeight','bold','Color','r','HorizontalAlignment','left',...
   'VerticalAlignment','bottom');
end
lx=get(ax2,'XLim');
ly=get(ax2,'YLim');
try 
   dlx=lx(2)-lx(1);
   if dlx<3, lx(1)=lx(1)-1; lx(2)=lx(2)+2; end
end
set(ax2,'XLim',lx,'YLim',ly);

%Third axes: Sigma-T
relpos=pos1(4)/6.5;
pos3=[pos1(1) pos1(2)-relpos pos1(3) pos1(4)+relpos];
lim1=get(ax1,'YLim');
limdy=(lim1(2)-lim1(1))/6.5;
lim3=[lim1(1) lim1(2)+limdy];

ax3=axes('Position',pos3,...
   'Color','none','XColor','b','YColor','k',...   
   'YTick',[],'YDir','reverse','YLim',lim3,...
   'XMinorTick','on','YMinorTick','on');
xlabel('Sigma-T (kg m^{-3})');

hl3=line(S.sigt,S.deph,'Color','b','Parent',ax3);
try
tx3=text(unique(S.sigt(S.sigt==max(S.sigt))),unique(S.deph(S.deph==max(S.deph))),...
   '\sigma_T','FontWeight','bold','Color','b','HorizontalAlignment','left',...
   'VerticalAlignment','bottom');
end
lx=get(ax3,'XLim');
ly=get(ax3,'YLim');
try
   dlx=lx(2)-lx(1);
   if dlx<2, lx(1)=lx(1)-1.5; lx(2)=lx(2)+0.5; end
end
set(ax3,'XLim',lx,'YLim',ly);

lim2=get(ax3,'XLim');
hl4=line([lim2(1) lim2(1)],[lim1(2)+limdy/80 lim3(2)-limdy/18],...
   'Color',c1,'Parent',ax3,'Clipping','off');

%Fourth axes: GSL chart
load gsl_bathy
latlim=[min(y0) max(y0)];
longlim=[min(x0) max(x0)];
ax4=axes('Position',[0.02 0.80 1.5*0.15 0.15],...
   'DataAspectRatio',[1.5 1 1],...
   'XLim',longlim,'YLim',latlim,...
   'XTick',[],'YTick',[],'Box','on');   
hl4=line(x0,y0,'color','k','Parent',ax4); hold on
pl4=plot(S.lon,S.lat,'ro');
set(pl4,'MarkerFaceColor','g');

%Optional fifth axes: Textual information about profile
ax5=axes('Position',[0.06 0.10 0.10 0.70]);
set(gca,'DefaultTextFontSize',10,'visible','off','Units','normalized')
text(0.01,0.95,upper(S.filename),'FontWeight','bold','FontSize',8,'Interpreter','none')
text(0.01,0.90,['Stn: ' S.station])
text(0.01,0.85,S.time(1:11))
text(0.01,0.80,[S.time(13:20) ' GMT'])
text(0.01,0.75,['lat: ' num2str(S.lat)])
text(0.01,0.70,['lon: ' num2str(S.lon)])
text(0.01,0.65,['sounding: ' num2str(S.sounding) 'm'])

%Sixth axes: TS diagram
ax6=axes('Position',[0.07 0.15 0.18 0.30],...
   'DataAspectRatio',[1.5 1 1],'Box','on');
hl6=plot(S.psal,S.temp,'color','m'); hold on
set(gca,'XMinorTick','on','YMinorTick','on')
%grid on
lx=get(gca,'XLim');
try
   dlx=lx(2)-lx(1);
   if dlx<2, lx(1)=lx(1)-1; lx(2)=lx(2)+1; end
end
ly=get(gca,'YLim');
try
	dly=ly(2)-ly(1);
   if dly<3, ly(1)=ly(1)-1.5; ly(2)=ly(2)+1.5; end
end
ts_diagram(S.psal,S.temp)
%set(gca,'XLim',lx,'YLim',ly)
xlabel('S')
ylabel('T')

%7th axes: descent rate
if isfield(S,'dpdt') & ~isempty(S.dpdt) & ~isnan(max(S.dpdt))
   ax7=axes('Position',[0.90 0.2 0.07 0.65]);
   hl7=plot(S.dpdt,S.deph,'g');
   set(gca,'YLim',lim1,'YTickLabel',' ',...
      'YMinorTick','on','YDir','reverse');
   if mean(S.dpdt)<0, set(gca,'Xlim',[-2 0])
   elseif mean(S.dpdt)>0, set(gca,'XLim',[0 2])
   end
   grid on
   xlabel('dp/dt')
end

%Print option
set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')

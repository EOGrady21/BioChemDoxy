function B_plot_SOCH(S)
%B_PLOT_SOCH - Plots salinity, dissolved oxygen, chlorophyll and pH profiles
%
%Syntax:  B_plot_soch(S)
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
%  S.phph: pH
%  S.Qphph: Q pH
%  S.lat: start latitude (degrees)
%  S.lon: start longitude (degrees)
%  S.time_start: start date and time 
%  S.timezone: GMT
%  S.station: station number
%  S.sounding: sounding (m)
%
%Mat-Files required: gsl_bathy.mat

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 05-Feb-2004 CL

%Fonction dérivée de B_plot_TSOC.m

clf
set(gcf,'units','normal',...
   'NextPlot','add')
c1=get(gcf,'color'); 

%Increasing depths
[deph,Id] = sort(S.deph);

%Subplots
ax1=axes('Position',[0.10 0.06 0.17 0.55]); %Temperature
ax2=axes('Position',[0.32 0.06 0.17 0.55]); %Salinity
ax3=axes('Position',[0.54 0.06 0.17 0.55]); %Dissolved Oxygen
ax4=axes('Position',[0.76 0.06 0.17 0.55]); %Chlorophyll
ax5=axes('Position',[0.02 0.77 1.5*0.12 0.15]); %Carte GSL
ax6=axes('Position',[0.20 0.75 0.20 0.19]); %Information
ax7=axes('Position',[0.75 0.75 0.20 0.15]); %TS-diagram
ax8=axes('Position',[0.38 0.77 0.20 0.15]); %Legend

%Axes 1: Salinity
axes('Position',get(ax1,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('PSAL','FontWeight','bold')

axes(ax1);
psal=S.psal(Id,:);
psal2=psal;
hold on
if isfield(S,'Qpsal') & ~isempty(S.Qpsal)
   Qpsal=S.Qpsal(Id,:);
   for j=1:size(psal,2)
      Is0 = find(Qpsal(:,j)==2);
      s0 = plot(psal(Is0,j),deph(Is0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      Is2 = find(Qpsal(:,j)==3 | Qpsal(:,j)==4);
      s2 = plot(psal(Is2,j),deph(Is2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      Is3 = find(Qpsal(:,j)==7);
      s3 = plot(psal(Is3,j),deph(Is3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      Is4 = find(Qpsal(:,j)~=3 | Qpsal(:,j)~=4);
      psal2(Is2,j)=nan;
   end
end
s1 = plot(psal,deph,'.k');
psal2 = nanmean(psal2,2);
p4 = plot(psal2(isnan(psal2)==0),deph(isnan(psal2)==0),'-','Color',[0.1 0.1 0.8]);
psal3 = S.CTD_psal;
s4 = plot(psal3(isnan(psal3)==0),deph(isnan(psal3)==0),'-','Color',[0.8 0.1 0.1]);

ax1=gca;
lx=get(ax1,'XLim'); lx(1)=max([lx(1)-1; 0]); lx(2)=lx(2)+1;
ly=get(ax1,'YLim'); ly(1)=0;
set(ax1,'XLim',lx,'YLim',ly,'Ydir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('Salinity','FontWeight','bold'); ylabel('Depth (m)','FontWeight','bold');
grid on

%Axes 2: Dissolved Oxygen
axes('Position',get(ax2,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('DOXY (ml/l)','FontWeight','bold')

axes(ax2);
doxy=S.doxy(Id,:);
doxy2=doxy;
hold on
if isfield(S,'Qdoxy') & ~isempty(S.Qdoxy)
   Qdoxy=S.Qdoxy(Id,:);
   for j=1:size(doxy,2)
      Ip0 = find(Qdoxy(:,j)==2);
      p0 = plot(doxy(Ip0,j),deph(Ip0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      Ip2 = find(Qdoxy(:,j)==3 | Qdoxy(:,j)==4);
      p2 = plot(doxy(Ip2,j),deph(Ip2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      Ip3 = find(Qdoxy(:,j)==7);
      p3 = plot(doxy(Ip3,j),deph(Ip3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      Ip4 = find(Qdoxy(:,j)~=3 | Qdoxy(:,j)~=4);
      doxy2(Ip2,j)=nan;
   end
end
p1 = plot(doxy,deph,'.k');
doxy2 = nanmean(doxy2,2);
p4 = plot(doxy2(isnan(doxy2)==0),deph(isnan(doxy2)==0),'-','Color',[0.1 0.1 0.8]);
doxy3 = S.CTD_doxy;
p4 = plot(doxy3(isnan(doxy3)==0),deph(isnan(doxy3)==0),'-','Color',[0.8 0.1 0.1]);

ax2=gca;
lx=get(ax2,'XLim'); lx(1)=max([lx(1)-1; 0]); lx(2)=lx(2)+1;
ly=get(ax2,'YLim'); ly(1)=0;
set(ax2,'XLim',lx,'YLim',ly,'YDir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('Dissolved Oxygen','FontWeight','bold'); %ylabel('Depth (m)');
grid on

%Axes 3: Chlorophyll
axes('Position',get(ax3,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('CPHL (mg/m³)','FontWeight','bold')

axes(ax3);
cphl=S.cphl(Id,:);
cphl2=cphl;
hold on
if isfield(S,'Qcphl')  & ~isempty(S.Qcphl)
   Qcphl=S.Qcphl(Id,:);
   for j=1:size(cphl,2)
      Ip0 = find(Qcphl(:,j)==2);
      p0 = plot(cphl(Ip0,j),deph(Ip0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      Ip2 = find(Qcphl(:,j)==3 | Qcphl(:,j)==4);
      p2 = plot(cphl(Ip2,j),deph(Ip2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      Ip3 = find(Qcphl(:,j)==7);
      p3 = plot(cphl(Ip3,j),deph(Ip3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      Ip4 = find(Qcphl(:,j)~=3 | Qcphl(:,j)~=4);
      cphl2(Ip2,j)=nan;
   end
end
p1 = plot(cphl,deph,'.k');
cphl2 = nanmean(cphl2,2);
p4 = plot(cphl2(isnan(cphl2)==0),deph(isnan(cphl2)==0),'-','Color',[0.1 0.1 0.8]);

ax3=gca;
lx=get(ax3,'XLim'); lx(1)=0;
ly=get(ax3,'YLim'); ly(1)=0;
set(ax3,'XLim',lx,'YLim',ly,'YDir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('Chlorophyll','FontWeight','bold'); %ylabel('Depth (m)');
grid on

%Axes 4: pH
axes('Position',get(ax4,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('pH','FontWeight','bold')

axes(ax4)
phph=S.phph(Id,:);
phph2=phph;
hold on
if isfield(S,'Qphph') & ~isempty(S.Qphph)
   Qphph=S.Qphph(Id,:);
   for j=1:size(phph,2)
      It0 = find(Qphph(:,j)==2);
      t0 = plot(phph(It0,j),deph(It0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      It2 = find(Qphph(:,j)==3 | Qphph(:,j)==4);
      t2 = plot(phph(It2,j),deph(It2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      It3 = find(Qphph(:,j)==7);
      t3 = plot(phph(It3,j),deph(It3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      It4 = find(Qphph(:,j)~=3 | Qphph(:,j)~=4);
      phph2(It2,j)=nan;
   end
end
h1 = plot(phph,deph,'.k');
phph2 = nanmean(phph2,2);
h2 = plot(phph2(isnan(phph2)==0),deph(isnan(phph2)==0),'-','Color',[0.1 0.1 0.8]);
phph3 = S.CTD_phph;
h3 = plot(phph3(isnan(phph3)==0),deph(isnan(phph3)==0),'-','Color',[0.8 0.1 0.1]);

ax4=gca;
lx=get(ax4,'XLim'); lx(1)=nanmax([floor(nanmin([phph2;phph3]*10))/10-0.2,6]); lx(2)=nanmin([ceil(nanmax([phph2;phph3]*10))/10+0.2,10]);
if lx(2)<lx(1), lx = get(ax4,'Xlim'); end
ly=get(ax4,'YLim'); ly(1)=0;
set(ax4,'XLim',lx,'YLim',ly,'YDir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('pH','FontWeight','bold');
grid on

%Axes 5: GSL chart
load gsl_bathy
latlim=[min(y0) max(y0)];
longlim=[min(x0) max(x0)];
axes(ax5)
set(gca,'DataAspectRatio',[1.5 1 1],...
   'XLim',longlim,'YLim',latlim,...
   'XTick',[],'YTick',[],'Box','on');   
hl4=line(x0,y0,'color','k','Parent',ax5); hold on
pl4=plot(S.lon,S.lat,'ro');
set(pl4,'MarkerFaceColor','g');

%Axes 6: Textual information about profile
axes(ax6)
set(gca,'DefaultTextFontSize',9,'visible','off','Units','normalized','Ylim',[0 1.2])
text(0.01,1.2,upper(S.filename),'FontWeight','bold','FontSize',8,'Interpreter','none')
text(0.01,1.0,['Stn : ' S.station])
%text(0.01,0.6,[S.time(1:11) ' ' S.time(13:20) ' GMT'])
text(0.01,0.8,S.time(1:11))
text(0.01,0.6,[S.time(13:20) ' GMT'])
text(0.01,0.4,['Lat : ' num2str(S.lat)])
text(0.01,0.2,['Lon : ' num2str(S.lon)])
text(0.01,0.0,['Z : ' num2str(S.sounding) 'm'])

%Axes 7: CTD - TS-diagram
temp2 = S.temp(Id,:);
axes(ax7)
set(ax7,'Box','on','FontSize',8)
I=find(isnan(temp2)==0 & isnan(psal2)==0);
temp2=temp2(I);
psal2=psal2(I);
ts_diagram(psal2,temp2), hold on
set(gca,'XMinorTick','on','YMinorTick','on')
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
ts=plot(S.CTD_psal,S.CTD_temp,'.-','Color',[0.8 0.1 0.1]);
set(gca,'XAxisLocation','top')
title('')
xlabel('CTD psal','FontWeight','bold')
ylabel('CTD temp','FontWeight','bold')

%Axes 8: Legend
axes(ax8), set(gca,'visible','off'); hold on
set(gca,'DefaultTextFontSize',9,'Visible','off','Units','normalized','Xlim',[0 1],'Ylim',[0 1])
plot(0.04,1.0,'k.'), text(0.12,1.0,'BOTL (Q=1)','FontSize',8,'Interpreter','none')
plot(0.04,0.8,'^','color',[0.1 0.1 0.6],'Markerfacecolor','y'), plot(0.04,0.8,'k.'), text(0.12,0.8,'BOTL (Q=2)','FontSize',8,'Interpreter','none')
plot(0.04,0.6,'s','color',[0.1 0.6 0.1],'Markerfacecolor','g'), plot(0.04,0.6,'k.'), text(0.12,0.6,'BOTL (Q=7)','FontSize',8,'Interpreter','none')
plot(0.04,0.4,'o','color',[0.6 0.1 0.1],'Markerfacecolor','r'), plot(0.04,0.4,'k.'), text(0.12,0.4,'BOTL (Q=3 or 4)','FontSize',8,'Interpreter','none')
plot([0.01 0.07],[0.2 0.2],'-','Color',[0.1 0.1 0.8]), text(0.12,0.2,'BOTL means (Q=1 or 7)','FontSize',8,'Interpreter','none')
plot([0.01 0.07],[0.01 0.01],'-','Color',[0.8 0.1 0.1]), text(0.12,0,'CTD','FontSize',8,'Interpreter','none')

%Print option
set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')

%Zoom on
%zoom on
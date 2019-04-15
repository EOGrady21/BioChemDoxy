function B_plot_nsp(S)
%B_PLOT_NSP - Plots nitrate, nitrite, silicate and phosphate profiles 
%
%Syntax:  B_plot_nsp(S)
% S is the bottle-structure
% Fields used:
%  S.deph: depth (m)
%  S.ntrz: nitrate (mmol/m³)
%  S.Qntrz: Q nitrate
%  S.ntri: nitrite (mmol/m³)
%  S.Qntri: Q nitrite
%  S.slca: silicate (mmol/m³)
%  S.Qslca: Q silicate
%  S.phos: phosphate (mmol/m³)
%  S.Qphos: Q phosphate
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

clf
set(gcf,'units','normal',...
   'NextPlot','add')
c1=get(gcf,'color');

%Increasing depths
[deph,Id] = sort(S.deph);

%Subplots
ax1=axes('Position',[0.10 0.06 0.17 0.55]); %Nitrate
ax2=axes('Position',[0.32 0.06 0.17 0.55]); %Nitrite
ax3=axes('Position',[0.54 0.06 0.17 0.55]); %Silicate
ax4=axes('Position',[0.76 0.06 0.17 0.55]); %Phosphate
ax5=axes('Position',[0.02 0.77 1.5*0.12 0.15]); %Carte GSL
ax6=axes('Position',[0.20 0.75 0.20 0.19]); %Information
ax7=axes('Position',[0.67 0.75 0.20 0.15]); %Nitrate:Phosphate
ax8=axes('Position',[0.80 0.75 0.20 0.15]); %Nitrate:Silicate
ax9=axes('Position',[0.38 0.77 0.20 0.15]); %Legend

%Axes 1: Nitrate
axes('Position',get(ax1,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('NTRZ (mmol/m³)','FontWeight','bold')

axes(ax1)
ntrz=S.ntrz(Id,:);
ntrz2=ntrz;
hold on
if isfield(S,'Qntrz') & ~isempty(S.Qntrz)
   Qntrz=S.Qntrz(Id,:);
   for j=1:size(ntrz,2)
      In0 = find(Qntrz(:,j)==2);
      n0 = plot(ntrz(In0,j),deph(In0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      In2 = find(Qntrz(:,j)==3 | Qntrz(:,j)==4);
      n2 = plot(ntrz(In2,j),deph(In2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      In3 = find(Qntrz(:,j)==7);
      n3 = plot(ntrz(In3,j),deph(In3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      In4 = find(Qntrz(:,j)~=3 | Qntrz(:,j)~=4);
      ntrz2(In2,j)=nan;
   end
end
n1 = plot(ntrz,deph,'.k');
ntrz2 = nanmean(ntrz2,2);
n4 = plot(ntrz2(isnan(ntrz2)==0),deph(isnan(ntrz2)==0),'-b');

ax1=gca;
lx=get(ax1,'XLim'); lx(1)=0;
ly=get(ax1,'YLim'); ly(1)=0;
set(ax1,'Xlim',lx,'Ylim',ly,'YDir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('Total N','FontWeight','bold'); ylabel('Depth (m)','FontWeight','bold');
grid on

%Axes 2: Nitrite
axes('Position',get(ax2,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('NTRI (mmol/m³)','FontWeight','bold')

axes(ax2)
ntri=S.ntri(Id,:);
ntri2=ntri;
hold on
if isfield(S,'Qntri') & ~isempty(S.Qntri)
   Qntri=S.Qntri(Id,:);
   for j=1:size(ntri,2)
      In0 = find(Qntri(:,j)==2);
      n0 = plot(ntri(In0,j),deph(In0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      In2 = find(Qntri(:,j)==3 | Qntri(:,j)==4);
      n2 = plot(ntri(In2,j),deph(In2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      In3 = find(Qntri(:,j)==7);
      n3 = plot(ntri(In3,j),deph(In3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      In4 = find(Qntri(:,j)~=3 | Qntri(:,j)~=4);
      ntri2(In2,j)=nan;
   end
end
n1 = plot(ntri,deph,'.k');
ntri2 = nanmean(ntri2,2);
n4 = plot(ntri2(isnan(ntri2)==0),deph(isnan(ntri2)==0),'-b');

ax1=gca;
lx=get(ax1,'XLim'); lx(1)=0;
ly=get(ax1,'YLim'); ly(1)=0;
set(ax1,'Xlim',lx,'Ylim',ly,'YDir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('Nitrite','FontWeight','bold');
grid on

%Axes 3: Silicate
axes('Position',get(ax3,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('SLCA (mmol/m³)','FontWeight','bold')

axes(ax3);
slca=S.slca(Id,:);
slca2=slca;
hold on
if isfield(S,'Qslca') & ~isempty(S.Qslca)
   Qslca=S.Qslca(Id,:);
   for j=1:size(slca,2)
      Is0 = find(Qslca(:,j)==2);
      s0 = plot(slca(Is0,j),deph(Is0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      Is2 = find(Qslca(:,j)==3 | Qslca(:,j)==4);
      s2 = plot(slca(Is2,j),deph(Is2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      Is3 = find(Qslca(:,j)==7);
      s3 = plot(slca(Is3,j),deph(Is3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      Is4 = find(Qslca(:,j)~=3 | Qslca(:,j)~=4);
      slca2(Is2,j)=nan;
   end
end
s1 = plot(slca,deph,'.k');
slca2 = nanmean(slca2,2);
s4 = plot(slca2(isnan(slca2)==0),deph(isnan(slca2)==0),'-b');

ax3=gca;
lx=get(ax3,'XLim'); lx(1)=min([lx(1) 0]);
ly=get(ax3,'YLim'); ly(1)=min([ly(1) 0]);
set(ax3,'XLim',lx,'YLim',ly,'Ydir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('Silicate','FontWeight','bold'); % ylabel('Depth (m)');
grid on

%Axes 4: Phophate
axes('Position',get(ax4,'Position'),...
   'XAxisLocation','bottom','YAxisLocation','right',...
   'Color','none','XColor','k','YColor','k','XTick',[],'YTick',[])
xlabel('PHOS (mmol/m³)','FontWeight','bold')

axes(ax4);
phos=S.phos(Id,:);
phos2=phos;
hold on
if isfield(S,'Qphos') & ~isempty(S.Qphos)
   Qphos=S.Qphos(Id,:);
   for j=1:size(phos,2)
      Ip0 = find(Qphos(:,j)==2);
      p0 = plot(phos(Ip0,j),deph(Ip0),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y');
      Ip2 = find(Qphos(:,j)==3 | Qphos(:,j)==4);
      p2 = plot(phos(Ip2,j),deph(Ip2),'o','color',[0.6 0.1 0.1],'Markerfacecolor','r');
      Ip3 = find(Qphos(:,j)==7);
      p3 = plot(phos(Ip3,j),deph(Ip3),'s','color',[0.1 0.6 0.1],'Markerfacecolor','g');
      Ip4 = find(Qphos(:,j)~=3 | Qphos(:,j)~=4);
      phos2(Ip2,j)=nan;
   end
end
p1 = plot(phos,deph,'.k');
phos2 = nanmean(phos2,2);
p4 = plot(phos2(isnan(phos2)==0),deph(isnan(phos2)==0),'-b');

ax4=gca;
lx=get(ax4,'XLim'); lx(1)=0;
ly=get(ax4,'YLim'); ly(1)=0;
set(ax4,'XLim',lx,'YLim',ly,'YDir','reverse','XAxisLocation','top','XminorTick','on','YminorTick','on','Box','on');
xlabel('Phosphate','FontWeight','bold'); %ylabel('Depth (m)');
grid on

%Axes 5: GSL chart
load gsl_bathy
latlim=[min(y0) max(y0)];
longlim=[min(x0) max(x0)];
axes(ax5)
set(gca,'DataAspectRatio',[1.5 1 1],...
   'XLim',longlim,'YLim',latlim,...
   'XTick',[],'YTick',[],'Box','on');   
hl5=line(x0,y0,'color','k','Parent',ax5); hold on
pl5=plot(S.lon,S.lat,'ro');
set(pl5,'MarkerFaceColor','g');

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

%Axes 7: Nitrate:Phosphate
axes(ax7)
phos2(phos2==0)=nan;
np=ntrz2./phos2;
pnp=plot(np(isnan(np)==0),deph(isnan(np)==0),'.-','Color',[0.1 0.1 0.8]); hold on
set(gca,'FontSize',8,'PlotBoxAspectRatio',[1 1 1],'XminorTick','on','YminorTick','on','Ydir','reverse','XaxisLocation','top')
xlabel('N:P','FontWeight','bold')
ylabel('Depth (m)','FontWeight','bold')
set(gca,'Xlim',[0 20])
grid on

%Axes 8: Nitrate:Silicate
axes(ax8)
slca2(slca2==0)=nan;
ns=ntrz2./slca2;
pnp=plot(ns(isnan(ns)==0),S.deph(isnan(ns)==0),'.-','Color',[0.1 0.1 0.8]); hold on
set(gca,'FontSize',8,'PlotBoxAspectRatio',[1 1 1],'XminorTick','on','YminorTick','on','Ydir','reverse','XaxisLocation','top','YaxisLocation','right')
xlabel('N:Si','FontWeight','bold')
set(gca,'Xlim',[0 2])
grid on

%Axes 9: Legend
axes(ax9), hold on
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
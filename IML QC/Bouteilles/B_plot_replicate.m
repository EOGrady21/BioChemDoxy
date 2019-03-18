function B_plot_replicate(S)
%B_PLOT_REPLICATE - Plots bottle replicates 
%
%Syntax:  B_plot_replicate(S)
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
%  S.ntrz: nitrate (mmol/m³)
%  S.Qntrz: Q nitrate
%  S.ntri: nitrite (mmol/m³)
%  S.Qntri: Q nitrite
%  S.slca: silicate (mmol/m³)
%  S.Qslca: Q silicate
%  S.phos: phosphate (mmol/m³)
%  S.Qphos: Q phosphate
%  S.phph: pH
%  S.Qphph: Q pH
%  S.lat: start latitude (degrees)
%  S.lon: start longitude (degrees)
%  S.cruiseid: cruise number
%  S.cruise_start: cruise start
%  S.cruise_end: cruise end

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 10-Feb-2004 CL

%Modifications:
% - retrait de la variable température et ajout de pH
% CL, 19-Nov-2009

clf
set(gcf,'units','normal','Position',[0.1 0.1 0.8 0.8])
c1=get(gcf,'color'); 

%Subplots
ax11=axes('Position',[0.06 0.08 0.20 0.30]); %Nitrate
ax12=axes('Position',[0.30 0.08 0.20 0.30]); %Nitrite
ax13=axes('Position',[0.54 0.08 0.20 0.30]); %Silicate
ax14=axes('Position',[0.78 0.08 0.20 0.30]); %Phosphate
ax21=axes('Position',[0.06 0.45 0.20 0.30]); %Salinity
ax22=axes('Position',[0.30 0.45 0.20 0.30]); %Dissolved Oxygen
ax23=axes('Position',[0.54 0.45 0.20 0.30]); %Chlorophyll
ax24=axes('Position',[0.78 0.45 0.20 0.30]); %pH
ax31=axes('Position',[0.10 0.83 0.20 0.1]); %Information
ax32=axes('Position',[0.40 0.79 1.5*0.12 0.20]); %Carte GSL
ax33=axes('Position',[0.65 0.80 0.30 0.15]); %Legend

%Symbols for replicates (up to 6)
symbol_rep={'.k';'.m';'.b';'.y';'.c';'.g';'.r';'.r';'.r';'.r';'.r';'.r'};

%Variable names
names = {'ntrz','ntri','slca','phos','psal','doxy','cphl','phph'};
units = {'(mmol/m³)','(mmol/m³)','(mmol/m³)','(mmol/m³)','','(ml/l)','(mg/m³)',''};
axes_no = {'ax11','ax12','ax13','ax14','ax21','ax22','ax23','ax24'};

%Loop over axes
for ax=1:length(axes_no)
    min_var=nan;
    max_var=nan;
    v0=[]; v1=[]; v2=[]; v3=[]; v4=[];
    eval(['axes(' axes_no{ax} ')']);
    hold on

%Loop over files
for i=1:size(S,2)

%Increasing depths
[deph,Id] = sort(S(i).deph);
var = eval(['S(i).' names{ax} '(Id,:)']);

if isfield(S(i),['Q' names{ax}]) & ~isempty(eval(['S(i).Q' names{ax}]))
   Qvar = eval(['S(i).Q' names{ax} '(Id,:)']);
   for j=2:size(var,2)
      It0 = find(nanmax([Qvar(:,1) Qvar(:,j)],[],2)==2);
      v0 = [v0; var(It0,[1 j])];
      v1 = [v1; var];
      It2 = find(Qvar(:,1)==3 | Qvar(:,j)==3 | Qvar(:,1)==4 | Qvar(:,j)==4);
      v2 = [v2; var(It2,[1 j])];
      It3 = find((nanmax([Qvar(:,1) Qvar(:,j)],[],2)==7 & nanmin([Qvar(:,1) Qvar(:,j)],[],2)<=2) | nanmean([Qvar(:,1) Qvar(:,j)],2)==7);
      v3 = [v3; var(It3,[1 j])];
      %It4 = find(Qvar(:,1)~=3 & Qvar(:,1)~=4 & Qvar(:,j)~=3 & Qvar(:,j)~=4 & isnan(var(:,1))==0 & isnan(var(:,j))==0);
      %v4 =  [v4; var(It4,[1 j])];
   end
end
end

if ~isempty(v0), t0 = plot(v0(:,1),v0(:,2),'^','color',[0.1 0.1 0.6],'Markerfacecolor','y'); end
if ~isempty(v2), t2 = plot(v2(:,1),v2(:,2),'o','color',[0.6 0.1 0.1],'Markerfacecolor',[1 0.8 0.8]); end
if ~isempty(v3), t3 = plot(v3(:,1),v3(:,2),'s','color',[0.1 0.6 0.1],'Markerfacecolor',[0.9 0.9 0.9]); end
%if ~isempty(v4), t4 = plot(v4(:,1),v4(:,2),'.k'); end
if ~isempty(v1)
  for t=size(v1,2):-1:2, t1 = plot(v1(:,1),v1(:,t),symbol_rep{t-1}); end
end

axx=gca;
min_var=nanmin(v1(:));
max_var=nanmax(v1(:));
if isnan(min_var),min_var=0; end
if isnan(max_var),max_var=1; end
switch (max_var<1)
case 1, lx=[floor(min_var) ceil(max_var*10)/10];
case 0, lx=[floor(min_var) ceil(max_var)];
end
set(axx,'Xlim',lx,'Ylim',lx,'XminorTick','on','YminorTick','on',...
    'Box','on','PlotBoxAspectRatio',[1 1 1]);
xlabel([upper(names{ax}) ' ' units{ax}],'FontWeight','bold');

switch axes_no{ax}
    case {'ax11','ax21'}
    ylabel('Replicates','Fontweight','bold')
end        

grid on
plot(lx,lx,'-','color',[0.1 0.1 0.8])

end

%Axes 31: Textual information about cruise
axes(ax31)
set(gca,'DefaultTextFontSize',11,'visible','off','Units','normalized','Ylim',[1 3],'XLim',[0 1],'DefaultTextColor',[0.5 0 0])
text(0.5,3,['Cruise_Number : ' S(1).cruiseid],'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
text(0.5,2,['Cruise_Start : ' datestr(S(1).cruise_start,'dd-mmm-yyyy')],'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
text(0.5,1,['Cruise_End : ' datestr(S(1).cruise_end,'dd-mmm-yyyy')],'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')

%Axes 32: GSL chart
axes(ax32)
gsl_mask; hold on
set(ax32,'XTickLabel',[],'YTickLabel',[])
pl5=plot(cat(1,S.lon),cat(1,S.lat),'ro','MarkerSize',3);
set(pl5,'MarkerFaceColor','g');

%Axes 33: Legend
axes(ax33), hold on
set(gca,'DefaultTextFontSize',9,'Visible','off','Units','normalized','Xlim',[0 1],'Ylim',[0 1],'DefaultTextFontWeight','bold')
plot(0.04,1.0,'^','color',[0.1 0.1 0.6],'Markerfacecolor','y'), text(0.10,1.0,'BOTL (Q=2)','FontSize',8,'Interpreter','none')
plot(0.04,0.8,'s','color',[0.1 0.6 0.1],'Markerfacecolor',[0.9 0.9 0.9]), text(0.10,0.8,'BOTL (Q=7)','FontSize',8,'Interpreter','none')
plot(0.04,0.6,'o','color',[0.6 0.1 0.1],'Markerfacecolor',[1 0.8 0.8]), text(0.10,0.6,'BOTL (Q=3 or 4)','FontSize',8,'Interpreter','none')
plot([0.01 0.07],[0.4 0.4],'-','Color',[0.1 0.1 0.8]), text(0.12,0.4,'Theoretical fit','FontSize',8,'Interpreter','none')

plot(0.54,1.0,'k.'), text(0.6,1.0,'First replicate','FontSize',8,'Interpreter','none')
plot(0.54,0.8,'m.'), text(0.6,0.8,'Second replicate','FontSize',8,'Interpreter','none')
plot(0.54,0.6,'b.'), text(0.6,0.6,'Third replicate','FontSize',8,'Interpreter','none')
plot(0.54,0.4,'y.'), text(0.6,0.4,'Fourth replicate','FontSize',8,'Interpreter','none')
plot(0.54,0.2,'c.'), text(0.6,0.2,'Fifth replicate','FontSize',8,'Interpreter','none')
plot(0.54,0.0,'g.'), text(0.6,0.0,'Sixth replicate','FontSize',8,'Interpreter','none')

%Print option
set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')


%Zoom on
%zoom on
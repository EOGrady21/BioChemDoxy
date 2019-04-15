function B_plot_profile(S)
%B_PLOT_PROFILE - Plots bottle data with depth 
%
%Syntax:  B_plot_profile(S)
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

%Modifications
% - ajout variable pH
% CL, 19-Nov-2009

%Figure
clf
set(gcf,'units','normal','Position',[0.1 0.1 0.8 0.8])
c1=get(gcf,'color'); 

%Subplots
ax11=axes('Position',[0.06 0.03 0.20 0.30]); %Nitrate
ax12=axes('Position',[0.30 0.03 0.20 0.30]); %Nitrite
ax13=axes('Position',[0.54 0.03 0.20 0.30]); %Silicate
ax14=axes('Position',[0.78 0.03 0.20 0.30]); %Phosphate
ax21=axes('Position',[0.06 0.40 0.20 0.30]); %N:P
ax22=axes('Position',[0.30 0.40 0.20 0.30]); %N:Si
ax23=axes('Position',[0.54 0.40 0.20 0.30]); %Dissolved Oxygen
ax24=axes('Position',[0.78 0.40 0.20 0.30]); %Chlorophyll
ax31=axes('Position',[0.04 0.83 0.23 0.1]); %Information
ax32=axes('Position',[0.27 0.79 1.5*0.12 0.20]); %GSL Chart
ax33=axes('Position',[0.47 0.80 0.25 0.15]); %Legend
ax34=axes('Position',[0.78 0.77 0.20 0.17]); %pH

%Symbols for replicates (up to 6)
symbol_rep={'.k';'.m';'.b';'.y';'.c';'.g';'.k';'.k';'.k';'.k';'.k';'.k';'.k';'.k';'.k';'.k';'.k';'.k'};

%Variable names
names = {'ntrz','ntri','slca','phos','NP','NSi','doxy','cphl','phph'};
units = {'(mmol/m³)','(mmol/m³)','(mmol/m³)','(mmol/m³)','','','(ml/l)','(mg/m³)',''};
axes_no = {'ax11','ax12','ax13','ax14','ax21','ax22','ax23','ax24','ax34'};

%Loop over axes
for ax=1:length(axes_no)
    min_var=nan;
    max_var=nan;
    v0=[]; v1=[]; v2=[]; v3=[]; v4=[];
    v0_deph=[]; v1_deph=[]; v2_deph=[]; v3_deph=[]; v4_deph=[];
    eval(['axes(' axes_no{ax} ')']);
    hold on

%Loop over files
for i=1:size(S,2)

%Increasing depths
[deph,Id] = sort(S(i).deph);

%Variables
%disp(names{ax})
switch names{ax}
case 'NP'
    %S(i)=B_nan_doubtful(S(i));
    phos=nanmean(S(i).phos(Id,:),2);
    phos(phos==0)=nan;
    var = nanmean(S(i).ntrz(Id,:),2) ./ phos;
    S(i).QNP = ones(length(var),1);
case 'NSi'
    %S(i)=B_nan_doubtful(S(i));
    slca=nanmean(S(i).slca(Id,:),2);
    slca(slca==0)=nan;
    var = nanmean(S(i).ntrz(Id,:),2) ./ slca;
    S(i).QNSi = ones(length(var),1);
otherwise
    var = eval(['S(i).' names{ax} '(Id,:)']);
end

if isfield(S(i),['Q' names{ax}]) & ~isempty(eval(['S(i).Q' names{ax}]))
   Qvar = eval(['S(i).Q' names{ax} '(Id,:)']);
   for j=1:size(var,2)
      It0 = find(Qvar(:,j)==2);
      v0 = [v0; var(It0,j)];
      v0_deph = [v0_deph; deph(It0)];
      v1 = [v1; var];
      v1_deph = [v1_deph; deph];
      It2 = find(Qvar(:,j)==3 | Qvar(:,j)==4);
      v2 = [v2; var(It2,j)];
      v2_deph = [v2_deph; deph(It2)];
      It3 = find(Qvar(:,j)==7);
      v3 = [v3; var(It3,j)];
      v3_deph = [v3_deph; deph(It3)];
      %It4 = find(Qvar(:,j)~=3 & Qvar(:,j)~=4 & isnan(var(:,j))==0);
      %v4 =  [v4; var(It4,j)];
      %v4_deph = [v4_deph; deph(It4)];
   end
end
end

%Plot variables
if ~isempty(v0), t0 = plot(v0,v0_deph,'^','color',[0.1 0.1 0.6],'Markerfacecolor','y'); end
if ~isempty(v2), t2 = plot(v2,v2_deph,'o','color',[0.6 0.1 0.1],'Markerfacecolor',[1 0.8 0.8]); end
if ~isempty(v3), t3 = plot(v3,v3_deph,'s','color',[0.1 0.6 0.1],'Markerfacecolor',[0.9 0.9 0.9]); end
%if ~isempty(v4), t4 = plot(v4,v4_deph,'.k'); end
if ~isempty(v1)
    switch names{ax}
    case {'NP','NSi'}
        for t=size(v1,2):-1:1, t1 = plot(v1(:,t),v1_deph,'.','color',[0.1 0.4 0.1]); end
    otherwise
        for t=size(v1,2):-1:1, t1 = plot(v1(:,t),v1_deph,symbol_rep{t}); end
    end    
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
ly=[-1 max([1 ceil(max(v1_deph)/100)*100])];
set(axx,'Xlim',lx,'Ylim',ly,'XminorTick','on','YminorTick','on',...
    'Box','on','PlotBoxAspectRatio',[1 1 1],'Ydir','reverse','XAxisLocation','top');

%Labels
switch names{ax}
case 'NP', xlabel('N:P','FontWeight','bold');
case 'NSi', xlabel('N:Si','FontWeight','bold');
otherwise, xlabel([upper(names{ax}) ' ' units{ax}],'FontWeight','bold');
end
switch axes_no{ax}
case {'ax11','ax21'}, ylabel('Depth (m)','Fontweight','bold')
case {'ax34'}, ylabel('Depth (m)','Fontweight','bold'),set(ax34,'PlotBoxAspectRatio',[1*3/2*2/1.7 1 1])
end        

grid on

end

%Axes 31: Textual information about cruise
axes(ax31)
set(gca,'DefaultTextFontSize',11,'visible','off','Units','normalized','Ylim',[1 3],...
    'XLim',[0 1],'DefaultTextColor',[0.5 0 0])
text(0.5,3,['Cruise_Number : ' S(1).cruiseid],'FontWeight','bold',...
    'Interpreter','none','HorizontalAlignment','center')
text(0.5,2,['Cruise_Start : ' datestr(S(1).cruise_start,'dd-mmm-yyyy')],...
    'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
text(0.5,1,['Cruise_End : ' datestr(S(1).cruise_end,'dd-mmm-yyyy')],...
    'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')

%Axes 32: GSL chart
axes(ax32)
gsl_mask; hold on
set(ax32,'XTickLabel',[],'YTickLabel',[])
pl5=plot(cat(1,S.lon),cat(1,S.lat),'ro','MarkerSize',3);
set(pl5,'MarkerFaceColor','g');

%Axes 33: Legend
axes(ax33), hold on
set(gca,'DefaultTextFontSize',9,'Visible','off','Units','normalized','Xlim',[0 1],...
    'Ylim',[0 1],'DefaultTextFontWeight','bold')

plot(0.04,1.0,'^','color',[0.1 0.1 0.6],'Markerfacecolor','y')
text(0.10,1.0,'BOTL (Q=2)','FontSize',8,'Interpreter','none')

plot(0.04,0.8,'s','color',[0.1 0.6 0.1],'Markerfacecolor',[0.9 0.9 0.9])
text(0.10,0.8,'BOTL (Q=7)','FontSize',8,'Interpreter','none')

plot(0.04,0.6,'o','color',[0.6 0.1 0.1],'Markerfacecolor',[1 0.8 0.8])
text(0.10,0.6,'BOTL (Q=3 or 4)','FontSize',8,'Interpreter','none')

plot([0.01 0.07],[0.4 0.4],'-','Color',[0.1 0.1 0.8])
text(0.12,0.4,'Theoretical fit','FontSize',8,'Interpreter','none')

plot(0.04,0.2,'.','color',[0.1 0.4 0.1])
text(0.10,0.2,'Mean BOTL','FontSize',8,'Interpreter','none')

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
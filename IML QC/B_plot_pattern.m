function B_plot_pattern(S)
%B_PLOT_PATTERN - Plots bottle data with time and depth 
%
%Syntax:  plot_nsp(S)
% S is the bottle-structure
% Fields used:
%  S.deph: depth (m)
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
%  S.lat: start latitude (degrees)
%  S.lon: start longitude (degrees)
%  S.cruiseid: cruise number
%  S.cruise_start: cruise start
%  S.cruise_end: cruise end

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 12-Feb-2004 CL

%Figure
clf, 
set(gcf,'units','normal','Position',[0.1 0.1 0.8 0.8],...
    'NextPlot','add','MenuBar','none')

%Sort S by date
a=cat(1,S.time);
a=datenum(a);
[X,I]=sort(a);
S=S(I);
[files{1:size(S,2)}]=deal(S.filename);

%Subplots
ax1 = [0.07 0.74 0.86 0.19]; 
ax2 = [0.07 0.52 0.86 0.19]; 
ax3 = [0.07 0.30 0.86 0.19]; 
ax4 = [0.07 0.08 0.86 0.19]; 

%Variable names
names1 = {'CTD_flor','ntrz','doxy','phos'};
names2 = {'cphl','slca','NP','NSi'};
units1 = {'(mg/m³)','(mmol/m³)','(ml/l)','(mmol/m³)'};
units2 = {'(mg/m³)','(mmol/m³)','',''};
axes_no = {'ax1','ax2','ax3','ax4'};

%Initialize variables
deph=[];
CTD_flor=[];
cphl=[];
doxy=[];
ntrz=[];
slca=[];
phos=[];
NP=[];
NSi=[];
file={};
ind=[];

%Variables to plot
for i=1:size(S,2)
    S(i)=B_nan_doubtful(S(i));
    [d,Id] = sort(S(i).deph);  %Increasing depths
    Id = flipud(Id);
    deph = [deph; S(i).deph(Id)];
    CTD_flor = [CTD_flor; nanmean(S(i).CTD_flor(Id,:),2)];
    cphl = [cphl; nanmean(S(i).cphl(Id,:),2)];
    doxy = [doxy; nanmean(S(i).doxy(Id,:),2)];
    ntrz = [ntrz; nanmean(S(i).ntrz(Id,:),2)];
    slca = [slca; nanmean(S(i).slca(Id,:),2)];
    phos = [phos; nanmean(S(i).phos(Id,:),2)];
    pp = nanmean(S(i).phos(Id,:),2);
    pp(pp==0)=nan;
    NP = [NP; nanmean(S(i).ntrz(Id,:),2)./ pp];
    ss = nanmean(S(i).slca(Id,:),2);
    ss(ss==0)=nan;
    NSi = [NSi; nanmean(S(i).ntrz(Id,:),2)./ ss];
    file = [file; repmat({S(i).filename},length(deph),1)];
    ind = [ind; i+(1:length(Id))'/(length(Id)+1)];
end
%ind = (1:length(deph))';

%Loop over axes
for ax=1:length(axes_no)
    %Variables
    var1 = eval(names1{ax});
    var2 = eval(names2{ax});
    
    %First axes : depth
    axes('Position',eval(axes_no{ax}));
    a1(ax) = gca;
    n1 = bar(ind,deph);
    set(n1,'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.9 0.9 0.8]); 
    e1=size(S,2)/20;
    lx=[1-e1 ind(end)+1.5*e1];
    set(a1(ax),'Box','off','XLim',lx,'Tickdir','out','YMinorTick','on');
    set(a1(ax),'Xtick',(1:length(files)),'XTickLabel','')
    if ax==4
      for c=1:length(files)
        text(c,0,files{c},'VerticalAlignment','top','HorizontalAlignment','right','Rotation',90,'FontSize',8,'FontWeight','bold')
      end
    end 
    if ax==1
        title(['Cruise ' S(1).cruiseid '  :  ' datestr(S(1).cruise_start,'dd-mmm-yyyy') ...
               '  to  ' datestr(S(1).cruise_end,'dd-mmm-yyyy')],...
               'FontWeight','bold','Color',[0 0.4 0],'FontSize',12)
    end
    ylabel('Depth(m)','FontSize',8,'FontWeight','bold')
    
    %Second axes : variables
    axes('Position',eval(axes_no{ax}),'XAxisLocation','top',...
       'YAxisLocation','right',...
       'Color','none','XColor','k','YColor','k',...
       'XTickLabel',' ','YMinorTick','on','box','off');
    a2(ax)=gca;
    v1=line(ind,var1,'Color','k','Parent',a2(ax));
    v2=line(ind,var2,'Color',[0.1 0.1 0.5],'Parent',a2(ax));
    set(v1,'Marker','s','MarkerFaceColor',[0.8 0.2 0.2],'MarkerSize',4);
    set(v2,'Marker','^','MarkerFaceColor',[0.2 0.8 0.2],'MarkerSize',4);
    set(a2(ax),'Tickdir','out','XTick',[],'YMinorTick','on','XLim',lx);
    if ~isnan(nanmax([var1(:); var2(:)])) 
       set(a2(ax),'Ylim',[0 ceil(nanmax([var1(:); var2(:)]))]);
    else
       ylim=get(a2(ax),'YLim');
       set(a2(ax),'Ylim',[0 ylim(2)]);
    end
    
    %Variable legends
    ly=get(a2(ax),'ylim');
    switch names1{ax}
       case 'CTD_flor', t1=['CTD-FLOR ' units1{ax}]; 
       otherwise, t1=[upper(names1{ax}) ' ' units1{ax}];
    end
    switch names2{ax}
       case 'NP', t2='N:P'; 
       case 'NSi', t2='N:Si'; 
       otherwise, t2=[upper(names2{ax}) ' ' units2{ax}];
    end
    hold on
    plot([lx(2)-e1/1.2 lx(2)-e1/1.2],[ly(1)+ly(2)/30 ly(1)+ly(2)/8],'-s',...
        'Color',[0 0 0],'MarkerFaceColor',[0.8 0.2 0.2],'MarkerSize',4);
    text(lx(2)-e1/1.2,ly(1)+ly(2)/5,t1,'Fontweight','bold','Rotation',90,...
        'HorizontalAlignment','left','FontSize',8);
    plot([lx(2)-e1/3.5 lx(2)-e1/3.5],[ly(1)+ly(2)/30 ly(1)+ly(2)/8],'-^',...
        'Color',[0.1 0.1 0.5],'MarkerFaceColor',[0.2 0.8 0.2],'MarkerSize',4);
    text(lx(2)-e1/3.5,ly(1)+ly(2)/5,t2,'Fontweight','bold','Rotation',90,...
        'HorizontalAlignment','left','FontSize',8);
    ylabel([strtok(t1) '(r) ; ' strtok(t2) '(b)'],'FontSize',8,'FontWeight','bold')

%Depth legend

%     v=ver('MATLAB');
%     datestr(v.Date,'yyyy');
%     if str2num(datestr(v.Date,'yyyy'))<2014
%         n = bar([lx(1)+e1/3],[ly(1)+ly(2)/5]);
%         if strmatch('(R13',v.Release)
%           a=n;
%         else
%           a=get(n,'children');
%         end
%         vert = get(a,'vertices');
%         dx=(vert(4,1)-vert(3,1)-0.07)/2;
%         set(a,'vertices',[[vert(1:3,1)+dx; vert(4:6,1)-dx] vert(:,2)+(ly(1)+ly(2)/30)]);
%         set(a,'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.9 0.9 0.8]); 
%     else
%     end
    
    n = bar([lx(1)+e1/3],[ly(1)+ly(2)/5]);
    set(n,'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.9 0.9 0.8],'BarWidth',0.05); 
    text(lx(1)+e1/3,ly(1)+ly(2)/4,'Depth (m)','Fontweight','bold',...
        'Rotation',90,'HorizontalAlignment','left','FontSize',8);
    
end

%Zoom onx (link x axis of all subplots of specified fig, leave y axis unmodified)
pause(3)

linkaxes([a1 a2],'x')
zoom reset
zoom xon

%Print option
set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')

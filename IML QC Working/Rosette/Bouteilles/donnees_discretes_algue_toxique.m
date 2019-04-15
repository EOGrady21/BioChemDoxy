function donnees_discretes_algue_toxique(annee,files)
%DONNEES_DISCRETES_ALGUE_TOXIQUE - Read toxic algue data files and write the BTL-file
%Syntax: biochem_table_algue_toxique(annee)
% annee is the corresponding program year
%
%M-files needed:
%  station_type: Name and position of program stations
%  cruise_event: General information on data
%  time_zone: Time zone conversion
%  codes_phyto: Name and details about taxons

%Lafleurc, SC\DS0, Mont-Joli, March 2005

% Initialisation
station_type
cruise_event
time_zone
codes_phyto

% Liste des fichiers a lire
if nargin==1
    a=dir('*.csv');
    [files{1:size(a,1)}]=deal(a.name);
end

% Boucle sur les CSV
for f=1:size(files,2)

%BTL data
h1={'CTD','CTD','CTD','CTD','CTD','CTD','CTD','CTD',...
    'Terrain','Terrain','labo','labo','labo','labo','labo','labo'};
h2={'Fichier','Station','Latitude','Longitude','Echantillon','zbouteille','Date','Heure',...
    'SECC','SSTP_BK','PSAL_BS','NO2_01','NO3_01','PO4_01','Si_01','CHL_XX'};
h3={'nom','nom/no','degres','degres','no_unique','dbar','jj-mmm-yyyy','GMT',...
    'm','celsius','psu','umol/L','umol/L','umol/L','umol/L','ug/L'};
h4={'%s','%s','%.5f','%.5f','%.0f','%.1f','%s','%s',...
      '%.1f','%.1f','%.1f','%.2f','%.2f','%.2f','%.2f','%.2f'};

x=0;
z=0;
if isnumeric(annee); annee=num2str(annee); end

%Fichier BTL  
fid=fopen(['BTL_' files{f}(1:end-4) '.txt'],'wt');
for i=1:length(h1)-1
   fprintf(fid,'%s,',h1{i});
end
fprintf(fid,'%s\n',h1{end});
for i=1:length(h2)-1
   fprintf(fid,'%s,',h2{i});
end
fprintf(fid,'%s\n',h2{end});
for i=1:length(h3)-1
   fprintf(fid,'%s,',h3{i});
end
fprintf(fid,'%s\n',h3{end});

disp(files{f})

% First, read the input file 'file_in'
h1=textread(files{f},'%s','delimiter','\n');

% add a column in 2003 and +
if annee>=2003
for i=1:size(h1,1)
   toto=h1{i};
   I=findstr(';',toto);
   h1{i}=[toto(1:I(1)) ';' toto(I(1)+1:end)];
end
end

% Remove empty lines
h=h1(1);
for i=2:size(h1,1)
   l=length(findstr(h1{i},';'));
   if l~=length(h1{i})
      h=[h; h1(i)];
   end
end
a=findstr(h{end},';');
if a(1)==1
   h=h(1:end-1);
end

% First line
t = strrep(h{1},';','');
station = t(12:end-5);
annee = t(end-3:end);

% Second line
t=h{2};
I=findstr(t,';');
fm=key.mois{strmatch(t(I(2)+1:I(3)-1),key.mois(:,1)),2};
mm={fm};
for j=3:length(I)-1
   %txt = t(I(j)+1:I(j+1))
   %if ~isempty(deblank(txt)) & length(txt)==1
   %mm{end+1} = fm;
   txt = t(I(j)+1:I(j+1)-1);
   if isempty(deblank(txt))
       mm{end+1} = fm;
   elseif ~isempty(txt) & length(txt)>2
      %fm=key.mois{strmatch(deblank(txt(1:end-1)),key.mois(:,1)),2};
      fm=key.mois{strmatch(deblank(txt(1:end)),key.mois(:,1)),2};
      mm{end} = fm;
   end
end
mm{end+1} = fm;

% Third line
t = strrep(h{3},';',' ');
dd = str2num(t);

% Fourth line
t=h{4};
I=findstr(t,';');
fh=t(I(2)+1:I(3)-1);
hh={fh};
for j=3:length(I)-1
   txt = t(I(j)+1:I(j+1));
   if ~isempty(txt) & length(txt)>2
       fh=txt(1:end-1);
       hh{end+1} = fh;
   end
end
hh{end+1} = t(I(end)+1:end);

%Date
matdate=[];
for i=1:size(dd,2)
    matdate{i}=[num2str(dd(i),'%02d') '-' mm{i} '-' annee ' ' hh{i}];
end

%Test chronologique
m=datenum(matdate);
dm=m(2:end)-m(1:end-1);
I=find(dm<=0);
if ~isempty(I)
    disp(['Vérifier les dates de ' files{f}]);
    for kk=1:length(matdate)
        if ~isempty(find(I+1==kk))
            disp([matdate{kk} '!!!!!!!!!!!!!!!!!!'])
        else    
            disp(matdate{kk})
        end
    end
end
        

% First colunm
name=[];
data=[];
for i=6:size(h,1)
   I=findstr(h{i},';');
   name{i-5,1}=fliplr(deblank(fliplr(deblank(h{i}(1:I(1)-1)))));
   
   t=strrep(h{i}(I(1)+1:end),';',' ');
   data(i-5,:)=str2num(strrep(lower(t),'nd','nan'));
end

% Fichier de stations
Istation = strmatchi(deblank(fliplr(deblank(fliplr(station)))),key.station(:,1));

if isempty(Istation)
    disp(['Station ' station ' inconnue'])
   
else

Istation=Istation(1);    
% Time zone
key.time_zone=key.station{Istation,6};
Izone=strmatchi(key.time_zone,cat(1,zone.code));

matdate=datenum(matdate);
UTC_offset=zeros(size(matdate));
I=find(matdate>=datenum([key.heure_normale(4:6) key.heure_normale(1:3) key.heure_normale(7:10)]));
matdate(I)=matdate(I)+1/24;
UTC_offset(I)=UTC_offset(I)+1;

matdate=matdate+zone(Izone).GMT/24;
UTC_offset=UTC_offset+zone(Izone).GMT;
matdate=cellstr(datestr(matdate))';

% Écriture du fichier
    h2={'Fichier','Station','Latitude','Longitude','Echantillon','zbouteille','Date','Heure',...
    'SECC','TEMP_BS','PSAL_BS','NTRI_XX','NTRA_XX','PHOS_XX','SLCA_XX','CHL_XX'};

y=0;
for i=1:size(matdate,2)
    x=x+1;
    y=y+1;
    s=[];
    s=[s sprintf('%s,',[files{f}(1:end-4) '_' num2str(i,'%02d')])]; %Fichier
    s=[s sprintf('%s,',station)]; %Station        
    s=[s sprintf('%.5f,',key.station{Istation,4})]; %Latitude
    s=[s sprintf('%.5f,',key.station{Istation,5})]; %Longitude       
    s=[s sprintf('%s,','-99')]; %Echantillon
    s=[s sprintf('%s,','0')]; %zbouteille
    s=[s sprintf('%s,',datestr(matdate{i},'dd-mmm-yyyy'))]; %Date
    s=[s sprintf('%s,',datestr(matdate{i},'HH:MM:SS'))]; %Heure
    J=strmatchi('Secchi',name);
    s=[s sprintf('%.1f,',data(J,i))]; %SECC
    J=strmatchi('Température',name);
    s=[s sprintf('%.1f,',data(J,i))]; %TEMP_BS
    J=strmatchi('Salinité',name);
    s=[s sprintf('%.1f,',data(J,i))]; %PSAL_BS
    J=strmatchi('Nitrite',name);
    s=[s sprintf('%.2f,',data(J,i))]; %NTRI_XX
    J=strmatchi('Nitrate',name);
    s=[s sprintf('%.2f,',data(J,i))]; %NTRA_XX
    J=strmatchi('Phosphate',name);
    s=[s sprintf('%.2f,',data(J,i))]; %PHOS_XX
    J=strmatchi('Silicate',name);
    s=[s sprintf('%.2f,',data(J,i))]; %SCLA_XX
    J=strmatchi('Chlorophylle',name);
    if ~isempty(J), s=[s sprintf('%.2f',data(J,i))]; else, s=[s sprintf('nan')]; end %CHL_XX
    
    fprintf(fid,'%s\n',s);
end
end   
fclose(fid);
end


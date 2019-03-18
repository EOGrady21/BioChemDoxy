function B=B_read_btl_txtfile(btl_file)
%B_READ_BTL_TXTFILE - Transfert des données d'un fichier BTL vers un cell-array of strings
%
%Syntax: data_in = B_read_BTL_txtfile(btl_file)
%  Les données d'un fichier BTL_xxxxx.txt sont simplement chargées dans
%  l'environnement matlab sous la forme d'un cell-array contenant
%  uniquement des strings
%
%QC-BOTL

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 28-Jan-2004 CL

%Lit le fichier bouteilleet élimine les lignes vides
h1=textcell(btl_file);
h1=h1(cellfun(@isempty,h1)==0);
t=strread(h1{1},'%s','delimiter',';')';

%Transfert des données
h2=repmat({''},length(h1),length(t));
for i=1:size(h1,1)
    t=strread(h1{i},'%s','delimiter',';')';
    h2(i,1:length(t))=t;
end

%Élimine les colonnes et lignes du fichier sans donnée
h2 = h2(:,min(cellfun(@isempty,h2))==0);
h2 = h2(min(cellfun(@isempty,h2),[],2)==0,:);

%Remplace les cellules vides par NaN
h2(cellfun(@isempty,h2)==1)={'NaN'};

%Présence de -99
nullvalue='n';
if max(max(strcmp('-99',h2)))
    nullvalue = input('-99 found in data file. Do you want to replace them by NaN (y/n, default n)? ','s');
    if strcmp(lower(nullvalue),'y')
        h2(strcmp('-99',h2)==1)={'NaN'};
    end 
end

%Présence de -99.9
nullvalue='n';
if max(max(strcmp('-99.9',h2)))
    nullvalue = input('-99.9 found in data file. Do you want to replace them by NaN (y/n, default n)? ','s');
    if strcmp(lower(nullvalue),'y')
        h2(strcmp('-99.9',h2)==1)={'NaN'};
    end 
end

%Original data
B.filename=btl_file;
B.data=h2;
B.data;

%Variable codes
codes = cell(1,size(B.data,2));
for i=1:size(B.data,2);
    codes{i}=[B.data{1,i} '_' B.data{2,i}];
end

%Réorganisation selon la date et la profondeur
%Stations
x=1;
files_in=B.data(4:end,strmatch('CTD_Fichier',codes,'exact'));
files(1)=files_in(1);
dates{1}=datestr([B.data{4,strmatch('CTD_Date',codes,'exact')} ' ' B.data{4,strmatch('CTD_Heure',codes,'exact')}],0);
for i=2:size(files_in,1)
    if isempty(strmatch(files_in(i),files_in(i-1),'exact'))
        x=x+1;
        files(x)=files_in(i);
        dates{x,1}=datestr([B.data{i+3,strmatch('CTD_Date',codes,'exact')} ' ' B.data{i+3,strmatch('CTD_Heure',codes,'exact')}],0);
    end
end
files=files';    
[d,Id]=sort(datenum(char(dates)));
files=files(Id);

%New B
BB.filename=B.filename;
BB.data=B.data(1:3,:);

%Traitement station par station
for i=1:size(files,1)
   Ifiles=strmatch(files(i),B.data(:,strmatch('CTD_Fichier',codes,'exact')),'exact');
   lI=length(Ifiles);
   lat=str2num(B.data{Ifiles(1),strmatch('CTD_Latitude',codes,'exact')});

   %Données CTD
   J=strmatch('CTD_PRES',codes,'exact');
   if ~isempty(J)
       pres=str2num(char(B.data(Ifiles,J)));
   else
       J=strmatch('CTD_zbouteille',codes,'exact');
       pres=str2num(char(B.data(Ifiles,J)));
   end  
   I=find(isnan(pres));
   if ~isempty(I)
       J=strmatch('CTD_zbouteille',codes,'exact');
       p=sw_pres(str2num(char(B.data(Ifiles,J))),lat);
       pres(I)=p(I);
   end
   
   %Increasing depth
   [p,Id]=sort(pres);
   Ifiles=Ifiles(Id);
   
   BB.data=[BB.data; B.data(Ifiles,:)]; 
end  
%commented out to avoid nulling of data not matched with CTD data points
%B=BB;

%Réorganisation par codes
I=strmatch('CTD',codes);
names=B.data(2,:);
for i=1:size(names,2)
    if names{i}(1)=='Q'
        names{i}=upper(names{i}(3:end));
    else
        names{i}=upper(names{i});
    end
    J=findstr(names{i},'_');
    if ~isempty(J)
        names{i}=names{i}(1:J-1);
    end
end

n=0;
i=I(end)+1;
while i<length(codes)
   In=strmatch(names{i},names(i+1:end))';
   I_n=setdiff((1:size(names(i+1:end),2)),In);
   if ~isempty(In)
      if In(1)==i+1
         i=i+1;
      else
         B.data=[B.data(:,1:i) B.data(:,In+i) B.data(:,I_n+i)];
         names=[names(1:i) names(In+i) names(I_n+i)];
         i=i+length(In)+1;    
      end
   else
      i=i+1;
   end
end

Ino2=strmatch('NO2',names,'exact');
Ino3=strmatch('NO3',names,'exact');
Inox=strmatch('NOX',names,'exact');
Ipo4=strmatch('PO4',names,'exact');
Isi=strmatch('SI',names,'exact');

Isels=[Ino2' Ino3' Inox' Ipo4' Isi'];
I_sels=setdiff((1:size(names,2)),Isels);
B.data=[B.data(:,I_sels) B.data(:,Isels)];

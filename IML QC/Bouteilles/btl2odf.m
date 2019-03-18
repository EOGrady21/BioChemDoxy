function B= btl2odf(S,bottle_file,xls_file)
%BTL2ODF - Converts a BTL TXT-file (BTL_(cruise_number).txt) to an ODF-structure
%
%Syntax:  B=odf2btl(S,bottle_file,xls_file)
% S is the CTD ODF-structure
% B is the BOTL ODF-struture
% bottle_file=='BTL_(cruise_number).txt' (excel file saved as TXT)
% xls_file=='BTL_(cruise_number).xls' (primary BTL file)
% 
%Intput: BTL_(cruise_number).txt (tab delimited)
% Fichier(nom),Latitude(degres),Longitude(degres),Echantillon(no_unique), ...
% zbouteille(dbar),Date(jj-mmm-yyyy),Heure(GMT),CNTR(scan),nCNTR(nombre_scan),...
% PRES(dbar),PRES_SDEV(dbar),TE90(celsius),TE90_SDEV(celsius),CNDC(S/m),...
% CNDC_SDEV(S/m),PSAL(psu),PSAL_SDEV(psu),SIGT(kg/m**3),SIGT_SDEV(kg/m**3),...
% FLOR(ug/L),FLOR_SDEV(ug/L),DOXY(mL/L),DOXY_SDEV(mL/L),TRAN(%),TRAN_SDEV(%),...
% PAR(uEin/s/m**2),PAR_SDEV(uEin/s/m**2),TEMP_RT(celsius),SECC(m),PSAL_BS(psu),...
% OXY_**(mL/L),CHL_**(ug/L),PHA_**(ug/L),CHN_**(umol/L),NO3_**(umol/L),...
% NO2_**(umol/L),PO4_**(umol/L),Si_**(umol/L),NH4_**(umol/L),Uree_**(umol/L)\n');
%
%The B ODF-structure is created using information in the CTD ODF-structure and the data 
%in the bottle_file.
%
%Toolbox required: Seawater, ODSTools
%M-file required: data_btl

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%April 2000; Last revision: 17-Apr-2000 CL
%
%Modifications
%  - Ajouts pour traiter un fichier BTL sans r�f�rence � un CTD (ex: estuaire79_80)
% CL, 07-Nov-2005
%  - Dans create_empty_CTD, si heure == NaN, on inscrit 00:00:00 et on met
%  un commentaire dans l'�v�nement (ex: algues toxiques)
% CL, 27-Apr-2006
%  - modification pour enlever la colonne de Q_xx lorsque la colonne de la 
%  variable xx est nan ou -99.
% CL, 26-Jun-2007
% - Country_Institute_Code : {'1830'} now obsolete, use {'CaIML'}
% CL, 18-May-2011

B=[];
%Read btl_(cruise_number).txt file
if nargin~=3
   disp('Wrong number of inputs')
   return
end
if exist(bottle_file)~=2
   disp(['Bottle file ' bottle_file ' not found in current directory'])
   return
end

%bottle_file='btl_97042.txt';
disp(['Reading ' bottle_file])
h=textread(bottle_file,'%s','delimiter','\t','whitespace','\n','endofline','\r\n');
I=strmatch(' ',h); J=(1:length(h));
if ~isempty(I), disp(['Problem with file ' bottle_file ' near']),h{I(1)-1}; end
K=setdiff(J,I);
h=h(K);
I=strmatchi('Fichier',h);
n=I-1;
m=length(h)/n;
data=reshape(h,[n m])';
header=data(1:3,:);
data=data(4:end,:);

%Variable name associations
data_btl

%remove all NaN variables
J=strmatchi('CNTR',header(2,:));
if isempty(J)
    J=strmatchi('Heure',header(2,:))+1;
end
if isempty(J)
    J=strmatchi('echantillon',header(2,:));
end
J_ech = strmatchi('echantillon',header(2,:));
J_zbtl = strmatchi('zbouteille',header(2,:));
names=[header(2,J_ech) header(2,J_zbtl) header(2,setdiff(J:end,[J_ech J_zbtl]))];
units=[header(3,J_ech) header(3,J_zbtl) header(3,setdiff(J:end,[J_ech J_zbtl]))];
var=[data(:,J_ech) data(:,J_zbtl) data(:,setdiff(J:end,[J_ech J_zbtl]))];
dat=[];
for j=1:size(var,2)
    r=str2num(char(var(:,j)));
    if isempty(r), disp(['La colonne ' names{j} ' contient du texte. Modifier les fichier ' bottle_file ' et recommencer.']),disp(' '),return, end
   dat=[dat str2num(char(var(:,j)))];
end

I=[];
for j=1:length(names)
   try
      %k=strmatchi(names{j},key.code,'exact');
      k=strmatchi(names{j},key.code);
      if length(k)>1
          k=strmatchi(names{j},key.code,'exact');
      end

      codes{j}=btlLIST(k(1)).gf3;
      nbtl(j)=k(1);
      I=[I j];
   catch
      %k=strmatchi(names{j}(1:3),key.code,'exact');
      k=strmatchi(names{j}(1:findstr(names{j},'_')),key.code);
      if isempty(k) | length(k)==length(key.code)
   		disp(['Data ' names{j} ' not stored: no correspondence found in data_btl'])
        codes{j}='';
      else
        if isempty(codes{j-1}) & names{j}(1:2)=='Q_';
           codes{j}='';
        else
           codes{j}=btlLIST(k(1)).gf3;
           nbtl(j)=k(1);
           I=[I j];
        end
      end
   end
end
dat=dat(:,I);
names=names(I);
units=units(I);
codes=codes(I);
nbtl=nbtl(I);

%Remove data column if all nan or -99 (with Q_ column)
dat(dat==-99)=nan;
if size(dat,1)==1, 
   mdat=dat;
else
   mdat=nanmean(dat);
end
I=find(isnan(mdat==1));
J=[];
for u=I
    if u<length(names) & ~isempty(['Q_' names{u}],strmatch(names{u+1}))
        J=[J u];
    end
end
K=setdiff((1:length(names)),[I J]);
names1=names(K);
units1=units(K);
codes1=codes(K);
dat1=dat(:,K);
nbtl1=nbtl(K);
dat1(isnan(dat1))=-99;

%Modification: Loop over fichier CTD au lieu de la structure S
[bb,ii,jj]=unique(data(:,1));
fichierCTD=data(sort(ii),1);
if ~isempty(S)
  [filesS{1:size(S,2)}]=deal(S.filename);
else
  filesS=[];
end

m=0;
disp('Creating BOTL-files')
for i=1:size(fichierCTD,1)
   ndat=strmatchi(fichierCTD{i},data(:,1),'exact');
   Ictd=strmatchi([fichierCTD{i} '.'],filesS);
   if isempty(Ictd)
       disp(['No CTD file for ' fichierCTD{i}])
       if ~isempty(S)
           CTD=create_empty_CTD(fichierCTD{i},S(1),header,data(ndat(1),:));
       else
           CTD=create_empty_CTD(fichierCTD{i},[],header,data(ndat(1),:));
           S=CTD;
       end
   else
       CTD=S(Ictd);
   end
   
   %Create BTL file
   m=m+1;  
   if (~isempty(strmatchi('PRES',names1)) & isempty(find(dat1(ndat,strmatchi('PRES',names1))==-99))) ...
      | (~isempty(strmatchi('DEPH',names1)) & isempty(find(dat1(ndat,strmatchi('DEPH',names1))==-99)))
%   if isempty(isnan(dat1(ndat,strmatchi('PRES',names1))==1))
      p=strmatchi('zbouteille',names1);
	  names=[names1(1:p-1) names1(p+1:end)];
      codes=[codes1(1:p-1) codes1(p+1:end)];
      nbtl=[nbtl1(1:p-1) nbtl1(p+1:end)];
      dat=[dat1(:,1:p-1) dat1(:,p+1:end)];
   else
      if ~isempty(strmatch(units{strmatchi('zbouteille',names1)},'(m)'))
          p=strmatchi('zbouteille',names1);
     	  names=[names1(1:p-1) {'DEPH'} names1(p+1:end)];
          codes=[codes1(1:p-1) {'DEPH'} codes1(p+1:end)];
          nbtl=[nbtl1(1:p-1) strmatchi('DEPH',key.code) nbtl1(p+1:end)];
          dat=dat1;
      else   
          names=names1;
          codes=codes1;
          nbtl=nbtl1;
          dat=dat1;
      end
   end
   
   %ODF_Header
   B(m).ODF_Header=CTD.ODF_Header;
   disp([CTD.filename ' ...'])
   
   %Cruise_Header	
   B(m).Cruise_Header=CTD.Cruise_Header;

   %Event_Header
   B(m).Event_Header=CTD.Event_Header;
   B(m).Event_Header.Data_Type={'BOTL'};
   B(m).Event_Header.Event_Qualifier2={''};
   B(m).Event_Header.Creation_Date=cellstr(mdate(datevec(now)));
   if exist(xls_file)==2
      a=dir(xls_file);
   else
      disp(['Excel file ' xls_file ' not found in current directory'])
      return
   end
   B(m).Event_Header.Orig_Creation_Date=cellstr(mdate(datevec(a.date)));
   B(m).Event_Header.Sampling_Interval=-99;
   %Verify that the time is the same
   J=strmatchi('Date',header(2,:));
   dates=datenum([char(data(ndat,J)) repmat(' ',length(ndat),1) char(data(ndat,J+1))]);
   if length(find(dates==datenum(char(getvalue(CTD,'Start_Date_Time')))))~=length(ndat)
      error([CTD.filename(1:end-4) ' and bottle sample do not have the same date and time'])
   end
   %Verify that the position is the same
   J=strmatchi('Latitude',header(2,:));
   lat=str2num(num2str(str2num(char(data(ndat,J))),'%.5f'));
   if length(find(lat==str2num(num2str(getvalue(CTD,'Initial_Latitude'),'%.5f'))))~=length(ndat)
      error([CTD.filename ' and bottle sample do not have the same latitude'])
   end
   J=strmatchi('Longitude',header(2,:));
   lon=str2num(num2str(str2num(char(data(ndat,J))),'%.5f'));
   if length(find(lon==str2num(num2str(getvalue(CTD,'Initial_Longitude'),'%.5f'))))~=length(ndat)
      error([CTD.filename ' and bottle sample do not have the same longitude'])
   end
   %B(m).Event_Comments

   %Instrument_Header
   B(m).Instrument_Header={};

   %General_Cal_Header
   B(m).General_Cal_Header={};

   %Polynomial_Cal_Header
   B(m).Polynomial_Cal_Header={};

   %Compass_Cal_Header
   B(m).Compass_Cal_Header={};

   %History_Header
   h=0;
   %CTD history
   if ~isempty(CTD.Instrument_Header)
      h=h+1;
   	  B(m).History_Header{h}.Creation_Date=CTD.Event_Header.Creation_Date;
      B(m).History_Header{h}.Process{1}='CTD data treatment';
      B(m).History_Header{h}.Process{2}=['CTD_INST_TYPE= ' char(getvalue(CTD,'Inst_Type'))];
      B(m).History_Header{h}.Process{3}=['CTD_MODEL= ' char(getvalue(CTD,'Model'))];
      B(m).History_Header{h}.Process{4}=['CTD_SERIAL_NUMBER= ' char(getvalue(CTD,'Serial_Number'))];
      B(m).History_Header{h}.Process{5}=['CTD_DESCRIPTION= ' char(getvalue(CTD,'Description'))];
   end
   %BOTL history
   if ~isempty(CTD.Instrument_Header)
      h=h+1;
      B(m).History_Header{h}.Creation_Date={mdate(datevec(now))};
      ctd_file=['CTD_' char(getvalue(CTD,'Cruise_Number')) '_' ...
         char(getvalue(CTD,'Event_Number')) '_' ...
         char(getvalue(CTD,'Event_Qualifier1')) '_' ...
         char(getvalue(CTD,'Event_Qualifier2')) '.odf'];
      B(m).History_Header{h}.Process{1}=['BOTL-files from ' ctd_file ' and ' xls_file];
   else
      h=h+1;
      B(m).History_Header{h}.Creation_Date={mdate(datevec(now))};
      B(m).History_Header{h}.Process{1}=['BOTL-files from ' xls_file];       
   end  
   %Data history
   h=h+1;
   B(m).History_Header{h}.Creation_Date={mdate(datevec(now))};
   B(m).History_Header{h}.Process{1,1}='Parameter / Method CODE / Description';

   %Parameter_Header
   B(m).Parameter_Header=[];
   B(m).Record_Header=[];
   B(m).Data=[];
   
   %assign data
   n=0;
   j=0; newcodes=[];
   
   while j<length(codes)
      j=j+1;
      %Data
      if max(dat(ndat,j))==-99
         if j+1<=length(codes) & codes{j+1}(1:4)=='QQQQ'
            j=j+1;
         end
      else
      dat2=dat;
      dat2(dat2==-99)=nan;
      n=n+1;
      newcodes{end+1}=codes{j};
      J=strmatchi(codes{j},char(newcodes));
      num=sprintf('%2.2d',length(J));
      eval(['B(m).Data.' btlLIST(nbtl(j)).gf3 '_' num '=dat2(ndat,j)*btlLIST(nbtl(j)).btl2gf3;'])
      
      %Parameter_Header
      R = gf3defs(codes{j});
      if R.code=='FLOR', R.units='mg/m**3'; end
      if R.code=='PSAR', R.units='ueinsteins/s/m**2'; end
   	  B(m).Parameter_Header{n}.Type = cellstr('DOUB');
   	  B(m).Parameter_Header{n}.Name = cellstr(btlLIST(nbtl(j)).name);
      if codes{j}=='SDEV'
      	B(m).Parameter_Header{n}.Units = cellstr(B(m).Parameter_Header{n-1}.Units);
 	  else
      	B(m).Parameter_Header{n}.Units = cellstr(R.units);
      end
      B(m).Parameter_Header{n}.Code = cellstr([btlLIST(nbtl(j)).gf3 '_' num]);
   	  B(m).Parameter_Header{n}.NULL_Value = cellstr(sprintf('%E',key.null_value));
      B(m).Parameter_Header{n}.Print_Field_Width =	10;	% R.fieldwidth;
   	  B(m).Parameter_Header{n}.Print_Decimal_Places = btlLIST(nbtl(j)).decimal;	%R.decimalplaces;
   	  B(m).Parameter_Header{n}.Angle_of_Section = 0;
   	  B(m).Parameter_Header{n}.Magnetic_Variation = 0;
      B(m).Parameter_Header{n}.Depth = 0;
      B(m).Parameter_Header{n}.Minimum_Value = num2str(nanmin(dat2(ndat,j)*btlLIST(nbtl(j)).btl2gf3),...
         eval(['''%.' num2str(btlLIST(nbtl(j)).decimal) 'f''']));
      B(m).Parameter_Header{n}.Maximum_Value = num2str(nanmax(dat2(ndat,j)*btlLIST(nbtl(j)).btl2gf3),...
         eval(['''%.' num2str(btlLIST(nbtl(j)).decimal) 'f''']));
	  B(m).Parameter_Header{n}.Number_Valid = length(find(~isnan(dat2(ndat,j))));
      B(m).Parameter_Header{n}.Number_NULL = length(find(isnan(dat2(ndat,j))));
      
      %History
      c=strmatchi(names{j},btlLIST(nbtl(j)).method);
      if isempty(c)
   		B(m).History_Header{h}.Process{n+1,1}=[codes{j} '_' num ' / ' char(names{j}) ...
            ' / unknown method']; 
      else   
      	B(m).History_Header{h}.Process{n+1,1}=[codes{j} '_' num ' / ' char(btlLIST(nbtl(j)).method(c)) ...
            ' / ' char(btlLIST(nbtl(j)).desc(c))]; 
      end
      B(m).Parameter_Header=B(m).Parameter_Header';
      end
   end

   %filename
   B(m).filename=CTD.filename;
   
   %Meteo_Header
   B(m).Meteo_Header=CTD.Meteo_Header;
   
   %B(m).Quality_Header
   %C = strmatch('QCFF',header(2,:),'exact');
   a=exist('QC_Tests_performed.txt');
   %if ~isempty(C)
   if a==2
      fileT=['QC_Tests_performed.txt'];
      if exist(fileT,'file')==2     
         B(m).Quality_Header.Quality_Date = cellstr(mdate(datevec(now)));
         B(m).Quality_Header.Quality_Tests = textcell(fileT);
         B(m).Quality_Header.Quality_Comments = ...
          {'QCFF values are derived from tests of the bottle quality control stage 2';...
           'A quality flag modified by hand has a QCFF value of 1'};
      end
   end
   
   %Update of Event_Header info
   if isfield(B(m).Data,'DEPH_01')
	  d=B(m).Data.DEPH_01;   
   elseif isfield(B(m).Data,'PRES_01')
      %view_parameters(B(m)),pause
      d=sw_dpth(B(m).Data.PRES_01,B(m).Event_Header.Initial_Latitude);
   end
   B(m).Event_Header.Min_Depth=nanmin(d);
   B(m).Event_Header.Max_Depth=nanmax(d);
   if B(m).Event_Header.Sounding>0
	  B(m).Event_Header.Depth_Off_Bottom=B(m).Event_Header.Sounding-nanmax(d);
   end

   %Record_Header
   B(m).Record_Header.Num_History = length(B(m).History_Header);
   B(m).Record_Header.Num_Swing = 0;
   try
       B(m).Record_Header.Num_Cycle = length(B(m).Data.PRES_01);
   catch
       B(m).Record_Header.Num_Cycle = length(B(m).Data.DEPH_01);
   end
   B(m).Record_Header.Num_Param = length(B(m).Parameter_Header);
   B(m).Record_Header.Num_Calibration = length(B(m).General_Cal_Header);
  
   %Secchi !!!!! not the right way to do it
   %if isfield(B(m).Data,'SECC_01')
   %    B(m)=add_event(B(m),'Event_Comments',['Secchi (m): ' num2str(B(m).Data.SECC_01)]);
   %    B(m)=remove_parameter(B(m),'SECC_01');
   %end 
end


%------------------------------
function S=create_empty_CTD(filename,anotherS,header,data)
% CREATE_EMPTY_CTD - Create an empty structure of CTD data

names=header(2,:);
S.ODF_Header.File_Spec={filename};

if ~isempty(anotherS)
    S.Cruise_Header=anotherS.Cruise_Header;

else    
    %ask if the data manager wants to enter cruide details if not, than
    %default values are entered
    y_n = input('Do you want to enter cruise details (y or n) = ','s');
    
    switch y_n
    case 'y'
      
    %ask cruise details
    S.Cruise_Header.Country_Institute_Code={'CaIML'};
    
    cruise_number = input('Cruise_Number (yyyynnn) = ','s');
    S.Cruise_Header.Cruise_Number = {cruise_number};
    
    organisation = input('Organization (ex: DSO) = ','s');
    S.Cruise_Header.Organization = {organisation};
    
    chief = input('Chief_Scientist = ','s');
    S.Cruise_Header.Chief_Scientist = {chief};
    
    start_date = input('Cruise_Start_Date (ex: 05-MAY-1993) = ','s');
    S.Cruise_Header.Start_Date = {[start_date(1:11) ' 00:00:00.00']};

    end_date = input('Cruise_End_Date (ex: 10-OCT-1993) = ','s');
    S.Cruise_Header.End_Date = {[end_date(1:11) ' 23:50:00.00']}; 
    
    platform = input('Platform (ex: Beluga) = ','s');
    S.Cruise_Header.Platform = {platform};
    
    cruise_name = input('Cruise_Name = ','s');
    S.Cruise_Header.Cruise_Name = {cruise_name};
    
    description = input('Cruise_Description = ','s');
    S.Cruise_Header.Cruise_Description = {description};
    
    case 'n'
    S.Cruise_Header.Country_Institute_Code={'CaIML'};
    S.Cruise_Header.Cruise_Number = {''};
    S.Cruise_Header.Organization = {''};
    S.Cruise_Header.Chief_Scientist = {''};
    S.Cruise_Header.Start_Date = {'17-Nov-1858 00:00:00.00'};
    S.Cruise_Header.End_Date = {'17-Nov-1858 00:00:00.00'}; 
    S.Cruise_Header.Platform = {'inconnu'};
    S.Cruise_Header.Cruise_Name = {''};
    S.Cruise_Header.Cruise_Description = {''};
    end
end    

S.Event_Header.Data_Type = {'CTD'};
if length(filename)==12 & filename(9)=='.'
    try
       event_number = num2str(str2num(filename(6:8)));
    catch
       event_number = data{strmatchi('Station',names)};
    end 
else
    event_number = data{strmatchi('Station',names)};
end
S.Event_Header.Event_Number = {event_number};
S.Event_Header.Event_Qualifier1 = {'1'};
S.Event_Header.Event_Qualifier2 = {'DN'};
S.Event_Header.Orig_Creation_Date = cellstr(mdate(datevec(now)));
S.Event_Header.Creation_Date = cellstr(mdate(datevec(now)));

date = datestr(data{strmatchi('Date',names)},'dd-mmm-yyyy');
try
    heure = datestr(data{strmatchi('Heure',names)},'HH:MM:SS');
    c = '';
catch
    heure = '00:00:00';
    c = 'L`heure d`�chantillonnage est inconnue';
    disp(c)
end
S.Event_Header.Start_Date_Time = {[date ' ' heure '.00']};
S.Event_Header.End_Date_Time = {'17-NOV-1858 00:00:00.00'};

latitude = data{strmatchi('Latitude',names)};
longitude = data{strmatchi('Longitude',names)};
S.Event_Header.Initial_Latitude = str2num(latitude);
S.Event_Header.Initial_Longitude = str2num(longitude);

S.Event_Header.End_Latitude = -99.0;
S.Event_Header.End_Longitude = -999.0;
S.Event_Header.Min_Depth = 0;
S.Event_Header.Max_Depth = 500;
S.Event_Header.Sampling_Interval = -99.0;
Isounding = strmatchi('Sounding',names);
if ~isempty(Isounding)
    S.Event_Header.Sounding = str2num(data{Isounding});
else
    S.Event_Header.Sounding = -99.0;
end
S.Event_Header.Depth_Off_Bottom = -99.0;

station = data{strmatchi('Station',names)}; 
S.Event_Header.Event_Comments = {['Station ' station]};
if ~isempty(c)
    S.Event_Header.Event_Comments{end+1,1}=c;
end
IQposition = strmatchi('Q_position',names);
if ~isempty(IQposition) & str2num(data{IQposition})
    S.Event_Header.Event_Comments{length(S.Event_Header.Event_Comments)+1} = ['La qualit� de la position g�ographique est de ' data{IQposition}];
end
IQdatetime = strmatchi('Q_date/time',names);
if ~isempty(IQdatetime) & str2num(data{IQdatetime})
    S.Event_Header.Event_Comments{length(S.Event_Header.Event_Comments)+1} = ['La qualit� de la date/heure d`�chantillonnage est de ' data{IQdatetime}];
end

S.Instrument_Header = {};

S.General_Cal_Header = {};

S.Polynomial_Cal_Header = {};

S.Compass_Cal_Header = {};

S.History_Header = {};
S.Record_Header = {};

S.filename = filename;

S.Meteo_Header = {};

S.Quality_Header = {};

S.Parameter_Header{1}.Type = {'DOUB'};
S.Parameter_Header{1}.Name = 'Sea Pressure (sea surface - 0)';
S.Parameter_Header{1}.Units = {'decibars'};
S.Parameter_Header{1}.Code = {'PRES_01'};
S.Parameter_Header{1}.NULL_Value = {'-9.900000E+001'};
S.Parameter_Header{1}.Print_Field_Width = 10;
S.Parameter_Header{1}.Print_Decimal_Places = 2;
S.Parameter_Header{1}.Angle_of_Section = 0;
S.Parameter_Header{1}.Magnetic_Variation = 0;
S.Parameter_Header{1}.Depth = 0;
S.Parameter_Header{1}.Minimum_Value = '0';
S.Parameter_Header{1}.Maximum_Value = '500';
S.Parameter_Header{1}.Number_Valid = length(0:0.5:500);
S.Parameter_Header{1}.Number_NULL = 0;

S.Data.PRES_01=(1:0.5:500)';

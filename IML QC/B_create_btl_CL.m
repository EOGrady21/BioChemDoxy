function S_btl=B_create_btl(B,call)
%B_CREATE_BTL - Creates the bottle quality control structure 
%
%Syntax:  S_btl = B_create_btl(S_odf,call)
%The btl_cell (see B_read_BTL_txtfile) is converted to the btl-structure 
%for the quality control procedure.
% B is the structure out of B_read_btl_txtfile
% S_btl is the temporary structure used by the quality control program
% call is the platform call sign (optionnal)
%
%Other toolbox required: seawater
%M-files required: sw_t68
%QC-BTL

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 28-Jan-2004 CL

%Modifications:
% -Ajout variables pH, alky
% CL, 19-Nov-2009
% - Ajustements pour PHT
% CL, 2015

%Input variables
if nargin==1
call=input(['Enter ship call_sign -> '],'s');
end

%btl_cell
btl_cell=B.data;

%Variable codes
for i=1:size(btl_cell,2);
    codes{i}=[btl_cell{1,i} '_' btl_cell{2,i}];
end

%Stations
x=1;
files_in=btl_cell(4:end,strmatch('CTD_Fichier',codes,'exact'));
files(1)=files_in(1);
for i=2:size(files_in,1)
    if isempty(strmatch(files_in(i),files_in(i-1),'exact'))
        x=x+1;
        files(x)=files_in(i);
    end
end
files=files';    

%Traitement station par station
for i=1:size(files,1)
   Ifiles=strmatch(files(i),btl_cell(:,strmatchi('CTD_Fichier',codes,'exact')),'exact');
   lI=length(Ifiles);
   
   %Metadonnées
   S_btl(i).filename=btl_cell{Ifiles(1),strmatchi('CTD_Fichier',codes,'exact')};
   S_btl(i).call_sign=lower(call);
   S_btl(i).cruiseid=B.filename(5:end-4);
   S_btl(i).cruise_start='17-Nov-1858 00:00:00';
   S_btl(i).cruise_end='17-Nov-1858 00:00:00';
   S_btl(i).station=btl_cell{Ifiles(1),strmatchi('CTD_Station',codes,'exact')};
   S_btl(i).lat=str2num(btl_cell{Ifiles(1),strmatchi('CTD_Latitude',codes,'exact')});
   S_btl(i).lon=str2num(btl_cell{Ifiles(1),strmatchi('CTD_Longitude',codes,'exact')});
   S_btl(i).time=datestr([btl_cell{Ifiles(1),strmatchi('CTD_Date',codes,'exact')} ' ' btl_cell{Ifiles(1),strmatch('CTD_Heure',codes,'exact')}],0);
   S_btl(i).lat_end=nan;
   S_btl(i).lon_end=nan;
   S_btl(i).time_end='17-Nov-1858 00:00:00';
   J=strmatchi('Terrain_Sounding',codes,'exact');
   if ~isempty(J)
       S_btl(i).sounding=str2num(btl_cell{Ifiles(1),strmatchi('Terrain_Sounding',codes,'exact')});
   else
       S_btl(i).sounding = nan;
   end
   S_btl(i).interval=nan; 
   
   %Données CTD
   J=strmatch('CTD_PRES',codes,'exact');
   if ~isempty(J)
      pres=str2num(char(btl_cell(Ifiles,J)));
   else
      J=strmatch('CTD_zbouteille',codes,'exact');
      pres=str2num(char(btl_cell(Ifiles,J)));
   end
   I=find(isnan(pres));
   if ~isempty(I)
      J=strmatch('CTD_zbouteille',codes,'exact');
      p=sw_pres(str2num(char(btl_cell(Ifiles,J))),S_btl(i).lat);
      pres(I)=p(I);
   end
 
   %Decreasing depth
   [p,Id]=sort(pres);
   Ifiles=Ifiles(Id);

   %test pour savoir si duplicata
   S_btl(i).uniqueno=str2num(char(btl_cell(Ifiles,strmatch('CTD_Echantillon',codes,'exact'))));
   %I=find(S_btl(i).uniqueno==-99);
   %if ~isempty(I)
   %    S_btl(i).uniqueno=str2num(char(btl_cell(Ifiles,6)));
   %end
   unique(S_btl(i).uniqueno);
   if length(S_btl(i).uniqueno)~=length(unique(S_btl(i).uniqueno))
       disp(['Samples are not unique in ' S_btl(i).filename])
       S_btl=[];
       return
   end
   S_btl(i).CTD_pres=str2num(char(btl_cell(Ifiles,J)));
   S_btl(i).CTD_deph=sw_dpth(S_btl(i).CTD_pres,S_btl(i).lat);
   I = strmatch('CTD_TEMP',codes,'exact');
   if ~isempty(I)
      S_btl(i).CTD_temp=str2num(char(btl_cell(Ifiles,I(1))));
   else      
      I = strmatch('CTD_TE90',codes,'exact');
      if ~isempty(I)
          S_btl(i).CTD_temp=str2num(char(btl_cell(Ifiles,I(1))));
      else
          S_btl(i).CTD_temp=S_btl(i).CTD_deph*nan;
      end
   end
   I = strmatch('CTD_PSAL',codes,'exact');
   if ~isempty(I)
      S_btl(i).CTD_psal=str2num(char(btl_cell(Ifiles,I(1))));
   else
      S_btl(i).CTD_psal=S_btl(i).CTD_temp*nan;
   end
   I = strmatch('CTD_SIGT',codes,'exact');
   if ~isempty(I)
      S_btl(i).CTD_sigt=str2num(char(btl_cell(Ifiles,I(1))));
   else
      S_btl(i).CTD_sigt=sw_dens(S_btl(i).CTD_psal,S_btl(i).CTD_temp,0)-1000;
   end
   I = strmatch('CTD_DOXY',codes,'exact');
   if ~isempty(I)
      S_btl(i).CTD_doxy=str2num(char(btl_cell(Ifiles,I(1))));
   else
      S_btl(i).CTD_doxy=S_btl(i).CTD_temp*nan;
   end
   I = strmatch('CTD_FLOR',codes,'exact');
   if ~isempty(I)
      S_btl(i).CTD_flor=str2num(char(btl_cell(Ifiles,I(1))));
   else
      S_btl(i).CTD_flor=S_btl(i).CTD_temp*nan;
   end
   I = strmatch('CTD_PHPH',codes,'exact');
   if ~isempty(I)
      S_btl(i).CTD_phph=str2num(char(btl_cell(Ifiles,I(1))));
   else
      I = strmatch('CTD_PHT_',codes,'exact');
      if ~isempty(I)
          S_btl(i).CTD_phph=str2num(char(btl_cell(Ifiles,I(1))));
      else
          S_btl(i).CTD_phph=S_btl(i).CTD_temp*nan;
      end
   end

%   S_btl(i).dpdt=getvalue(S_odf(i),'dpdt_01');
%   S_btl(i).ffff=getvalue(S_odf(i),'ffff_01');

   %Données labo
   
   %pres
   S_btl(i).pres=S_btl(i).CTD_pres;
   S_btl(i).Qpres=ones(length(S_btl(i).pres),1);
   
   %deph
   S_btl(i).deph=S_btl(i).CTD_deph;
   S_btl(i).Qdeph=ones(length(S_btl(i).deph),1);

   %terrain_TEMP_RT or terrain_SSTP_BK or terrain_TEMP_BT or terrain_TEMP_XX
   J1=union(strmatchi('terrain_TEMP_RT',codes,'exact'),strmatchi('terrain_SSTP_BK',codes,'exact'));
   J2=union(strmatchi('terrain_TEMP_XX',codes,'exact'),strmatchi('terrain_TEMP_BT',codes,'exact'));
   J=union(J1,J2);
   S_btl(i).temp=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).temp)
      S_btl(i).temp=S_btl(i).CTD_temp*nan;
      S_btl(i).Qtemp=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('terrain_Q_TEMP',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qtemp(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qtemp(:,j)=S_btl(i).CTD_temp*nan;
      end
   end

   %labo_PSAL_BT or labo_SSAL_BS
   J=union(strmatchi('labo_PSAL_BS',codes,'exact'),strmatchi('labo_SSAL_BS',codes,'exact'));
   S_btl(i).psal=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).psal)
      S_btl(i).psal=S_btl(i).CTD_temp*nan;
      S_btl(i).Qpsal=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_PSAL',codes);
   for j=1:length(J)
        JJ=find(JQ==J(j)+1);
        if ~isempty(JJ)
           S_btl(i).Qpsal(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
        else
           S_btl(i).Qpsal(:,j)=S_btl(i).CTD_temp*nan;
        end
   end
   
   %labo_SIGT
   J=strmatchi('labo_SIGT_00',codes,'exact');
   S_btl(i).sigt=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).sigt)
      S_btl(i).sigt=S_btl(i).CTD_temp*nan;
      S_btl(i).Qsigt=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_SIGT',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qsigt(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qsigt(:,j)=S_btl(i).CTD_temp*nan;
      end
   end
   
   %labo_OXY
   J=strmatchi('labo_OXY_',codes);
   S_btl(i).doxy=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).doxy)
      S_btl(i).doxy=S_btl(i).CTD_temp*nan;
      S_btl(i).Qdoxy=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_OXY',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qdoxy(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qdoxy(:,j)=S_btl(i).CTD_temp*nan;
      end
   end

   %labo_OXYM
   J=strmatchi('labo_OXYM_',codes);
   S_btl(i).doxy=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J))/44.66;
   if isempty(S_btl(i).doxy)
      S_btl(i).doxy=S_btl(i).CTD_temp*nan;
      S_btl(i).Qdoxy=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_OXYM',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qdoxy(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qdoxy(:,j)=S_btl(i).CTD_temp*nan;
      end
   end
   
   %labo_CHL
   J=strmatchi('labo_CHL_',codes);
   S_btl(i).cphl=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).cphl)
      S_btl(i).cphl=S_btl(i).CTD_temp*nan;
      S_btl(i).Qcphl=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_CHL',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qcphl(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qcphl(:,j)=S_btl(i).CTD_temp*nan;
      end
   end
   
   %labo_NOX et labo_NO3
   Jnox=strmatchi('labo_NOX_',codes);
   Jno3=strmatchi('labo_NO3_',codes);
   nox=unique(codes(Jnox));
   for n=1:length(nox)
     nox{n}=nox{n}(end-1:end);
   end
   no3=unique(codes(Jno3));
   for n=1:length(no3)
     no3{n}=no3{n}(end-1:end);
   end
   duplicat=intersect(nox,no3);
   if ~isempty(duplicat)
      disp(['NO3 and NOX acquired with the same method. You must keep only NOX'])
      S_btl=[];
      return
   else
      J=sort([Jnox(:)' Jno3(:)']);
      S_btl(i).ntrz=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   end
   if isempty(S_btl(i).ntrz)
      S_btl(i).ntrz=S_btl(i).CTD_temp*nan;
      S_btl(i).Qntrz=S_btl(i).CTD_temp*nan;
   end
   JQnox=strmatchi('labo_Q_NOX',codes);
   JQno3=strmatchi('labo_Q_NO3',codes);
   JQ=unique([JQnox(:)' JQno3(:)']);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qntrz(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qntrz(:,j)=S_btl(i).CTD_temp*nan;
      end
   end

   %labo_NO2
   J=strmatchi('labo_NO2_',codes);
   S_btl(i).ntri=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).ntri)
      S_btl(i).ntri=S_btl(i).CTD_temp*nan;
      S_btl(i).Qntri=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_NO2',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qntri(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qntri(:,j)=S_btl(i).CTD_temp*nan;
      end
   end

   %labo_PO4
   J=strmatchi('labo_PO4_',codes);
   S_btl(i).phos=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).phos)
      S_btl(i).phos=S_btl(i).CTD_temp*nan;
      S_btl(i).Qphos=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_PO4',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qphos(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qphos(:,j)=S_btl(i).CTD_temp*nan;
      end
   end

   %labo_Si
   J=strmatchi('labo_Si_',codes);
   S_btl(i).slca=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).slca)
      S_btl(i).slca=S_btl(i).CTD_temp*nan;
      S_btl(i).Qslca=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_Si',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qslca(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qslca(:,j)=S_btl(i).CTD_temp*nan;
      end
   end
   
   %labo_pH
   J=strmatchi('labo_pH_',codes);
   if isempty(J)
      J=strmatchi('labo_pHT_',codes);
   end
   S_btl(i).phph=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).phph)
      S_btl(i).phph=S_btl(i).CTD_temp*nan;
      S_btl(i).Qphph=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_pH',codes);
   if isempty(JQ)
      JQ=strmatchi('labo_Q_pHT_',codes);
   end
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qphph(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qphph(:,j)=S_btl(i).CTD_temp*nan;
      end
   end

   %labo_alky
   J=strmatchi('labo_ALKY_',codes);
   S_btl(i).alky=reshape(str2num(char(btl_cell(Ifiles,J))),lI,length(J));
   if isempty(S_btl(i).alky)
      S_btl(i).alky=S_btl(i).CTD_temp*nan;
      S_btl(i).Qalky=S_btl(i).CTD_temp*nan;
   end
   JQ=strmatchi('labo_Q_ALKY',codes);
   for j=1:length(J)
      JJ=find(JQ==J(j)+1);
      if ~isempty(JJ)
         S_btl(i).Qalky(:,j)=reshape(str2num(char(btl_cell(Ifiles,JQ(JJ)))),lI,1);
      else
         S_btl(i).Qalky(:,j)=S_btl(i).CTD_temp*nan;
      end
   end

   %QCFF global - tests echoués
   S_btl(i).QCFF=ones(length(S_btl(i).pres),1)*0;
   
   %QCFF global - tests effectués
   %S_btl(i).QCF=ones(length(S_btl(i).pres),1)*0;
   
   %refresh_Q
   %S_btl(i)=refresh_Q(S_btl(i));
   S_btl(i).history='';
   
end
time=cat(1,S_btl.time);
cruise_start=datestr(min(datenum(time)));
cruise_end=datestr(max(datenum(time)));
for i=1:size(S_btl,2)
    S_btl(i).cruise_start=cruise_start;
    S_btl(i).cruise_end=cruise_end;
end
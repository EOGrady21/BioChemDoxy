function odf2btl(S,opt,LABO,optoxy)
%ODF2BTL - Writes CTD and bottle data in a TXT file (BTL_(cruise_number).txt)
%
%Syntax:  odf2btl(S,opt,LABO)
% S is the ODF-structure array.
% opt:
%  opt='deph': takes the data at specified pressure depth in downcast
%  opt='cntr': takes the data at specified scan numbers in upcast or downcast
%  opt='fbtl': takes the BTL files to get the corresponding data
% LABO is a structure of labo data (see labo.m)
% optoxy='upcast' or 'downcast' from oxygen extraction (default:'downcast')
% Notes:
%  -O2 data are always selected from downcasts.
%  -S is either the structure of upcast or up and down casts for opt='cntr'.
%   If the scan numbers are not known (=-99), then the nominal pressure depth will be used.
%  -S is either the structure of downcast or up and down casts for opt='deph'.
%   The downcast which has been qualified is preferable.
%  -S is either the structure of downcast or up and down casts for opt='fbtl'.
% 
%TXT-file needed: btlscan.txt (comma delimited) - not needed for opt='fbtl'.
%  1. unique bottle number (or profile bottle number)
%  2. filename of CTD data in CNV format (without extension)
%  3. nominal pressure depth (dbar)
%  4. start scan number
%  5. end scan number
%This file is created automatically with 
%  ros2btlscan.m using ROS-files or
%  mrk2btlscan.m using MRK-files or
%  bsr2btlscan.m using BSR-files
%
%Output: BTL_(cruise_number).txt
% Fichier(nom),Station(nom/no),Latitude(degres),Longitude(degres),Echantillon(no_unique),...
% znominal(dbar),Date(jj-mmm-yyyy),Heure(GMT),CNTR(scan),nCNTR(nombre_scan),...
% PRES(dbar),std(PRES)(dbar),TE90(celsius),std(TE90)(celsius),PSAL(psu),...
% SIGT(kg/m**3),FLOR(ug/l),DOXY(ml/l),TRAN(%%),PAR(uEin/s/m**2),TEMP_RT(celcius),...
% SECC(m),PSAL_BS(psu),OXY_**(mL/L),CHL_**(ug/L),PHA_**(ug/L),POC_**(umol/L),...
% PON_**(umol/L),NO3_**(umol/L),NO2_**(umol/L),PO4_**(umol/L),Si_**(umol/L),...
% NH4_**(umol/L),Uree_**(umol/L)
%
%Bottle data in the TXT are identified as CTD data, LABO data ou TERRAIN data.
%
%M-files required: data_btl

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2000; Last revision: 27-Jun-2000 CL

%Modifications:
% -La fonction tient compte des QQQQ pour toutes les variables pour
% les options 'deph' et 'cntr'
% CL, 15-sep-2009

%nargin
if nargin==2
   LABO=[];
   optoxy='upcast';
elseif nargin==3
   optoxy='upcast';
end

opt=lower(opt);
%Possible opt
if isempty(strmatch(opt,{'cntr','deph','fbtl'}))
   error('Unknown option')
end

%Reads unique_no.txt if present
uni=dir('unique_no.txt');
if isempty(uni)
   uni=dir('uniqueno.txt');
end
if ~isempty(uni)
    disp('Reading unique_no.txt ....')
    U=[];
    [U.sample,U.file,U.deph]=textread('unique_no.txt','%f %s %f');
else
   disp('No unique_no.txt found.')
   disp('Links will be made with filename and pressure depth.');
   U=[];
end

%Reads btlscan.txt if present
btl=dir('btlscan.txt');
if ~isempty(btl)
	disp('Reading btlscan.txt ....') 
    N=[];
    [N.sample,N.file,N.deph,N.startscan,N.endscan]=textread('btlscan.txt','%f %s %f %f %f');
	N.startscan(N.startscan==-99)=nan;
	N.endscan(N.endscan==-99)=nan;
	N.deph(N.deph==-99)=nan;
else
   switch opt
   case 'cntr'
      error(['No btlscan.txt found. You need this file to use ''cntr'' option']);
   case 'deph'    
      error(['No btlscan.txt found. You need this file to use ''deph'' option']);
   end
end

%if isempty(strmatch('fbtl',opt))

%Split profile
switch opt
case 'deph'
	S=split_odf(S,1);   
case 'cntr'
   %H=split_odf(S,1);
case 'fbtl'
   disp('Reading BTL-files ....')
   B=create_S('btl','sbe_btl');
end

%Create STD structure
Q=create_std(S,'inconnu_10');
other_var = {'cntr','cndc','flor','doxy','tran','psar','spar','cdom','phph'};
for i=1:size(Q,2)
    for j=1:size(other_var,2)
        Q(i).(other_var{j}) = getvalue(S(i),[upper(other_var{j}) '_01']);
        code = fieldnames(S(i).Data);
        I=strmatch([upper(other_var{j}) '_01'],code);
        if ~isempty(I) & I~=length(code) & strmatch('QQQQ',code{I+1})
           QQQQ = getvalue(S(i),char(code(I+1)));
           QQQQ = QQQQ==1 | QQQQ==0 | QQQQ==5;
           Q(i).(other_var{j})(~QQQQ)=nan;
        end
    end
end

%Initialize CTD
CTD.filename={};
CTD.station={};
CTD.lat=[];
CTD.lon=[];
CTD.sample=[];
CTD.zbouteille=[];
CTD.date={};
CTD.time={};
CTD.data=[];

%Sort files according to btlscan.txt
switch opt
case 'fbtl' 
   [file{1:size(B,2)}]=deal(B.filename);
otherwise
 	[Bfiles,K]=unique(N.file);
	Bfiles=N.file(sort(K));
    for i=1:size(Q,2)
        Qfiles{i}=Q(i).filename(1:end-4);
    end
	I=[];
	for i=1:length(Bfiles)
 	  J=strmatchi(Bfiles{i},Qfiles,'exact');
	  I=[I J];
	end
	Q=Q(I);
	S=S(I);
end

%If no quality flag, then set them to 1
I=strmatchi('QCFF',fieldnames(Q));
if isempty(I)
   switch opt
   case 'deph'
      Q=setQto1(Q,'flag');
   case 'cntr'
      Q=setQto1(Q,'none');
   end
end

%CTD header
data_btl
h1={'CTD','CTD','CTD','CTD','CTD','CTD','CTD','CTD',...
      'CTD','CTD','CTD','CTD','CTD','CTD','CTD','CTD'};
h2={'Fichier','Station','Latitude','Longitude','Echantillon','zbouteille','Date','Heure',...
      'CNTR','nCNTR','PRES','PRES_SDEV','TE90','TE90_SDEV','PSAL','SIGT'};
h3={'nom','nom/no','degres','degres','no_unique','dbar','jj-mmm-yyyy','GMT',...
      'scan','nombre_scan','dbar','dbar','celsius','celsius','psu','kg/m**3'};
h4={'%s','%s','%.5f','%.5f','%.0f','%.1f','%s','%s',...
      '%.0f','%.0f','%.1f','%.2f','%.2f','%.3f','%.2f','%.2f'};
other={'FLOR','DOXY','TRAN','PSAR','SPAR','CDOM','PHPH'};
for i=1:length(other)
  if eval(['~isempty(cat(1,Q.' lower(other{i}) '))'])
      II=strmatchi(other{i},key.code,'exact');
      %if other{i}=='PSAR', II=strmatchi('PAR',key.code); end
      h1{end+1}='CTD';
      h2{end+1}=btlLIST(II).code;
      h3{end+1}=btlLIST(II).units;
      h4{end+1}=['%.' num2str(btlLIST(II).decimal) 'f'];
  end
end      

%Extract BTL data (loop over all files)
disp('Extracting BTL data ....')
for i=1:size(Q,2) 
	A=nan_doubtful(Q(i));
   if opt=='fbtl' 
   	I=strmatchi([A.filename(1:end-4) '.btl'],file,'exact');
      disp([A.filename ' - ' char(file{I})])
      if isempty(I), disp(['No ' A.filename(1:end-4) '.btl found. Check filenames']), end
   else
      I=strmatchi(A.filename(1:end-4),N.file,'exact');
   end

   J=[];
   if ~isempty(U)
      J=strmatchi(A.filename(1:end-4),cat(1,U.file),'exact');
      if isempty(J)
         disp(['!warning : No unique number for file ' A.filename])
      end
   end
   
   if ~isempty(I)
      
   %Mean of found data
   switch opt
   case 'fbtl'
      BTL=B(I).btl;
      %print to file
      for k=size(BTL.data.PRES_01,1):-1:1
      %filename
		CTD.filename{end+1,1}=A.filename(1:end-4);
      %station
      II=strmatchi('Station',S(i).Event_Header.Event_Comments{1});
      if ~isempty(II)
         [a,b]=strtok(char(S(i).Event_Header.Event_Comments{1}));
      	CTD.station{end+1,1}=b(2:end);
      else
         CTD.station{end+1,1}=A.station;
      end
      %latitude,longitude
      CTD.lat(end+1,1)=A.lat;
      CTD.lon(end+1,1)=A.lon;
      
      %sample
      uniq=[-99];
      if isempty(J)
         CTD.sample(end+1,1)=size(BTL.data.PRES_01,1)+1-k;
         uniq=[-99];
      else
     	%if size(BTL.data.PRES_01,1)~=size(U.deph(J),2)
       	%if k==1, disp(['!!! WARNING !!! Incorrect number of bottle in ' B(I).filename ' : association by depth']), end
         samp=find(U.deph(J)>BTL.data.PRES_01(k,1)-3 & U.deph(J)<BTL.data.PRES_01(k,1)+3);
         uniq=U.sample(J(samp));
         if length(uniq)>1
           	uniq=uniq(uniq>999);
            if length(uniq)>1
            	samp=find(abs(U.deph(J)-BTL.data.PRES_01(k,1))==min(abs(U.deph(J)-BTL.data.PRES_01(k,1))));
              	uniq=U.sample(J(samp));
            elseif isempty(uniq)
               uniq=[-99];
            end
         elseif isempty(uniq)
            uniq=-99;
         end
		%else
      %   uniq=U.sample(J(size(BTL.data.PRES_01,1)+1-k));
      %end
      if length(uniq)>1
          o=1;
          while ~isempty(intersect(uniq(o),CTD.sample));
              o=o+1;
          end
          disp(['Unique = ' num2str(uniq(1)) ' and ' num2str(uniq(2))])
          uniq = uniq(o);
      end
% 	  try,
 		CTD.sample(end+1,1)=uniq;
%       catch,
%          error(['Unique = ' num2str(uniq(1)) ' and ' num2str(uniq(2))])
%       end
         
      if length(CTD.sample)>unique(CTD.sample);
         CTD.sample(end,1)=-99;
      end
      end
      %zbouteille
      CTD.zbouteille(end+1,1)=BTL.data.PRES_01(k,1);
      %Date,Heure
      CTD.date{end+1,1}=datestr(A.time,1);
      CTD.time{end+1,1}=datestr(A.time,13);
      %CNTR
      CTD.data(end+1,1)=BTL.data.CNTR_01(k,1);
      try, CTD.data(end,2)=BTL.data.CNTR_01(k,4)-BTL.data.CNTR_01(k,3);
      catch, CTD.data(end,2)=nan; end
      %PRES
      CTD.data(end,3:4)=[BTL.data.PRES_01(k,1),BTL.data.PRES_01(k,2)];
      %TEMP
      try, CTD.data(end,5:6)=[BTL.data.TE90_01(k,1),BTL.data.TE90_01(k,2)];
      catch,CTD.data(end,5:6)=[BTL.data.TEMP_01(k,1),BTL.data.TEMP_01(k,2)];end
      %PSAL
      CTD.data(end,7)=BTL.data.PSAL_01(k,1);
      %SIGT
      try, CTD.data(end,8)=BTL.data.SIGT_01(k,1);
      catch, CTD.data(end,8)=sw_dens(CTD.data(end,7),CTD.data(end,5),0)-1000; end
      %FLOR
      if ~isempty(strmatchi('flor',h2))
      	try, CTD.data(end,strmatchi('flor',h2)-8)=BTL.data.FLOR_01(k,1);
      	catch, CTD.data(end,strmatchi('flor',h2)-8)=nan; end
      end
      %DOXY
      if ~isempty(strmatchi('doxy',h2))
      switch optoxy
      case 'downcast'
        %oxygen from downcast
        try
            K=find(A.pres>BTL.data.PRES_01(k,1)-1.0 & A.pres<BTL.data.PRES_01(k,1)+1.0);
        	if ~isempty(K), CTD.data(end,strmatchi('doxy',h2)-8)=nanmean(A.doxy(K));
            else, datestr('1'); end
        catch
        	CTD.data(end,strmatchi('doxy',h2)-8)=nan;
        end
      case 'upcast'
        %oxygen from BTL-file data
      	try, CTD.data(end,strmatchi('doxy',h2)-8)=BTL.data.DOXY_01(k,1);
      	catch, CTD.data(end,strmatchi('doxy',h2)-8)=nan; end	
      end
      end
      %TRAN
      if ~isempty(strmatchi('tran',h2))
      	try, CTD.data(end,strmatchi('tran',h2)-8)=BTL.data.TRAN_01(k,1);
      	catch, CTD.data(end,strmatchi('tran',h2)-8)=nan; end	
      end
      %PSAR
      if ~isempty(strmatchi('psar',h2))
      	try, CTD.data(end,strmatchi('psar',h2)-8)=BTL.data.PSAR_01(k,1);
      	catch, CTD.data(end,strmatchi('psar',h2)-8)=nan;	end	
      end
      %SPAR
      if ~isempty(strmatchi('spar',h2))
      	try, CTD.data(end,strmatchi('spar',h2)-8)=BTL.data.SPAR_01(k,1);
      	catch, CTD.data(end,strmatchi('spar',h2)-8)=nan;	end	
      end

      %CDOM
      if ~isempty(strmatchi('cdom',h2))
      	try, CTD.data(end,strmatchi('cdom',h2)-8)=BTL.data.CDOM_01(k,1);
      	catch, CTD.data(end,strmatchi('cdom',h2)-8)=nan;	end	
      end
      
      %PHPH
      if ~isempty(strmatchi('phph',h2))
      	try, CTD.data(end,strmatchi('phph',h2)-8)=BTL.data.PHPH_01(k,1);
      	catch, CTD.data(end,strmatchi('phph',h2)-8)=nan;	end	
      end
     
   end
   %opt 'deph' and 'cntr'
   otherwise
      disp([A.filename ' ........'])  
		for j=1:length(I)
      %Data according 'deph' or 'cntr'
      switch opt
      case 'deph'
        	L=find(Q(i).pres>N.deph(I(j))-1.0 & Q(i).pres<N.deph(I(j))+1.0);
      case 'cntr'
        	N.startscan(I(j)); N.endscan(I(j));
        	L=find(A.cntr>=N.startscan(I(j)) & A.cntr<=N.endscan(I(j)));
        	if isempty(L) & N.startscan(I(j))>min(A.cntr) & N.endscan(I(j))<max(A.cntr)
        	  	sc=mean([N.startscan(I(j)) N.endscan(I(j))]);
        	 	dsc=abs(A.cntr-sc);
        	 	L=find(dsc==min(dsc));
            end
      	    if isempty(L)
         	SS=split_odf(S(i),1); %downcast selected
         	Z=create_std(SS,'inconnu_10');
            Z.cntr=getvalue(SS,'CNTR_01');
            Z.cndc=getvalue(SS,'CNDC_01');
  	        Z.flor=getvalue(SS,'FLOR_01');
  	        Z.doxy=getvalue(SS,'DOXY_01');
  	        Z.tran=getvalue(SS,'TRAN_01');
  	        Z.psar=getvalue(SS,'PSAR_01');
            Z.spar=getvalue(SS,'SPAR_01');
            Z.cdom=getvalue(SS,'CDOM_01');
            Z.phph=getvalue(SS,'PHPH_01');
            Z.comments=getvalue(SS,'Event_Comments');  
         	Z=setQto1(Z,'flag');
            Z=nan_doubtful(Z);
            A=Z;
         	L=find(A.pres>N.deph(I(j))-1.0 & A.pres<N.deph(I(j))+1.0);
         	disp(['CNTR=' num2str(N.startscan(I(j))) ' not found in ' ...
               A.filename(1:end-4) ' -> Pressure depth used instead'])
            end
       end  
        
      %filename,latitude,longitude,sample,nominalZ,date,time
      CTD.filename{end+1,1}=A.filename(1:end-4);
      %station
      II=strmatchi('Station',S(i).Event_Header.Event_Comments{1});
      if ~isempty(II)
         [a,b]=strtok(char(S(i).Event_Header.Event_Comments{1}));
         CTD.station{end+1,1}=b(2:end);
      else
         CTD.station{end+1,1}=A.station;
      end
      CTD.lat(end+1,1)=A.lat;
      CTD.lon(end+1,1)=A.lon;
      %sample
      if isempty(U) | isempty(J)
 			CTD.sample(end+1,1)=N.sample(I(j));
         uniq=[-99];
      else
         samp=find(U.deph(J)>N.deph(I(j))-3 & U.deph(J)<N.deph(I(j))+3);
         uniq=U.sample(J(samp));
         if length(uniq)>1
            uniq=uniq(uniq>999);
            if length(uniq)>1
            	samp=find(abs((U.deph(J)-N.deph(I(j))))==min(abs(U.deph(J)-N.deph(I(j)))));
               uniq=U.sample(J(samp));
            elseif isempty(uniq)
               uniq=[-9];
            end
         end
        
         if isempty(uniq), uniq=[-99]; end
         CTD.sample(end+1,1)=uniq;
         
      end
     	CTD.zbouteille(end+1,1)=N.deph(I(j));
      CTD.date{end+1,1}=datestr(A.time,1);
      CTD.time{end+1,1}=datestr(A.time,13);
      if ~isempty(L)
      	%check if nanmean(A.pres(L)) lies close to N.deph(I(j))
      	dp=abs(nanmean(A.pres(L))-N.deph(I(j)));
      	if dp>5
        		disp([A.filename ': depth found is ' num2str(nanmean(A.pres(L))) ...
               ' m ; depth expected is ' num2str(N.deph(I(j))) ' m']);
      	end	
       
        %print to file
        if isempty(A.cntr)
           A.cntr=[1:length(A.pres)]';
        end
        CTD.data(end+1,1:2)=[floor(mean(A.cntr(L))),length(A.cntr(L))];
      	CTD.data(end,3:4)=[nanmean(A.pres(L)),nanstd(A.pres(L))];
      	CTD.data(end,5:6)=[nanmean(sw_t90(A.temp(L))),nanstd(sw_t90(A.temp(L)))];
      	CTD.data(end,7:8)=[nanmean(A.psal(L)),nanmean(A.sigt(L))];
         if ~isempty(strmatchi('flor',h2))
            try, CTD.data(end,strmatchi('flor',h2)-8)=nanmean(A.flor(L));
            catch, CTD.data(end,strmatchi('flor',h2)-8)=nan; end
         end
         if ~isempty(strmatchi('doxy',h2))
            O=find(A.pres==max(A.pres));
            LO2=find(A.pres(1:O)>=nanmean(A.pres(L))-1 & A.pres(1:O)<=nanmean(A.pres(L))+1);
   			try, CTD.data(end,strmatchi('doxy',h2)-8)=nanmean(A.doxy(LO2));
            catch, CTD.data(end,strmatchi('doxy',h2)-8)=nan; end
         end
         if ~isempty(strmatchi('tran',h2))
            try, CTD.data(end,strmatchi('tran',h2)-8)=nanmean(A.tran(L));
            catch, CTD.data(end,strmatchi('tran',h2)-8)=nan; end
     		end
         if ~isempty(strmatchi('psar',h2))
      	   try, CTD.data(end,strmatchi('psar',h2)-8)=nanmean(A.psar(L));
            catch, CTD.data(end,strmatchi('psar',h2)-8)=nan; end
         end
         if ~isempty(strmatchi('spar',h2))
      	   try, CTD.data(end,strmatchi('spar',h2)-8)=nanmean(A.spar(L));
            catch, CTD.data(end,strmatchi('spar',h2)-8)=nan; end
         end
         if ~isempty(strmatchi('cdom',h2))
      	   try, CTD.data(end,strmatchi('cdom',h2)-8)=nanmean(A.cdom(L));
            catch, CTD.data(end,strmatchi('cdom',h2)-8)=nan; end
         end
         if ~isempty(strmatchi('phph',h2))
      	   try, CTD.data(end,strmatchi('phph',h2)-8)=nanmean(A.phph(L));
            catch, CTD.data(end,strmatchi('phph',h2)-8)=nan; end
         end
         
     else
         CTD.data(end+1,:)=repmat(nan,1,length(h2)-8);
      end
      end
   end
	end
end

% Unique sample number
[t,Isample] = unique(CTD.sample);
I99 = find(CTD.sample==-99);
Idata = union(Isample,I99);
CTD.filename=CTD.filename(Idata);
CTD.station=CTD.station(Idata);
CTD.lat=CTD.lat(Idata);
CTD.lon=CTD.lon(Idata);
CTD.sample=CTD.sample(Idata);
CTD.zbouteille=CTD.zbouteille(Idata);
CTD.date=CTD.date(Idata);
CTD.time=CTD.time(Idata);
CTD.data=CTD.data(Idata,:);

%Labo data
%unique number
if ~isempty(LABO)
l=size(CTD.data,2);
CTD.data(:,end+1:end+size(LABO.data,2))=repmat(nan,[size(CTD.data,1) size(LABO.data,2)]);
if ~isempty(U)
   [C,IA,IB]=intersect(CTD.sample,str2num(char(LABO.sample)));
   CTD.data(IA,l+1:end)=LABO.data(IB,:);
   [C,IA]=setdiff(1:length(LABO.sample),IB);
else
   IA=(1:length(LABO.sample));
end   
LABO.sample=LABO.sample(IA,:);
LABO.filename=LABO.filename(IA,:);
LABO.pres=LABO.pres(IA,:);
LABO.data=LABO.data(IA,:);

%no unique number
if ~isempty(LABO.filename)
   for i=1:size(LABO.filename,1)
      J=strmatchi(LABO.filename{i},CTD.filename,'exact');
      if isempty(J)
         disp(['!!!! WARNING: no match CTD data for ' LABO.sample{i} ' ' LABO.filename{i} ' ' num2str(LABO.pres(i))])
      else
         samp=find(CTD.zbouteille(J)>LABO.pres(i)-20 & CTD.zbouteille(J)<LABO.pres(i)+20);
         if isempty(samp)
         	disp(['!!!! WARNING: no match CTD data for ' LABO.sample{i} ' ' LABO.filename{i} ' ' num2str(LABO.pres(i))])
      	else
            uniq=J(samp);
				if length(uniq)>1
            	samp=find(abs(CTD.zbouteille(J)-LABO.pres(i))==min(abs(CTD.zbouteille(J)-LABO.pres(i))));
               samp=samp(1);
               uniq=J(samp);  
            end
            if ~isnan(nanmean(CTD.data(uniq,l+1:end)))
         	   disp(['!!!! WARNING: no match CTD data for ' LABO.sample{i} ' ' LABO.filename{i} ' ' num2str(LABO.pres(i))])
            else   
               CTD.data(uniq,l+1:end)=LABO.data(i,:);
               CTD.zbouteille(uniq)=LABO.pres(i,:);
            end
         end   
      end
   end
end

%Header
for i=1:size(LABO.header,2)
   %I=strmatchi(LABO.header{i}(1:3),key.code,'exact');
   I=strmatchi(LABO.header{i}(1:3),key.code);
   if length(I)>1 
       I=strmatchi(LABO.header{i}(1:4),key.code);
       if isempty(I), I=strmatchi(LABO.header{i}(1:3),key.code); end  
   end
   I=I(end);
   h1{end+1}=btlLIST(I).type;
   h2{end+1}=LABO.header{i};
   h3{end+1}=btlLIST(I).units;
   h4{end+1}=['%.' num2str(btlLIST(I).decimal) 'f'];
end  

end %if ~isempty(LABO)

%Complete BTL file with possible labo analysis
[labo_codes{1:size(btlLIST,2)}]=deal(btlLIST.code);
[type{1:size(btlLIST,2)}]=deal(btlLIST.type);
for i=1:length(labo_codes)
   if isempty(strmatch('Q',labo_codes{i})) & isempty(strmatchi(labo_codes{i},h2)) & ...
         isempty(strmatchi('CTD',type{i},'exact')) & isempty(strmatchi('DIL',labo_codes{i}))
      h1{end+1}=btlLIST(i).type;
      switch labo_codes{i}(1:3)
      case 'TEM'
       	h2{end+1}='TEMP_RT';
      case 'SEC'
      	h2{end+1}='SECC';
      case 'PSA'
      	h2{end+1}='PSAL_BS';
      otherwise
      	h2{end+1}=[labo_codes{i} '**'];
      end
      h3{end+1}=btlLIST(i).units;
   end
end

%Output file
cruiseid=char(getvalue(S(1),'Cruise_Number'));
filename=['BTL_' cruiseid(3:end) '.txt'];
fchk = [filename, '*'];
m = dir(fchk);
if ~isempty(m)
   if length(m)>1
      r = zeros(length(m), 1);
      for i = (1:length(m))
         if length(m(i).name) > length(fliplr(strtok(fliplr(filename), '\')))
            r(i) = str2num(fliplr(strtok(fliplr(m(i).name),'.')));
         end
      end
      cc = max(r(i))+1;
   else
      cc = 1;
   end
   copyfile(filename, [filename, '.', num2str(cc)]);
end

%Open BTL_(cruise_number).txt
fid=fopen(filename,'wt');

%BTL-file header
h{1,1}=h1{1}; h{2,1}=h2{1}; h{3,1}=['(' h3{1} ')'];
for i=2:size(h1,2)
   h{1,1}=[h{1,:} ';' h1{i}];
   h{2,1}=[h{2,1} ';' h2{i}];
   h{3,1}=[h{3,1} ';(' h3{i} ')'];
end
fprintf(fid,'%s\n',h{1});
fprintf(fid,'%s\n',h{2});
fprintf(fid,'%s\n',h{3});
for i=1:size(CTD.data,1)
   fprintf(fid,'%s;%s;',CTD.filename{i},CTD.station{i});
   fprintf(fid,'%.5f;%.5f;',CTD.lat(i),CTD.lon(i));
   fprintf(fid,'%.0f;%.1f;',CTD.sample(i),CTD.zbouteille(i));
   fprintf(fid,'%s;%s',CTD.date{i},CTD.time{i});
   for j=1:size(CTD.data,2)
      fprintf(fid,[';' h4{j+8}],CTD.data(i,j));
   end
   fprintf(fid,'\n');
end

disp(['BTL-file: ' filename ' created'])
%Close BTL-file
fclose(fid);


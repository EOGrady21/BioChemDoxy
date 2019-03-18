function T=B_stage3_Q(T,testno)
%B_STAGE3_Q - Stage 3 of bottle quality control tests (Climatology Tests)
%
%Syntax:  S = B_STAGE3_Q(S,testno)
% T is the bottle-structure with quality control flags included (size(T)=[1 1]).
% testno available
%  35: TS Monthly Climatology (TEMP, PSAL, SIGT)
%  36: Nutrients WOA2009 Mountly Climatology (NTRA, PHOS, SLCA)(2048)
%
% Quality control test names are added to the structure field 'history'.
% Quality control test problems are reported on line and in 
% state_(cruise_number).txt file.
%
%Toolbox required: Seawater
%M-files required: B_nan_doubtful, in_petrie_box
%MAT-files requires: B_stage3_Q
%
%References: 
%   Unesco (1990) GSTPP Real-Time Quality Control Manual, 
%           Intergouvernmental Oceanographic Commission, Manuals 
%           and Guides, vol 22, SC/90/WS-74: 121 p.
%   Petrie, B., A. Drinkwater, A. Sandstrom, R. Pettipas, D. Gregory, D.
%           Gilbert and P. Sekhon. 1996. Temperature, salinity and sigmt-t 
%           atlas for the Gulf of St.Lawrence. Can. Tech. Rep. Hydrogr. 
%           Ocean Sci. 178, v+256pp.
%   WOA2009 : http://www.nodc.noaa.gov/OC5/WOA09/pubwoa09.html

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 04-Feb-2004 CL
%
% Modifications:
% - Changes made to qualify Newfoundland data
% CL, 12-May-2011

% Modified by Gordana Lazin, March 30, 2016
% Comment all fields fith sigt because BIO climatology does not include SIGMAT.

%Open state file
fid=fopen(['B_state_' T.cruiseid '.txt'],'a');

%Open QC_data file
fid_data=fopen(['QC_data_' T.cruiseid '.txt'],'a');

%Load stage3_Q
load B_stage3_Q_BIO

if ~isfield(test35,'P')
    load Petrie
    test35.P=P;
end

%circle équation
x=[];y=[];for i=0:0.1:10,x=[x;i];y=[y;sqrt(100-i^2)];end
x=[x; flipud(x); -x; -flipud(x)]*1.5; x=x/60;
y=[y; -flipud(y); -y; flipud(y)]; y=y/60;

%Switch 
switch testno

%------------------------------------------------------- 
%Test 3.5: TS Monthly Climatology (TEMP, PSAL, SIGT)
%------------------------------------------------------- 
case 35
 dz=[5;5;5;5;5;5;10;10;10;10;25;25;25;25;25;25];
 PN=test35.P;
 box=in_petrie_box(T.lat,T.lon,PN);	%in Box
 J=[]; K=[];
 if isempty(box)
    for i=1:length(x)
       b=in_petrie_box(T.lat+y(i),T.lon+x(i),PN);	%in Box
       if ~isempty(b), box=[box b(1)]; end    
    end
    box=unique(box);
    if isempty(box)
      disp([' Test 3.5 -> Profile outside TS Monthly Climatology polygons']) 
      fprintf(fid,[T.filename ': Test 3.6 -> Profile ' T.filename ' outside TS Monthly Climatology polygons\r\n']); 
    else
      disp([' Test 3.5 -> Profile slightly outside TS Monthly Climatology polygons; Test performed with the closest boxes']) 
      fprintf(fid,[T.filename ': Test 3.5 -> Profile ' T.filename ' slightly outside TS Monthly Climatology polygons; Test performed with the closest boxes\r\n']); 
    end
 end     

 if ~isempty(box)
    P=PN(cat(1,PN.box)==box(1));
    P.box=num2str(P.box);
    if length(PN(1).deph)>length(P.deph)
       P.deph=PN(1).deph;
    end
    l2=length(P.deph);
    ll=size(P.temp,1);
    P.temp(ll:l2,:)=nan;
    P.temp_std(ll:l2,:)=nan;
    P.psal(ll:l2,:)=nan;
    P.psal_std(ll:l2,:)=nan;
    %P.sigt(ll:l2,:)=nan;
    %P.sigt_std(ll:l2,:)=nan;
    for i=2:length(box); 
       I_box=find(cat(1,PN.box)==box(i)); 
       P.box = [P.box ', ' num2str(PN(I_box).box)];
       for j=1:size(P.temp,2)
          ll = size(PN(I_box).temp,1);
     %     P.temp(1:ll,j) = nanmean([P.temp(1:ll,j) PN(I_box).temp(1:ll,j)],2);
      %    P.temp_std(1:ll,j) = nanmax([P.temp_std(1:ll,j) PN(I_box).temp_std(1:ll,j)],[],2);
        %  P.psal(1:ll,j) = nanmean([P.psal(1:ll,j) PN(I_box).psal(1:ll,j)],2);
         % P.psal_std(1:ll,j) = nanmax([P.psal_std(1:ll,j) PN(I_box).psal_std(1:ll,j)],[],2);
%          P.sigt(1:ll,j) = nanmean([P.sigt(1:ll,j) PN(I_box).sigt(1:ll,j)],2);
%          P.sigt_std(1:ll,j) = nanmax([P.sigt_std(1:ll,j) PN(I_box).sigt_std(1:ll,j)],[],2);
       end
    end

    %Means by depths
    for j=1:size(test35.name,1)
	   Tn=B_nan_doubtful(T);
       par=eval(['Tn.' test35.name{j}]);
       if ~isnan(nanmean(nanmean(par)))
       pari=repmat(nan,length(P.deph),size(par,2));
       for k=1:length(P.deph)
          I=find(Tn.deph>=P.deph(k)-dz(k) & Tn.deph<=P.deph(k)+dz(k));
         if ~isempty(I), pari(k,:)=nanmean(par(I,:),1); end, % original
         %if ~isempty(I), pari(k,:)=nanmean(par(I,:)); end, % mod by Gordana
         
       end
       month=datestr(Tn.time,5);
       par_climato=eval(['P.' test35.name{j} '(:,' month ')']);
       par_climato=par_climato*ones(1,size(par,2));
       parstd_climato=eval(['P.' test35.name{j} '_std(:,' month ')']);
       dpar=abs(pari-par_climato);
       for k=1:size(dpar,1)
          par_std=[eval(['P.' test35.name{j} '_std(k,' month ')'])];
          J=find(dpar(k,:)>max(par_std)*3);
          if ~isempty(J);
             disp([' Test 3.5 -> ' test35.name{j} ' in box(es) ' P.box ' is out of TS Climatology by more than 3*std at ' num2str(P.deph(k),'%.1f') ' m'])
             fprintf(fid,[Tn.filename ': Test 3.5 -> ' test35.name{j} ' in box(es) ' P.box ' is out of TS Climatology by more than 3*std at ' num2str(P.deph(k),'%.1f') ' m\r\n']);
             form=['%s; %s; %.0f; %s; ' repmat('%.2f  ',1,length(J)) '; %s\r\n'];
             fprintf(fid_data,form,T.filename,[num2str(P.deph(k)-dz(k),'%3.0f') ' to ' num2str(P.deph(k)+dz(k),'%3.0f') ' m'],NaN,test35.name{j},pari(k,J),['Out of TS Climatology by more than 3*std in box(es) ' P.box ' (' num2str(par_climato(k),'%.2f') ' ± ' num2str(parstd_climato(k)*3,'%.2f') ')']);
             K=[K; J(:)];    
          end
       end
       end
    end
 end
 if isempty(K), disp(' Test 3.5 ok'), end
 T.history{length(T.history)+1,1}=test35.history;      
    
%------------------------------------------------------- 
%Test 3.6: Monthly Nutrient Climatology (NTRA, PHOS, SLCA)
%------------------------------------------------------- 
case 36 
 %test
 PN=test36.PN;
 box=in_petrie_box(T.lat,T.lon,PN);	%in Box
 J=[]; K=[];
 if isempty(box)
    for i=1:length(x)
       b=in_petrie_box(T.lat+y(i),T.lon+x(i),PN);	%in Box
       if ~isempty(b), box=[box b]; end    
    end
    box=unique(box);
    if isempty(box)
      disp([' Test 3.6 -> Profile outside Monthly Nutrient Climatology polygons']) 
      fprintf(fid,[T.filename ': Test 3.6 -> Profile ' T.filename ' outside Monthly Nutrient Climatology polygons\r\n']); 
    else
      disp([' Test 3.6 -> Profile slightly outside Monthly Nutrient Climatology polygons; Test performed with the closest boxes']) 
      fprintf(fid,[T.filename ': Test 3.6 -> Profile ' T.filename ' slightly outside Monthly Nutrient Climatology polygons; Test performed with the closest boxes\r\n']); 
    end
 end     
 
 if ~isempty(box)
    P=PN(cat(1,PN.box)==box(1));
    P.box=num2str(P.box);
    for i=2:length(box); 
       I_box=find(cat(1,PN.box)==box(i));
       P.box = [P.box ', ' num2str(PN(I_box).box)];
       for j=1:size(P.ntrz_min,2)
          P.ntrz_min(:,j) = min([P.ntrz_min(:,j) PN(I_box).ntrz_min(:,j)],[],2);
          P.ntrz_max(:,j) = max([P.ntrz_max(:,j) PN(I_box).ntrz_max(:,j)],[],2);
          P.ntrz_no(:,j) = P.ntrz_no(:,j)+PN(I_box).ntrz_no(:,j);
          P.phos_min(:,j) = min([P.phos_min(:,j) PN(I_box).phos_min(:,j)],[],2);
          P.phos_max(:,j) = max([P.phos_max(:,j) PN(I_box).phos_max(:,j)],[],2);
          P.phos_no(:,j) = P.phos_no(:,j)+PN(I_box).phos_no(:,j);
          P.slca_min(:,j) = min([P.slca_min(:,j) PN(I_box).slca_min(:,j)],[],2);
          P.slca_max(:,j) = max([P.slca_max(:,j) PN(I_box).slca_max(:,j)],[],2);
          P.slca_no(:,j) = P.slca_no(:,j)+PN(I_box).slca_no(:,j);
       end
    end
     
    %By depths
    for j=1:size(test36.name,1)
	   Tn=B_nan_doubtful(T);
       par=eval(['Tn.' test36.name{j}]);
       
       if ~isnan(nanmean(nanmean(par)))
       for i=1:size(par,1)
           I=find(P.mindeph<=Tn.deph(i) & P.maxdeph>=Tn.deph(i));
           month=datestr(Tn.time,5);
           par_climato_min=eval(['P.' test36.name{j} '_min(I,' month ')']);
           par_climato_max=eval(['P.' test36.name{j} '_max(I,' month ')']);
           par_climato_no =eval(['P.' test36.name{j} '_no(I,' month ')']);
           J=find(par(i,:)<par_climato_min | par(i,:)>par_climato_max);
           if ~isempty(J);
             disp([' Test 3.6 -> ' test36.name{j} ' in box(es) ' P.box ' is out of Nutrient Climatology at ' num2str(Tn.pres(i),'%.1f') ' m'])
             fprintf(fid,[Tn.filename ': Test 3.6 -> ' test36.name{j} ' in box(es) ' P.box ' is out of Nutrient Climatology at ' num2str(Tn.pres(i),'%.1f') ' m\r\n']);
             eval(['T.Q' test36.name{j} '(i,J)=2;'])
             form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,length(J)) '; %s\r\n'];
             fprintf(fid_data,form,T.filename,Tn.pres(i),T.uniqueno(i),test36.name{j},par(i,J),['Out of Nutrient Climatology in box(es) ' P.box ' (Min=' num2str(par_climato_min,'%.2f') ' Max=' num2str(par_climato_max,'%.2f') ' n=' num2str(par_climato_no,'%.0f') ')']);
             K=[K; i];    
           end
       end
       end
    end
 end
 if isempty(K), disp(' Test 3.6 ok'),
 else, T.QCFF(unique(K))=T.QCFF(unique(K))+2^11; end   
 T.history{length(T.history)+1,1}=test36.history;      
	         
%-------------------
%Unknown Test Number
%-------------------
otherwise
 disp([' Unknown Test Number: ' num2str(testno)])
 
end  %(swicth cases)

%Close state file
fclose(fid);

%Close QC_data file
fclose(fid_data);



   
   
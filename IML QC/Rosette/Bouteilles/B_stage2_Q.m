function T=B_stage2_Q(T,testno)
%B_STAGE2_Q - Stage 2 of bottle quality control tests (Profile Tests)
%
%Syntax:  T = B_STAGE2_Q(T,testno)
% T is the bottle-structure with quality control flags included (size(T)=[1 1]).
%
% testno available
%  21: Global Impossible Parameter Values (2)
%  22: Regional Impossible Parameter Values (4)
%  23: Increasing Depth (8)
%  24: Profile Envelope (16)
%  25: Constant Profile (32)
%  26: Freezing Point (64)
%  27: Replicate Comparisons (TEMP, PSAL, DOXY, CPHL, NTRZ, NTRI, PHOS, SLCA) (128)
%  28: Bottle versus CTD Measurements (TEMP, PSAL, DOXY) (256)
%  29: Excessive Gradient or Inversion in Temperature, Salinity, Nitrate and Phosphate (512)
% 210: Surface Dissolved Oxygen Data versus Percent Saturation (1024)
%
% Quality control test names are added to the structure field 'history'.
% A QCFF (Quality Control Flag Index) is attributed to every data of the
% profile for each test done. 
% Quality control test problems are reported on line and in 
% state_(cruise_number).txt file.
%
%Toolbox required: Seawater
%M-files required: B_nan_erroneous, B_nan_doubtful
%MAT-files required: B_stage2_Q
%
%Reference: Unesco (1990) GSTPP Real-Time Quality Control Manual, 
%           Intergouvernmental Oceanographic Commission, Manuals 
%           and Guides, vol 22, SC/90/WS-74: 121 p.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 28-Jan-2004 CL

%Load stage2_Q
load B_stage2_Q

%Open state file
fid=fopen(['B_state_' T.cruiseid '.txt'],'a');

%Open QC_data file
fid_data=fopen(['QC_data_' T.cruiseid '.txt'],'a');

%Switch 
switch testno
      
%--------------------------------------------
%Test 2.1: Global Impossible Parameter Values
%--------------------------------------------
case 21
 names=fieldnames(T);
 K=[];  
 for j=1:size(test21.name)
    I=strmatch(test21.name{j},names);
    if ~isempty(I)
       par=eval(['T.' test21.name{j}]);
       for i=1:size(par,1)
         I=find(par(i,:)<test21.minvalue(j) | par(i,:)>test21.maxvalue(j));
         if ~isempty(I)
           disp([' Test 2.1 -> Global Impossible Parameter Value for ' test21.name{j}])
           eval(['T.Q' test21.name{j} '(i,I)=4;'])
           K=[K; i];
           fprintf(fid,'%s: Test 2.1 -> Global Impossible Parameter Value for %s\r\n',T.filename,test21.name{j});
           form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,length(I)) '; %s\r\n'];
           fprintf(fid_data,form,T.filename,T.pres(i),T.uniqueno(i),test21.name{j},par(i,I),'Global Impossible Parameter Value');
         end    
       end    
    end
 end
 
 if isempty(K), disp(' Test 2.1 ok')
 else T.QCFF(unique(K))=T.QCFF(unique(K))+2^1; end
 T.history{length(T.history)+1,1}=test21.history;

%----------------------------------------------
%Test 2.2: Regional Impossible Parameter Values
%----------------------------------------------
case 22 
 %Tn=B_nan_erroneous(T);
 Tn=T;
 names=fieldnames(Tn);
 K=[];

 for j=1:size(test22.name,1)
    I=strmatch(test22.name{j},names);
    if ~isempty(I)
       par=eval(['Tn.' test22.name{j}]);
       for i=1:size(par,1)
         I=find(par(i,:)<test22.minvalue(j) | par(i,:)>test22.maxvalue(j));
         if ~isempty(I)
           disp([' Test 2.2 -> Regional Impossible Parameter Value for ' test21.name{j}])
           eval(['T.Q' test22.name{j} '(i,I)=4;'])
           K=[K; i];
           fprintf(fid,'%s: Test 2.2 -> Regional Impossible Parameter Value for %s\r\n',T.filename,test22.name{j});
           form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,length(I)) '; %s\r\n'];
           fprintf(fid_data,form,T.filename,T.pres(i),T.uniqueno(i),test21.name{j},par(i,I),'Regional Impossible Parameter Value');
         end    
       end    
    end
 end
 
 if isempty(K), disp(' Test 2.2 ok')
 else, T.QCFF(unique(K))=T.QCFF(unique(K))+2^2; end
 T.history{length(T.history)+1,1}=test22.history;

%---------------------------
%Test 2.3: Increasing Depth
%---------------------------
case 23
 Tn=B_nan_erroneous(T);
 par=Tn.pres;
 dpar=par(2:end)-par(1:end-1);
 I=find(dpar<0);
 if ~isempty(I), disp(' Test 2.3 -> Decreasing depths found'),
 else,  disp(' Test 2.3 ok'), end
 while ~isempty(I)
    form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,size(par,2)) '; %s\r\n'];
    fprintf(fid_data,form,T.filename,T.pres(I(1)),T.uniqueno(I(1)),'pres',par(I(1),:),'Increasing Depth');
    par(I+1)=par(I);
 	dpar=par(2:end)-par(1:end-1);
    I=find(dpar<0);
 end
 I=find(dpar==0);
 T.Qpres(I+1)=3;
 T.QCFF(I+1)=T.QCFF(I+1)+2^3;
 T.history{length(T.history)+1,1}=test23.history;

%--------------------------
%Test 2.4: Profile Envelope
%--------------------------
case 24
 Tn=B_nan_erroneous(T);   
 names=fieldnames(T);
 [U,J]=unique(test24.name(:,1));
 K=[];
 for j=1:length(J)
    I=strmatch(test24.name{J(j)},names);
    if ~isempty(I)
       I=strmatch(test24.name{J(j)},test24.name);
       d1=test24.prof1(I);
       d2=test24.prof2(I);
       m1=test24.minvalue(I);
       m2=test24.maxvalue(I);
       par=eval(['Tn.' test24.name{J(j)}]);
       if ~isempty(par)
         for i=1:size(par,2)
           for k=1:length(d1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
             minv=par(:,i);
             minv(T.deph<d1(k) | T.deph>d2(k))=nan;
             I=find(minv<m1(k) | minv>m2(k));
             if ~isempty(I)
               disp([' Test 2.4 -> Impossible Parameter Value in Profile for ' test24.name{J(j)}])
               eval(['T.Q' test24.name{J(j)} '(I,i)=3;'])
               K=[K; I(:)];
               form=['%s; %.2f; %.0f; %s; %.2f; %s\r\n'];
               for kk=1:length(I)
                  fprintf(fid_data,form,T.filename,T.pres(I(kk)),T.uniqueno(I(kk)),test24.name{J(j)},par(I(kk),i),'Impossible Parameter Value in Profile');
               end
      	     end
           end
         end
       else
       K=[];
       end
    end
 end
 
 if isempty(K),  disp(' Test 2.4 ok')
 else, T.QCFF(unique(K))=T.QCFF(unique(K))+2^4; end   
 T.history{length(T.history)+1,1}=test24.history;

%--------------------------
%Test 2.5: Constant Profile
%--------------------------
case 25
 K=[];  
 Tn=B_nan_doubtful(T);
 for j=1:size(test25.name,1)
     par=(eval(['Tn.' test25.name{j}]));     
     for i=1:size(par,2) 
       if length(find(isnan(par(:,i))==0))>1 
           pari=par(find(isnan(par(:,i))==0),i);
           U=unique(pari);
           if length(U)==1 & length(pari)>1 
              disp([' Test 2.5 -> Constant profile problem in ' test25.name{j}])
              I=find(par(:,i)==U);
              eval(['T.Q' test25.name{j} '(I,i)=7;'])
    	      K=[K; I(:)];
              form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,1) '; %s\r\n'];
              for kk=1:length(I)
                 fprintf(fid_data,form,T.filename,T.pres(I(kk)),T.uniqueno(I(kk)),test25.name{j},par(I(kk),i),'Constant profile problem');
              end
           end 
       end
    end
 end
 
 if isempty(K), disp(' Test 2.5 ok')
 else T.QCFF(unique(K))=T.QCFF(unique(K))+2^5; end
 T.history{length(T.history)+1,1}=test25.history;
   
%------------------------   
%Test 2.6: Freezing Point
%------------------------   
case 26 
 K=[];  
 Tn=B_nan_doubtful(T);  
 if ~isnan(nanmax(Tn.CTD_psal)) & ~isnan(nanmax(Tn.CTD_pres)) & ~isnan(nanmax(Tn.temp(:,1)))
   fp=sw_fp(Tn.CTD_psal,T.CTD_pres);
   dt=Tn.temp-fp*ones(1,size(Tn.temp,2));
   for i=1:size(dt,1)
      I=find(dt(i,:)<0);
      if ~isempty(I)
         disp([' Test 2.6 -> Data below freezing temperature']);
         T.Qtemp(i,I)=4;
         K=[K; i];
         fprintf(fid,'%s: Test 2.6 -> Data below freezing temperature\r\n',T.filename);
         form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,length(I)) '; %s\r\n'];
         fprintf(fid_data,form,T.filename,T.pres(i),T.uniqueno(i),'temp',Tn.temp(i,I),'Data Below Freezing Temperature');
      end
   end
    
   if isempty(K), disp(' Test 2.6 ok')
   else, T.QCFF(unique(K))=T.QCFF(unique(K))+2^6; end
   T.history{length(T.history)+1,1}=test26.history;
end

%-------------------------------
%Test 2.7: Replicate Comparisons 
%-------------------------------
case 27
 Tn=B_nan_doubtful(T);   
 K=[];  
 for j=1:size(test27.name,1)
    par=eval(['Tn.' test27.name{j}]);
    dpar=[];
    for i=1:size(par,2)-1
        dpar=[dpar par(:,i+1:end)-par(:,i)*ones(1,size(par,2)-i)];
    end
    if size(dpar,2)>1
        dpar=nanmax(abs(dpar'))'; 
    else
        dpar=abs(dpar);
    end
    I=find(dpar>test27.delta(j));
    if ~isempty(I)
       disp([' Test 2.7 -> Duplicate problem in ' test27.name{j}])
       form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,size(par,2)) '; %s\r\n'];
       for k=1:length(I)
          eval(['T.Q' test27.name{j} '(I(k),T.Q' test27.name{j} '(I(k),:)~=9)=7;'])
          fprintf(fid_data,form,T.filename,T.pres(I(k)),T.uniqueno(I(k)),test27.name{j},par(I(k),:),'Duplicate Problem');
       end
       K=[K; I(:)];
    end
 end
 
 if isempty(K), disp(' Test 2.7 ok')
 else, T.QCFF(unique(K))=T.QCFF(unique(K))+2^7; end
 T.history{length(T.history)+1,1}=test27.history;
 
%-----------------------------------------------------------
%Test 2.8: Bottle versus CTD Measurements (TEMP, PSAL, DOXY)
%-----------------------------------------------------------
case 28
 Tn=B_nan_doubtful(T);   
 K=[];  
 for j=1:size(test28.name,1)
    par1=eval(['Tn.' test28.name{j}]);
    par2=eval(['T.CTD_' test28.name{j}]); 
    dpar=[];
    for i=1:size(par1,2)
        dpar=abs(par1(:,i)-par2);
        I=find(dpar>test28.delta(j));
        if ~isempty(I)
           disp([' Test 2.8 -> Bottle-CTD difference problem in ' test28.name{j}])
           eval(['T.Q' test28.name{j} '(I,i)=7;'])
           K=[K; I(:)];
           form=['%s; %.2f; %.0f; %s; %.2f; %s\r\n']; 
           for kk=1:length(I)
              fprintf(fid_data,form,T.filename,T.pres(I(kk)),T.uniqueno(I(kk)),test28.name{j},par1(I(kk),i),'Bottle-CTD Difference Problem');
           end
        end
    end
 end
 
 if isempty(K), disp(' Test 2.8 ok')
 else, T.QCFF(unique(K))=T.QCFF(unique(K))+2^8; end
 T.history{length(T.history)+1,1}=test28.history;

%------------------------------------------------------------------
%Test 2.9: Excessive Gradient or Inversion (TEMP, PSAL, NTRZ, PHOS)
%------------------------------------------------------------------
case 29
 K=[];  
 Tn=B_nan_doubtful(T);
 for j=1:size(test29.name,1)
     %disp(test29.name{j})
     par=(eval(['Tn.' test29.name{j}]));
     allI=(1:size(par,2));
     I=[];
    
     for i=1:size(par,2) 
         if length(find(isnan(par(:,i))==0))>1 
           pari=par(:,i);
           if size(par,2)>1 & ~isempty(find(isnan(pari)==1))
             II=setdiff(allI,i);
             nanmean(par(isnan(pari),II)')';
             pari(isnan(pari))=nanmean(par(isnan(pari),II),2);
           end
	   
           %(V2-V1)/(Z2-Z1)
           J=find(isnan(pari)==0);
           dpar=(pari(J(2:end))-pari(J(1:end-1)))./(Tn.pres(J(2:end))-Tn.pres(J(1:end-1)));
           I=find((dpar<test29.gradients(j,1) | dpar>test29.gradients(j,2)) & isnan(dpar)==0);
           if ~isempty(I);
              J=J(:);
              J=[J(I) J(I+1)];
              form=['%s; %s; %.0f, %.0f; %s; ' repmat('%.2f  ',1,2) '; %s\r\n'];
              for kk=1:size(J,1)
                K=[K; J(kk,:)'];
                eval(['T.Q' test29.name{j} '(J(kk,:)'',i)=7;']);
                fprintf(fid_data,form,T.filename,[num2str(T.pres(J(kk,1)),'%.2f') ' to ' num2str(T.pres(J(kk,2)),'%.2f')],T.uniqueno(J(kk,:)),test29.name{j},par(J(kk,:),i),'Gradient or Inversion too high');
              end
           end
       end
   end
   if ~isempty(I);
      disp([' Test 2.9 -> Gradients or Inversions in ' test29.name{j} ' too high'])
   end
 end
 
 if isempty(K), disp(' Test 2.9 ok')
 else T.QCFF(unique(K))=T.QCFF(unique(K))+2^9; end
 T.history{length(T.history)+1,1}=test29.history;

%-------------------------------------------------------------------
%Test 2.10: Surface Dissolved Oxygene Data versus Percent Saturation
%-------------------------------------------------------------------
case 210
 K=[];  
 Tn=B_nan_doubtful(T);
 par=Tn.doxy;

% if ~isnan(nanmax(Tn.CTD_psal)) & ~isnan(nanmax(Tn.CTD_pres)) & ~isnan(nanmax(Tn.doxy(:,1)))
 % Data between 0 and 10 dbar
 J=find(Tn.pres<=10);
 
 if ~isempty(J)
 pari=par(J,:);
 sat=sw_satO2(Tn.CTD_psal(J),T.CTD_temp(J))*ones(1,size(pari,2));
 
 % %O2
 o2sat=pari./sat.*100;
 for i=1:size(pari,2)
    I=find(o2sat(:,i)<test210.limits(1) | o2sat(:,i)>test210.limits(2));
    if ~isempty(I);
       disp([' Test 2.10 -> Surface dissolved oxygen out of prescribed limits'])
       T.Qdoxy(I,i)=3;
       K=[K; I(:)];   
%       form=['%s; %.2f; %.0f; %s; ' repmat('%.2f  ',1,size(par,2)) '; %s\r\n'];
       form=['%s; %.2f; %.0f; %s; %.2f; %s\r\n'];
       for kk=1:length(I)
          fprintf(fid_data,form,T.filename,T.pres(I(kk)),T.uniqueno(I(kk)),'doxy',par(I(kk),i),'Surface O2 Out of Prescribed Limits');
       end
    end
 end
 end
  
 if isempty(K), disp(' Test 2.10 ok')
 else T.QCFF(unique(K))=T.QCFF(unique(K))+2^10; end
 T.history{length(T.history)+1,1}=test210.history;
 
 %end

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


   
function S=B_addQ2btl(B,Q)
%B_ADDQ2BTL - Adds quality flags to the cell array of bottle data 
%
%Syntax:  S_odf=B_addQ2odf(S_odf,S_std)
%  B is the structure out of B_read_btl_txtfile (B.filename, B.data: cell array of bottle data)
%  Q is the bottle quality control structure with quality flags
%  S is B with the quality flags added or updated 

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 12-Feb-2004 CL

%Modifications:
% - Ajout de la variable pH, alky
% CL, 19-Nov-2009

%Remove QCFF from B.data if present
I=strmatchi('QCFF',B.data(2,:));
if ~isempty(I)
    JJ=setdiff(1:size(B.data,2),I);
    B.data = B.data(:,JJ);
end

%Output=Input
S=B;

%Files
[files{1:size(Q,2)}]=deal(Q.filename);

%Variable codes
for i=1:size(S.data,2);
    %codes{i}=[S.data{1,i} '_' S.data{2,i}];
    codes{i} = S.data{2,i};
end

%Variable names
names_B  = {'TEMP_RT'  ,'SSTP_BK'  ,'PSAL_BS','SSAL_BS','SIGT_0','OXY_0','OXYM_0','CHL_0','NO2_0','NO3_0','NOX_0','PO4_0','Si_0' ,'pH_0' ,'ALKY_0','QCFF'};  
names_BQ = {'Q_TEMP_RT','Q_SSTP_BK','Q_PSAL' ,'Q_SSAL' ,'Q_SIGT','Q_OXY', 'Q_OXYM', 'Q_CHL','Q_NO2','Q_NO3','Q_NOX','Q_PO4','Q_Si' ,'Q_pH' ,'Q_ALKY','QCFF'};
names_Q  = {'temp'     ,'temp'     ,'psal'   ,'psal'   ,'sigt'  ,'doxy' , 'doxy','cphl' ,'ntri' ,'ntrz' ,'ntrz' ,'phos' ,'slca' ,'phph' ,'alky'  ,'QCFF'};
names_QQ = {'Qtemp'    ,'Qtemp'    ,'Qpsal'  ,'Qpsal'  ,'Qsigt' ,'Qdoxy', 'Qdoxy', 'Qcphl','Qntri','Qntrz','Qntrz','Qphos','Qslca','Qphph','Qalky' ,'QCFF'};

%Find variable tested in Q
for j=1:length(names_Q)
    par = eval(['cat(1,Q.' names_Q{j} ')']);
    mean_Q = nanmean(par(:));
    Qflag(j) = ~isnan(mean_Q);
end

%Add Q columns to B.data cell array
J=strmatchi('CTD',S.data(1,:));
ok=1; 
j=J(end);
S.data(2,:)
while ok
    j=j+1;
    K=strmatchi(S.data{2,j}(1:end-2),names_B);
    if j<size(S.data,2), KQ=strmatchi(S.data{2,j+1},names_BQ); else, KQ=[]; ok=0; end
    if ~isempty(K) & Qflag(K) & isempty(KQ)
        cellQ = [{'labo'};names_BQ(K);{'((none))'};repmat({'0'},size(S.data,1)-3,1)];
        if j<size(S.data,2), S.data = [S.data(:,1:j) cellQ S.data(:,j+1:end)]; end
        if j==size(S.data,2), S.data = [S.data cellQ]; end  
    end
end
K=strmatchi('QCFF',S.data(2,:),'exact');
if isempty(K)
   cellQ = [{'labo'};{'QCFF'};{'((none))'};repmat({'0'},size(S.data,1)-3,1)];
   S.data = [S.data cellQ];
end
K=strmatchi('N_P',S.data(2,:),'exact');
if isempty(K)
   cellQ = [{'calc'};{'N_P'};{'((none))'};repmat({'NaN'},size(S.data,1)-3,1)];
   S.data = [S.data cellQ];
end
K=strmatchi('N_Si',S.data(2,:),'exact');
if isempty(K)
   cellQ = [{'calc'};{'N_Si'};{'((none))'};repmat({'NaN'},size(S.data,1)-3,1)];
   S.data = [S.data cellQ];
end

%Variable codes
for i=1:size(S.data,2);
    %codes{i}=[S.data{1,i} '_' S.data{2,i}];
    codes{i} = S.data{2,i};
    I=strmatchi('NO3',codes{i});
    if ~isempty(I)
        codes{i}(1:3)='NOX';
    end
    I=strmatchi('Q_NO3',codes{i});
    if ~isempty(I)
        codes{i}='Q_NOX';
    end
end

%Unique identifier
I1 = strmatchi('Fichier',S.data(2,:),'exact');
I2 = strmatchi('Echantillon',S.data(2,:),'exact');
I3 = strmatchi('PRES',S.data(2,:),'exact');
for i=1:size(S.data,1)
    Biden{i} = [S.data{i,I1} S.data{i,I2}];
end

%Loop over files
for i=1:size(files,2)
   %disp(files{i})
   
   for j=1:size(Q(i).pres,1)
       Qiden = [files{i} num2str(Q(i).uniqueno(j))];
       K = strmatchi(Qiden,Biden,'exact');
       for k=1:size(names_Q,2)
         Qvar=eval(['Q(i).' names_QQ{k}]);
         if Qflag(k)
             J = strmatchi(names_BQ(k),codes,'exact');
             for jj=1:length(J)
                 %updating Qs
                 switch S.data{K,J(jj)}
                  case {'0','1','NaN','9'}
                      S.data{K,J(jj)}=num2str(Qvar(j,jj));
                  case {'3'}, if Qvar(j,jj)==4, S.data{K,J(jj)}='4'; end
                 end
             end
          else
             %if j==1, disp([files{i} ' : No Q for' names_Q{k}]), end
          end
       end
       ntrz=nanmean(Q(i).ntrz(j,(Q(i).Qntrz(j,:)~=3 & Q(i).Qntrz(j,:)~=4)));
       phos=nanmean(Q(i).phos(j,(Q(i).Qphos(j,:)~=3 & Q(i).Qphos(j,:)~=4)));
       slca=nanmean(Q(i).slca(j,(Q(i).Qslca(j,:)~=3 & Q(i).Qslca(j,:)~=4)));
       phos(phos==0)=nan;
       slca(slca==0)=nan;
       %N:P
       J=strmatchi('N_P',codes,'exact');
       S.data{K,J}=num2str(ntrz/phos,'%.2f');
       %N:Si
       J=strmatchi('N_Si',codes,'exact');
       S.data{K,J}=num2str(ntrz/slca,'%.2f');
   end
   
end

%File with tests performed
fidT = fopen(['QC_Tests_performed.txt'],'wt');
for i=1:size(Q(1).history,1)
    fprintf(fidT,'%s\n',Q(1).history{i});
end
fclose(fidT);
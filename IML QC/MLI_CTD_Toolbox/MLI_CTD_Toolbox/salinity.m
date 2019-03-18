function sal=salinity(Q)
%SALINITY - Salinity validation with salinity bottle measurements
%
%Syntax: sal=salinity(Q)
% Compare STD salinities and AutoSAL salinities
% Q is the STD-structure
% sal is a matrix of       
%  1. Filename
%  2. Pres(db): pressure depth (db)
%  3. AutoSAL: AutoSAL measurement
%  4. CTD_psal: CTD salinity
%  5. AutoSAL-CTD: salinity difference = Autosal measurement - CTD salinity
%  6. Pres_AutoSAL_found: pressure depth of Autosal measurement in CTD file 
%  7. D_Pres: pressure difference = Pres - Pres_AutoSAL_found
%
% The autosal.txt file as the following columns (maximum one header line):
%  1. unique sample number
%  2. filename (without extension)
%  3. pressure depth (db)
%  4. AutoSAL psal
%
% Results are display on line and in TXT-file salinity.txt.
%
%M-files required: nan_doubtful

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2000; Last revision: 20-Jan-2000 CL

%Read autosal.txt file
a=dir('autosal.txt');
if isempty(a)
   disp('No autosal.txt found')
else
   [sample,file,deph,autosal] = textread('autosal.txt','%s %s %f %f','headerlines',1,'endofline','\r\n');      
end
sample=str2num(char(sample));
autosal(autosal==-99)=nan;

%Extract CTD psal
sal=[]; files=[];
for i=1:size(Q,2)
   Q(i)=nan_doubtful(Q(i));
   filename=Q(i).filename(1:end-4);
   I=strmatchi(filename,file,'exact');
  
   for j=1:length(I)
      %at pressure depths
      J=find(Q(i).pres>deph(I(j))-0.5 & Q(i).pres<deph(I(j))+0.5);
      try
         if ~isempty(J)
           J=J(Q(i).Qpsal(J)==1 | Q(i).Qpsal(J)==5);
         end
         if ~isempty(J)
           files{length(files)+1}=char(file{I(j)});
           sal=[sal; sample(I(j)) deph(I(j)) autosal(I(j)) ...
                  mean(Q(i).psal(J)) autosal(I(j))-mean(Q(i).psal(J)) NaN NaN];
      	end  
        if isempty(J)
           files{length(files)+1}=char(file{I(j)});
           sal=[sal; sample(I(j)) deph(I(j)) autosal(I(j)) ...
                  NaN NaN NaN NaN];
        end
            
      catch
			files{length(files)+1}=char(file{I(j)});
 			sal=[sal; sample(I(j)) deph(I(j)) autosal(I(j)) NaN NaN NaN NaN];
      end
       
      %at salinity depths
      try
         J=find(Q(i).psal>autosal(I(j))-0.1 & Q(i).psal<autosal(I(j))+0.1);
         O=Q(i).pres(J);
      	dp=abs(Q(i).pres(J)-deph(I(j)));
			p=O(dp==min(dp));
     		J=find(Q(i).psal>autosal(I(j))-0.1 & Q(i).psal<autosal(I(j))+0.1 ...
         	& Q(i).pres>p(1)-20 & Q(i).pres<p(1)+20);
			J(1);
   		J=J((Q(i).Qpres(J)==1 & Q(i).Qpsal(J)==1) | (Q(i).Qpres(J)==5 & Q(i).Qpsal(J)==5) | (Q(i).Qpres(J)==1 & Q(i).Qpsal(J)==5) | (Q(i).Qpres(J)==5 & Q(i).Qpsal(J)==1));
         if ~isempty(J)
            ds=abs(Q(i).psal(J)-autosal(I(j)));
            L=find(ds==min(ds));
            sal(end,6)=Q(i).pres(J(L(1)));
            sal(end,7)=abs(deph(I(j))-Q(i).pres(J(L(1))));
      	end  
      catch
         sal(end,6)=NaN;
         sal(end,7)=NaN;
   	end
   end
end

fclose('all');
%Displaying result
fid=fopen('salinity.txt','wt');
fprintf(fid,['IML-' Q(1).cruiseid ': CTD-AutoSAL comparisons\n\n']);
fprintf('Filename Pres(db) AutoSAL CTD AutoSAL-CTD Pres_AutoSAL_found D_Pres\n');
fprintf(fid,'Filename Pres(db) AutoSAL CTD AutoSAL-CTD Pres_AutoSAL_found D_Pres\n');
for i=1:size(sal,1)
   fprintf('%10s %6.1f %6.3f %6.3f %6.3f %6.1f %6.1f\n',char(files{i})',sal(i,2:end));
   fprintf(fid,'%10s %6.1f %6.3f %6.3f %6.3f %6.1f %6.1f\n',char(files{i})',sal(i,2:end));
end
fprintf('-------------------------------------------------------------------\n');
fprintf(fid,'-------------------------------------------------------------------\n');

s=sal(~isnan(sal(:,5)),:);
means=mean(s(:,5));
stds=std(s(:,5));
I=find(s(:,5)>=means-2*stds & s(:,5)<=means+2*stds);
s=s(I,1:5);

fprintf(['Mean(AutoSAL-CTD) = ' num2str(nanmean(s(:,end))) ...
      ' ±' num2str(nanstd(s(:,end))) ...
      ' (' num2str(length(find(~isnan(s(:,end))))) ' data)\n']);
fprintf(['Mean(AutoSAL-CTD 100db+) = ' num2str(nanmean(s(s(:,2)>=100,end))) ...
      ' ±' num2str(nanstd(s(s(:,2)>=100,end))) ...
      ' (' num2str(length(find(~isnan(s(s(:,2)>=100,end))))) ' data)\n']);
fprintf(['Mean(AutoSAL-CTD 100db-) = ' num2str(nanmean(s(s(:,2)<=100,end))) ...
      ' ±' num2str(nanstd(s(s(:,2)<=100,end))) ...
      ' (' num2str(length(find(~isnan(s(s(:,2)<=100,end))))) ' data)\n']);
fprintf(fid,['Mean(AutoSAL-CTD) = ' num2str(nanmean(s(:,end))) ...
      ' ±' num2str(nanstd(s(:,end))) ...
      ' (' num2str(length(find(~isnan(s(:,end))))) ' data)\n']);
fprintf(fid,['Mean(AutoSAL-CTD 100db+) = ' num2str(nanmean(s(s(:,2)>=100,end))) ...
      ' ±' num2str(nanstd(s(s(:,2)>=100,end))) ...
      ' (' num2str(length(find(~isnan(s(s(:,2)>=100,end))))) ' data)\n']);
fprintf(fid,['Mean(AutoSAL-CTD 100db-) = ' num2str(nanmean(s(s(:,2)<=100,end))) ...
      ' ±' num2str(nanstd(s(s(:,2)<=100,end))) ...
      ' (' num2str(length(find(~isnan(s(s(:,2)<=100,end))))) ' data)\n']);

fclose('all');
end
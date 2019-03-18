function temp=thermometer(Q)
%THERMOMETER - Temperature validation with reversing thermometer measurements
%
%Syntax: temp=thermometer(Q)
% Compare STD temperatures and reversing thermometer temperatures
% Q is the STD-structure
% temp is a matrix of 
%  1. Filename
%  2. Pres(db): pressure depth (db)
%  3. RevT: Reversing thermometer temperature
%  4. CTD_temp: CTD temperature
%  5. RevT-CTD_temp: temperature difference = Reversing thermometer measurement - CTD temperature
%  6. Pres_RevT_found: pressure depth of reversing thermometer temperature in CTD file 
%  7. D_Pres: pressure difference = Pres - Pres_RevT_found
%
% The thermometer.txt file as the following columns (maximum one header line):
%  1. unique sample number
%  2. filename (without extension)
%  3. pressure depth (db)
%  4. Reversing thermometer temperature
%
% Results are display on line and in TXT-file RevT.txt.
%
%M-files required: nan_doubtful

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2000; Last revision: 20-Jan-2000 CL

%Read thermometer.txt file
a=dir('thermometer.txt');
if isempty(a)
   disp('No thermometer.txt found')
else
   [sample,file,deph,thermo] = textread('thermometer.txt','%s %s %f %f','headerlines',1,'endofline','\r\n');      
end
sample=str2num(char(sample));
thermo(thermo==-99)=nan;

%Extract CTD temp
temp=[]; files=[];
for i=1:size(Q,2)
   Q(i)=nan_doubtful(Q(i));
   filename=Q(i).filename(1:end-4);
   I=strmatchi(filename,file);
   for j=1:length(I)
      %at pressure depths
      J=find(Q(i).pres>deph(I(j))-0.5 & Q(i).pres<deph(I(j))+0.5);
      try
         J(1);
   		J=J(Q(i).Qtemp(J)==1);
      	if ~isempty(J)
           files{length(files)+1}=char(file{I(j)});
           temp=[temp; sample(I(j)) deph(I(j)) thermo(I(j)) ...
                  mean(Q(i).temp(J)) thermo(I(j))-mean(Q(i).temp(J)) NaN NaN];
      	end  
      catch
         files{length(files)+1}=char(file{I(j)});
 			temp=[temp; sample(I(j)) deph(I(j)) thermo(I(j)) NaN NaN NaN NaN];
       end
       
      %at salinity depths
      try
      	J=find(Q(i).temp>thermo(I(j))-0.1 & Q(i).temp<thermo(I(j))+0.1);
         J(1);
         O=Q(i).pres(J);
      	dp=abs(Q(i).pres(J)-deph(I(j)));
			p=O(dp==min(dp));
     		J=find(Q(i).temp>thermo(I(j))-0.1 & Q(i).temp<thermo(I(j))+0.1 ...
         	& Q(i).pres>p(1)-20 & Q(i).pres<p(1)+20);
			J(1);
   		J=J(Q(i).Qpres(J)==1 & Q(i).Qtemp(J)==1);
         if ~isempty(J) & ~isnan(temp(end,5))
            ds=abs(Q(i).temp(J)-thermo(I(j)));
            L=find(ds==min(ds));
            temp(end,6)=Q(i).pres(J(L(1)));
            temp(end,7)=abs(deph(I(j))-Q(i).pres(J(L(1))));
      	end  
      catch
         %temp(end,6)=NaN;
         %temp(end,7)=NaN;
   	end
   end
end

fclose('all');
%Displaying result
fid=fopen('RevT.txt','wt');
fprintf(fid,['IML-' Q(1).cruiseid ': CTD-RevT comparisons\n\n']);
fprintf('Filename Pres(db) RevT CTD RevT-CTD Pres_RevT_found D_Pres\n');
fprintf(fid,'Filename Pres(db) RevT CTD RevT-CTD Pres_RevT_found D_Pres\n');
for i=1:size(temp,1)
   fprintf('%10s %6.1f %6.3f %6.3f %6.3f %6.1f %6.1f\n',char(files{i})',temp(i,2:end));
   fprintf(fid,'%10s %6.1f %6.3f %6.3f %6.3f %6.1f %6.1f\n',char(files{i})',temp(i,2:end));
end
fprintf('-------------------------------------------------------------------\n');
fprintf(fid,'-------------------------------------------------------------------\n');

s=temp(~isnan(temp(:,5)),:);
means=mean(s(:,5));
stds=std(s(:,5));
I=find(s(:,5)>=means-2*stds & s(:,5)<=means+2*stds);
s=s(I,1:5);

fprintf(['Mean(RevT-CTD) = ' num2str(nanmean(s(:,end))) ...
      ' ±' num2str(nanstd(s(:,end))) ...
      ' (' num2str(length(find(~isnan(s(:,end))))) ' data)\n']);
fprintf(['Mean(RevT-CTD 100m+) = ' num2str(nanmean(s(s(:,2)>=100,end))) ...
      ' ±' num2str(nanstd(s(s(:,2)>=100,end))) ...
      ' (' num2str(length(find(~isnan(s(s(:,2)>=100,end))))) ' data)\n']);
fprintf(fid,['Mean(RevT-CTD) = ' num2str(nanmean(s(:,end))) ...
      ' ±' num2str(nanstd(s(:,end))) ...
      ' (' num2str(length(find(~isnan(s(:,end))))) ' data)\n']);
fprintf(fid,['Mean(RevT-CTD 100m+) = ' num2str(nanmean(s(s(:,2)>=100,end))) ...
      ' ±' num2str(nanstd(s(s(:,2)>=100,end))) ...
      ' (' num2str(length(find(~isnan(s(s(:,2)>=100,end))))) ' data)\n']);

fclose('all');
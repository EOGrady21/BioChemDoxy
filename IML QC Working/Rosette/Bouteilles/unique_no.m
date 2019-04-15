function unique_no
%UNIQUE_NO - Unique sample number, filename and pressure depth
%
%Syntax:  UNIQUE_NO
% Writes a unique_no.txt file of 3 columns from QAT-files or btlscan.txt
%  1. unique bottle number (or profile bottle number)
%  2. filename of CTD data in CNV format (without extension)
%  3. pressure depth (dbar)
% In btlscan.txt, depth need not to be a NaN. If so, than create a btl_(cruise_number).txt
% file with odf2blt.m and use selected columns to make a unique_no.txt by hand.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%June 2000; Last revision: 09-Jun-2000 CL

%read_qat if present
qat=dir('*.qat');
if ~isempty(qat)
   disp('Reading QAT-files ....')
   QAT=create_S('qat','bio_qat');
   s=cat(2,QAT.sample);
   if length(unique(s))~=length(s)
      [ss,jj]=unique(s);
      I=setdiff(1:length(s),jj);
      error(['Sample ' num2str(s(I(1))) ' is not unique in QAT-files']);
   end
   
%write unique_no.txt from Quat files   
   fid=fopen('unique_no.txt','wt');
   for i=1:size(QAT,2)
     for j=1:length(QAT(i).sample)
        fprintf(fid,'%.0f %s %.1f\n',QAT(i).sample(j),QAT(i).filename(1:end-4),QAT(i).pres(j));
     end
   end
   fclose(fid);
   disp('unique_no.txt created with QAT-files')
else
   disp('No QAT-file found')
end

%read btlscan.txt file if present
scan=dir('btlscan.txt');
if ~isempty(scan) & isempty(qat)
	fid=fopen('btlscan.txt','r');
	disp('Reading btlscan.txt ....')
	n=0;
	while feof(fid)==0
   	n=n+1;
   	line=fgetl(fid);
  		sample(n)=sscanf(line,'%f %*s %*f %*f %*f');
   	file{n}=sscanf(line,'%*f %s %*f %*f %*f');
   	deph(n)=sscanf(line,'%*f %*s %f %*f %*f');
   	startscan(n)=sscanf(line,'%*f %*s %*f %f %*f');
   	endscan(n)=sscanf(line,'%*f %*s %*f %*f %f');
   end
	fclose(fid);
	startscan(startscan==-99)=nan;
	endscan(endscan==-99)=nan;
   deph(deph==-99)=nan;
   if max(isnan(deph)==1)
      disp('Unidentified pressure depth')
      disp('unique_no.txt must be done by hand')
   elseif length(unique(sample))~=length(sample)
      disp('Samples are not unique in btlscan.txt')
      disp('unique_no.txt must be done by hand')
   else
      sample(sample<999)=-99;
      
%write unique_no.txt from btlscan.txt      
      fid=fopen('unique_no.txt','wt');
      for i=1:length(sample)
         fprintf(fid,'%.0f %s %.1f\n',sample(i),file{i},deph(i));
      end
      fclose(fid);
      disp('unique_no.txt created with btlscan.txt')
   end
else
   if isempty(qat)
      disp('No btlscan.txt file found')
      disp('Unique_no must be done by hand')
   end
end


function S=stage4_Q(S,testno)
%STAGE4_Q - Stage 4 of quality control tests (Profile Consistency Tests)
%
%Syntax:  S = STAGE2_Q(S,testno)
% S is the std structure.
% testno available
%  41: Waterfall
%  42: Annual Deep Water Profile Consistency
%
% Quality control test names are added to the structure field 'history'.
% Quality control test problems are reported on line and in 
% state_(cruise_number).txt file.
%
%Toolbox required: Seawater
%M-files required: remove_doubtful
%MAT-files required: stage4_Q1 
%
%Reference: Unesco (1990) GSTPP Real-Time Quality Control Manual, 
%           Intergouvernmental Oceanographic Commission, Manuals 
%           and Guides, vol 22, SC/90/WS-74: 121 p.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 27-Oct-1999 CL

%Open state file
fid=fopen(['state_' S(1).cruiseid '.txt'],'a');

%Load stage4_Q
load stage4_Q

%Switch
switch testno

%--------------------------------
%Test 41: Waterfall
%--------------------------------
case 41
  
 d=test41.pres;
 
 %S profiles used
 I=[];
 for i=1:size(S,2)
    if max(S(i).pres)>=min(d);
       I=[I i];
    end
 end
 SS=S(I);
 
 %Comparisons
 J=[]; L=[]; 
 for i=1:size(SS,2)
    dist=repmat(nan,size(SS));
    time=repmat(nan,size(SS));
 	for k=i:size(SS,2)
   	dist(k)=sw_dist([SS(i).lat SS(k).lat],[SS(i).lon SS(k).lon],'km');
   	time(k)=abs(datenum(SS(k).time)-datenum(SS(i).time));   
   end
   I=find(dist<test41.max_dist & time>0 & time<test41.max_time);
   if length(I)>0
      for j=1:size(test41.name,1)
         [Si,Isi]=remove_doubtful(SS(i),j+4);
			par1=eval(['Si.' test41.name{j}]);
         for l=1:length(I)
            [SI,IsI]=remove_doubtful(SS(I(l)),j+4);
            par2=eval(['SI.' test41.name{j}]);
            for k=1:length(d)
					try
               	para(k)=nanmean(par1(Si.pres>=d(k)-2.5 & Si.pres<=d(k)+2.5));
                  parb(k)=nanmean(par2(SI.pres>=d(k)-2.5 & SI.pres<=d(k)+2.5));   
               catch
                  para(k)=nan;
                  parb(k)=nan;
               end
            end
            Ipara=find(~isnan(para));
            Iparb=find(~isnan(parb));
            Ipar=intersect(Ipara,Iparb);
            if length(Ipar)>1
               L=1;
            	para=para(Ipar);
            	parb=parb(Ipar);
            	dpar=abs(para-mean(para))-abs(parb-mean(parb));
               %disp(['nanmean(para)=' num2str(nanmean(para))])
               %disp(['nanmean(parb)=' num2str(nanmean(parb))])
               %disp(['max(dpar)=' num2str(max(abs(dpar)))])
					K=find(abs(dpar)>test41.max_value(j));
            	if ~isempty(K)
              		J=1;
               	disp([' Test 4.1: Differences in ''' test41.name{j} ''' between ' ...
                     SS(i).filename ' and ' SS(I(l)).filename ' exceed ' ...
                     num2str(test41.max_value(j))])
               	fprintf(fid,['Test 4.1: Differences in ''' test41.name{j} ''' between ' ...
                     SS(i).filename ' and ' SS(I(l)).filename ' exceed ' ...
                     num2str(test41.max_value(j)) '\r\n']);
            	end
            end
         end
      end
   end
end
if ~isempty(I)
   for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test41.history; end
end
if isempty(J), disp(' Test 4.1 ok'), end

%---------------------------------------------
%Test 42: Annual Deep Water Profile Consistency
%---------------------------------------------
case 42
 P=test42.profile;
 d=test42.pres;
 
 %Test profiles used (with respect to time)
 Stime=datenum(cat(1,S.time));
 Ptime=datenum(cat(1,P.time));
 I=find(Ptime >= min(Stime)-test42.max_time & Ptime <= max(Stime)+test42.max_time);
 P=P(I);
 
 %S profiles used (with respect to depth)
 I=[];
 for i=1:size(S,2)
    if max(S(i).pres)>=min(d);
       I=[I i];
    end
 end
 SS=S(I);
 
 %Comparisons
 J=[];
 n=0;
 tempdif=[];
 psaldif=[];
 cruiseid=[];
 if ~isempty(P) & ~isempty(SS)
 for i=1:size(SS,2)
 	for k=1:size(P,2)
  		dist(k)=sw_dist([SS(i).lat P(k).lat],[SS(i).lon P(k).lon],'km');
  		time(k)=abs(datenum(P(k).time)-datenum(SS(i).time));   
  	end
  	I=find(dist<test42.max_dist & time>0 & time<test42.max_time);
  	if length(I)>0
  		for j=1:size(test42.name,1)
        	[Si,Isi]=remove_doubtful(SS(i),j+4);
			par1=eval(['Si.' test42.name{j}]);
        	for l=1:length(I)
           	SI=P(I(l));
        		par2=eval(['SI.' test42.name{j}]);
           	cruiseid=[cruiseid; SI.cruiseid];
           	for k=1:length(d)
              	try
                 	II=find(Si.pres>=d(k)-5 & Si.pres<=d(k)+5);
						if (nanmax(Si.pres(II))-nanmin(Si.pres(II))) > 2/3*10
               	  	para(k)=nanmean(par1(II));
                    	parb(k)=par2(k);
                 	else
                   	datenum('1')
                 	end
              	catch
                 	para(k)=nan;
              		parb(k)=nan;
              	end
           	end
           	Ipara=find(~isnan(para));
           	Iparb=find(~isnan(parb));
           	Ipar=intersect(Ipara,Iparb);
           	%Imin=max(min(find(~isnan(para))),min(find(~isnan(parb))));
           	%Imax=min(max(find(~isnan(para))),max(find(~isnan(parb))));
           	if length(Ipar)>0
           	   para=para(Ipar);
        	 		parb=parb(Ipar);
              	dpar=abs(para)-abs(parb);
              	eval([test42.name{j} 'dif=[' test42.name{j} 'dif ; mean(dpar(:))];'])
              	%disp(['nanmean(para)=' num2str(para)])
              	%disp(['nanmean(parb)=' num2str(parb)])
              	%disp(['max(dpar)=' num2str(abs(dpar))])
              	n=n+1;
     				file{n}=SS(i).filename;
					cruiseid=[cruiseid; SI.cruiseid];
					for r=1:length(Ipar)
                  disp([Si.filename ' ' SI.filename ' ' test42.name{j} ' ' num2str(d(Ipar(r))) 'm ' num2str(dpar(r))])
               end
               
            	K=find(abs(dpar)>test42.max_value(j));
            	if ~isempty(K)
                  J=1;
               	disp([' Test 4.2: Differences in ''' test42.name{j} ''' between ' ...
                     Si.filename ' and ' SI.filename ' exceed ' ...
                     num2str(test42.max_value(j))])
               	fprintf(fid,['Test 4.2: Differences in ''' test42.name{j} ''' between ' ...
                     Si.filename ' and ' SI.filename ' exceed ' ...
                     num2str(test42.max_value(j)) '\r\n']);
            	end
            end
         end
      end
   end
 end
 end
 if ~isempty(tempdif),
   for i=1:size(S,2)
      S(i).history{length(S(i).history)+1,1}=test42.history;      
   end
   cruiseid=unique(cellstr(cruiseid));
 	cruise=sprintf('%5s',char(cruiseid{1}));
 	for i=2:length(cruiseid), cruise=[cruise sprintf(', %5s ',char(cruiseid{i}))]; end
	disp([' Test 4.2: TEMP (' S(1).cruiseid ') - TEMP (' cruise ') = ' num2str(mean(tempdif))])
   fprintf(fid,['Test 4.2: TEMP (' S(1).cruiseid ') - TEMP (' cruise ') = ' num2str(mean(tempdif)) '\r\n']);
   if ~isnan(psaldif)
   disp([' Test 4.2: PSAL (' S(1).cruiseid ') - PSAL (' cruise ') = ' num2str(mean(psaldif))])
   fprintf(fid,['Test 4.2: PSAL (' S(1).cruiseid ') - PSAL (' cruise ') = ' num2str(mean(psaldif)) '\r\n']);
   end
   if isempty(J), disp(' Test 4.2 ok'), end
   fprintf(fid,'Test 4.2: files used: ');
   file=unique(file);
   for k=1:length(file)
      fprintf(fid,'%s ',char(file{k}));
   end
   fprintf(fid,'\r\n');
else
   disp(' Test 4.2: No comparison done')
   fprintf(fid,'Test 4.2: No comparison done\r\n');
 end

%-------------------
%Unknown Test Number
%-------------------
otherwise
 disp([' Unknown Test Number: ' num2str(testno)])
 
end %(swicth cases) 

%Close state file
fclose(fid);
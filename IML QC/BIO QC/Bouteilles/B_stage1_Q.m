function S=B_stage1_Q(S,testno)
%B_STAGE1_Q - Stage 1 of bottle quality control tests (Location and Identification Tests)
%
%Syntax:  S = D_STAGE1_Q(S,testno)
% S is the bottle-structure.
% testno available
%  10: Time Sequence
%  11: Platform Identification
%  13: Impossible Location
%  12: Impossible Date/Time
%  14: Position on Land
%  15: Impossible Speed
%  16: Impossible sounding
%
% Quality control test names are added to the structure field 'history'.
% Quality control test problems are reported on line and in 
% B_state_(cruise_number).txt file.
%
%Toolbox required: seawater
%MAT-file required: B_stage1_Q (out of B_stage_Q_ini)
%
%Reference: Unesco (1990) GSTPP Real-Time Quality Control Manual, 
%           Intergouvernmental Oceanographic Commission, Manuals 
%           and Guides, vol 22, SC/90/WS-74: 121 p.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 28-Jan-2004 CL
%
%Modifications:
% - Correction pour 2 profils avec la même date/heure mais 2 positions
%   différentes. Ancien QC n'interceptait pas ce problème.
% CL, 12-dec-2005


%Open state file
fid=fopen(['B_state_' S(1).cruiseid '.txt'],'a');

%Load stage1_Q
load B_stage1_Q

%Switch
switch testno

%--------------------------------
%Test 1.0: Time Sequence
%--------------------------------
case 10
 time=datenum(cat(1,S.time));
 [sorted_time,Isorted]=sort(time);
 if ~isempty(find((time-sorted_time)~=0)), 
    disp(' Test 1.0 -> Files are not sorted in time -> Sorting files ...')
    fprintf(fid,'Test 1.0 -> Files are not sorted in time -> Sorting files ...\r\n');
    S=S(Isorted);
 else
    disp(' Test 1.0 ok')
 end
 
%---------------------------------   
%Test 1.1: Platform Identification
%---------------------------------
case 11
 I=strmatch(S(1).call_sign,cat(1,S.call_sign));
 if length(I)~=size(S,2)
    disp(' Test 1.1 -> Files in the structure do not have the same call sign')
    fprintf(fid,'Test 1.1 -> Files in the structure do not have the same call sign\r\n');
 else
    disp(' Test 1.1 ok')
 end
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test11.history; end
 
%------------------------------ 
%Test 1.2: Impossible Date/Time
%------------------------------
case 12
 time=cat(1,S.time);
 I=strmatchi('17-NOV-1858',time);
 if ~isempty(I)
    for j=1:length(I)
%       error([' Test 1.2 -> Start time of ' S(I(j)).filename ' is not known'])
       disp([' Test 1.2 -> Start time of ' S(I(j)).filename ' is not known'])
       fprintf(fid,['Test 1.2 -> Start time of ' S(I(j)).filename ' is not known\r\n']);
    end
 end
 J=findstr('17-NOV-1858',S(1).cruise_start);
 if isempty(J)
    t1=datenum(S(1).cruise_start);
    t2=datenum(S(1).cruise_end);
	 I=find(datenum(time)<t1 | datenum(time)>t2);   
	 if ~isempty(I)
    	for j=1:length(I)
%       	 error([' Test 1.2 -> Start time of ' S(I(j)).filename ' is out cruise time'])
       	    disp([' Test 1.2 -> Start time of ' S(I(j)).filename ' is out cruise time'])
            fprintf(fid,['Test 1.2 -> Start time of ' S(I(j)).filename ' is not known\r\n']);
     end
 	 else
 	 		disp(' Test 1.2 ok')   
 	 end
 else
    disp(' Test 1.2 -> No cruise start found')
    fprintf(fid,'Test 1.2 -> No cruise start found\r\n');
 end   
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test12.history; end
  
%-----------------------------   
%Test 1.3: Impossible Location
%-----------------------------
case 13  
 lon=cat(1,S.lon);
 lat=cat(1,S.lat);
 I=find(lat<-90 | lat>90);
 if ~isempty(I)
    J=find(lat(I)==-99.0);
    if ~isempty(J);
       for j=1:length(J)
       	error([' Test 1.3 -> Initial latitude of ' S(I(J(j))).filename ' is not known'])
       end
    end
    J=find(lat(I)~=-99.0);
    if ~isempty(J)
       for j=1:length(J)
          error([' Test 1.3 -> ' S(I(J(j))).filename ' -> Impossible initial latitude'])
   	 end
 	 end
 end 
 I=find(lon<-180 | lon>180);
 if ~isempty(I)
    J=find(lon(I)==-999.9);
    if ~isempty(J);
       for j=1:length(J)
       	error([' Test 1.3 -> Initial longitude of ' S(I(J(j))).filename ' is not known'])
       end
    end
    J=find(lon(I)~=-999.9);
    if ~isempty(J)
       for j=1:length(J)
          error([' Test 1.3 -> ' S(I(J(j))).filename ' -> Impossible initial longitude'])
   	 end
 	 end
 end 
 if isempty(I), disp(' Test 1.3 ok'), end
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test13.history; end
  
%--------------------------
%Test 1.4: Position on Land
%--------------------------
case 14
 I=[]; J=[];
 for i=1:size(test14.poly_lon,1)
    in=inpolygon(cat(1,S.lon),cat(1,S.lat),test14.poly_lon{i},test14.poly_lat{i});
    I=find(in>0);
 	 if ~isempty(I)
    	for j=1:length(I)
          disp([' Test 1.4 -> ' S(I(j)).filename ' is on land']);
        	 fprintf(fid,['Test 1.4 -> ' S(I(j)).filename ' is on land\r\n']);
      end   
    end   
 end   
 if isempty(I), disp(' Test 1.4 ok'), end
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test14.history; end
 
%-------------------------- 
%Test 1.5: Impossible Speed
%--------------------------
case 15   
 %time
 timein=cat(1,S.time);
 timeout=cat(1,S.time_end);
 I=strmatch('17-Nov-1858',timeout);
 timeout(I,:)=datestr(datenum(timein(I,:))+1/(60*24));  
 %longitude
 longin=cat(1,S.lon);
 longout=cat(1,S.lon_end);
 longout(isnan(longout))=longin(isnan(longout));
 %latitude
 latin=cat(1,S.lat);
 latout=cat(1,S.lat_end);
 latout(isnan(latout))=latin(isnan(latout));
 %deltas
 time=[]; lat=[]; lon=[];
 for i=1:length(longin)
    time=[time; timein(i,:); timeout(i,:)];
    lat=[lat; latin(i); latout(i)];
    lon=[lon; longin(i); longout(i)];
 end
 dtime=datenum(time(2:end,:))-datenum(time(1:end-1,:));
 %dtime(dtime==0)=nan;
 dist=sw_dist(lat,lon,'nm');
 if size(S,2)>1 
 	 I=strmatchi(S(1).call_sign,test15.call_sign);
	 if isempty(I)
       disp([' Test 1.5 -> No ship velocity known for call_sign ' S(1).call_sign])
       fprintf(fid,['Test 1.5 -> No ship velocity known for call_sign ' S(1).call_sign '\r\n']);
	 else     
	   ship_vel=test15.max_vel(I);							%Maximum velocity in knots 
       cruise_vel=dist./(dtime*24);
       J=find(cruise_vel>ship_vel);
       JJ=J(:);
       if ~isempty(J)
       	  disp(' Test 1.5 -> Cruise velocity > permitted -> Check time and position of')
           fprintf(fid,'Test 1.5 -> Cruise velocity > permitted -> Check time and position of\r\n');
           for i=1:length(J)
              K=ceil(J(i)/2);
              if K==J(i)/2
					 disp(['    the end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)'])
           		 fprintf(fid,['    the end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)\r\n']);
          	  else
  					 disp(['    the beginning of ' S(K).filename ' and the end of ' ...
                S(K).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)'])
           		 fprintf(fid,['    the beginning of ' S(K).filename ' and the end of ' ...
                S(K).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)\r\n']);
   			  end
       	 end 
       end
       %J=find(cruise_vel<0);
       J=find(dtime<0);
       JJ=[JJ; J(:)];
       if ~isempty(J)
          disp(' Test 1.5 ->Negative cruise velocity -> Check time of')
          fprintf(fid,'Test 1.5 ->Negative cruise velocity -> Check time of\r\n');
          for i=1:length(J)
             K=ceil(J(i)/2);
             if K==J(i)/2
		       disp(['    The end of ' S(K).filename ' and the beginning of ' ...
                   S(K+1).filename ' (deltaT=' ...
                   num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                   num2str(dist(J(i)),'%.1f') ' nm)'])
               fprintf(fid,['    The end of ' S(K).filename ' and the beginning of ' ...
                   S(K+1).filename ' (deltaT=' ...
                   num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                   num2str(dist(J(i)),'%.1f') ' nm)\r\n']);
             else
  			   disp(['    the beginning of ' S(K).filename ' and the end of ' ...
               	   S(K).filename ' (deltaT=' ...
               	   num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                   num2str(dist(J(i)),'%.1f') ' nm)'])
           	   fprintf(fid,['    the beginning of ' S(K).filename ' and the end of ' ...
               	   S(K).filename ' (deltaT=' ...
                   num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                   num2str(dist(J(i)),'%.1f') ' nm)\r\n']);
   			 end
         end 
       end
       
       J=find(cruise_vel==0);
       Ji=[];
       if ~isempty(J)
          for i=1:length(J)
             K=ceil(J(i)/2);
             if K==J(i)/2
                 if i==1, 
                 disp(' Test 1.5 ->Null cruise velocity -> Check time of')
                  fprintf(fid,'Test 1.5 ->Null cruise velocity -> Check time of\r\n');
                 end
                  disp(['    The end of ' S(K).filename ' and the beginning of ' ...
                   S(K+1).filename ' (found ship velocity is ' ...
                   num2str(cruise_vel(J(i)),'%5.2f') ' kt)'])
             	fprintf(fid,['    The end of ' S(K).filename ' and the beginning of ' ...
                   S(K+1).filename ' (found ship velocity is ' ...
                   num2str(cruise_vel(J(i)),'%5.2f') ' kt)\r\n']);
               Ji=[Ji J(i)];
             end
          end 
       end
       JJ=[JJ; Ji(:)];

       if isempty(JJ), disp(' Test 1.5 ok'), end
    end
 end
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test15.history; end

%-----------------------------
%Test 1.6: Impossible sounding
%-----------------------------
case 16
  for i=1:size(S,2)
    [Tn,Itn]=remove_doubtful(S(i),1);
    %Check first if sounding > max_depth
    if Tn.sounding<max(Tn.deph)
       disp([' Test 1.6 ->' Tn.filename ': Maximum depth of profile (' ...
             num2str(max(Tn.deph),'%.1f') 'm) > Sounding (' ...
             num2str(Tn.sounding,'%.1f') 'm)'])
     	fprintf(fid,['Test 1.6 ->' Tn.filename ': Maximum depth of profile (' ...
             num2str(max(Tn.deph),'%.1f') 'm) > Sounding (' ...
             num2str(Tn.sounding,'%.1f') 'm)\r\n']);
	 end
    dx=abs(test16.lon-Tn.lon);
    Ix=find(dx==min(dx)); Ix=Ix(1);
    dy=abs(test16.lat-Tn.lat);
    Iy=find(dy==min(dy)); Iy=Iy(1); 
    J=[];
    if ~isempty(Ix) & dx(Ix)<2 & Ix~=1 & Ix~=length(test16.lon) & ...
          Iy~=1 & Iy~=length(test16.lat)
   	 minz=min(min(test16.sounding(Iy-1:Iy+1,Ix-1:Ix+1)));
   	 maxz=max(max(test16.sounding(Iy-1:Iy+1,Ix-1:Ix+1)));
   	 if S(i).sounding<minz-20 | S(i).sounding>maxz+20
          disp([' Test 1.6 ->' Tn.filename ': Sounding = ' ...
                num2str(Tn.sounding,'%3.0f') '; Expected value: ' ...
                num2str(minz,'%3.0f') ' to ' num2str(maxz,'%3.0f')])
          fprintf(fid,['Test 1.6 ->' Tn.filename ': Sounding = ' ...
                num2str(S(i).sounding,'%3.0f') '; Expected value: ' ...
                num2str(minz,'%3.0f') ' to ' num2str(maxz,'%3.0f') '\r\n']);
          J=1;
       end
    else
       disp([' Test 1.6 -> No known depth for ' Tn.filename])
       fprintf(fid,['Test 1.6 -> No known depth for ' Tn.filename '\r\n']);
       J=1;
    end
    S(i)=replace_erroneous(S(i),Tn,Itn);
 end
 if isempty(J), disp(' Test 1.6 ok'), end
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test16.history; end

%-------------------
%Unknown Test Number
%-------------------
otherwise
 disp([' Unknown Test Number: ' num2str(testno)])
 
end %(swicth cases) 

%Close state file
fclose(fid);
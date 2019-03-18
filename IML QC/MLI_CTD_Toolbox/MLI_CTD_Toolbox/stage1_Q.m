function S = stage1_Q(S, testno)
%STAGE1_Q - Stage 1 of quality control tests (Location and Identification Tests)
%
%Syntax:  S = STAGE1_Q(S, testno)
% S is the std structure.
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
% state_(cruise_number).txt file.
%
%Toolbox required: seawater
%MAT-file required: stage1_Q (out of stage_Q_ini)
%
%Reference: Unesco (1990) GSTPP Real-Time Quality Control Manual,
%           Intergouvernmental Oceanographic Commission, Manuals
%           and Guides, vol 22, SC/90/WS-74: 121 p.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 27-Oct-1999 CL
%
%Modifications:
% - Vitesse du bateau entre 2 station ne peut etre nulle
% CL, 22-Aug-2002
% - Le deltaT entre le début et la fin du profil ne peut etre négatif.
% CL, 14-Aug-2003
% - Correction pour 2 profils avec la même date/heure mais 2 positions
%   différentes. Ancien QC n'interceptait pas ce problème.
% CL, 12-dec-2005
% - Added code so that when a test is passed as well as failed, a comment is
%   output to the status report.
% JJ, 02-NOV-2011
% 
% Updated for use at BIO by Jeff Jackson
% Last Updated: 02-NOV-2011

%Open state file
fid = fopen(['state_' S(1).cruiseid '.txt'],'a');

%Load stage1_Q
load stage1_Q

%Switch
switch testno
  
  %------------------------------
  % Test 1.0: Time Sequence (IML)
  %------------------------------
  % Description: This test verifies that the files in the structure are
  % listed in chronological order.  If they are not, then they are sorted
  % chronologically.
  case 10
    time = datenum(cat(1,S.time));
    [sorted_time,Isorted] = sort(time);
    if ~isempty(find((time-sorted_time)~=0, 1)),
      disp(' Test 1.0 -> Files are not sorted in time -> Sorting files ...')
      fprintf(fid, '%s\r\n', 'Test 1.0 -> Files are not sorted in time -> Sorting files ...');
      S = S(Isorted);
    else
      disp(' Test 1.0 ok')
      fprintf(fid, '%s\r\n', 'Test 1.0 ok');
    end
    
    %------------------------------------------
    % Test 1.1: Platform Identification (GTSPP)
    %------------------------------------------
    % Description: This test verifes that all profiles were sampled from the
    % same ship. This is performed by checking to see if the user supplied
    % call-sign (the first profile's call sign is used when one is not
    % supplied) is identical to every profile's call-sign.
  case 11
    I = strcmp(S(1).call_sign, cellstr(char(S.call_sign)));
    if length(I) ~= size(S,2)
      disp(' Test 1.1 -> Files in the structure do not have the same call sign');
      fprintf(fid, '%s\r\n', 'Test 1.1 -> Files in the structure do not have the same call sign');
    else
      disp(' Test 1.1 ok');
      fprintf(fid, '%s\r\n', 'Test 1.1 ok');
    end
    for i = 1:size(S,2)
      if isfield(S(i), 'history')
        S(i).history{length(S(i).history)+1,1} = test11.history;
      elseif isfield(S(i), 'History')
        S(i).History{length(S(i).History)+1,1} = test11.history;
      end
    end
    
    %---------------------------------------
    % Test 1.2: Impossible Date/Time (GTSPP)
    %---------------------------------------
    % Description: This test verifies that the date and time of the beginning
    % and end of the profile fall within the mission dates.
  case 12
    time = cat(1,S.time);
    I = strcmpi('17-NOV-1858', cellstr(time));
    if sum(I) > 0
      for j = 1:length(I)
        %       error([' Test 1.2 -> Start time of ' S(I(j)).filename ' is not known'])
        disp([' Test 1.2 -> Start time of ' S(I(j)).filename ' is not known'])
        fprintf(fid, '%s\r\n', ['Test 1.2 -> Start time of ' S(I(j)).filename ' is not known']);
      end
    end
    J = strfind('17-NOV-1858',S(1).cruise_start);
    if isempty(J)
      t1 = datenum(S(1).cruise_start);
      t2 = datenum(S(1).cruise_end);
      I = find(datenum(time)<t1 | datenum(time)>t2);
      if ~isempty(I)
        for j = 1:length(I)
          %       	 error([' Test 1.2 -> Start time of ' S(I(j)).filename ' is out cruise time'])
          disp([' Test 1.2 -> Start time of ' S(I(j)).filename ' is out of cruise time'])
          fprintf(fid, '%s\r\n', ['Test 1.2 -> Start time of ' S(I(j)).filename ' is out of cruise time']);
        end
      else
        disp(' Test 1.2 ok')
        fprintf(fid, '%s\r\n', 'Test 1.2 ok');
      end
    else
      disp(' Test 1.2 -> No cruise start found')
      fprintf(fid, '%s\r\n', 'Test 1.2 -> No cruise start found');
    end
    for i = 1:size(S,2)
      if isfield(S(i), 'history')
        S(i).history{length(S(i).history)+1,1} = test12.history;
      elseif isfield(S(i), 'History')
        S(i).History{length(S(i).History)+1,1} = test12.history;
      end
    end
    
    %--------------------------------------
    % Test 1.3: Impossible Location (GTSPP)
    %--------------------------------------
    % Description: This test verifies that the profile’s position is
    % possible; that is, that the latitude falls between –90 and 90 and the
    % longitude between –180 and 180.
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
    if isempty(I)
      disp(' Test 1.3 ok')
      fprintf(fid, '%s\r\n', 'Test 1.3 ok');
    end
    for i = 1:size(S,2)
      if isfield(S(i), 'history')
        S(i).history{length(S(i).history)+1,1} = test13.history;
      elseif isfield(S(i), 'History')
        S(i).History{length(S(i).History)+1,1} = test13.history;
      end
    end
    
    %-----------------------------------
    % Test 1.4: Position on Land (GTSPP)
    %-----------------------------------
    % Description: This test checks whether the profile’s position falls
    % within the land polygons describing the area of the St. Lawrence Gulf
    % and estuary. The area covered is from -70 to –56 in longitude and from
    % 45 to 52 in latitude.
  case 14
    I=[];
    for i=1:size(test14.poly_lon,1)
      in=inpolygon(cat(1,S.lon),cat(1,S.lat),test14.poly_lon{i},test14.poly_lat{i});
      I=find(in>0);
      if ~isempty(I)
        for j=1:length(I)
          disp([' Test 1.4 -> ' S(I(j)).filename ' is on land']);
          fprintf(fid, '%s\r\n', ['Test 1.4 -> ' S(I(j)).filename ' is on land']);
        end
      end
    end
    if isempty(I)
      disp(' Test 1.4 ok')
      fprintf(fid, '%s\r\n', 'Test 1.4 ok');
    end
    for i = 1:size(S,2)
      if isfield(S(i), 'history')
        S(i).history{length(S(i).history)+1,1} = test14.history;
      elseif isfield(S(i), 'History')
        S(i).History{length(S(i).History)+1,1} = test14.history;
      end
    end
    
    %-----------------------------------
    % Test 1.5: Impossible Speed (GTSPP)
    %-----------------------------------
    % Description: This test checks the ship speed between two consecutive
    % profiles. The ship speed is calculated from the time–space position at
    % the beginning of the profile and those from the end of the preceding
    % profile. If the end position or date/time of the preceding profile are
    % missing, the test uses the coordinates at the beginning of the
    % preceding profile to determine ship speed. The calculated speed is
    % compared with the ship’s cruising speed.
  case 15
    %time
    timein = cat(1,S.time);
    timeout = cat(1,S.time_end);
    I = strncmp('17-Nov-1858',cellstr(timeout),11);
    if ~isempty(I)
      timeout(I,:) = datestr(datenum(timein(I,:))+1/(60*24));
    end
    %longitude
    longin=cat(1,S.lon);
    longout=cat(1,S.lon_end);
    longout(isnan(longout))=longin(isnan(longout));
    %latitude
    latin=cat(1,S.lat);
    latout=cat(1,S.lat_end);
    latout(isnan(latout))=latin(isnan(latout));
    %deltas
    time = [];
    lat = [];
    lon = [];
    for i = 1:length(longin)
      time = [time; timein(i,:); timeout(i,:)]; %#ok<*AGROW>
      lat = [lat; latin(i); latout(i)];
      lon = [lon; longin(i); longout(i)];
    end
    dtime = datenum(time(2:end,:)) - datenum(time(1:end-1,:));
    %dtime(dtime==0)=nan;
    dist = sw_dist(lat,lon,'nm');
    if size(S,2)>1
      I = strcmpi(S(1).call_sign, test15.call_sign);
      if isempty(I)
        disp([' Test 1.5 -> No ship velocity known for call_sign ' S(1).call_sign]);
        fprintf(fid, '%s\r\n', ['Test 1.5 -> No ship velocity known for call_sign ' S(1).call_sign]);
      else
        ship_vel = test15.max_vel(I);							%Maximum velocity in knots
        cruise_vel = dist./(dtime*24);
        J = find(cruise_vel > ship_vel);
        JJ = J(:);
        if ~isempty(J)
          disp(' Test 1.5 -> Cruise velocity > permitted -> Check time and position of')
          fprintf(fid, '%s\r\n', 'Test 1.5 -> Cruise velocity > permitted -> Check time and position of');
          for i = 1:length(J)
            K = ceil(J(i)/2);
            if K == J(i)/2
              disp(['    the end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)']);
              fprintf(fid, '%s\r\n', ['    the end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)']);
            else
              disp(['    the beginning of ' S(K).filename ' and the end of ' ...
                S(K).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)']);
              fprintf(fid, '%s\r\n', ['    the beginning of ' S(K).filename ' and the end of ' ...
                S(K).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.1f') ' kt)']);
            end
          end
        end
        %J=find(cruise_vel<0);
        J = find(dtime < 0);
        JJ = [JJ; J(:)];
        if ~isempty(J)
          disp(' Test 1.5 ->Negative cruise velocity -> Check time of')
          fprintf(fid,'Test 1.5 ->Negative cruise velocity -> Check time of\r\n');
          for i = 1:length(J)
            K = ceil(J(i)/2);
            if K == J(i)/2
              disp(['    The end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (deltaT=' ...
                num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                num2str(dist(J(i)),'%.1f') ' nm)']);
              fprintf(fid, '%s\r\n', ['    The end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (deltaT=' ...
                num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                num2str(dist(J(i)),'%.1f') ' nm)']);
            else
              disp(['    the beginning of ' S(K).filename ' and the end of ' ...
                S(K).filename ' (deltaT=' ...
                num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                num2str(dist(J(i)),'%.1f') ' nm)']);
              fprintf(fid, '%s\r\n', ['    the beginning of ' S(K).filename ' and the end of ' ...
                S(K).filename ' (deltaT=' ...
                num2str(dtime(J(i))*24,'%5.1f') ' h; deltaD=' ...
                num2str(dist(J(i)),'%.1f') ' nm)']);
            end
          end
        end
        
        J = find(cruise_vel == 0);
        Ji = [];
        if ~isempty(J)
          for i = 1:length(J)
            K = ceil(J(i) / 2);
            if K == J(i) / 2
              if i == 1
                disp(' Test 1.5 ->Null cruise velocity -> Check position of')
                fprintf(fid,'Test 1.5 ->Null cruise velocity -> Check position of\r\n');
              end
              disp(['    The end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.2f') ' kt)']);
              fprintf(fid, '%s\r\n', ['    The end of ' S(K).filename ' and the beginning of ' ...
                S(K+1).filename ' (found ship velocity is ' ...
                num2str(cruise_vel(J(i)),'%5.2f') ' kt)']);
              Ji = [Ji J(i)];
            end
          end
        end
        JJ = [JJ; Ji(:)];
        
        if isempty(JJ)
          disp(' Test 1.5 ok')
          fprintf(fid, '%s\r\n', 'Test 1.5 ok');
        end
      end
    end
    for i = 1:size(S,2)
      if isfield(S(i), 'history')
        S(i).history{length(S(i).history)+1,1} = test15.history;
      elseif isfield(S(i), 'History')
        S(i).History{length(S(i).History)+1,1} = test15.history;
      end
    end
    
    %--------------------------------------
    % Test 1.6: Impossible sounding (GTSPP)
    %--------------------------------------
    % Description: This test compares the sounded depth to a 3 km-grid
    % bathymetric map of the St. Lawrence Gulf and estuary to determine its
    % validity. A depth is considered valid if it is within 20 m of the depth
    % noted on the bathymetric grid. The area covered is from -70 to –56 in
    % longitude and from 45 to 52 in latitude.
  case 16
    for i = 1:size(S,2)
      [Tn,Itn] = remove_doubtful(S(i),1);
      %Check first if sounding > max_depth
      if Tn.sounding < max(Tn.deph)
        disp([' Test 1.6 ->' Tn.filename ': Maximum depth of profile (' ...
          num2str(max(Tn.deph),'%.1f') 'm) > Sounding (' ...
          num2str(Tn.sounding,'%.1f') 'm)']);
        fprintf(fid, '%s\r\n', ['Test 1.6 ->' Tn.filename ': Maximum depth of profile (' ...
          num2str(max(Tn.deph),'%.1f') 'm) > Sounding (' ...
          num2str(Tn.sounding,'%.1f') 'm)']);
      end
      dx = abs(test16.lon-Tn.lon);
      Ix = find(dx==min(dx)); Ix=Ix(1);
      dy = abs(test16.lat-Tn.lat);
      Iy = find(dy == min(dy));
      Iy = Iy(1);
      J = [];
      if ~isempty(Ix) && (dx(Ix) < 2) && (Ix ~= 1) && (Ix ~= length(test16.lon)) && ...
          (Iy ~= 1) && (Iy ~= length(test16.lat)) && (test16.sounding(Iy,Ix) < 550)
        minz = min(min(test16.sounding(Iy-1:Iy+1,Ix-1:Ix+1)));
        maxz = max(max(test16.sounding(Iy-1:Iy+1,Ix-1:Ix+1)));
        if (S(i).sounding < minz - 20) || (S(i).sounding > maxz + 20)
          disp([' Test 1.6 ->' Tn.filename ': Sounding = ' ...
            num2str(Tn.sounding,'%3.0f') '; Expected value: ' ...
            num2str(minz,'%3.0f') ' to ' num2str(maxz,'%3.0f')]);
          fprintf(fid, '%s\r\n', ['Test 1.6 ->' Tn.filename ': Sounding = ' ...
            num2str(S(i).sounding,'%3.0f') '; Expected value: ' ...
            num2str(minz,'%3.0f') ' to ' num2str(maxz,'%3.0f')]);
          J = 1;
        end
      else
        disp([' Test 1.6 -> No known depth for ' Tn.filename]);
        fprintf(fid, '%s\r\n', ['Test 1.6 -> No known depth for ' Tn.filename]);
        J = 1;
      end
      S(i) = replace_erroneous(S(i),Tn,Itn);
      S(i) = refresh_Q(S(i));
    end
    if isempty(J)
      disp(' Test 1.6 ok');
      fprintf(fid, '%s\r\n', 'Test 1.6 ok');      
    end
    for i = 1:size(S,2)
      S(i).history{length(S(i).history)+1,1} = test16.history;
    end
    
    %--------------------------
    % Unknown Test Number (IML)
    %--------------------------
  otherwise
    disp([' Unknown Test Number: ' num2str(testno)]);
    
end %(switch cases)

% Close state file
fclose(fid);
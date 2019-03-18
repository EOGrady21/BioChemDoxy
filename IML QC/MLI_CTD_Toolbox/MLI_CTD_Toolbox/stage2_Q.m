function T = stage2_Q(T, testno)
%STAGE2_Q - Stage 2 of quality control tests (Profile Tests)
%
%Syntax:  T = STAGE2_Q(T, testno)
% T is the std structure with quality control flags included (size(T)=[1 1]).
% testno available
%  20: Minimum Descent Rate (2)
%  21: Global Impossible Parameter Values (4)
%  22: Regional Impossible Parameter Values (8)
%  23: Incresssing Depth (16)
%  24: Profile Envelope (32)
%  26: Freezing Point (128)
%  27: Spike in temperature and salinity (one point) (256)
%  28: Top and Bottom Spike in temperature and salinity (one point) (512)
%  29: Gradient (point to point) (1024)
%  210: Density Inversion (point to point) (2048)
%  211: Spike (one point or more) (4096)
%  212: Density Inversion (overall profile) (8192)
%
% testno not available
%  25: Constant Profile (64)
%
% Quality control test names are added to the structure field 'history'.
% A QCFF (Quality Control Flag Index) is attributed to every data of the
% profile for each test done.
% Quality control test problems are reported on line and in
% state_(cruise_number).txt file.
%
%Toolbox required: Seawater
%M-files required: medfil, filtindex, remove_erroneous, replace_erroneous,
%                  refresh_Q, medfilt1_cl
%MAT-files required: stage2_Q
%
%Reference: Unesco (1990) GSTPP Real-Time Quality Control Manual,
%           Intergouvernmental Oceanographic Commission, Manuals
%           and Guides, vol 22, SC/90/WS-74: 121 p.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 23-Nov-1999 CL

%Modifications
% - Petit bug dans le test 2.9. Le flag QCFF était mal assigné si un test
% précédant sur la salinité avait échoué. L'attribution du Q était ok.
% Bug corrigé.
% CL, 15-Aug-2007
% 
% - Changed the checking of "~isempty(I)" to "sum(I) > 0" in tests 2.2 and
%   2.3 because when the varialbe "I" contains one or more zeros it will never
%   be empty so the logic failed. 
% JJ, 01-NOV-2011
% - Added code so that when a test is passed as well as failed, a comment is
%   output to the status report.
% JJ, 02-NOV-2011
% 
% Updated for use at BIO by Jeff Jackson
% Last Updated: 02-NOV-2011

% Load the information for the stage2 tests.
load stage2_Q

% Open the "state" file to record the results of the stage2 tests.
fid = fopen(['state_' T.cruiseid '.txt'], 'a');

% Switch
switch testno
  
  %-------------------------------
  %Test 2.0: Minimum Descent Rate
  %-------------------------------
  case 20
    if ~isempty(T.dpdt)
      [Tn,Itn] = remove_doubtful(T,8);
      I = find(abs(T.dpdt(Itn)) < test20.minvalue);
      if ~isempty(I)
        disp([' Test 2.0 -> Descent rates smaller than ' num2str(test20.minvalue) ' found']);
        fprintf(fid, '%s\n', [' Test 2.0 -> Descent rates smaller than ' num2str(test20.minvalue) ' found']);
        Tn.Qpsal(I) = 3;
        Tn.QCFF(I) = Tn.QCFF(I) + 2^1;
      else
        disp(' Test 2.0 ok');
        fprintf(fid, '%s\n', 'Test 2.0 ok');
      end
      [T] = replace_erroneous(T,Tn,Itn);
      T = refresh_Q(T);
      T.history{length(T.history)+1,1} = [test20.history ' (' num2str(test20.minvalue,'%.2f') 'm/s)'];
    else
      disp(' Test 2.0 -> no descent rate found');
      fprintf(fid, '%s\n', 'Test 2.0 -> no descent rate found');
    end
    
    %--------------------------------------------
    %Test 2.1: Global Impossible Parameter Values
    %--------------------------------------------
  case 21
    names = fieldnames(T);
    K = [];
    for j = 6:size(test21.name,1)		% temp, psal, pres, flor, and doxy for now.
      I = strncmp(test21.name{j}, names, 4);
      if sum(I) > 0
        par = eval(['T.' test21.name{j}]);
        I = find((par < test21.minvalue(j)) | (par > test21.maxvalue(j)));
        if ~isempty(I)
          disp([' Test 2.1 -> Global Impossible Parameter Value for ' test21.name{j}]);
          eval(['T.Q' test21.name{j} '(I)=4;'])
          K = [K; I(:)]; %#ok<*AGROW>
          fprintf(fid,'%s: Test 2.1 -> Global Impossible Parameter Value for %s\r\n',T.filename,test22.name{j});
        end
      end
    end
    if isempty(K)
      disp(' Test 2.1 ok');
      fprintf(fid, '%s\n', 'Test 2.1 ok');
    else
      T.QCFF(unique(K)) = T.QCFF(unique(K)) + 2^2;
    end
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test21.history;
    
    %----------------------------------------------
    %Test 2.2: Regional Impossible Parameter Values
    %----------------------------------------------
  case 22
    names = fieldnames(T);
    K = [];
    for j = 6:size(test22.name,1)		% temp, psal, pres, flor, and doxy for now.
      I = strncmp(test22.name{j}, names, 4);
      if (sum(I) > 0) && inpolygon(T.lon,T.lat,test22.poly_lon,test22.poly_lat)
        par = eval(['T.' test22.name{j}]);
        I = find(par<test22.minvalue(j) | par>test22.maxvalue(j));
        if ~isempty(I)
          disp([' Test 2.2 -> Regional Impossible Parameter Value for ' test22.name{j}]);
          eval(['T.Q' test22.name{j} '(I)=4;'])
          K = [K; I(:)];
          fprintf(fid,'%s: Test 2.2 -> Regional Impossible Parameter Value for %s\r\n', T.filename,test22.name{j});
        end
      end
    end
    if isempty(K)
      disp(' Test 2.2 ok');
      fprintf(fid, '%s\n', 'Test 2.1 ok');
    else
      T.QCFF(unique(K)) = T.QCFF(unique(K)) + 2^3;
    end
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test22.history;
    
    %---------------------------
    %Test 2.3: Increasing Depth
    %---------------------------
  case 23
    [Tn,Itn] = remove_erroneous(T,1);
    par = Tn.pres;
    
    %Despiking first
    spikes = 1;
    pfilt = medfil(par,7);
    dp = abs(par-pfilt);
    scan = 1:length(par);
    I1 = find(dp>spikes);
    I2 = find(dp<=spikes);
    if ~isempty(I1);
      par(I1) = interp1(scan(I2),par(I2),scan(I1));
    end
    
    dpar = par(2:end) - par(1:end-1);
    I = find(dpar < 0);
    if ~isempty(I)
      disp(' Test 2.3 -> Decreasing depths found');
      fprintf(fid, '%s\n', 'Test 2.3 -> Decreasing depths found');
    else
      disp(' Test 2.3 ok');
      fprintf(fid, '%s\n', 'Test 2.3 ok');
    end
    while ~isempty(I)
      par(I+1) = par(I);
      dpar = par(2:end) - par(1:end-1);
      I = find(dpar < 0);
    end
    I = find(dpar == 0);
    Tn.Qpres(I+1) = 3;
    Tn.QCFF(I+1) = Tn.QCFF(I+1) + 2^4;
    [T] = replace_erroneous(T,Tn,Itn);
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test23.history;
    
    %--------------------------
    %Test 2.4: Profile Envelope
    %--------------------------
  case 24
    [Tn,Itn] = remove_erroneous(T,1);
    names = fieldnames(Tn);
    [~,J] = unique(test24.name(:,1));
    K = [];
    for j = 1:length(J)
      I = strncmp(test24.name{J(j)}, names, 4);
      if ~isempty(I)
        I = strncmp(test24.name{J(j)}, test24.name, 4);
        d1 = test24.prof1(I);
        d2 = test24.prof2(I);
        m1 = test24.minvalue(I);
        m2 = test24.maxvalue(I);
        par = eval(['Tn.' test24.name{J(j)}]);
        if ~isempty(par)
          for k = 1:length(d1)
            minv = min(par(Tn.deph>=d1(k) & Tn.deph<d2(k)));
            maxv = max(par(Tn.deph>=d1(k) & Tn.deph<d2(k)));
            I = find(minv<m1(k) | maxv>m2(k));
            if ~isempty(I)
              disp([' Test 2.4 -> Impossible Parameter Value in Profile for ' test24.name{J(j)}]);
              fprintf(fid, '%s\n', ['Test 2.4 -> Impossible Parameter Value in Profile for ' test24.name{J(j)}]);
              eval(['Tn.Q' test24.name{j} '(I)=3;'])
              K = [K; I(:)];
            end
          end
        else
          K = [];
        end
      end
    end
    if isempty(K)
      disp(' Test 2.4 ok');
      fprintf(fid, '%s\n', 'Test 2.4 ok');
    else
      Tn.QCFF(unique(K)) = Tn.QCFF(unique(K)) + 2^5;
    end
    [T] = replace_erroneous(T,Tn,Itn);
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test24.history;
    
    %--------------------------
    %Test 2.5: Constant Profile
    %--------------------------
  case 25
    
    %------------------------
    %Test 2.6: Freezing Point
    %------------------------
  case 26
    [Tn,Itn] = remove_erroneous(T,8);
    fp = sw_fp(Tn.psal,Tn.pres);
    dt = Tn.temp-fp;
    I = find(dt<0);
    if ~isempty(I)
      disp(' Test 2.6 -> Data below freezing temperature');
      Tn.Qtemp(I) = 4;
      Tn.QCFF(I) = Tn.QCFF(I) + 2^7;
      fprintf(fid,'%s: Test 2.6 -> Data below freezing temperature\r\n',Tn.filename);
    else
      disp(' Test 2.6 ok')
      fprintf(fid, '%s\n', 'Test 2.5 ok');
    end
    [T] = replace_erroneous(T,Tn,Itn);
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test26.history;
    
    %-------------------------------------------------------
    %Test 2.7: Spike in temperature and salinity (one point)
    %-------------------------------------------------------
  case 27
    K = [];
    for j = 1:size(test27.name,1)
      [Tn,Itn] = remove_erroneous(T,j);
      par = eval(['Tn.' test27.name{j}]);
      dpar1 = par(2:end-1,:)-(par(3:end,:)+par(1:end-2,:))/2;
      dpar2 = (par(1:end-2,:)-par(3:end,:))/2;
      dpar = abs(dpar1)-abs(dpar2);
      I = find(dpar>test27.spikes(j));
      if ~isempty(I)
        disp([' Test 2.7 -> Spikes in ' test27.name{j}]);
        fprintf(fid, '%s\n', ['Test 2.7 -> Spikes in ' test27.name{j}]);
        eval(['Tn.Q' test27.name{j} '(I+1)=3;'])
        K = [K; Itn(I(:)+1)];
      end
      [T] = replace_erroneous(T,Tn,Itn);
    end
    if isempty(K)
      disp(' Test 2.7 ok');
      fprintf(fid, '%s\n', 'Test 2.7 ok');
    else
      T.QCFF(unique(K)) = T.QCFF(unique(K))+2^8;
    end
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test27.history;
    
    %----------------------------------------------------------------------
    %Test 2.8: Top and Bottom Spike in temperature and salinity (one point)
    %----------------------------------------------------------------------
  case 28
    K = [];
    for j = 1:size(test28.name,1)
      [Tn,Itn] = remove_erroneous(T,j+3);
      par = eval(['Tn.' test28.name{j}]);
      if length(~isnan(par)) > 2
        dpar1 = abs(par(1,:) - par(2,:))/2;		%surface
        I = find(dpar1 > test28.spikes(j)); %#ok<*EFIND>
        if ~isempty(I)
          disp([' Test 2.8 -> Spikes in ' test28.name{j} ' at the surface']);
          fprintf(fid, '%s\n', ['Test 2.8 -> Spikes in ' test28.name{j} ' at the surface']);
          eval(['Tn.Q' test28.name{j} '(1)=3;'])
          K = [K; Itn(1)];
        end
        dpar2 = abs(par(end,:)-par(end-1,:))./2;		%bottom
        I = find(dpar2 > test28.spikes(j));
        if ~isempty(I)
          disp([' Test 2.8 -> Spikes in ' test28.name{j} ' at the bottom']);
          fprintf(fid, '%s\n', ['Test 2.8 -> Spikes in ' test28.name{j} ' at the bottom']);
          eval(['Tn.Q' test28.name{j} '(end)=3;'])
          K = [K; Itn(end)];
        end
      else
        K = [];
      end
      [T] = replace_erroneous(T,Tn,Itn);
    end
    if isempty(K)
      disp(' Test 2.8 ok');
      fprintf(fid, '%s\n', 'Test 2.8 ok');
    else
      T.QCFF(unique(K)) = T.QCFF(unique(K)) + 2^9;
    end
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test28.history;
    
    %-----------------------------------
    %Test 2.9: Gradient (point to point)
    %-----------------------------------
  case 29
    K = [];
    for j = 1:size(test29.name,1)
      [Tn,Itn] = remove_doubtful(T,j+4);
      par = eval(['Tn.' test29.name{j}]);
      if length(~isnan(par)) > 2
        dpar = par(2:end-1,:) - ((par(3:end,:) + par(1:end-2,:))/2);
        dpar = 2 * dpar ./ (Tn.pres(3:end) - Tn.pres(1:end-2));
        I = find(abs(dpar) > test29.gradients(j));
        if ~isempty(I);
          disp([' Test 2.9 -> Gradients in ' test29.name{j} ' too high']);
          fprintf(fid, '%s\n', ['Test 2.9 -> Gradients in ' test29.name{j} ' too high']);
          eval(['Tn.Q' test29.name{j} '(I+1)=3;'])
          K = [K; Itn(I(:)+1)];
        end
        [T] = replace_erroneous(T,Tn,Itn);
      else
        K = [];
      end
    end
    if isempty(K)
      disp(' Test 2.9 ok');
      fprintf(fid, '%s\n', 'Test 2.9 ok');
    else
      T.QCFF(unique(K)) = T.QCFF(unique(K)) + 2^10; 
    end
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test29.history;
    
    %---------------------------------------------
    %Test 2.10: Density Inversion (point to point)
    %---------------------------------------------
  case 210
    [Tn,Itn] = remove_doubtful(T,7);
    par = eval(['Tn.' test210.name{1}]);
    if length(~isnan(par)) > 2
      dpar = par(2:end,:) - par(1:end-1,:);
      dpar = dpar ./ (Tn.pres(2:end) - Tn.pres(1:end-1));
      I = find(dpar < test210.invers);
      if ~isempty(I)
        disp(' Test 2.10 -> Density inversion found');
        fprintf(fid, '%s\n', 'Test 2.10 -> Density inversion found');
        eval(['Tn.Q' test210.name{1} '(I+1)=3;'])
        Tn.QCFF(I+1) = Tn.QCFF(I+1) + 2^11;
      else
        disp(' Test 2.10 ok');
        fprintf(fid, '%s\n', 'Test 2.10 ok');
      end
    else
      disp(' Test 2.10 ok');
      fprintf(fid, '%s\n', 'Test 2.10 ok');
    end
    [T] = replace_erroneous(T,Tn,Itn);
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test210.history;
    
    %--------------------------------------------------------
    %Test 2.11: Spike (one point or more) (suplementary test)
    %--------------------------------------------------------
  case 211 		%Difference between data and median(data)
    K = [];
    %findex=filtindex(T.pres,T.Qpres,T.sigt,T.Qsigt);
    findex = 3;
    for j = 1:size(test211.name,1)
      [Tn,Itn] = remove_doubtful(T,j);
      par = eval(['Tn.' test211.name{j}]);
      if length(~isnan(par)) > 2
        switch test211.name{j}
          case 'temp'
            findex = max([5 findex-6]);
        end
        parfilt = medfilt1_CL(par,findex);
        dpar = abs(par-parfilt);
        I = find(dpar>test211.spikes(j));
        if ~isempty(I);
          disp([' Test 2.11 -> Spikes in ' test211.name{j}]);
          fprintf(fid, '%s\n', ['Test 2.11 -> Spikes in ' test211.name{j}]);
          eval(['Tn.Q' test211.name{j} '(I)=3;'])
          K = [K; Itn(I(:))];
        end
        [T] = replace_erroneous(T,Tn,Itn);
      else
        K = [];
      end
    end
    if isempty(K)
      disp(' Test 2.11 ok');
      fprintf(fid, '%s\n', 'Test 2.11 ok');
    else
      T.QCFF(unique(K)) = T.QCFF(unique(K)) + 2^12;
    end
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test211.history;
    
    %----------------------------------------------
    %Test 2.12: Density Inversion (overall profile)
    %----------------------------------------------
  case 212
    [Tn,Itn] = remove_doubtful(T,7);
    par = eval(['Tn.' test212.name{1}]);
    if length(~isnan(par)) > 2
      dpar = par(2:end,:)-par(1:end-1,:);
      dpar = dpar./(Tn.pres(2:end)-Tn.pres(1:end-1));
      I = find(dpar<test212.invers);
      K = I(:);
    else
      K = [];
      I = [];
    end
    if ~isempty(K)
      disp(' Test 2.12 -> Density inversion found');
      fprintf(fid, '%s\n', 'Test 2.12 -> Density inversion found');
    else
      disp(' Test 2.12 ok');
      fprintf(fid, '%s\n', 'Test 2.12 ok');
    end
    while ~isempty(I)
      par(I+1) = par(I);
      dpar = par(2:end,:) - par(1:end-1,:);
      dpar = dpar ./ (Tn.pres(2:end) - Tn.pres(1:end-1));
      I = find(dpar < test212.invers);
      K = [K; I(:)];
    end
    eval(['Tn.Q' test212.name{1} '(K+1)=3;'])
    Tn.QCFF(unique(K)+1) = Tn.QCFF(unique(K)+1) + 2^13;
    [T] = replace_erroneous(T,Tn,Itn);
    T = refresh_Q(T);
    T.history{length(T.history)+1,1} = test212.history;
    
    %-------------------
    %Unknown Test Number
    %-------------------
  otherwise
    disp([' Unknown Test Number: ' num2str(testno)]);
    
end  %(swicth cases)

%Close state file
fclose(fid);

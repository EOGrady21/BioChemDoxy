function S_std = create_std(S_odf, call)
%CREATE_STD - Creates the quality control structure
%
%Syntax:  S_std = create_std(S_odf,call)
%The ODF-structure is converted to the STD-structure for the quality control
%procedure.
% S_odf is the ODF structure of multiple profiles
% S_std is the temporary structure used by the quality control program
% call is the platform call sign (optionnal)
%
%Other toolbox required: seawater
%M-files required: getvalue, sw_t68

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%Octobre 1999; Last revision: 05-Oct-1999 CL

% Updated for use at BIO by Jeff Jackson
% Last Updated: 20-APR-2011
% 
% Added code to handle FLOR and DOXY parameters and adapted code to work
% with ODS Toolbox Version 2.
% 

% Input variables.
if nargin==1
  call = input(['Enter call_sign (Ship: ' char(S_odf(1).Cruise_Header.Platform) ') -> '],'s');
end

for i = 1:max(size(S_odf))
  code = fieldnames(S_odf(i).Data);
  S_std(i).filename = getvalue(S_odf(i),'filename');
  S_std(i).call_sign = lower(call);
  S_std(i).cruiseid = char(getvalue(S_odf(i).Cruise_Header, 'cruise_number', 0));
  S_std(i).cruise_start = char(getvalue(S_odf(i).Cruise_Header, 'start_date', 0));
  S_std(i).cruise_end = char(getvalue(S_odf(i).Cruise_Header, 'end_date', 0));
  S_std(i).station = char(getvalue(S_odf(i).Event_Header, 'event_number', 0)); %#ok<*AGROW>
  S_std(i).lat = getvalue(S_odf(i).Event_Header, 'initial_lat', 0);
  S_std(i).lon = getvalue(S_odf(i).Event_Header, 'initial_lon', 0);
  S_std(i).time = datestr(char(getvalue(S_odf(i).Event_Header, 'start_date_time', 0)),0);
  S_std(i).lat_end = getvalue(S_odf(i).Event_Header, 'end_latitude', 0);
  if abs(S_std(i).lat_end) > 90
    S_std(i).lat_end = nan;
  end
  S_std(i).lon_end = getvalue(S_odf(i).Event_Header, 'end_longitude', 0);
  if abs(S_std(i).lon_end) > 180
    S_std(i).lon_end = nan;
  end
  S_std(i).time_end = datestr(char(getvalue(S_odf(i).Event_Header, 'end_date_time', 0)),0);
  S_std(i).sounding = getvalue(S_odf(i),'sounding');
  if S_std(i).sounding < 0
    S_std(i).sounding = nan;
  end
  S_std(i).interval = getvalue(S_odf(i),'sampling_interval');
  if S_std(i).interval < 0
    S_std(i).interval=nan;
  end
  S_std(i).cndc = getvalue(S_odf(i).Data, 'cndc_01', 0);
  S_std(i).pres = getvalue(S_odf(i).Data, 'pres_01', 0);
  S_std(i).deph = getvalue(S_odf(i).Data, 'deph_01', 0);
  if isempty(S_std(i).pres) && ~isempty(S_std(i).deph)
    S_std(i).pres = sw_pres(S_std(i).deph, S_std(i).lat);
  elseif ~isempty(S_std(i).pres) && isempty(S_std(i).deph)
    S_std(i).deph = sw_dpth(S_std(i).pres, S_std(i).lat);
  elseif isempty(S_std(i).pres) && isempty(S_std(i).deph)
    warning('No pressure or depth found'); %#ok<WNTAG>
  end
  if ~isempty(strmatchi('temp',code))
    S_std(i).temp = getvalue(S_odf(i).Data, 'temp_01', 0);
  elseif ~isempty(strmatchi('te90',code))
    S_std(i).temp = sw_t68(getvalue(S_odf(i).Data, 'te90_01', 0));
  else
    S_std(i).temp = nan * S_std(i).pres;
  end
  if isfield(S_odf(i).Data,'PSAL_01')
    S_std(i).psal = getvalue(S_odf(i).Data, 'psal_01', 0);
    S_std(i).sigt = getvalue(S_odf(i).Data, 'sigt_01', 0);
    if isempty(S_std(i).sigt)
      S_std(i).sigt = sw_dens(S_std(i).psal,S_std(i).temp,0) - 1000;
    end
  else
    S_std(i).psal = nan * S_std(i).temp;
    S_std(i).sigt = nan * S_std(i).temp;
  end
  if isfield(S_odf(i).Data,'DOXY_01')
    S_std(i).doxy = getvalue(S_odf(i).Data, 'doxy_01', 0);
  end
  if isfield(S_odf(i).Data,'FLOR_01')
    S_std(i).flor = getvalue(S_odf(i).Data, 'flor_01', 0);
  end
  S_std(i).dpdt = getvalue(S_odf(i).Data, 'dpdt_01', 0);
  S_std(i).ffff = getvalue(S_odf(i).Data, 'ffff_01', 0);
  if isempty(S_std(i).cndc)
    S_std(i).cndc = nan * S_std(i).temp;
  end
  if isempty(S_std(i).dpdt)
    S_std(i).dpdt = nan * S_std(i).temp;
  end
  
  %look for QQQQ
  if sum(strncmp('QQQQ',code,4)) > 0
    
    %PRES
    I = strncmp('PRES_01',code,7);
    I = find(I > 0);
    if ~isempty(I) && strncmp('QQQQ',code{I+1},4)
      S_std(i).Qpres = getvalue(S_odf(i).Data, char(code(I+1)), 0);
    else
      J = strncmp('DEPH_01',code,7);
      K = strncmp('QQQQ',code(J),4);
      if ~isempty(J) && ~isempty(K)
        S_std(i).Qpres = getvalue(S_odf(i).Data, char(code(J)), 0);
      else
        S_std(i).Qpres = ones(getvalue(S_odf(i),'Num_Cycle'),1);
      end
    end
    clear I J K;
    
    %DEPH
    I = strncmp('DEPH_01',code,7);
    I = find(I > 0);
    if ~isempty(I) && strncmp('QQQQ',code{I+1},4)
      S_std(i).Qdeph = getvalue(S_odf(i),char(code(I+1)));
    else
      I = strncmp('PRES_01',code,7);
      if strncmp('QQQQ',code(I),4)
        S_std(i).Qdeph = getvalue(S_odf(i),char(code(I+1)));
      else
        S_std(i).Qdeph = ones(length(S_std(i).pres),1);
      end
    end
    clear I;
    
    %TEMP
    I = strncmp('TEMP_01',code,7);
    I = find(I > 0);
    if isempty(I)
      I = strncmp('TE90_01',code,7);
    end
    if ~isempty(I) && (I ~= length(code)) && strncmp('QQQQ',code{I+1},4)
      S_std(i).Qtemp = getvalue(S_odf(i),char(code(I+1)));
    else
      S_std(i).Qtemp = ones(length(S_std(i).temp),1);
    end
    clear I;
    
    %PSAL
    I = strncmp('PSAL_01',code,7);
    I = find(I > 0);
    if ~isempty(I) && I~=length(code) && strncmp('QQQQ',code{I+1},4)
      S_std(i).Qpsal = getvalue(S_odf(i),char(code(I+1)));
    else
      S_std(i).Qpsal = ones(length(S_std(i).psal),1);
    end
    clear I;
    
    %DENS
    I = strncmp('DENS_01',code,7);
    I = find(I > 0);
    if isempty(I)
      I = strncmp('SIGP',code,4);
      I = find(I > 0);
    end
    if ~isempty(I) && (I ~= length(code)) && strncmp('QQQQ',code{I(1)+1},4)
      S_std(i).Qsigt = getvalue(S_odf(i),char(code(I+1)));
    else
      S_std(i).Qsigt = ones(length(S_std(i).sigt),1);
    end
    clear I;
    
    %DOXY
    I = strncmp('DOXY_01',code,7);
    I = find(I > 0);
    if isempty(I)
      I = strncmp('DOXY',code,4);
      I = find(I > 0);
    end
    if ~isempty(I) && (I ~= length(code)) && strncmp('QQQQ',code{I(1)+1},4)
      S_std(i).Qdoxy = getvalue(S_odf(i),char(code(I+1)));
    else
      S_std(i).Qdoxy = ones(length(S_std(i).doxy),1);
    end
    clear I;
    
    %FLOR
    I = strncmp('FLOR_01',code,7);
    I = find(I > 0);
    if isempty(I)
      I = strncmp('FLOR',code,4);
    end
    if ~isempty(I) && (I ~= length(code)) && strncmp('QQQQ',code{I(1)+1},4)
      S_std(i).Qflor = getvalue(S_odf(i),char(code(I+1)));
    else
      S_std(i).Qflor = ones(length(S_std(i).flor),1);
    end
    clear I;
    
    %QCFF
    I = strncmp('QCFF_01',code,7);
    I = find(I > 0);
    if ~isempty(I)
      S_std(i).QCFF = getvalue(S_odf(i),'qcff_01');
    else
      S_std(i).QCFF = ones(length(S_std(i).pres),1)*0;
    end
    clear I;

    %OTHER
    S_std(i).history = getvalue(S_odf(i),'quality_tests');
    S_std(i).comments = getvalue(S_odf(i),'quality_comments');
    
    %refresh_Q
    S_std(i) = refresh_Q(S_std(i));
  end
  
end

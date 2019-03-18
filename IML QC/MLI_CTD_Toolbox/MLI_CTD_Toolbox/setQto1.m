function S=setQto1(S,ffff)
%SETQTO1 - Set quality flag to one in STD structure.
%
%Syntax:  S = setQto1(S,ffff)
% S is the STD-structure with or without quality flag.
% If quality flags already exist, ask to reset or not.
% If ffff is 'flag', then quality flags are used
% If ffff is 'none', then quality flags are not used
% If fff is not specified, then a question is asked to know if
% seabird flags must be used or not.
%
%Toolbox required: Signal Processing

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 23-Nov-1999 CL

%Modifications
% - Reformatted the code to make it more readable and increased performance
% as advised by Matlab.
% - Added code to include QF fields for doxy and flor.
% JJ, 02-NOV-2011
% 
% Updated for use at BIO by Jeff Jackson
% Last Updated: 02-NOV-2011

%Open state file
fid = fopen(['state_' S(1).cruiseid '.txt'],'w');
fclose(fid);

%disp
disp('Setting Q flags to 1');

%Check input
if nargin == 1
  ffff = 'asks';
end
if isempty(S(1).ffff)
  ffff = 'asks';
end

%Check for existing quality flags
switch isfield(S,'Qpres');
  case 0
    resetQ = 'y';
  case 1
    resetQ = input('The Q quality flags already exist. Do you want to reset them to 1? (y or n) -> ','s');
end

%Set Qs
if resetQ == 'y'
  for i = 1:size(S,2)
    S(i).Qpres = ones(size(S(i).pres));
    S(i).Qdeph = ones(size(S(i).deph));
    S(i).Qtemp = ones(size(S(i).temp));
    S(i).Qpsal = ones(size(S(i).psal));
    S(i).Qsigt = ones(size(S(i).sigt));
    S(i).Qdoxy = ones(size(S(i).doxy));
    S(i).Qflor = ones(size(S(i).flor));
    S(i).Qtemp(isnan(S(i).temp)) = 9;
    S(i).Qpres(isnan(S(i).pres)) = 9;
    S(i).Qdeph(isnan(S(i).deph)) = 9;
    S(i).Qpsal(isnan(S(i).psal)) = 9;
    S(i).Qsigt(isnan(S(i).sigt)) = 9;
    S(i).Qdoxy(isnan(S(i).doxy)) = 9;
    S(i).Qflor(isnan(S(i).flor)) = 9;
    S(i).QCFF = zeros(size(S(i).temp));
    S(i).history = '';
    S(i).comments = '';
  end
end

%Check for existing FFFF (seabird treatement)
switch ffff
  case 'none'
    setffff = 'n';
  case 'flag'
    setffff = 'y';
  case 'asks'
    if resetQ == 'y'
      setffff = input('Do you want to use SEABIRD flag treatment? (y or n) -> ','s');
    else
      setffff = 'n';
    end
end

%Set Qs according to ffff
if setffff == 'y';
  for i = 1:size(S,2)
    I = find(isnan(S(i).ffff));
    S(i).Qpsal(I) = 3;
    S(i).Qsigt(I) = 3;
    S(i).QCFF(I) = 2;
  end
end

%Check for existing dpdt
if isempty(S(1).dpdt)
  for i = 1:size(S,2)
    %Removing negative pressure
    
    %Removing spikes in pressure
    scan = 1:length(S(i).pres);
    spikes = 1;
    pfilt = medfilt1(S(i).pres,7);
    dp = abs(S(i).pres-pfilt);
    I1 = find(dp>spikes | S(i).pres<0);
    I2 = setdiff(1:length(S(i).pres),I1);
    p = S(i).pres;
    if ~isempty(I1) && length(p)>7
      p(I1) = interp1(scan(I2),p(I2),scan(I1));
    end
    
    %Descent rate
    if ~isempty(S(i).interval) && (S(i).interval ~= 0) && (S(i).interval ~= -99)
      dpdt = (p(3:end)-p(1:end-2))/(2*S(i).interval);
      S(i).dpdt = [dpdt(1);dpdt;dpdt(end)];
    end
  end
end

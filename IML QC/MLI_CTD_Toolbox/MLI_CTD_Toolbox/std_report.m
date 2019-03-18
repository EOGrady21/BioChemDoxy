function std_report(S,comments)
%STD_REPORT - STD profile quality report
%
%Syntax: std_report(S,comments)
% S id the ODF-structure with quality flags included.
% This function reports the following information about the cruise (in french):
%   - Cruise number, chief scientist, platform and start and end date
%   - General comments
%   - Quality control tests done + explanations + state_(cruiseid).txt
%   - Salinity bottle comparison
%   - Quality flag description
%   - ODF format description
%   - Attached: profiles and global TS-diagram

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 24-Nov-1999 CL

%Modifications:
% - Suite à un commentaire d'un producteur de données qui juge l'information
% concernant certains tests erronée et non-pertinente, les résultats des
% tests 1.6 (sounding), 3.5 (climato Petrie), 4.1 (différence en temp
% >0.5°C) et 4.2 (climato IML) ne sont plus transférés dans le rapport. Les
% résultats demeurent cependant disponibles dans le fichier
% state_(no_mission).txt.
% lafleurc, 05-Apr-2006
%
% Updated for use at BIO by Jeff Jackson
% Last Updated: 21-APR-2011
%
% Reformatted code and changed the French output text into English and
% modified the code to work with ODS Toolbox Version 2.


%Inputs
if nargin == 1
  comments = {};
end

%Report filename
cruiseno = char(S(1).Cruise_Header.Cruise_Number);
file = ['Report_' cruiseno(3:end) '.txt'];

%Verify if a report file already exists
yesno = 'y';
if exist(file, 'file') == 2;
  yesno = input(['File ' file ' already exists. Do you want reset this file (y/n)? '],'s');
end

%Open report-file
if yesno == 'y'
  fid = fopen(file,'wt');
  
  A = cat(1,S.Cruise_Header);
  
  % Cruise information
  cruiseid = A.Cruise_Number;
  chief = A.Chief_Scientist;
  platform = A.Platform;
  start_date = A.Start_Date;
  end_date = A.End_Date;
  
  fprintf(fid, 'MISSION INFORMATION\n');
  fprintf(fid, '  Mission Number: %s\n',char(cruiseid));
  fprintf(fid, '  Chief Scientist: %s\n', char(chief));
  fprintf(fid, '  Platform: %s\n', char(platform));
  fprintf(fid, '  Mission Start Date: %s\n', char(start_date));
  fprintf(fid, '  Mission End Date: %s\n', char(end_date));
  
  %General comments
  fprintf(fid, '\nCOMMENTS\n');
  for i = 1:length(comments)
    fprintf(fid, '  %s\n', char(comments(i)));
  end
  
  %state_(cruiseid).txt
  if isfield(S,'Quality_Header')
    fid2 = fopen(['state_' char(S(1).Cruise_Header.Cruise_Number) '.txt'],'r');
    fprintf(fid, '\nRESULTS FROM THE QUALITY CONTROL\n');
    while feof(fid2) == 0
      t = fgetl(fid2);
      if ischar(t) && isempty(strfind('Test 1.6',t)) && isempty(strfind('Test 3.5',t)) ...
          && isempty(strfind('Test 4.2',t)) && isempty(strfind('Test 4.1',t))
        fprintf(fid, '  %s\n', t);
      end
    end
    fclose(fid2);
    
    %Quality tests done
    fprintf(fid, '\nQUALITY CONTROL\n');
    for i = 1:length(S(1).Quality_Header.Quality_Tests)
      fprintf(fid, '  %s\n', S(1).Quality_Header.Quality_Tests{i});
    end
    
    %Quality flag description
    fprintf(fid, '\nQUALITY CODES\n');
    fprintf(fid, '  0: no quality control\n');
    fprintf(fid, '  1: value seems correct\n');
    fprintf(fid, '  3: value seems doubtful\n');
    fprintf(fid, '  4: value seems erroneous\n');
    fprintf(fid, '  5: value was modified\n');
    fprintf(fid, '  9: value missing\n');
    
    %Quality QCFF
    fprintf(fid, '\nQCFF CHANNEL\n');
    fprintf(fid, '  The QCFF flag allows one to determine from which test(s) the quality flag(s) originate.\n');
    fprintf(fid, '  It only applies to the step 2 quality control tests. Each test in this\n');
    fprintf(fid, '  step is associated with a number 2x, where x is a whole positive number.\n');
    fprintf(fid, '  Before running the quality control, a QCFF value of 0 is attributed to each line of data.\n');
    fprintf(fid, '  When a test fails, the value of 2x that is associated with that test is added to the QCFF.\n');
    fprintf(fid, '  In this way one can easily identify which tests failed by analyzing the QCFF value.\n');
    fprintf(fid, '  If the QC flag of a record is modified by hand, a value of 1 is added to the QCFF.\n');
  end
  
  %Odf format
  fprintf(fid, '\nDESCRIPTION OF ODF FORMAT\n');
  fprintf(fid, '  ODF (Ocean Data Format) is the format utilised by BIO for storing\n');
  fprintf(fid, '  physical, biological, and chemical oceanographic data. Additional\n');
  fprintf(fid, '  information has been added to the format by MLI as part of the\n');
  fprintf(fid, '  quality control procedure they devised and has now been implemented\n');
  fprintf(fid, '  at BIO. The ODS Toolbox is a group of Matlab scripts used to\n');
  fprintf(fid, '  manipulate data stored in ODF files.\n');
  
  %Attached file
  fprintf(fid, '\nSUPPLEMENTARY INFORMATION\n');
  cr = char(getvalue(S(1),'cruise_number'));
  fprintf(fid, '  TS Diagram: TS_%s.jpg\n',cr(3:end));
  fprintf(fid, '  Profiles of temperature, salinite and sigma-T: STD_%s.avi\n',...
    cr(3:end));
  
  fclose(fid);
end

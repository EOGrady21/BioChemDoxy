function write_imlodf(varargin)
%WRITE_IMLODF - Writes an ODF array structure to a file (MLI)
%
%Class: ODF_Function
%
%ODS Version: 1.0
%Date: 26 August 1999
%
%Source: Ocean Sciences, DFO. (Dave Kellow)
%Modifications for new headers specific to MLI: Caroline Lafleur, SC/DSO, 14-Jan-2000
%
%Description: Writes an ODF array structure to a file.
%
%Usage: write_odf(A,[filename],[{'desparam1';'desparam2'}])
%
%Input:
%       A: the ODF-structured array
%filename: Optional. The filename to which the ODF information will be
%          written. If none is specified, the old ODF file will be overwritten.
%desparam: Optional. An array containing the parameter names of the
%          desired parameters, or the word 'ask' if the user wishes to be prompted for each one.
%
%Output:
% An ODF text file.
%
%Examples:
%write_odf(C) - takes the entire ODF array stored in C and outputs it to the filename previously stored in C.
%
%write_odf(A, "C:\newodfs\file3.odf", {'TEMP_01';'PSAL_01'}) - takes only the temperature and salinity
%information stored in A, and uses it to create a new odf file with the specified filename.
%
%Other Notes: The C programs 'writeodfdata' and 'writeodfdate' are used by this program to expedite data output.
%                                 The code for these programs can be found in the 'odftoolbox' directory.
%
%Toolbox required: ODSTools

%A modified write_odf function: ODSTools of BIO, Ocean Sciences, DFO. (Dave Kellow)
%CLafleur, December 1999
%Modification:
% - Ajout et modifications pour données de plancton
% CL, 20-Sep-2004
% - Ajout et modifications pour les données de bouées
% CL, 26-Apr-2006
% - skip writeodfdata.dll to write data to files (no longer works in R2007a)
%CL, 28-Jun-2007

% Updated for use at BIO by Jeff Jackson
% Last Updated: 23-JUN-2011
%
% Reformatted code and adapted code to work with ODS Toolbox Version 2.


%Set inputs to variables.
A = varargin{1};

%Update Structure and remove NaN Data.
if ~isempty(str2num(A.Event_Header.Event_Number)) && ~isempty(strmatch(' ',A.Event_Header.Event_Number))
  A.Event_Header.Event_Number = num2str(str2num(char(A.Event_Header.Event_Number)));
end
if ~isempty(str2num(A.Event_Header.Event_Qualifier1))
  A.Event_Header.Event_Qualifier1 = num2str(str2num(char(A.Event_Header.Event_Qualifier1)));
end
switch strtok(A.ODF_Header.File_Spec,'_')
  case {'PLNKG','MMOB','MADCP'}
    %A = updateodf(A);
  otherwise
    A = update_odf_v2(A);
    A = null2nan(A);
end
A = nan2null(A);

%Output filename
if length(varargin) >= 2
  filename = varargin{2};
else
  filename = [char(A.ODF_Header.File_Spec) '.odf'];
end
fchk = [filename, '*'];
m = dir(fchk);
if ~isempty(m)
  if length(m)>1
    r = zeros(length(m), 1);
    for i = (1:length(m))
      if length(m(i).name) > length(fliplr(strtok(fliplr(filename), '\')))
        r(i) = str2num(fliplr(strtok(fliplr(m(i).name),'.')));
      end
    end
    cc = max(r(i))+1;
  else
    cc = 1;
  end
  copyfile(filename, [filename, '.', num2str(cc)]);
end

if (length(varargin) < 3) || (strcmp(varargin{3},'all') == 1)
  e = length(A.Parameter_Header);
  desparam = 1:e;
elseif strcmp(varargin{3},'ask') == 1
  %select Parameters to be entered in ODF file.
  e = length(A.Parameter_Header);
  g = 0;
  i = 1;
  while i <= e
    inpstr = ['Do you wish to include ',char(39),char(A.Parameter_Header{i}.Code),char(39),'(Y/n)?'];
    answ = input(inpstr,'s');
    if ((strcmp(answ, 'Y') == 1) || (strcmp(answ, 'y') == 1) || (strcmp(answ, '') == 1))
      g = g + 1;
      desparam(g) = i;
      i = i + 1;
    elseif ((strcmp(answ, 'N') == 0) && (strcmp(answ, 'n') == 0))
      disp('Invalid Answer!');
    else
      i = i + 1;
    end
  end
else
  e = length(varargin{3});
  f = length(A.Parameter_Header);
  g = 0;
  h = 0;
  for i = 1:e
    for j = 1:f
      if(strcmp(varargin{3}{i},char(A.Parameter_Header{j}.Code))==1)
        g = g + 1;
        h = i;
        desparam(g) = j;
      end
    end
    if h ~= i
      error(['Parameter ',char(39),varargin{3}{i},char(39),' Not found in ODF Structure.'])
    end
  end
end

%Open File

fid = fopen(filename, 'wt');

%Write Header Information.

%Write ODF Header
fprintf(fid, 'ODF_HEADER,\n');
fprintf(fid, '  FILE_SPECIFICATION = %s,\n', (zqset(char(A.ODF_Header.File_Spec))));

%Write Cruise Header
fprintf(fid, 'CRUISE_HEADER,\n');
fprintf(fid, '  COUNTRY_INSTITUTE_CODE = %s,\n', (num2str(A.Cruise_Header.Country_Institute_Code)));
fprintf(fid, '  CRUISE_NUMBER = %s,\n', (zqset(char(A.Cruise_Header.Cruise_Number))));
fprintf(fid, '  ORGANIZATION = %s,\n', (zqset(char(A.Cruise_Header.Organization))));
fprintf(fid, '  CHIEF_SCIENTIST = %s,\n', (zqset(char(A.Cruise_Header.Chief_Scientist))));
fprintf(fid, '  START_DATE = %s,\n', (zqset(char(A.Cruise_Header.Start_Date))));
fprintf(fid, '  END_DATE = %s,\n', (zqset(char(A.Cruise_Header.End_Date))));
fprintf(fid, '  PLATFORM = %s,\n', (zqset(char(A.Cruise_Header.Platform))));
fprintf(fid, '  CRUISE_NAME = %s,\n', (zqset(char(A.Cruise_Header.Cruise_Name))));
fprintf(fid, '  CRUISE_DESCRIPTION = %s,\n', (zqset(char(A.Cruise_Header.Cruise_Description))));

%Write Event Header
fprintf(fid, 'EVENT_HEADER,\n');
fprintf(fid, '  DATA_TYPE= %s,\n', (zqset(char(A.Event_Header.Data_Type))));
fprintf(fid, '  EVENT_NUMBER= %s,\n', (zqset(char(A.Event_Header.Event_Number))));
fprintf(fid, '  EVENT_QUALIFIER1= %s,\n', (zqset(char(A.Event_Header.Event_Qualifier1))));
fprintf(fid, '  EVENT_QUALIFIER2= %s,\n', (zqset(char(A.Event_Header.Event_Qualifier2))));
fprintf(fid, '  CREATION_DATE= %s,\n', (zqset(char(A.Event_Header.Creation_Date))));
fprintf(fid, '  ORIG_CREATION_DATE= %s,\n', (zqset(char(A.Event_Header.Orig_Creation_Date))));
fprintf(fid, '  START_DATE_TIME= %s,\n', (zqset(char(A.Event_Header.Start_Date_Time))));
fprintf(fid, '  END_DATE_TIME= %s,\n', (zqset(char(A.Event_Header.End_Date_Time))));
fprintf(fid, '  INITIAL_LATITUDE= %f,\n', (A.Event_Header.Initial_Latitude));
fprintf(fid, '  INITIAL_LONGITUDE= %f,\n', (A.Event_Header.Initial_Longitude));
fprintf(fid, '  END_LATITUDE= %f,\n', (A.Event_Header.End_Latitude));
fprintf(fid, '  END_LONGITUDE= %f,\n', (A.Event_Header.End_Longitude));
fprintf(fid, '  MIN_DEPTH= %.2f,\n', (A.Event_Header.Min_Depth));
fprintf(fid, '  MAX_DEPTH= %.2f,\n', (A.Event_Header.Max_Depth));
fprintf(fid, '  SAMPLING_INTERVAL= %.1f,\n', (A.Event_Header.Sampling_Interval));
fprintf(fid, '  SOUNDING= %.2f,\n', (A.Event_Header.Sounding));
fprintf(fid, '  DEPTH_OFF_BOTTOM= %.2f', (A.Event_Header.Depth_Off_Bottom));

for i = 1:(length(A.Event_Header.Event_Comments))
  fprintf(fid, ',\n  EVENT_COMMENTS= %s', (zqset(char(A.Event_Header.Event_Comments{i}))));
end
fprintf(fid, ',\n');

%Write Buoy Header if present
if isfield(A,'Buoy_Header') && ~isempty(A.Buoy_Header)
  fprintf(fid, 'BUOY_HEADER,\n');
  fprintf(fid, '  NAME = %s,\n', (zqset(char(A.Buoy_Header.Name))));
  fprintf(fid, '  TYPE = %s,\n', (zqset(char(A.Buoy_Header.Type))));
  fprintf(fid, '  MODEL = %s,\n', (zqset(char(A.Buoy_Header.Model))));
  fprintf(fid, '  HEIGHT = %s,\n', (zqset(char(A.Buoy_Header.Height))));
  fprintf(fid, '  DIAMETER = %s,\n', (zqset(char(A.Buoy_Header.Diameter))));
  fprintf(fid, '  WEIGHT = %s,\n', (zqset(char(A.Buoy_Header.Weight))));
  fprintf(fid, '  DESCRIPTION = %s,\n', (zqset(char(A.Buoy_Header.Description))));
end

%Write Plankton Header if present
if isfield(A,'Plankton_Header') && ~isempty(A.Plankton_Header)
  fprintf(fid, 'PLANKTON_HEADER,\n');
  fprintf(fid, '  WATER_VOLUME= %.5f,\n', (A.Plankton_Header.Water_Volume));
  fprintf(fid, '  VOLUME_METHOD= %s,\n', (zqset(char(A.Plankton_Header.Volume_Method))));
  fprintf(fid, '  LRG_PLANKTON_REMOVED= %s,\n', (zqset(char(A.Plankton_Header.Lrg_Plankton_Removed))));
  fprintf(fid, '  COLLECTION_METHOD= %s,\n', (zqset(char(A.Plankton_Header.Collection_Method))));
  fprintf(fid, '  MESH_SIZE= %.0f,\n', (A.Plankton_Header.Mesh_Size));
  fprintf(fid, '  PHASE_OF_DAYLIGHT= %s,\n', (zqset(char(A.Plankton_Header.Phase_Of_Daylight))));
  fprintf(fid, '  COLLECTOR_DPLMT_ID= %s,\n', (zqset(char(A.Plankton_Header.Collector_Dplmt_Id))));
  fprintf(fid, '  COLLECTOR_SAMPLE_ID= %s,\n', (zqset(char(A.Plankton_Header.Collector_Sample_Id))));
  fprintf(fid, '  PROCEDURE= %s,\n', (zqset(char(A.Plankton_Header.Procedure))));
  fprintf(fid, '  PRESERVATION= %s,\n', (zqset(char(A.Plankton_Header.Preservation))));
  fprintf(fid, '  STORAGE= %s,\n', (zqset(char(A.Plankton_Header.Storage))));
  fprintf(fid, '  METERS_SQD_FLAG= %s', (zqset(char(A.Plankton_Header.Meters_Sqd_Flag))));
  for i = 1:(length(A.Plankton_Header.Plankton_Comments))
    fprintf(fid, ',\n  PLANKTON_COMMENTS= %s', (zqset(char(A.Plankton_Header.Plankton_Comments{i}))));
  end
  fprintf(fid, ',\n');
end

%Write Meteo Header if present
if isfield(A,'Meteo_Header') && ~isempty(A.Meteo_Header)
  a(1)=getvalue(A,'air_temperature');
  a(2)=getvalue(A,'atmospheric_pressure');
  a(3)=getvalue(A,'wind_speed');
  a(4)=getvalue(A,'wind_direction');
  a(5)=getvalue(A,'sea_state');
  a(6)=getvalue(A,'cloud_cover');
  a(7)=getvalue(A,'ice_thickness');
  if max(a) ~= -99
    fprintf(fid, 'METEO_HEADER,\n');
    fprintf(fid, '  AIR_TEMPERATURE= %.2f,\n', (A.Meteo_Header.Air_Temperature));
    fprintf(fid, '  ATMOSPHERIC_PRESSURE= %.2f,\n', (A.Meteo_Header.Atmospheric_Pressure));
    fprintf(fid, '  WIND_SPEED= %.2f,\n', (A.Meteo_Header.Wind_Speed));
    fprintf(fid, '  WIND_DIRECTION= %.2f,\n', (A.Meteo_Header.Wind_Direction));
    fprintf(fid, '  SEA_STATE= %.0f,\n', (A.Meteo_Header.Sea_State));
    fprintf(fid, '  CLOUD_COVER= %.0f,\n', (A.Meteo_Header.Cloud_Cover));
    fprintf(fid, '  ICE_THICKNESS= %.2f,\n', (A.Meteo_Header.Ice_Thickness));
    for i = 1:(length(A.Meteo_Header.Meteo_Comments))
      fprintf(fid, '  METEO_COMMENTS= %s,\n', (zqset(char(A.Meteo_Header.Meteo_Comments{i}))));
    end
  end
end

%Write Instrument Header
if isfield(A,'Instrument_Header') && ~isempty(A.Instrument_Header)
  fprintf(fid, 'INSTRUMENT_HEADER,\n');
  fprintf(fid, '  INST_TYPE= %s,\n',(zqset(char(A.Instrument_Header.Inst_Type))));
  fprintf(fid, '  MODEL= %s,\n',(zqset(char(A.Instrument_Header.Model))));
  fprintf(fid, '  SERIAL_NUMBER= %s,\n',(zqset(char(A.Instrument_Header.Serial_Number))));
  fprintf(fid, '  DESCRIPTION= %s,\n',(zqset(char(A.Instrument_Header.Description))));
end

%Write Buoy Instrument Header if present
if isfield(A,'Buoy_Instrument_Header') && ~isempty(A.Buoy_Instrument_Header)
  for i = 1:length(A.Buoy_Instrument_Header)
    fprintf(fid, 'BUOY_INSTRUMENT_HEADER,\n');
    fprintf(fid, '  NAME= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Name))));
    fprintf(fid, '  TYPE= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Type))));
    fprintf(fid, '  MODEL= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Model))));
    fprintf(fid, '  SERIAL_NUMBER= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Serial_Number))));
    fprintf(fid, '  DESCRIPTION= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Description))));
    fprintf(fid, '  INST_START_DATE_TIME= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Inst_Start_Date_Time))));
    fprintf(fid, '  INST_END_DATE_TIME= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Inst_End_Date_Time))));
    for j = 1:max(size(A.Buoy_Instrument_Header{i}.Buoy_Instrument_Comments))
      fprintf(fid, '  BUOY_INSTRUMENT_COMMENTS= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Buoy_Instrument_Comments{j}))));
    end
    for j = 1:max(size(A.Buoy_Instrument_Header{i}.Sensors))
      fprintf(fid, '  SENSORS= %s,\n',(zqset(char(A.Buoy_Instrument_Header{i}.Sensors{j}))));
    end
  end
end

%Write Quality Header
if isfield(A,'Quality_Header') && ~isempty(A.Quality_Header)
  fprintf(fid, 'QUALITY_HEADER,\n');
  fprintf(fid, '  QUALITY_DATE= %s,\n',(zqset(char(A.Quality_Header.Quality_Date))));
  for j = 1:length(A.Quality_Header.Quality_Tests)
    fprintf(fid, '  QUALITY_TESTS= %s,\n',(zqset(char(A.Quality_Header.Quality_Tests{j}))));
  end
  for j = 1:length(A.Quality_Header.Quality_Comments)
    fprintf(fid, '  QUALITY_COMMENTS= %s,\n',(zqset(char(A.Quality_Header.Quality_Comments{j}))));
  end
end

% Determine which General Calibration headers need to be included.
if isfield(A,'General_Cal_Header') && ~isempty(A.General_Cal_Header)
  f = length(A.General_Cal_Header);
  descalib = [];
  h = 1;
  for i = desparam
    for j = 1:f
      if (strcmp(A.Parameter_Header{i}.Code, A.General_Cal_Header{j}.Parameter_Code) == 1) || ...
          ~isempty(strmatchi(A.Parameter_Header{i}.Code(1:4),{'CNDC';'PRES';'DEPH';'PSAL'}))
        descalib(h) = j;
        h = h + 1;
      end
    end
  end
  descalib=unique(descalib);
  
  %Write General Calibration Headers
  if e > 0
    for i = descalib
      fprintf(fid, 'GENERAL_CAL_HEADER,\n');
      fprintf(fid, '  PARAMETER_CODE= %s,\n', (zqset(char(A.General_Cal_Header{i}.Parameter_Code))));
      fprintf(fid, '  CALIBRATION_TYPE= %s,\n', (zqset(char(A.General_Cal_Header{i}.Calibration_Type))));
      fprintf(fid, '  CALIBRATION_DATE= %s,\n', (zqset(char(A.General_Cal_Header{i}.Calibration_Date))));
      fprintf(fid, '  APPLICATION_DATE= %s,\n', (zqset(char(A.General_Cal_Header{i}.Application_Date))));
      fprintf(fid, '  NUMBER_COEFFICIENTS= %d,\n', (A.General_Cal_Header{i}.Number_Coefficients));
      fprintf(fid, '  COEFFICIENTS=');
      for j = (1:A.General_Cal_Header{i}.Number_Coefficients)
        fprintf(fid, ' %12.8e ', (A.General_Cal_Header{i}.Coefficients(j)));
      end
      fprintf(fid, ',\n');
      for j = 1:length(A.General_Cal_Header{i}.Calibration_Equation)
        fprintf(fid, '  CALIBRATION_EQUATION= %s,\n', (zqset(char(A.General_Cal_Header{i}.Calibration_Equation{j}))));
      end
      for j = 1:(length(A.General_Cal_Header{i}.Calibration_Comments))
        fprintf(fid, '  CALIBRATION_COMMENTS= %s,\n', (zqset(char(A.General_Cal_Header{i}.Calibration_Comments{j}))));
      end
    end
  end
end
% Determine which Polynomial Calibration headers need to be included.
if isfield(A,'Polynomial_Cal_Header') && ~isempty(A.Polynomial_Cal_Header)
  f = length(A.Polynomial_Cal_Header);
  descalib = [];
  h = 1;
  for i = desparam
    for j = 1:f
      if (strcmp(A.Parameter_Header{i}.Code,A.Polynomial_Cal_Header{j}.Parameter_Code)==1) || ...
          ~isempty(strmatchi(A.Parameter_Header{i}.Code(1:4),{'CNDC';'PRES';'DEPH';'PSAL'}))
        descalib(h) = j;
        h=h+1;
      end
    end
  end
  descalib = unique(descalib);
  
  %Write Polynomial Calibration Headers
  if e > 0
    for i = descalib
      fprintf(fid, 'POLYNOMIAL_CAL_HEADER,\n');
      fprintf(fid, '  PARAMETER_CODE= %s,\n', (zqset(char(A.Polynomial_Cal_Header{i}.Parameter_Code))));
      fprintf(fid, '  CALIBRATION_DATE= %s,\n', (zqset(char(A.Polynomial_Cal_Header{i}.Calibration_Date))));
      fprintf(fid, '  APPLICATION_DATE= %s,\n', (zqset(char(A.Polynomial_Cal_Header{i}.Application_Date))));
      fprintf(fid, '  NUMBER_COEFFICIENTS= %d,\n', (A.Polynomial_Cal_Header{i}.Number_Coefficients));
      fprintf(fid, '  COEFFICIENTS=');
      for j = (1:A.Polynomial_Cal_Header{i}.Number_Coefficients)
        fprintf(fid, ' %12.8e ', (A.Polynomial_Cal_Header{i}.Coefficients(j)));
      end
      fprintf(fid, ',\n');
    end
  end
end

%Write Compass Calibration Headers
if isfield(A,'Compass_Cal_Header') && ~isempty(A.Compass_Cal_Header)
  e = length(A.Compass_Cal_Header);
  if e > 0
    for i = 1:e
      fprintf(fid, 'COMPASS_CAL_HEADER,\n');
      fprintf(fid, '  PARAMETER_CODE= %s,\n', (zqset(char(A.Compass_Cal_Header{i}.Parameter_Code))));
      fprintf(fid, '  CALIBRATION_DATE= %s,\n', (zqset(char(A.Compass_Cal_Header{i}.Calibration_Date))));
      fprintf(fid, '  APPLICATION_DATE= %s,\n', (zqset(char(A.Compass_Cal_Header{i}.Application_Date))));
      %Assumes 36 Directions/Corrections, in Accordance with the manual.
      for j = 0:8
        fprintf(fid, '  DIRECTIONS= % 12.8e   % 12.8e   % 12.8e   % 12.8e,\n',A.Compass_Cal_Header{i}.Directions(((4*j)+1):((4*j)+4)));
      end
      for j = 0:8
        fprintf(fid, '  CORRECTIONS= % 12.8e   % 12.8e   % 12.8e   % 12.8e,\n',A.Compass_Cal_Header{i}.Corrections(((4*j)+1):((4*j)+4)));
      end
    end
  end
end

%Write History Headers
if isfield(A,'History_Header') && ~isempty(A.History_Header)
  e = length(A.History_Header);
  if e > 0
    for i = 1:e
      fprintf(fid, 'HISTORY_HEADER,\n');
      fprintf(fid, '  CREATION_DATE= %s',(zqset(char(A.History_Header{i}.Creation_Date))));
      f = length(A.History_Header{i}.Process);
      if f == 0
        fprintf(fid, ',\n');
      else
        fprintf(fid, ',\n');
      end
      if f >= 2
        for j = 1:(f-1)
          fprintf(fid, '  PROCESS= %s,\n',(zqset(char(A.History_Header{i}.Process{j}))));
        end
      end
      if f >= 1
        fprintf(fid, '  PROCESS= %s,\n',(zqset(char(A.History_Header{i}.Process{f}))));
      end
    end
  end
end

%Write Parameter Headers
for i = desparam
  code = char(A.Parameter_Header{i}.Code);
  I_ = findstr(code,'_');
  strrep(code(1:I_-1),'n','');
  hh = gf3defs(strrep(code(1:I_(end)-1),'n',''));
  if ~isfield(A.Parameter_Header{i}, 'Name');
    A.Parameter_Header{i}.Name = cellstr(hh.desc);
  end
  fprintf(fid, 'PARAMETER_HEADER,\n');
  fprintf(fid, '  TYPE= %s,\n',(zqset(char(A.Parameter_Header{i}.Type))));
  fprintf(fid, '  NAME= %s,\n',(zqset(char(A.Parameter_Header{i}.Name))));
  fprintf(fid, '  UNITS= %s,\n',(zqset(char(A.Parameter_Header{i}.Units))));
  fprintf(fid, '  CODE= %s,\n',(zqset(strrep(char(A.Parameter_Header{i}.Code),'n',''))));
  if isfield(A.Parameter_Header{i},'NULL_Value')
    switch char(A.Parameter_Header{i}.Type)
      case 'CHAR'
        fprintf(fid, '  NULL_VALUE= %s,\n',(zqset(char(A.Parameter_Header{i}.NULL_Value))));
      otherwise
        fprintf(fid, '  NULL_VALUE= %s,\n',(char(A.Parameter_Header{i}.NULL_Value)));
    end
  end
  fprintf(fid, '  PRINT_FIELD_WIDTH= %d,\n',A.Parameter_Header{i}.Print_Field_Width);
  fprintf(fid, '  PRINT_DECIMAL_PLACES= %d,\n',A.Parameter_Header{i}.Print_Decimal_Places);
  fprintf(fid, '  ANGLE_OF_SECTION= %f,\n',A.Parameter_Header{i}.Angle_of_Section);
  fprintf(fid, '  MAGNETIC_VARIATION= %f,\n',A.Parameter_Header{i}.Magnetic_Variation);
  fprintf(fid, '  DEPTH= %f ',A.Parameter_Header{i}.Depth);
  if (length(fieldnames(A.Parameter_Header{i})) > 10)
    switch char(A.Parameter_Header{i}.Type)
      case 'CHAR'
        fprintf(fid, ',\n  MINIMUM_VALUE= %s,\n',(zqset(A.Parameter_Header{i}.Minimum_Value)));
        fprintf(fid, '  MAXIMUM_VALUE= %s,\n',(zqset(A.Parameter_Header{i}.Maximum_Value)));
      otherwise
        fprintf(fid, ',\n  MINIMUM_VALUE= %s,\n',char(A.Parameter_Header{i}.Minimum_Value));
        fprintf(fid, '  MAXIMUM_VALUE= %s,\n',char(A.Parameter_Header{i}.Maximum_Value));
    end
    fprintf(fid, '  NUMBER_VALID= %d,\n',A.Parameter_Header{i}.Number_Valid);
    fprintf(fid, '  NUMBER_NULL= %d,\n',A.Parameter_Header{i}.Number_Null);
  else
    fprintf(fid, ',\n');
  end
end

%Write Record Header
if ~isfield(A,'General_Cal_Header'), A.General_Cal_Header=[]; end
if ~isfield(A,'Polynomial_Cal_Header'), A.Polynomial_Cal_Header=[]; end
if ~isfield(A,'Compass_Cal_Header'), A.Compass_Cal_Header=[]; end
fprintf(fid, 'RECORD_HEADER,\n');
fprintf(fid, '  NUM_CALIBRATION= %d,\n', length(A.Polynomial_Cal_Header)+length(A.General_Cal_Header));
fprintf(fid, '  NUM_SWING= %d,\n', length(A.Compass_Cal_Header));
fprintf(fid, '  NUM_HISTORY= %d,\n', length(A.History_Header));
fprintf(fid, '  NUM_CYCLE= %d,\n', A.Record_Header.Num_Cycle);
fprintf(fid, '  NUM_PARAM= %d,\n', length(desparam));

%Write Data Header
fprintf(fid, ' -- DATA -- \n');

%Switch case for PLNKG files
switch A.Event_Header.Data_Type
  case 'MMOB'
    %String format
    n = A.Record_Header.Num_Cycle;
    str = [repmat('''',n,1) datestr(gregorian(A.Matdate),0) repmat('.00''  ',n,1)];
    for i=1:length(A.Parameter_Header)
      width = A.Parameter_Header{i}.Print_Field_Width;
      decim = A.Parameter_Header{i}.Print_Decimal_Places;
      switch A.Parameter_Header{i}.Name(1:5)
        case 'Time '
        case {'Radia','Irrad'}
          form = ['%' num2str(width,'%.0f') '.' num2str(decim,'%.0f') 'E  '];
          str = [str reshape(sprintf(form,A.Data.(['n' A.Parameter_Header{i}.Code])),width+2,n)'];
        otherwise
          form = ['%' num2str(width,'%.0f') '.' num2str(decim,'%.0f') 'f  '];
          str = [str reshape(sprintf(form,A.Data.(A.Parameter_Header{i}.Code)),width+2,n)'];
      end
    end
    %Print data to a cell array if strings
    for i = 1:n
      while ~isempty(findstr(str(i,:),' '' '))
        str(i,:) = strrep(str(i,:),' '' ','''  ');
      end
      fprintf(fid,'%s\n',str(i,:));
    end
    fclose(fid);
  otherwise
    n = A.Record_Header.Num_Cycle;
    str = repmat(' ',n,1);
    for i=1:length(A.Parameter_Header)
      width = A.Parameter_Header{i}.Print_Field_Width;
      decim = A.Parameter_Header{i}.Print_Decimal_Places;
      switch A.Parameter_Header{i}.Type
        case 'CHAR'
          str = [str repmat('''',n,1) eval(['A.Data.' A.Parameter_Header{i}.Code]) repmat('''  ',n,1)];
        case 'SYTM'
          str = [str repmat('''',n,1) upper(datestr(gregorian(A.Matdate),0)) repmat('.00''  ',n,1)];
        otherwise
          form = ['%' num2str(width,'%.0f') '.' num2str(decim,'%.0f') 'f  '];
          str = [str reshape(sprintf(form,eval(['A.Data.' A.Parameter_Header{i}.Code])'),width+2,n)'];
      end
    end
    %Print data to a cell array if strings
    for i = 1:n
      while ~isempty(findstr(str(i,:),' '' '))
        str(i,:) = strrep(str(i,:),' '' ','''  ');
      end
      fprintf(fid, '%s\n', str(i,1:end-1));
    end
    fclose(fid);
end
% %Close File
% fclose(fid);
%
% %Determine writeodfdata inputs
%
% g=0;
% params=0;
% timepos=-1;
% ddata=zeros(A.Record_Header.Num_Cycle,1);
% fieldval=zeros(1,2);
% for i=(desparam)
%    if((strcmp((char(A.Parameter_Header{i}.Code)),'Time')==1)|(findstr('SYTM',(char(A.Parameter_Header{i}.Code)))>0))
%       timepos=g;
%       dvect=gregorian(A.Matdate);
%    else
%       g=g+1;
%       tname = deblank(char(A.Parameter_Header{i}.Code));
%       tname = strrep(tname, ' ', '_');
%       tname = strrep(tname, char(46), '_');
%       f=num2str(g);
%       eval(['ddata(:,',f,') = A.Data.',tname,';']);
%       fieldval(g,1)=A.Parameter_Header{i}.Print_Field_Width;
%       fieldval(g,2)=A.Parameter_Header{i}.Print_Decimal_Places;
%       params=params+1;
%    end
% end
%
% if(timepos==-1)
%    dvect=zeros(A.Record_Header.Num_Cycle,6);
% end
%
% %Call writeodfdata routine
%
% writeodfdata(A.Record_Header.Num_Cycle, params, ddata, filename, timepos, dvect, fieldval);
%
% end

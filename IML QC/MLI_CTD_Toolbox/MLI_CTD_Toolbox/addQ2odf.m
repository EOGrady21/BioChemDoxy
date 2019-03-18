function S_odf=addQ2odf(S_odf,S_std)
%ADDQ2ODF - Adds quality flags to ODF structure array
%
%Syntax:  S_odf=addQ2odf(S_odf,S_std)
% S_odf is the ODF structure of multiple profiles
%   S_odf as input: without the quality controled
%   S_odf as output: with the quality controled
%
% S_std is the temporary STD-structure used by the quality control program
% to which flag have been added by the quality control procedure.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%Octobre 1999; Last revision: 21-Oct-1999 CL

% Updated for use at BIO by Jeff Jackson
% Last Updated: 21-APR-2011
%
% Reformatted code and adapted code to work with ODS Toolbox Version 2.

[odf_file{1:size(S_odf,2)}] = deal(S_odf.filename);

%Quality names
for i = 1:size(S_std,2)
  clear G
  
  %File link
  std = S_std(i);
  Iodf = strmatchi(std.filename,odf_file);
  odf = S_odf(Iodf);
  
  %remove existing Qs
  Qi = fieldnames(odf.Data);
  I = strmatchi('QQQQ',Qi);
  for j = 1:length(I)
    odf = remove_parameter(odf,char(Qi(I(j))));
  end
  
  %disp(['STD: ' std.filename '; ODF: ' S_odf(Iodf).filename])
  
  %Variable links
  names = fieldnames(std);
  I = strmatchi('Q',names);
  [dataQ{1:length(I)}] = deal(names{I(1:end)});
  dataQ = setdiff(dataQ,'QCFF');
  dataQ = char(dataQ);
  dataQ = dataQ(:,2:5);
  dataQ = cellstr(dataQ);
  data = fieldnames(odf.Data);
  
  %matdate
  param = cat(1,odf.Parameter_Header);
  code = cell(0);
  for k = 1:size(param,1), code{k}=char(param{k}.Code); end
  K = strmatch('SYTM',code);
  if ~isempty(K)
    Stemp = odf.Parameter_Header(K);
    L = setdiff((1:length(code)),K);
    odf.Parameter_Header = odf.Parameter_Header(L);
  end
  
  k = 0;
  for j = 1:length(data)
    switch data{j}(1:4)
      case 'TE90'
        Istd = strmatchi('TEMP',dataQ);
      case 'POTM'
        Istd = strmatchi('TEMP',dataQ);
      case 'DENS'
        Istd = strmatchi('SIGT',dataQ);
      case 'SIGP'
        Istd = strmatchi('SIGT',dataQ);
      case 'SIG0'
        Istd = strmatchi('SIGT',dataQ);
      otherwise
        Istd = strmatchi(data{j}(1:4),dataQ);
    end
    
    %Data
    eval(['G.Data.' data{j} '=odf.Data.' data{j} ';'])
    
    %Parameter_Header
    G.Parameter_Header{j+k,1} = odf.Parameter_Header{j};
    
    %QQQQ
    if ~isempty(Istd)
      k = k + 1;
      
      %Data QQQQ
      QQQQ = eval(['std.Q' dataQ{Istd}]);
      eval(['G.Data.QQQQ_' num2str(k,'%2.2d') '=QQQQ;'])
      
      %Parameter_Header QQQQ
      I_ = findstr('_',data{j});
      R = gf3defs(data{j}(1:I_-1));
      G.Parameter_Header{j+k,1}.Type = 'DOUB';
      G.Parameter_Header{j+k,1}.Name = ['Quality flag: ' R.desc];
      G.Parameter_Header{j+k,1}.Units = 'none';
      G.Parameter_Header{j+k,1}.Code = ['QQQQ_' num2str(k,'%2.2d')];
      G.Parameter_Header{j+k,1}.NULL_Value = G.Parameter_Header{j+k-1}.NULL_Value;
      G.Parameter_Header{j+k,1}.Print_Field_Width =	1;
      G.Parameter_Header{j+k,1}.Print_Decimal_Places = 0;
      G.Parameter_Header{j+k,1}.Angle_of_Section = 0;
      G.Parameter_Header{j+k,1}.Magnetic_Variation = 0;
      G.Parameter_Header{j+k,1}.Depth = 0;
      G.Parameter_Header{j+k,1}.Minimum_Value = num2str(nanmin(QQQQ),'%.0f');
      G.Parameter_Header{j+k,1}.Maximum_Value = num2str(nanmax(QQQQ),'%.0f');
      G.Parameter_Header{j+k,1}.Number_Valid = length(QQQQ);
      G.Parameter_Header{j+k,1}.Number_NULL = 0;
    end
  end
  
  %QCFF
  k = k + 1;
  
  %Data QCFF
  G.Data.QCFF_01 = std.QCFF;
  
  %Parameter_Header QCFF
  l=length(num2str(max(std.QCFF),'%.0f'));
  G.Parameter_Header{j+k}.Type = 'DOUB';
  G.Parameter_Header{j+k}.Name = 'Quality flag: QCFF';
  G.Parameter_Header{j+k}.Units = 'none';
  G.Parameter_Header{j+k}.Code = 'QCFF_01';
  G.Parameter_Header{j+k}.NULL_Value = G.Parameter_Header{j+k-1}.NULL_Value;
  G.Parameter_Header{j+k}.Print_Field_Width = l;
  G.Parameter_Header{j+k}.Print_Decimal_Places = 0;
  G.Parameter_Header{j+k}.Angle_of_Section = 0;
  G.Parameter_Header{j+k}.Magnetic_Variation = 0;
  G.Parameter_Header{j+k}.Depth = 0;
  G.Parameter_Header{j+k}.Minimum_Value = cellstr(num2str(min(std.QCFF),'%.0f'));
  G.Parameter_Header{j+k}.Maximum_Value = cellstr(num2str(max(std.QCFF),'%.0f'));
  G.Parameter_Header{j+k}.Number_Valid = length(std.QCFF);
  G.Parameter_Header{j+k}.Number_NULL = 0;
  
  %SYTM
  if exist('Stemp','var')
    G.Parameter_Header=[Stemp; G.Parameter_Header];
  end
  
  %addQ2odf
  S_odf(Iodf).Data = G.Data;
  S_odf(Iodf).Parameter_Header = G.Parameter_Header;
  S_odf(Iodf).Record_Header.Num_Param = length(S_odf(Iodf).Parameter_Header);
  S_odf(Iodf).Quality_Header.Quality_Date = cellstr(mdate(datevec(now)));
  S_odf(Iodf).Quality_Header.Quality_Tests = std.history;
  S_odf(Iodf).Quality_Header.Quality_Comments = ...
    {'QCFF values are derived from tests of GTSPP stage 2';...
    'A quality flag modified by hand has a QCFF value of 1'};
  
  %add more comments lines
  if ~isempty(std.comments)
    S_odf(Iodf).Quality_Header.Quality_Comments = [S_odf(Iodf).Quality_Header.Quality_Comments ; std.comments(:)];
  end
  
  %End loop
end
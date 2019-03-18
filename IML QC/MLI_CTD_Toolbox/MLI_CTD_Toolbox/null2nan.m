function A = nan2null(A)
%Substitutes NaN data for null data in ODF structured Dataset.
%
%Class: Analysis_Function
%
%ODS Version: 1.0
%Date: 26 August 1999
%
%
%Source: Ocean Sciences, DFO. (Dave Kellow)
%
%Description:NULL2NAN(A) Substitutes null data for NaN data in ODF structured Dataset.
%
%Usage:A = NULL2NAN(A)
%
%Input:
%A: The ODF structured array.
%
%Output:
%A: The ODF structured array with null data in place of NaN data.
%
%Example:
% A = NULL2NAN(A)
%Other Notes: ODF uses a null data value (stored in the ODF parameter header for each parameter). MatLab
%             uses NaN (not a number).
%
%Modifications:
% - ajout date nulle, radiance and irradiance
% lafleurc


e = length(A.Parameter_Header);

for i = (1:e)

   switch A.Parameter_Header{i}.Type{1}   
   case 'SYTM'
      null=A.Parameter_Header{i}.NULL_Value{1};
      A.Matdate(A.Matdate==julian(datevec(null))) = NaN;
   case 'CHAR'
   otherwise
      switch A.Parameter_Header{i}.Name{1}(1:5)
      case {'Radia','Irrad'}
         eval(['A.Data.n',char(A.Parameter_Header{i}.Code),'(find(A.Data.n',char(A.Parameter_Header{i}.Code),' == (str2num(char(A.Parameter_Header{',num2str(i),'}.NULL_Value))))) = NaN;']);
      otherwise
         eval(['A.Data.',char(A.Parameter_Header{i}.Code),'(find(A.Data.',char(A.Parameter_Header{i}.Code),' == (str2num(char(A.Parameter_Header{',num2str(i),'}.NULL_Value))))) = NaN;']);
      end
   end
   
end





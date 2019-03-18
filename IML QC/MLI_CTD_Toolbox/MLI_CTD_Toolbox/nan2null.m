function A = nan2null(A)
%Changes all NaN data into null data in ODF structured Dataset.
%
%Class: Analysis_Function
%
%ODS Version: 1.0
%Date: 26 August 1999
%
%
%Source: Ocean Sciences, DFO. (Dave Kellow)
%
%Description:NAN2NULL(A) Changes all NaN data into null data in ODF structured Dataset.
%
%Usage:A = NAN2NULL(A)
%
%Input:
%A: The ODF structured array.
%
%Output:
%A: The ODF structured array with null data in place of NaN data.
%
%Example:
% A = nan2null(A)
%Other Notes: ODF uses a null data value (stored in the ODF parameter header for each parameter). MatLab
%             uses NaN (not a number).
%
%Modifications:
% - Valeur null de Matdate
% cl, 30-mai-2006

e = length(A.Parameter_Header);

for i = (1:e)

   switch A.Parameter_Header{i}.Type{1}
   case 'SYTM'
       null=A.Parameter_Header{i}.NULL_Value{1};
       A.Matdate(isnan(A.Matdate)) = julian(datevec(null));
   case 'CHAR'
   otherwise
       eval(['A.Data.',char(A.Parameter_Header{i}.Code),'(find(isnan(A.Data.',char(A.Parameter_Header{i}.Code),'))) = ((round(10000*(str2num(char(A.Parameter_Header{',num2str(i),'}.NULL_Value)))))/10000);']);
   end

end





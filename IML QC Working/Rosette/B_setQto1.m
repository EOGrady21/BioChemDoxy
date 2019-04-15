function S=B_setQto1(S)
%B_SETQTO1 - Set quality flag to one in bottle-structure. 
%
%Syntax:  S = B_setQto1(S)
% S is the bottle-structure with or without quality flag.
% If quality flags already exist, ask to reset or not.
%
%Toolbox required: Signal Processing

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 28-Jan-2004 CL

%Modifications:
% -Ajout variable pH, alky
% CL, 19-Nov-2009
% -Ajout variable sigt
% CL, 08-dec-2010


%Open state file
fid=fopen(['B_state_' S(1).cruiseid '.txt'],'w');
fclose(fid);

%Open QC_data file
fid_data=fopen(['QC_data_' S(1).cruiseid '.txt'],'w');
fprintf(fid_data,'Filename; Pressure; Uniqueno; Variable; Values; Test failed\r\n');
fclose(fid_data);

%disp
disp('Setting Q flags to 1')

%Check for existing quality flags
%Qs=[S(1).Qtemp S(1).Qpsal S(1).Qdoxy S(1).Qcphl S(1).Qntrz S(1).Qntri S(1).Qphos S(1).Qslca];
%switch isnan(nanmean(Qs(:))) | nanmean(Qs(:))==9
%case 1
%   resetQ='y';
%case 0
   %resetQ=input('The Q quality flags already exist. Do you want to reset them to 1? (y or n) -> ','s');
   %end
   resetQ='n';

%Set Qs   
for i=1:size(S,2)
  if resetQ=='y'
    S(i).Qpres=repmat(1,size(S(i).pres));
    S(i).Qdeph=repmat(1,size(S(i).deph));
    S(i).Qtemp=repmat(1,size(S(i).temp));
    S(i).Qpsal=repmat(1,size(S(i).psal));
    S(i).Qsigt=repmat(1,size(S(i).sigt));
    S(i).Qdoxy=repmat(1,size(S(i).doxy));
    S(i).Qcphl=repmat(1,size(S(i).cphl));
    S(i).Qntrz=repmat(1,size(S(i).ntrz));
    S(i).Qntri=repmat(1,size(S(i).ntri));
    S(i).Qphos=repmat(1,size(S(i).phos));
    S(i).Qslca=repmat(1,size(S(i).slca));
    S(i).Qphph=repmat(0,size(S(i).phph));
    S(i).Qalky=repmat(1,size(S(i).alky));
  end
  
  %var=NaN to Q=9 
  S(i).Qtemp(isnan(S(i).temp))=9;
  S(i).Qpres(isnan(S(i).pres))=9;
  S(i).Qdeph(isnan(S(i).deph))=9;
  S(i).Qpsal(isnan(S(i).psal))=9;
  S(i).Qsigt(isnan(S(i).sigt))=9;
  S(i).Qdoxy(isnan(S(i).doxy))=9; 
  S(i).Qcphl(isnan(S(i).cphl))=9;  
  S(i).Qntrz(isnan(S(i).ntrz))=9;  
  S(i).Qntri(isnan(S(i).ntri))=9;  
  S(i).Qphos(isnan(S(i).phos))=9;  
  S(i).Qslca(isnan(S(i).slca))=9;  
  S(i).Qphph(isnan(S(i).phph))=9;  
  S(i).Qalky(isnan(S(i).alky))=9;  

  %Q=0 or NaN to Q=1
  S(i).Qtemp(isnan(S(i).Qtemp) | S(i).Qtemp==0)=1;
  S(i).Qpres(isnan(S(i).Qpres) | S(i).Qpres==0)=1;
  S(i).Qdeph(isnan(S(i).Qdeph) | S(i).Qdeph==0)=1;
  S(i).Qpsal(isnan(S(i).Qpsal) | S(i).Qpsal==0)=1; 
  S(i).Qsigt(isnan(S(i).Qsigt) | S(i).Qsigt==0)=1; 
  S(i).Qdoxy(isnan(S(i).Qdoxy) | S(i).Qdoxy==0)=1;  
  S(i).Qcphl(isnan(S(i).Qcphl) | S(i).Qcphl==0)=1;  
  S(i).Qntrz(isnan(S(i).Qntrz) | S(i).Qntrz==0)=1;  
  S(i).Qntri(isnan(S(i).Qntri) | S(i).Qntri==0)=1;  
  S(i).Qphos(isnan(S(i).Qphos) | S(i).Qphos==0)=1;  
  S(i).Qslca(isnan(S(i).Qslca) | S(i).Qslca==0)=1;  
  S(i).Qphph(isnan(S(i).Qphph))=1;  
  S(i).Qalky(isnan(S(i).Qalky))=1;  

  %general
  S(i).QCFF=repmat(0,size(S(i).temp));   
  S(i).history='';
  S(i).comments='';

end
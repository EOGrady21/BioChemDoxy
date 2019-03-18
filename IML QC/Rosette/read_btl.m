function B=read_btl(filename)
%READ_BTL - Reads a CTD BTL-file out of Seabird bottle treatment 
%
%Syntax:  B = read_btl(filename)
% filename is the name of the BTL file between quotes (ex:'temp.btl')
% B is a structure of BTL data with fields
%   B.filename: Filename
%   B.header: BTL header
%   B.name: Variable name
%   B.units: Variable units
%   B.code: Variable GF3 code
%   B.desc: Descrition of data matrix
%   B.data: Data
%
%Toolbox required: ODSTools, data_cnv

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%October 1999; Last revision: 06-Oct-1999 CL

%Modifications:
% Lecture du fichier BTL nom de variable par bloc de 11 caract�res. Avant
% lecture des noms de variables s�par�es par des espaces.
% CL, 15-May-2014

%INI files
data_cnv		%Seabird data code

%Struture
B.filename=filename;	%Filename
B.header=[];		%BTL header
B.name=[];			%Variable name
B.units=[];			%Variable units
B.code=[];			%Variable GF3 code
B.desc={'BTL_value','std_value','min_value','max_value'};	%Descrition of data matrix
B.data=[];			%Data

%Textcell
h=textcell(filename);
B.header=h;
header=char(h);

%Find rossum_in
no=strmatch('    Bottle',header)-1;
if (no+6)>length(header)
    bottle=[1 2];
else
    bottle=str2num(header(no+3:no+6,1:11));
end

%Variable name
t=header(no+1,:);
data=header(no+3:end,:);
n=0;
I=1;
while ~isempty(strtrim(t))
   n=n+1;
   names{n}=strtrim(t(1:11));
   II=findstr(names{n},header(no+1,:));
   varpos{n}=[I:II(end)+length(names{n})-1];
   I=II(end)+length(names{n});
   t=t(12:end);
end

%assign data
j=0;
for i=3:length(names)
   par=data(:,varpos{i});
   I=findstr(par(:,end)',' ');
   if ~isempty(I)
      for k=1:length(I)
         par(I(k),1:3)='nan';
      end
   end
   par=str2num(par);
   switch length(bottle)
	case 1
      par=flipud(reshape(par,[4 length(par)/4])');
	case 2
      par=flipud(reshape(par,[2 length(par)/2])');
	end
   par(par==-9.990e-29)=nan;
   
   I=strmatchi(names{i},key.code,'exact');
   if length(I)>1, I=I(end); end
   if isempty(I)
      disp(['Data ' names{i} ' not stored: no correspondence found in data_btl'])
   else
      j=j+1;
      switch i
      case 3
         J=[]; 
      otherwise
         name_data=fieldnames(B.data);
         J=strmatch(cnvLIST(I).gf3,name_data);
      end
      if isempty(J), J=1; else J=length(J)+1; end
      num=sprintf('%2.2d',J);
      
      %Data
      eval(['B.data.' cnvLIST(I).gf3 '_' num '=par*cnvLIST(I).cnv2gf3;'])
      
      %Parameter_Header
      R = gf3defs(char(cnvLIST(I).gf3));
      if R.code=='FLOR', R.units='mg/m**3'; end
      if R.code=='PSAR', R.units='ueinsteins/s/m**2'; end
   	B.name{j} = R.desc;
   	B.units{j} = R.units;
   	B.code{j} = [cnvLIST(I).gf3 '_' num];
   end
end   



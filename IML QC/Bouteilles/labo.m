function L=labo(opt,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12)
%LABO - Separated labo data TXT files are put together
%
%Syntax:  labo(opt,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10)
% opt: 'uniqueno': unique number or 'filepres': file+pres used as unique identifiers
% 
% TXT-file needed: *.txt
%   Each column in a file f* must be identified by proper keyword
%   List of accepted keywords:
%   echantillon, fichier, pres(dbar), temp_rt(C), psal_bs, oxy_**(ml/l),
%   chl_**(ug/l), pha_**(ug/l), poc_**(umol/l), pon_**(umol/l),
%   no3_**(umol/l), no2_**(umol/l), po4_**(umol/l), si_**(umol/l),
%   nh4_**(umol/l), uree_**(umol/l)
% Upper and lower cases are accepted. Only column with valid method number
% will be transferred.
%
% Output:
%   L.sample: unique number
%   L.filename: CTD filenames
%   L.pres: pressure depth of the bottle sample (db)
%   L.header: header of bottle data keywords
%   L.data: associated bottle data
%
% This function has been written to be able to group water sample ananlysis.
% The repetition of a data keywords in L.header means that replicates have been done.
% Replicates do not need to be in separated columns in the input TXT file.
%
%M-files required: data_btl

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2000; Last revision: 01-Mar-2000 CL

%Methods
data_btl;

%nargin
no_files=nargin-1;

%unique_sample
unique_sample=[];

%option
valid_opt=['uniqueno';'filepres'];
opt=lower(opt);
if isempty(strmatch(opt,valid_opt))
   error(['Option ' opt ' not valid'])
end

%btl data
data_btl

%loop over all files
for i=1:no_files
   %read file
   filename=eval(['f' num2str(i)]);
   %check if filename exist
   if exist(filename)~=2
      error(['Filename ' filename ' do not exist in the current directory'])
   end
	disp(['Reading ' filename]);
	h=textread(filename,'%s');
   n=0;
   while isempty(str2num(h{n+1}))
      n=n+1;
   end
   m=length(h)/n;
   try, mat=reshape(h,[n m])';
   catch, error(['Check ' filename ' for blanks or header line']), end

	%header
	h=mat(1,:);
	%valid data codes
	valid_code=lower(cat(1,btlLIST.method));
   for j=1:length(h)
      I=strmatch(lower(h{j}),valid_code,'exact');
      if isempty(I)
         error(['''' h{j} ''' is not a valid data code in ' filename])
      end
   end
        
	%data
	data=mat(2:end,:);
   
   %unique_no
   ff=lower(data(:,strmatchi('fichier',h,'exact')));
   if isempty(ff), disp(['!!! WARNING: No ''''fichier'''' found in ' filename]), end
   pp=round(str2num(char(data(:,strmatchi('pres',h,'exact'))))*10);
   if isempty(pp), disp(['!!! WARNING: No ''''pres'''' found in ' filename]), end
   switch opt
   case 'uniqueno'
      sampleno=data(:,strmatchi('echantillon',h));
      if isempty(sampleno)
         disp(['!!! ERROR: no ''''echantillon'''' found in ' filename])
         disp(['!!! Treatement of ' filename ' aborted']);
         break
      end
%      K=find(str2num(char(sampleno)) < 999);
      K=find(str2num(char(sampleno)) < 0);
      if ~isempty(K)
      	for j=1:size(K),sampleno{K(j),1}=cat(2,lower(ff{K(j)}),num2str(pp(K(j),:)));end
      end
   case 'filepres'
      if isempty(ff) | isempty(pp)
         disp(['!!! ERROR: No ''''fichier'''' or ''''pres'''' found in ' filename])
         disp(['!!! Treatement of ' filename ' aborted']);
         break
      end
      clear sampleno
      for j=1:size(ff,1),sampleno{j,1}=cat(2,ff{j},num2str(pp(j,:)));end
   end
   
   %find columns with labo data
   labo_col=[];
   for j=1:size(h,2)
      if ~isempty(findstr(h{j},'_')) | ~isempty(strmatch(h{j},'SECC'))
         labo_col=[labo_col j];
      end
   end
   
   %labo data
   dat=str2num(char(data(:,labo_col)));
   n_row=size(data,1);
   m_col=length(labo_col);
   dat=reshape(dat,[n_row m_col]);
   dat(dat==-99)=nan;
   
   %set them unique
   [labo_h,labo_d,unique_sample_no,f,p]=setunique(sampleno,h,dat,labo_col,ff,pp);
   
   %union
   if i==1
      labo_hh=labo_h;
      labo_dd=labo_d;
      unique_sample=unique_sample_no;
      files=f;
      pres=p/10;
   else
      [C,uniqJJ,IB]=intersect(unique_sample,unique_sample_no); 
      ll=size(labo_dd,2);
      labo_dd=[labo_dd repmat(nan,[size(labo_dd,1) size(labo_d,2)])];
      labo_dd(uniqJJ,ll+1:end)=labo_d(IB,:);
      [C,IA]=setdiff(unique_sample_no,unique_sample_no(IB));
      if ~isempty(IA)
      	labo_dd=[labo_dd; repmat(nan,[length(IA) size(labo_dd,2)-size(labo_d,2)]) labo_d(IA,:)];   
      	unique_sample=[unique_sample;  unique_sample_no(IA,:)];
         files=[files; f(IA)];
         pres=[pres; p(IA)/10];
      end
		labo_hh=[labo_hh labo_h];   
   end
end   

if ~isempty(unique_sample)
   n=0;
   for j=1:length(unique_sample)
      no=str2num(char(unique_sample(j)));
      if isempty(no) | no>1000000000
         n=n+1;
         unique_sample{j}=num2str(-99);
      end
   end
   L.sample=unique_sample;
	L.filename=files;
	L.pres=pres;
	L.header=labo_hh;
   L.data=labo_dd;
else
   L=[];
end

%Check for data conversion to gf3 (btlLIST.btl2gf3)
for i=1:size(L.data,2)
   t=str2num(L.header{i}(end-1:end));
   if ~isempty(t) | lower(L.header{i}(end-1:end))=='xx'
      I=strmatch(lower(L.header{i}(1:end-2)),lower(key.code),'exact');
      %if isempty(I)
      %    I=strmatch(lower(L.header{i}(1:end-3)),lower(key.code),'exact');
      %end
   elseif isempty(t)
      I=strmatch(lower(L.header{i}),lower(key.code),'exact');
   end
   L.data(:,i)=L.data(:,i)*btlLIST(I).btl2gf3;
end

function [labo_h,labo_d,unique_sample_no,f,p]=setunique(sampleno,h,dat,labo_col,ff,pp)   
   
%Find duplicates
[unique_sample_no,uniqJ]=unique(sampleno);
non_unique=setdiff((1:size(dat,1)),uniqJ);
labo_h{1}='echantillon';
labo_h=h(labo_col);
labo_d=dat(uniqJ,:);
if ~isempty(ff), f=ff(uniqJ); else f=cellstr(repmat(' ',[size(uniqJ)])); end
if ~isempty(pp), p=pp(uniqJ); else p=repmat(nan,[size(uniqJ)]); end

while ~isempty(non_unique)
   ll=size(labo_d,2);
   [unique_sample,uniqJJ]=unique(sampleno(non_unique));
   uniqJJ=non_unique(uniqJJ);
   labo_d=[labo_d repmat(nan,[size(labo_d,1) size(dat,2)])];
   [C,IA,IB]=intersect(unique_sample_no,sampleno(uniqJJ));
   labo_d(IA,ll+1:end)=dat(uniqJJ(:),:);
   non_unique=setdiff((1:size(dat,1)),[uniqJ; uniqJJ(:)]);
	uniqJ=[uniqJ; uniqJJ(:)];      
   labo_h=[labo_h h(labo_col)];
end


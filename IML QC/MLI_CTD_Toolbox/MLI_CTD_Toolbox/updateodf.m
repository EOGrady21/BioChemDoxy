function A=updateodf(A)
%Updates all header information stored in an ODF structured array.
%
%Class: ODF_Function
%
%ODS Version: 1.0
%Date: 26 August 1999
%
%
%Source: Ocean Sciences, DFO. (Dave Kellow)
%
%Description: UPDATEODF goes through the ODF data and updates the ODF headers accordingly.
%             Fields that are updated:
%             ODF_header        File_Spec
%             Event_header      creation_date
%                               start_date_time
%                               end_date_time
%                               min_depth
%                               max_depth
%             Parameter_header  minimun_value
%                               maximum_value
%                               number_valid
%                               number_null
%             Record_header     num_history
%                               num_cycle
%                               num_param
%                               num_swing
%                               num_calibration
%Usage:A = updateodf(A)
%
%Input:
%A : the ODF structured array to be updated.
%
%Output:
%A : the updated ODF structured array.
%
%Example:
%
%A = updateodf(A)
%
%
%Other Notes: UPDATEODF is called by write_odf and is not normally required by the user
%
%Modifications:
% - ajouts pour QQQQ
% lafleurc

A.ODF_Header.File_Spec = cellstr(bfspec(A));
timecheck = 1;
prescheck = 1;
posicheck = 1;

for i = (1:(length(A.Parameter_Header)))
   if isfield(A.Parameter_Header{i},'WMO_Code')
     wmo = char(A.Parameter_Header{i}.WMO_Code);
   else
     wmo = char(A.Parameter_Header{i}.Code);
     wmo = wmo(1:4);
   end

   wmo = upper(wmo);
   if strcmp(wmo,'SYTM')~=1
        names=fieldnames(A.Data);
        Inames=strmatch(wmo,names);
        Inames=Inames(1);
        I=(1:eval(['length(A.Data.' char(names(Inames)) ')']));
        eval(['A.Parameter_Header{',num2str(i),'}.Minimum_Value=num2str(min(A.Data.',char(A.Parameter_Header{i}.Code),'(I)));']);
        eval(['A.Parameter_Header{',num2str(i),'}.Maximum_Value=num2str(max(A.Data.',char(A.Parameter_Header{i}.Code),'(I)));']);
        eval(['A.Parameter_Header{',num2str(i),'}.Number_Valid=sum(~isnan(A.Data.',char(A.Parameter_Header{i}.Code),'));']);
        eval(['A.Parameter_Header{',num2str(i),'}.Number_NULL=sum(isnan(A.Data.',char(A.Parameter_Header{i}.Code),'));']);
        eval(['len(',num2str(i),') = length(A.Data.',char(A.Parameter_Header{i}.Code),');']);
        if Inames<length(names)
           Qflag=char(names(Inames+1));
           if strcmp(Qflag(1:4),'QQQQ');
               I=eval(['find(A.Data.' char(names(Inames+1)) '==1 | A.Data.' char(names(Inames+1)) '==0 | A.Data.' char(names(Inames+1)) '==2)']);
               if ~isempty(I)
                  eval(['A.Parameter_Header{',num2str(i),'}.Minimum_Value=num2str(nanmin(A.Data.',char(A.Parameter_Header{i}.Code),'(I)));']);
                  eval(['A.Parameter_Header{',num2str(i),'}.Maximum_Value=num2str(nanmax(A.Data.',char(A.Parameter_Header{i}.Code),'(I)));']);
               end
           end
        end
   end

   if strcmp(wmo,'SYTM')==1
      timecheck = 1;
      Itime=find(A.Matdate>julian(datevec('19-nov-1858')));
      eval(['A.Parameter_Header{',num2str(i),'}.Minimum_Value=cellstr(zqset(mdate(gregorian(min(A.Matdate(Itime))))));']);
      eval(['A.Parameter_Header{',num2str(i),'}.Maximum_Value=cellstr(zqset(mdate(gregorian(max(A.Matdate(Itime))))));']);
        eval(['A.Parameter_Header{',num2str(i),'}.Number_Valid=length(Itime);']);
        eval(['A.Parameter_Header{',num2str(i),'}.Number_NULL=length(A.Matdate)-length(Itime);']);
        eval(['len(',num2str(i),') = length(A.Matdate);']);

   end

   if strcmp(wmo,'PRES')==1
      prescheck = 1;
   end

   %Verify Parameter Name
    if ~iscell(A.Parameter_Header{i}.Name)
        A.Parameter_Header{i}.Name = cellstr(A.Parameter_Header{i}.Name);
    end



end


A.Event_Header.Creation_Date = cellstr(mdate(datevec(now)));


if timecheck==1 & isfield(A.Data,'SYTM_01')
    Itime=find(A.Matdate>julian(datevec('19-nov-1858')));
   A.Event_Header.Start_Date_Time = cellstr(mdate(gregorian(A.Matdate(Itime(1)))));
   A.Event_Header.End_Date_Time = cellstr(mdate(gregorian(A.Matdate(Itime(end)))));
end

if prescheck==1
   %DEPH
   if isfield(A.Data,'DEPH_01')
        names=fieldnames(A.Data);
        Inames=strmatch('DEPH_01',names);
        I=(1:length(A.Data.(char(names(Inames)))));
        if Inames<length(names)
           Qflag=char(names(Inames+1));
           if strcmp(Qflag(1:4),'QQQQ');
               a=char(names(Inames+1));
               I=find([A.Data.(a)==1 | A.Data.(a)==3 | A.Data.(a)==5 | A.Data.(a)==0 |A.Data.(a)==7]);
           end
        end
        if ~isempty(I)
        	A.Event_Header.Min_Depth = min(A.Data.DEPH_01(I));
        	A.Event_Header.Max_Depth = max(A.Data.DEPH_01(I));
        end
        if A.Event_Header.Sounding>0
            A.Event_Header.Depth_Off_Bottom = A.Event_Header.Sounding - A.Event_Header.Max_Depth;
        end
        names=fieldnames(A.Data);
   %PRES
   elseif isfield(A.Data,'PRES_01')
       Inames=strmatch('PRES_01',names);
        I=(1:length(A.Data.(char(names(Inames)))));
        if Inames<length(names)
           Qflag=char(names(Inames+1));
           if strcmp(Qflag(1:4),'QQQQ');
               a=char(names(Inames+1));
               I=find([A.Data.(a)==1 | A.Data.(a)==3 | A.Data.(a)==5 | A.Data.(a)==0 |A.Data.(a)==7]);
           end
        end
        Mean_Depth=A.Event_Header.Sounding - A.Event_Header.Depth_Off_Bottom;
        if ~isempty(I)
        	A.Event_Header.Min_Depth = sw_dpth(min(A.Data.PRES_01(I)),A.Event_Header.Initial_Latitude);
        	A.Event_Header.Max_Depth = sw_dpth(max(A.Data.PRES_01(I)),A.Event_Header.Initial_Latitude);
            Mean_Depth = sw_dpth(mean(A.Data.PRES_01(I)),A.Event_Header.Initial_Latitude);
        end
        if A.Event_Header.Sounding>0
           switch A.Event_Header.Data_Type{1}(1)
           case 'M'
                 A.Event_Header.Depth_Off_Bottom = round(A.Event_Header.Sounding - Mean_Depth);
           otherwise
                A.Event_Header.Depth_Off_Bottom = round(A.Event_Header.Sounding - A.Event_Header.Max_Depth);
            end
        end
	end      
end

if posicheck==1
   if isfield(A.Data,'LATD_01')
    Ilat=find(isnan(A.Data.LATD_01)==0);
   	A.Event_Header.Initial_Latitude = A.Data.LATD_01(Ilat(1));
   	A.Event_Header.End_Latitude = A.Data.LATD_01(Ilat(end));
	end
	if isfield(A.Data,'LOND_01')
    Ilon=find(isnan(A.Data.LOND_01)==0);    
   	A.Event_Header.Initial_Longitude = A.Data.LOND_01(Ilon(1));
      A.Event_Header.End_Longitude = A.Data.LOND_01(Ilon(end));
   end
end

%Check for same number of cycles in each parameter.

for i = (1:(length(A.Parameter_Header)))
   if len(i)~=len(1)
      error('Data categories are not all the same length.');
   end
end

A.Record_Header.Num_Param = length(A.Parameter_Header);
A.Record_Header.Num_History = length(A.History_Header);
if isfield(A,'Compass_Cal_Header')
A.Record_Header.Num_Swing = length(A.Compass_Cal_Header);
end
if isfield(A,'Polynomial_Cal_Header')
A.Record_Header.Num_Calibration = length(A.Polynomial_Cal_Header);
end
A.Record_Header.Num_Cycle = len(1);




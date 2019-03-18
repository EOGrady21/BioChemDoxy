function T=stage3_Q(T,testno)
%STAGE3_Q - Stage 3 of quality control tests (Climatology Tests)
%
%Syntax:  S = STAGE3_Q(S,testno)
% T is the std structure with quality control flags included (size(T)=[1 1]).
% testno available
%  35: Petrie Monthly Climatology
%
% testno not available
%  31: Levitus Seasonal Statistics
%  32: Emery and Dewar Climatology
%  33: Asheville Climatology
%  34: Levitus Montly Climatology
%
% Quality control test names are added to the structure field 'history'.
% Quality control test problems are reported on line and in 
% state_(cruise_number).txt file.
%
%Toolbox required: Seawater, Petrie
%M-files required: remove_doubtful, in_petrie_box
%MAT-files requires: stage3_Q
%
%Reference: Unesco (1990) GSTPP Real-Time Quality Control Manual, 
%           Intergouvernmental Oceanographic Commission, Manuals 
%           and Guides, vol 22, SC/90/WS-74: 121 p.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 27-Oct-1999 CL

%Open state file
fid=fopen(['state_' T.cruiseid '.txt'],'a');

%Load stage3_Q
load stage3_Q

if ~isfield(test35,'P')
    load Petrie
    test35.P=P;
end

%Switch 
switch testno
   
%------------------------------------ 
%Test 3.5: Petrie Monthly Climatology
%------------------------------------ 
case 35
 P=test35.P;
 box=in_petrie_box(T.lat,T.lon,P);	%in Box
 dz=[5;5;5;5;5;5;10;10;10;10;25;25;25;25;25;25];
 J=[];
 if isempty(box)
    disp([' Test 3.5 -> Profile ' T.filename ' outside Petrie Monthly Climatology']) 
    fprintf(fid,[T.filename ': Test 3.5 -> Profile outside Petrie Monthly Climatology\r\n']); 
 else
    P=P(cat(1,P.box)==box(1));
    %Means by depths
    for j=1:size(test35.name,1)
    	 [Tn,Itn]=remove_doubtful(T,j+4);
		 par=eval(['Tn.' test35.name{j}]);
       pari=repmat(nan,length(P.deph),1);
       for k=1:length(P.deph)
          I=[];
          if max(Tn.deph)>=P.deph(k)
          	I=find(Tn.deph>=P.deph(k)-dz(k) & Tn.deph<=P.deph(k)+dz(k));
          end
          if ~isempty(I), pari(k)=nanmean(par(I)); end
       end
       month=datestr(Tn.time,5);
       dpar=abs(pari-eval(['P.' test35.name{j} '(:,' month ')']));
       for k=1:length(dpar)
          par_std=[eval(['P.' test35.name{j} '_stda(k,' month ')']) eval(['P.' ...
                   test35.name{j} '_std(k,' month ')'])];
          J=find(dpar(k)>max(par_std)*3);
        	 if ~isempty(J);
            disp([' Test 3.5 -> ' test35.name{j} ' is out of Petrie Climatology by more than 3*std at ' num2str(P.deph(k),'%3.0f') ' m'])
       		fprintf(fid,[Tn.filename ': Test 3.5 -> ' test35.name{j} ' is out of Petrie Climatology by more than 3*std at ' num2str(P.deph(k),'%3.0f') ' m\r\n']);
       	 end
      end
end
 end
 if isempty(J), disp(' Test 3.5 ok'), end
 T.history{length(T.history)+1,1}=test35.history;      
	         
%-------------------
%Unknown Test Number
%-------------------
otherwise
 disp([' Unknown Test Number: ' num2str(testno)])
 
end  %(swicth cases)

%Close state file
fclose(fid);



   
   
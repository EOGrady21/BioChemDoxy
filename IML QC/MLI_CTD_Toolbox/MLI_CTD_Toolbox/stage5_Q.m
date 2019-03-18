function S=stage5_Q(S,testno)
%STAGE5_Q - Stage 5 of quality control tests (Visual Inspection)
%
%Syntax:  S = stage5_Q(S,testno)
% S is the std structure.
% testno available
%  51: Cruise Track Visual Inspection
%  52: Profile Visual Inspection
%
% Quality control test names are added to the structure field 'history'.
% Quality control test problems are reported on line and in 
% state_(cruise_number).txt file.
%
%M-files required: east_mask, gsl_mask, plot_std, east_ca
%MAT-files required: stage5_Q
%
%Reference: Unesco (1990) GSTPP Real-Time Quality Control Manual, 
%           Intergouvernmental Oceanographic Commission, Manuals 
%           and Guides, vol 22, SC/90/WS-74: 121 p.

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 27-Oct-1999 CL

%Load stage5_Q
load stage5_Q

%Switch
switch testno
 
%----------------------------------------   
%Test 5.1: Cruise Track Visual Inspection
%----------------------------------------   
case 51
 disp(' Cruise Track Inspection -> Strike any key to continue')
 close('all'), 
 figure(1)
 
 %plot gsl coast
 gsl_mask; hold on, grid on
 
 %if not in gsl, plot east Canada coast
 gsl_lon=[-70 -70 -56 -56];
 gsl_lat=[ 45  52  52  45];
 if ~min(inpolygon(cat(1,S.lon),cat(1,S.lat),gsl_lon,gsl_lat))
	 load east_ca
    plot(x0,y0,'k'); hold on
    east_mask; grid on
    axis([ min([cat(1,S.lon); gsl_lon(:)]) max([cat(1,S.lon); gsl_lon(:)]) ...
           min([cat(1,S.lat); gsl_lat(:)]) max([cat(1,S.lat); gsl_lat(:)]) ]);
 end
 
 %plot station positions      
 plot(cat(1,S.lon),cat(1,S.lat),'-ob','MarkerFaceColor','g','MarkerEdgeColor','r')
 for i=1:size(S,2)
    text(cat(1,S(i).lon),cat(1,S(i).lat),['  ' num2str(S(i).station)],...
       'HorizontalAlignment','left','FontSize',8,'FontWeight','Bold')
 end
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test51.history; end
 pause, figure(1), close(1)
 
%-----------------------------------   
%Test 5.2: Profile Visual Inspection
%-----------------------------------   
case 52
 disp(' Profile Inspection')  
 for i=1:size(S,2)
    disp(['  ' S(i).filename ' -> Strike any key to continue'])
    figure(1), clf, plot_std(S(i))  
 	 P=nan_doubtful(S(i));
 	 figure(2), clf, plot_std(P)
 	 S(i).history{length(S(i).history)+1,1}=test52.history;
	 pause    
 end
  
%-------------------
%Unknown Test Number
%-------------------
otherwise
 disp([' Unknown Test Number: ' num2str(testno)])
 
end %(swicth cases) 
function S=B_stage5_Q(S,testno)
%B_STAGE5_Q - Stage 5 of bottle quality control tests (Visual Inspection)
%
%Syntax:  S = B_stage5_Q(S,testno)
% S is the bottle-structure.
% testno available
%   51: Cruise Track Visual Inspection
%   52: Ratio and Profile Visual Inspection (station data)
%   53: Replicates Visual Inspection (whole cruise data)
%   54: Bottle Versus CTD Measurements Visual Inspection (whole cruise data)
%   55: Ratio and Profile Visual Inspection (whole cruise data)
%   56: Variable patterns with time (whole cruise data)
%
% Quality control test names are added to the structure field 'history'.
% Quality control test problems are reported on line and in 
% state_(cruise_number).txt file.
%
%M-files required: east_mask, gsl_mask, B_plot_NSP, B_plot_TSOC,
%       B_plot_replicate, B_plot_BOTL_CTD, B_plot_profile, B_plot_pattern
%MAT-files required: B_stage5_Q, east_ca

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 05-Feb-2004 CL

%Load stage5_Q
load B_stage5_Q

%Switch
switch testno
 
%----------------------------------------   
%Test 5.1: Cruise Track Visual Inspection
%----------------------------------------   
case 51
 disp(' Cruise Track Inspection -> Strike any key to continue')
 close('all'), 
 figure(1)
 set(gcf,'Name',['Test 5.1: Cruise Track Visual Inspection'],'NumberTitle','off')

 %plot gsl coast
 gsl_mask; hold on, grid on
 
 %if not in gsl, plot east Canada coast
 gsl_lon=[-69 -69 -51 -51];
 gsl_lat=[ 39  48  48  39];
 if ~min(inpolygon(cat(1,S.lon),cat(1,S.lat),gsl_lon,gsl_lat))
	load east_ca
    east_mask; hold on, grid on
    plot(x0,y0,'k');
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
 %Print option
 set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')
 pause, figure(1), close(1)

%------------------------------------------------------------   
%Test 5.2: Ratio and Profile Visual Inspection (station data)
%------------------------------------------------------------   
case 52
 disp(' Profile Inspection')  
 
 g1=figure(1); clf
 set(g1,'Units','normalized');
 pos=get(g1,'Position');
 set(g1,'Position',[0 max([pos(2)-0.1 0.0390625]) pos(3:4)])
 set(g1,'Renderer','OpenGL','PaperOrientation','landscape')

 g2=figure(2); clf
 set(g2,'Units','normalized');
 pos=get(g2,'Position');
 set(g2,'Position',[1-pos(3) max([pos(2)-0.1 0.0390625]) pos(3:4)])
 set(g2,'Renderer','OpenGL','PaperOrientation','landscape')

 for i=1:size(S,2)
    disp(['  ' S(i).filename ' -> Strike any key to continue'])
    
    figure(g1)  
    set(gcf,'Name',['Test 5.2: Ratio and Profile Visual Inspection (station data)'],'NumberTitle','off')
    set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')
    B_plot_SOCH(S(i))
   
    figure(g2)
    set(gcf,'Name',['Test 5.2: Ratio and Profile Visual Inspection (station data)'],'NumberTitle','off')
    set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')
    B_plot_NSP(S(i))
    
    pause
    S(i).history{length(S(i).history)+1,1}=test52.history;
 end
 
  figure(g1), close(g1)
  figure(g2), close(g2)

%----------------------------------------------------------   
%Test 5.3: Replicates Visual Inspection (whole cruise data)
%----------------------------------------------------------   
case 53
 disp(' Replicate Inspection')
 figure(1)
 set(gcf,'Name',['Test 5.3: Replicates Visual Inspection (whole cruise data)'],'NumberTitle','off')
 set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')
 B_plot_replicate(S);
 pause
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test53.history; end

%------------------------------------------------------------------------------   
%Test 5.4: Bottle Versus CTD Measurements Visual Inspection (whole cruise data)
%------------------------------------------------------------------------------   
case 54
 disp(' Bottle versus CTD Inspection')
 figure(2)
 set(gcf,'Name',['Test 5.4: Bottle Versus CTD Measurements Visual Inspection (whole cruise data)'],'NumberTitle','off')
 set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')
 B_plot_BOTL_CTD(S);
 pause
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test54.history; end

%-----------------------------------------------------------------   
%Test 5.5: Ratio and Profile Visual Inspection (whole cruise data)
%-----------------------------------------------------------------   
case 55
 disp(' Cruise Profile Inspection')
 figure(3)
 set(gcf,'Name',['Test 5.5:  Ratio and Profile Visual Inspection (whole cruise data)'],'NumberTitle','off')
 set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')
 B_plot_profile(S);
 pause
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test55.history; end

%---------------------------------------------------------   
%Test 5.6: Variable patterns with time (whole cruise data)
%---------------------------------------------------------   
case 56
 disp(' Variable Pattern Inspection')
 figure(4)
 set(gcf,'Name',['Test 5.6: Variable patterns with time (whole cruise data)'],'NumberTitle','off')%Print option
 set(gcf,'Renderer','OpenGL','PaperOrientation','landscape')
 B_plot_pattern(S);
 pause
 for i=1:size(S,2), S(i).history{length(S(i).history)+1,1}=test56.history; end
 
%-------------------
%Unknown Test Number
%-------------------
otherwise
 disp([' Unknown Test Number: ' num2str(testno)])
 
end %(swicth cases) 
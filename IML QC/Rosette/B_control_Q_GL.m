function S=B_control_Q(S)
%B_CONTROL_Q - Bottle quality control main function 
%
%Syntax:  S = B_control_Q(S)
% S is the input or output bottle-structure
% Quality flags are added to the bottle-structure.
%
%M-files required: B_setQto1, B_stage1_Q, B_stage2_Q, B_stage3_Q,
%                  B_stage4_Q and B_stage5_Q 

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 28-Jan-2004 CL

%Set Quality Flag to Ones
S=B_setQto1(S);

%Metadata Tests
disp('Stage 1: Location and Identification Tests .....')
S=B_stage1_Q(S,10); %Test 1.0: Verify time chronology
S=B_stage1_Q(S,11);	%Test 1.1: Platform Identification
S=B_stage1_Q(S,12); %Test 1.2: Impossible Date/Time
S=B_stage1_Q(S,13); %Test 1.3: Impossible Location
S=B_stage1_Q(S,14);	%Test 1.4: Position on Land
S=B_stage1_Q(S,15);	%Test 1.5: Impossible Speed
S=B_stage1_Q(S,16); %Test 1.6: Impossible Sounding

disp('Stage 5: Visual Inspection .....NOT WORKING FOR SCOTIAN SHELF')
%S=B_stage5_Q(S,51);	%Test 5.1: Cruise Track Visual Inspection

%Data Quality Control: Profile by Profile
disp('Stage 2: Profile Tests and Stage 3: Climatology Tests .....')
for i=1:size(S,2)
   disp(upper(S(i).filename))
   S(i)=B_stage2_Q(S(i),21);	%Test 2.1: Global Impossible Parameter Values 
   S(i)=B_stage2_Q(S(i),22);	%Test 2.2: Regional Impossible Parameter Values
   %S(i)=B_stage2_Q(S(i),23);	%Test 2.3: Incresssing Depth
   S(i)=B_stage2_Q(S(i),24);	%Test 2.4: Profile Envelope
   S(i)=B_stage2_Q(S(i),25);    %Test 2.5: Constant Profile
   S(i)=B_stage2_Q(S(i),26);	%Test 2.6: Freezing Point
   S(i)=B_stage2_Q(S(i),27);	%Test 2.7: IML Replicate comparisons (temp, psal, doxy, cphl, ntrz,ntri, phos, scla)
   S(i)=B_stage2_Q(S(i),28);	%Test 2.8: IML bottle versus CTD measurements (temp, psal, doxy)
   S(i)=B_stage2_Q(S(i),29);	%Test 2.9: NODC Excessive Gradient in temperature, salinity, nitrate and phosphate
   S(i)=B_stage2_Q(S(i),210);	%Test 2.10: IML Surface dissolved oxygen data versus percent saturation
   S(i)=B_stage3_Q(S(i),35);	%Test 3.5: Petrie Monthly Climatology (TEMP, PSAL)
   S(i)=B_stage3_Q(S(i),36);	%Test 3.6: Brickman Monthly Climatology (NTRZ, PHOS, SLCA)
end	%over all profiles of the structure


%Visual Inspection
disp('Stage 5: Visual Inspection .....')
%S=B_stage5_Q(S,52);	%Test 5.2: Ratio and Profile Visual Inspection (station data)
%S=B_stage5_Q(S,53);	%Test 5.3: Replicates Visual Inspection (whole cruise data)
%S=B_stage5_Q(S,54);	%Test 5.4: Bottle Versus CTD Measurements Visual Inspection (whole cruise data)
%S=B_stage5_Q(S,55);	%Test 5.5: Ratio and Profile Visual Inspection (whole cruise data)
%S=B_stage5_Q(S,56);	%Test 5.6: Variable patterns with time (whole cruise data)

%End of Quality Control
disp('End of Quality Control')


   
   
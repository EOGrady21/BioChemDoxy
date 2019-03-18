function S=control_Q(S)
%CONTROL_Q - Quality control main function
%
%Syntax:  S = control_Q(S)
% S is the input or output std structure
% Quality flags are added to the STD-structure.
%
%M-files required: setQto1, stage1_Q, stage2_Q, stage3_Q, satge4_Q and stage5_Q

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 27-Oct-1999 CL
%
%Modifications:
% - test 1.6 ramené apres les tests de l'étape 4 pour que la pression ait été controlée
% avant de faire le test.
% CL, 3-sept-2002

%Set Quality Flag to Ones
S=setQto1(S);

%Metadata Tests
disp('Stage 1: Location and Identification Tests .....')
S=stage1_Q(S,10); %Test 1.0: Verify time chronology
S=stage1_Q(S,11);	%Test 1.1: Platform Identification
S=stage1_Q(S,12); %Test 1.2: Impossible Date/Time
S=stage1_Q(S,13); %Test 1.3: Impossible Location
S=stage1_Q(S,14);	%Test 1.4: Position on Land
S=stage1_Q(S,15);	%Test 1.5: Impossible Speed
S=stage1_Q(S,16);	%Test 1.6: Impossible sounding
disp('Stage 5: Visual Inspection .....')
S=stage5_Q(S,51);	%Test 5.1: Cruise Track Visual Inspection

%Data Quality Control: Profile by Profile
disp('Stage 2: Profile Tests and Stage 3: Climatology Tests .....')
for i=1:size(S,2)
	disp(upper(S(i).filename))
	S(i)=stage2_Q(S(i),20);		%Test 2.0: Minimum Descent Rate
	S(i)=stage2_Q(S(i),21);		%Test 2.1: Global Impossible Parameter Values
	S(i)=stage2_Q(S(i),22);		%Test 2.2: Regional Impossible Parameter Values
	S(i)=stage2_Q(S(i),23);		%Test 2.3: Incresssing Depth
	S(i)=stage2_Q(S(i),24);		%Test 2.4: Profile Envelope
	S(i)=stage2_Q(S(i),26);		%Test 2.6: Freezing Point
	S(i)=stage2_Q(S(i),27);		%Test 2.7: Spike in temperature and salinity (one point)
	S(i)=stage2_Q(S(i),28);		%Test 2.8: Top and Bottom Spike in temperature and salinity (one point)
	S(i)=stage2_Q(S(i),29);		%Test 2.9: Gradient (point to point)
	S(i)=stage2_Q(S(i),210);	%Test 2.10: Density Inversion (point to point)
	S(i)=stage2_Q(S(i),211);	%Test 2.11: Spike (one point or more) (suplementary test)
	S(i)=stage2_Q(S(i),212);	%Test 2.12: Density Inversion (overall profile)
	S(i)=stage3_Q(S(i),35);		%Test 3.4: Petrie Monthly Climatology
end	%over all profiles of the structure

%Profil Consistency
disp('Stage 4: Profile Consistency .....')
S=stage4_Q(S,41);
S=stage4_Q(S,42);

%Visual Inspection
disp('Stage 5: Visual Inspection .....')
S=stage5_Q(S,52);	%Test 5.2: Profile Visual Inspection

%End of Quality Control
disp('End of Quality Control')

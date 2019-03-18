function B_stage_Q_ini
%B_STAGE_Q_INI - Script for bottle quality control test limits
%
%Syntax:  B_stage_Q_ini
% Contains limits of quality control tests. Files B_stage1_Q.mat, B_stage2_Q.mat
% B_stage3_Q.mat, B_stage4_Q.mat and B_stage5_Q.mat are created and used by quality
% control programs.
% List of available tests 
%  10: Time Chronology
%  11: Platform Identification
%  12: Impossible Date/Time
%  13: Impossible Location
%  14: Position on Land
%  15: Impossible Speed
%  16: Impossible sounding
%  21: Global Impossible Parameter Values
%  22: Regional Impossible Parameter Values
%  23: Increasing Depth
%  24: Profile Envelope
%  26: Freezing Point
%  27: Replicate Comparisons
%  28: Bottle versus CTD Measurements (TEMP, PSAL, DOXY, PHPH)
%  29: Excessive Gradient or Inversion (TEMP, PSAL, NTRZ, PHOS, PHPH)
%  210: Surface Dissolved Oxygene Data versus Percent Saturation
%  35: Petrie Monthly Climatology (TEMP, PSAL)
%  36: Brickman Monthly Climatology (NTRA, PHOS, SLCA)
%  41: Profile Consistency (TEMP, PSAL)
%  42: Annual Deep Water Profile Consistency (TEMP, PSAL)
%  51: Cruise Track Visual Inspection
%  52: Ratio and Profile Visual Inspection (station data)
%  53: Replicates Visual Inspection (whole cruise data)
%  54: Bottle Versus CTD Measurements Visual Inspection (whole cruise data)
%  55: Ratio and Profile Visual Inspection (whole cruise data)
%  56: Variable patterns with time (whole cruise data)
%
% MAT-files required: TS_dw96, TS_dw97, TS_dw98, TS_dw99, TS_dw00, gsl_mask, golfe_3km

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%January 2004; Last revision: 28-Jan-2004 CL

%Modifications:
% -Ajout variable pH, alky
% CL, 19-Nov-2009

%Test 11
test11.history='Test 1.1: GTSPP Platform Identification';

%Test 12
test12.history='Test 1.2: GTSPP Impossible Date/Time';

%Test 13
test13.history='Test 1.3: GTSPP Impossible Location';

%Test 14
load gsl_mask
I=find(isnan(x0)==1);
ls=I+1; le=[I(2:length(I))-1; length(x0)]; l=length(ls);
for i=1:l
   test14.poly_lon{i,1}=x0(ls(i):le(i));
   test14.poly_lat{i,1}=y0(ls(i):le(i));
end
test14.history='Test 1.4: GTSPP Position on Land';

%Test 15
test15.call_sign={'CG-3185'; 'CG-2648'; 'CG-3161'; 'CG-3190'; 'CG-2636'; 'CG-2683';...
      'CG-3159'; 'CG-3158'; 'CG-3191'; 'CG-2640'; 'CG-3163'; 'CG-3130'; 'CG-3129';...
      'CG-2639'; 'CG-2638'; 'CG-3197'; 'CG-3162'; 'CG-3193'; 'CG-3146'; 'CG-2648';...
      'CG-2650'; 'CG-2808'; 'CG-3147'; 'CG-2650'; 'CG-3160'; 'CGDX'; 'CGSB'; 'CGCC';...
      'CGJK'; 'CGCX'; 'VXZM'; 'CG-3187'; 'CG-3198'; 'CG-3181'; 'CG-3146'; 'VYPK';...
      'CG-3124'; 'CG-3125'; 'CGBX'; 'INCONNU_10'; 'INCONNU_15'; 'INCONNU_20'; 'INCONNU_25';...
      'INCONNU_A'; 'INCONNU_B'; 'INCONNU_C'; 'INCONNU_D'; 'INCONNU_E'; 'INCONNU_F';...
      'INCONNU_G'; 'VXZM';'CGBV'; 'VC-9450'; 'CGDG'; 'VOXS'; 'CG-3146'; 'CGCB';'VY-2606';...
   	'CF04735';'INCONNU_H';'CGDV';'CGDK';'CGDN'};
test15.max_vel=[20; 14; 20; 20; 20; 12; 14; 20; 12; 20; 20; 12; 20; 20; 20; 12;...
      20; 20; 20; 20; 20; 16; 20; 14; 20; 16; 16; 16; 16; 16; 10.5; 9.5; 17; 9;...
      10; 10; 12; 12; 13.5; 10; 15; 20; 25; 15; 15; 20; 25; 20; 12; 17; 10.5; 15;...
   	12; 17; 15; 10; 12; 12; 9; 100; 11; 15; 15];
test15.name={'BARACHOIS'; 'BEC-SCIE'; 'BELUGA'; 'BONNE-ESPERANCE'; 'CIVELLE';...
      'CSS ALFRED NEEDLER'; 'CSS PARIZEAU'; 'DAUPHIN'; 'DENIS RIVERIN'; 'DEFI';...
      'EIDER'; 'E.P. LE QUEBECOIS'; 'GIBOR'; 'HERON'; 'HUARD'; 'J.W. DERASPE';...
      'KAKAWI'; 'LE BRION'; 'LE FOULON'; 'LE MERMONT'; 'LE MIGUASHA'; 'LOUISBOURG';...
      'L''ISTORLET'; 'MACREUSE'; 'MARSOIN'; 'NGCC DESGROSEILLER'; 'NGCC RADISSON';...
      'NGCC MARTHA BLACK'; 'NGCC WILFRID LAURIER'; 'NGCC GEORGES R. PEARKES';...
      'N/M FOGO ISLE'; 'NSC CALANUS II'; 'NSC FREDERICK G. CREED'; 'NSC GREBE';...
      'NSC ROSMARUS'; 'PETREL'; 'PLUVIER'; 'SARCELLE'; 'TRACY'; 'ANONYME 1';...
      'ANONYME 2'; 'ANONYME 3'; 'ANONYME 4'; 'COLOMBO'; 'CREVETTE'; 'G.C. GLOBAL';...
      'GEMINI1'; 'JAKI'; 'LADY HAMMOND'; 'VAGABON'; 'DAWSON'; 'N/M FOGO ISLE';...
      'GADUS ATLANTICA'; 'HUDSON'; 'L.M. LAUZIER'; 'ROSMARUS'; 'FRV TELEOST';...
      'LADY MELISSA';'MORNING STAR';'HELICOPTERE';'WILFRED TEMPLEMAN';'E.E. PRINCE';'CORIOLIS II'};
test15.history='Test 1.5: GTSPP Impossible Speed';

test15.history='Test 1.5: GTSPP Impossible Speed';

%Test 16
load golfe_3km
test16.lon=xi;
test16.lat=yi;
test16.sounding=zi;
test16.history='Test 1.6: GTSPP Impossible Sounding';

%Test 21
test21.name={'temp';'psal';'pres';'doxy';'cphl';'ntrz';'ntri';'phos';'slca';'phph';'alky'};
test21.units={'degrees C';'psu';'decibars';'ml/l';'mg/m3';'mmol/m3';'mmol/m3';'mmol/m3';'mmol/m3';'';'mmol/m3'};
test21.minvalue=[-2.5;  0;     0;  0;  0;   0;  0;   0;   0;   6;   0];
test21.maxvalue=[  35; 40; 10000; 11; 50; 500; 15; 4.5; 250; 9.3; 3.1];
test21.history='Test 2.1: Global Impossible Parameter Values (2)';

%Test 22
test22.name={'temp';'psal';'pres';'doxy';'cphl';'ntrz';'ntri';'phos';'slca';'phph';'alky'};
test22.units={'degrees C';'psu';'decibars';'ml/l';'mg/m3';'mmol/m3';'mmol/m3';'mmol/m3';'mmol/m3';'';'mmol/m3'};
test22.minvalue=[-2.5;  0;   0;  0;  0;   0;  0;   0;   0; 6.3;   0];
test22.maxvalue=[  35; 35; 600; 10; 50; 500; 15; 4.5; 250; 9.2; 2.8];
test22.poly_lon=[-56.0; -73.0; -73.0; -64.5; -62.3; -56.0; -56.0; 5];
test22.poly_lat=[ 52.0;  49.5;  46.0;  46.0;  45.2;  48.2;  52.0; 10];
test22.history='Test 2.2: Regional Impossible Parameter Values (4)';

%Test 23
test23.history='Test 2.3: Increasing Depth (8)';

%Test 24
test24.name={'temp';'temp';'temp';'temp';'psal';'psal';'psal';'psal';'doxy';'doxy';'doxy';'cphl';'ntrz';'ntri';'phos';'phos';'slca';'slca';'phph';'phph';'alky';'alky'};
test24.prof1=[    0;    50;   100;   400;     0;    50;   100;   400;     0;    30;   200;     0;     0;     0;     0;   500;     0;   150;     0;   100;     0;    75];
test24.prof2=[   50;   100;   400;  1100;    50;   100;   400;  1100;    30;   200;  1500;  1500;  1500;  1500;   500;  1500;   150;   900;   100;   900;    75;   900];
test24.minvalue=[-2.5;-2.5;  -2.5;    -2;     0;     1;     3;    10;     0;     0;     0;     0;     0;     0;     0;  0.01;     0;  0.01;   6.3;     7;     0;   1.6];
test24.maxvalue=[35;    30;    28;    28;    35;    35;    35;    35;    10;     9;     8;    50;   500;    15;   4.5;   4.5;   250;   250;   9.2;   8.8;   2.8;   2.8];
test24.history='Test 2.4: Profile Envelope (16)';

%Test 25
test25.name={'temp';'psal';'doxy';'cphl';'ntrz';'phos';'slca';'phph';'alky'};
test25.history='Test 2.5: Constant Profile (32)';

%Test 26
test26.history='Test 2.6: Freezing Point (64)';

%test 27
test27.name={'temp';'psal';'doxy';'cphl';'ntrz';'ntri';'phos';'slca';'phph';'alky'};
test27.delta=[ 0.01;  0.01;  0.5;    0.5;   3.5;   0.1;   0.5;     4;   0.03;  0.02];
test27.history='Test 2.7: Replicate Comparisons (128)';

%test 28
test28.name={'temp';'psal';'doxy';'phph'};
test28.delta=[  0.1;   0.2;   1.0;   0.1];  
test28.history='Test 2.8: Bottle versus CTD Measurements (TEMP, PSAL, DOXY, PHPH) (256)';

%Test29
test29.name={'temp';'psal';'sigt';'ntrz';'phos';'phph';'alky'};
test29.gradients=[-10 10; -0.1 5;-0.05 5; -1 1;-1 1; -0.4 0.4; -0.1 0.1];
test29.history='Test 2.9: Excessive Gradient or Inversion (TEMP, PSAL, NTRZ, PHOS, PHPH, TALK) (512)';

%test210
test210.history='Test 2.10: Surface Dissolved Oxygen Data versus Percent Saturation (1024)';
test210.limits=[85 120];

%Test 35
test35.name={'temp';'psal';'sigt'};
test35.history='Test 3.5: Petrie Monthly Climatology (TEMP, PSAL, SIGT)';
load Petrie
load Scotian_shelf
load Newfoundland
test35.P=[P SS NF];

%Test 36
test36.name={'ntrz';'phos';'slca'};
test36.history='Test 3.6: Brickman Monthly Climatology (NTRA, PHOS, SLCA)';
load Petrie_Nutrients
test36.PN=[PN];

%Test 41
test41.name={'temp';'psal'};
test41.max_value=[0.5;0.3];
test41.max_time=2;			%Maximum time in day
test41.max_dist=10;			%Maximum distance in km
test41.pres=(200:5:550);	%Pressures being tested
test41.history='Test 4.1: Profile Consistency (TEMP, PSAL)';

%Test 42
load TS_dw12
TS=TS_dw;
load TS_dw11
TS=[TS TS_dw];
load TS_dw10
TS=[TS TS_dw];
load TS_dw09
TS=[TS TS_dw];
load TS_dw08
TS=[TS TS_dw];
load TS_dw07
TS=[TS TS_dw];
load TS_dw06
TS=[TS TS_dw];
load TS_dw05
TS=[TS TS_dw];
load TS_dw04
TS=[TS TS_dw];
load TS_dw03
TS=[TS TS_dw];
load TS_dw02
TS=[TS TS_dw];
load TS_dw01
TS=[TS TS_dw];
load TS_dw00
TS=[TS TS_dw];
load TS_dw99
TS=[TS TS_dw];
load TS_dw98
TS=[TS TS_dw];
load TS_dw97
TS=[TS TS_dw];
load TS_dw96
TS=[TS TS_dw];
[cruiseid{1:size(TS,2)}]=deal(TS.cruiseid);
cruise=unique(cruiseid);
test42.profile=TS;
test42.name={'temp';'psal'};
test42.max_value=[0.5;0.3];
test42.max_time=13*30;		%Maximum time in day
test42.max_dist=10;			%Maximum distance in km
test42.pres=(300:50:550);	%Pressures being tested
test42.history='Test 4.2: Annual Deep Water Profile Consistency (TEMP, PSAL)';
test42.cruise=char(cruise{1});
for i=2:length(cruise)
	test42.cruise=[test42.cruise ',' char(cruise{i})];
end
   
%Test 51
test51.history='Test 5.1: Cruise Track Visual Inspection';

%Test 52
test52.history='Test 5.2: Ratio and Profile Visual Inspection (station data)';

%Test 53
test53.history='Test 5.3: Replicates Visual Inspection (whole cruise data)';

%Test 54
test54.history='Test 5.4: Bottle Versus CTD Measurements Visual Inspection (whole cruise data)';

%Test 55
test55.history='Test 5.5: Ratio and Profile Visual Inspection (whole cruise data)';

%Test 56
test56.history='Test 5.6: Variable patterns with time (whole cruise data)';

%Saving to file
save B_stage1_Q test11 test12 test13 test14 test15 test16
save B_stage2_Q test21 test22 test23 test24 test25 test26 test27 test28 test29 test210
save B_stage3_Q test35 test36
save B_stage4_Q test41 test42
save B_stage5_Q test51 test52 test53 test54 test55 test56
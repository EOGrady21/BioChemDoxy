function stage_Q_ini
%STAGE_Q_INI - Script for quality control test limits
%
%Syntax:  stage_Q_ini
% Contains limits of quality control tests. Files stage1_Q.mat, stage2_Q.mat
% stage3_Q.mat, stage4_Q.mat and stage5_Q.mat are created and used by quality
% control programs.
% List of available tests 
%  10: Time Chronology
%  11: Platform Identification
%  12: Impossible Date/Time
%  13: Impossible Location
%  14: Position on Land
%  15: Impossible Speed
%  16: Impossible sounding
%  20: Minimum Descent Rate
%  21: Global Impossible Parameter Values
%  22: Regional Impossible Parameter Values
%  23: Increasing Depth
%  24: Profile Envelope
%  26: Freezing Point
%  27: Spike in temperature and salinity (one point)
%  28: Top and Bottom Spike in temperature and salinity (one point)
%  29: Gradient (point to point)
%  210: Density Inversion (point to point)
%  211: Spike (one point or more) (suplementary test)
%  212: Density Inversion (overall profile)
%  35: Petrie Monthly Climatology
%  41: Waterfall
%  42: Annual Deep Water Profile Consistency
%
% MAT-files required: TS_dw96, TS_dw97, TS_dw98, TS_dw99, TS_dw00, gsl_mask, golfe_3km

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%October 1999; Last revision: 05-Oct-1999 CL

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
      'INCONNU_G'; 'CGBV'; 'VC-9450'; 'CGDG'; 'VOXS'; 'CG-3146'; 'CGCB';'VY-2606';...
   	'CF04735';'INCONNU_H';'CGDV';'CGDK';'CGDN'};
test15.max_vel=[20; 14; 20; 20; 20; 12; 14; 20; 12; 20; 20; 12; 20; 20; 20; 12;...
      20; 20; 20; 20; 20; 16; 20; 14; 20; 16; 16; 16; 16; 16; 10.5; 9.5; 17; 9;...
      10; 10; 12; 12; 13.5; 10; 15; 20; 25; 15; 15; 20; 25; 20; 12; 17; 15;...
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

%Test 16
load golfe_3km
test16.lon=xi;
test16.lat=yi;
test16.sounding=zi;
test16.history='Test 1.6: GTSPP Impossible Sounding';

%Test 20
test20.minvalue=0;
test20.history='Test 2.0: IML Minimum Descent Rate (2)';

%Test 21
test21.name={'wspd';'wdir';'potm';'atms';'seaf';'temp';'psal';'pres'};
test21.units={'m/s';'degrees';'degrees C';'hpa';'m';'degrees C';'psu';'decibars'};
test21.minvalue=[ 0;   0; -80; 850;    0; -2.5;  0;     0];
test21.maxvalue=[60; 360;  40; 1060; 10000;   35; 40; 10000];
test21.history='Test 2.1: GTSPP Global Impossible Parameter Values (4)';

%Test 22
test22.name={'wspd';'wdir';'potm';'atms';'seaf';'temp';'psal';'pres'};
test22.units={'m/s';'degrees';'degrees C';'hpa';'m';'degrees C';'psu';'decibars'};
test22.minvalue=[ 0;   0; -40;  850;   0; -2.5;    0;   0];
test22.maxvalue=[50; 360;  30; 1060; 600;   35; 35; 600];
test22.poly_lon=[-56.0; -73.0; -73.0; -64.5; -62.3; -56.0; -56.0];
test22.poly_lat=[ 52.0;  49.5;  46.0;  46.0;  45.2;  48.2;  52.0];
test22.history='Test 2.2: GTSPP Regional Impossible Parameter Values (8)';

%Test 23
test23.history='Test 2.3: GTSPP Increasing Depth (16)';

%Test 24
test24.name={'temp';'temp';'temp';'temp';'psal';'psal';'psal';'psal'};
test24.prof1=[ 0;   50; 100;  400;  0;  50; 100;  400];
test24.prof2=[50; 100; 400; 1100; 50; 100; 400; 1100];
test24.minvalue=[-2.5; -2.5; -2.5; -2;  0;  1;  3; 10];
test24.maxvalue=[  35;   30;   28; 28; 40; 40; 40; 40];
test24.history='Test 2.4: GTSPP Profile Envelope (Temperature and Salinity) (32)';

%Test 25
test25.history='Test 2.5: GTSPP Constant Profile (64)';

%Test 26
test26.history='Test 2.6: GTSPP Freezing Point (128)';

%Test 27
test27.name={'pres';'temp';'psal'};
test27.spikes=[5; 2; 0.3];						
test27.history='Test 2.7: GTSPP Spike in Temperature and Salinity (one point) (256)';

%Test 28
test28.name={'pres';'temp';'psal'};
test28.spikes=[25; 10; 5];						
test28.history='Test 2.8: GTSPP Top and Bottom Spike in Temperature and Salinity (512)';

%Test29
test29.name={'temp';'psal'};
test29.gradients=[10; 5];
test29.history='Test 2.9: GTSPP Gradient in Temperature and Salinity (1024)';

%Test 210
test210.name={'sigt'};
test210.invers=-0.05;				%for 1 dbar intervals
test210.history='Test 2.10: GTSPP Density Inversion (point to point) (2048)';

%Test 211
test211.name={'pres';'temp';'psal'};
test211.spikes=[0.2; 0.3; 0.08];
test211.history='Test 2.11: IML Spike in Pressure, Temperature and Salinity (one point or more) (4096)';

%Test 212
test212.name={'sigt'};
test212.invers=-0.05;				%for 1 dbar intervals
test212.history='Test 2.12: IML Density Inversion (overall profile) (8192)';

%Test 35
test35.name={'temp';'psal';'sigt'};
test35.history='Test 3.5: IML Petrie Monthly Climatology (Temperature, Salinity and Sigma-T)';
load Petrie
load Scotian_shelf
load Newfoundland
test35.P=[P SS NF];

%Test 41
test41.name={'temp';'psal'};
test41.max_value=[0.5;0.3];
test41.max_time=2;			%Maximum time in day
test41.max_dist=10;			%Maximum distance in km
test41.pres=(200:5:550);	%Pressures being tested
test41.history='Test 4.1: GTSPP Profile Consistency';

%Test 42
load TS_dw07
TS=TS_dw;
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
test42.history='Test 4.2: IML Annual Deep Water Profile Consistency';
test42.cruise=char(cruise{1});
for i=2:length(cruise)
	test42.cruise=[test42.cruise ',' char(cruise{i})];
end
   
%Test 51
test51.history='Test 5.1: GTSPP Cruise Track Visual Inspection';

%Test 52
test52.history='Test 5.2: GTSPP Profile Visual Inspection';

%Saving to file
save stage1_Q test11 test12 test13 test14 test15 test16
save stage2_Q test20 test21 test22 test23 test24 test25 test26 test27 test28 test29 test210 test211 test212
save stage3_Q test35
save stage4_Q test41 test42
save stage5_Q test51 test52
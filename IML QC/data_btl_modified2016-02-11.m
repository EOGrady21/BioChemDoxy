%DATA_BTL - Script for BTL data code
%
%Syntax: data_BTL
% The structure btlLIST contains information about BTL data.
% Must be modified if new data are introduced.
% Field descriptions:
%   btlLIST.name -> Variable name in BTL_(Cruise_Number) file
%   btlLIST.units -> Variable units in BTL_(Cruise_Number) file
%   btlLIST.code -> Variable code in BTL_(Cruise_Number) file (unique)
%   btlLIST.gf3 -> Variable GF3 code
%   btlLIST.btl2gf3 -> Conversion factor*btl=GF3 (usually 1)
%   btlLIST.decimal -> Number of decimal places (precision needed)
%   btlLIST.method -> Method used (cell array of method codes)
%   btlLIST.desc -> Short description of method (cell array of method descriptions)
%   key.code -> list of btlLIST.code for quick retrieval
%   key.gf3 -> list of btlLIST.gf3 for quick retrieval
%   key.null -> null value

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2000; Last revision: 27-Jun-2000 CL
%% THIS LIST MODIFIED FOR NUTRIENTS ANALYZED USING BIO METHOD (**_05) DESCRIBED IN 
%% Strain, PM, & PM Clement. 1996. Nutrient and dissolved oxygen concentration in the Letange Inlet, NB, 
%% in the summer of 1994. Can Data Rep Fish Aquat Sci 1004, vi +33 pp.
% added UNO3 and UNH4: uptake rates of NOx and NH4 (used to distinguish new and regenerated production), jan 2013

%% May-June 2015 (LD): 
% pHT, ALKW, TICW added

%Data keywords
%Links between btl variables and GF3 codes and units
btlLIST(1).name = 'Filename';				%Variable name in btl-file
btlLIST(1).units = 'none';					%Variable units in btl-file
btlLIST(1).type = 'CTD';					%Data type
btlLIST(1).code = 'Fichier';				%Variable code in btl-file (unique)
btlLIST(1).gf3 = '(none)';					%Variable GF3 code
btlLIST(1).btl2gf3 = 1;						%Conversion factor*btl=GF3 (usually 1)
btlLIST(1).decimal = 0;						%Number of decimal places
btlLIST(1).method = {'Fichier'};			%Method number
btlLIST(1).desc = {'filename: CTD'};	%Method description

btlLIST(2).name = 'latitude';
btlLIST(2).units = 'degrees';
btlLIST(2).type = 'CTD';
btlLIST(2).code = 'Latitude';
btlLIST(2).gf3 = 'LATD';
btlLIST(2).btl2gf3 = 1;
btlLIST(2).decimal = 5;
btlLIST(2).method = {'Latitude'};
btlLIST(2).desc = {'latitude: CTD'};

btlLIST(3).name = 'longitude';
btlLIST(3).units = 'degrees';
btlLIST(3).type = 'CTD';
btlLIST(3).code = 'Longitude';
btlLIST(3).gf3 = 'LOND';
btlLIST(3).btl2gf3 = 1;
btlLIST(3).decimal = 5;
btlLIST(3).method = {'Longitude'};
btlLIST(3).desc = {'longitude: CTD'};

btlLIST(4).name = 'unique sample number';
btlLIST(4).units = 'none';
btlLIST(4).type = 'CTD';
btlLIST(4).code = 'Echantillon';
btlLIST(4).gf3 = 'IDEN';
btlLIST(4).btl2gf3 = 1;
btlLIST(4).decimal = 0;
btlLIST(4).method = {'Echantillon'};
btlLIST(4).desc = {'unique sample number'};

btlLIST(5).name = 'pressure depth of the water sample';
btlLIST(5).units = 'db';
btlLIST(5).type = 'CTD';
btlLIST(5).code = 'zbouteille';
btlLIST(5).gf3 = 'PRES';
btlLIST(5).btl2gf3 = 1;
btlLIST(5).decimal = 1;
btlLIST(5).method = {'zbouteille'};
btlLIST(5).desc = {'nominal or exact water sample depth'};

btlLIST(6).name = 'GMT date of the water sample';
btlLIST(6).units = 'none';
btlLIST(6).type = 'CTD';
btlLIST(6).code = 'Date';
btlLIST(6).gf3 = 'UNKN';
btlLIST(6).btl2gf3 = 1;
btlLIST(6).decimal = 0;
btlLIST(6).method = {'Date'};
btlLIST(6).desc = {'date: CTD'};

btlLIST(7).name = 'GMT time of the water sample';
btlLIST(7).units = 'none';
btlLIST(7).type = 'CTD';
btlLIST(7).code = 'Time';
btlLIST(7).gf3 = 'UNKN';
btlLIST(7).btl2gf3 = 1;
btlLIST(7).decimal = 0;
btlLIST(7).method = {'Time'};
btlLIST(7).desc = {'time: CTD'};

btlLIST(8).name = 'scan number';
btlLIST(8).units = 'none';
btlLIST(8).type = 'CTD';
btlLIST(8).code = 'CNTR';
btlLIST(8).gf3 = 'CNTR';
btlLIST(8).btl2gf3 = 1;
btlLIST(8).decimal = 0;
btlLIST(8).method = {'CNTR'};
btlLIST(8).desc = {'scan number: CTD'};

btlLIST(9).name = 'number of scans averaged';
btlLIST(9).units = 'none';
btlLIST(9).type = 'CTD';
btlLIST(9).code = 'nCNTR';
btlLIST(9).gf3 = 'NUM_'; %'NUM_';
btlLIST(9).btl2gf3 = 1;
btlLIST(9).decimal = 0;
btlLIST(9).method = {'nCNTR'};
btlLIST(9).desc = {'number of scans averaged: CTD'};

btlLIST(10).name = 'CTD pressure';
btlLIST(10).units = 'db';
btlLIST(10).type = 'CTD';
btlLIST(10).code = 'PRES';
btlLIST(10).gf3 = 'PRES';
btlLIST(10).btl2gf3 = 1;
btlLIST(10).decimal = 1;
btlLIST(10).method = {'PRES'};
btlLIST(10).desc = {'pressure: CTD'};

btlLIST(11).name = 'CTD standard deviation pressure';
btlLIST(11).units = 'db';
btlLIST(11).type = 'CTD';
btlLIST(11).code = 'PRES_SDEV';
btlLIST(11).gf3 = 'SDEV';
btlLIST(11).btl2gf3 = 1;
btlLIST(11).decimal = 2;
btlLIST(11).method = {'PRES_SDEV'};
btlLIST(11).desc = {'standard deviation pressure: CTD'};

btlLIST(12).name = 'CTD temperature ITS-90';
btlLIST(12).units = 'deg C';
btlLIST(12).type = 'CTD';
btlLIST(12).code = 'TE90';
btlLIST(12).gf3 = 'TE90';
btlLIST(12).btl2gf3 = 1;
btlLIST(12).decimal = 2;
btlLIST(12).method = {'TE90'};
btlLIST(12).desc = {'temperature: CTD'};

btlLIST(13).name = 'CTD standard deviation temperature';
btlLIST(13).units = 'deg C';
btlLIST(13).type = 'CTD';
btlLIST(13).code = 'TE90_SDEV';
btlLIST(13).gf3 = 'SDEV';
btlLIST(13).btl2gf3 = 1;
btlLIST(13).decimal = 3;
btlLIST(13).method = {'TE90_SDEV'};
btlLIST(13).desc = {'standard deviation temperature: CTD'};

btlLIST(14).name = 'CTD salinity PSS-78';
btlLIST(14).units = 'PSU';
btlLIST(14).type = 'CTD';
btlLIST(14).code = 'PSAL';
btlLIST(14).gf3 = 'PSAL';
btlLIST(14).btl2gf3 = 1;
btlLIST(14).decimal = 2;
btlLIST(14).method = {'PSAL'};
btlLIST(14).desc = {'salinity: CTD'};

btlLIST(15).name = 'CTD sigma-t';
btlLIST(15).units = 'kg/m**3';
btlLIST(15).type = 'CTD';
btlLIST(15).code = 'SIGT';
btlLIST(15).gf3 = 'SIGT';
btlLIST(15).btl2gf3 = 1;
btlLIST(15).decimal = 2;
btlLIST(15).method = {'SIGT'};
btlLIST(15).desc = {'sigma-t: CTD'};

btlLIST(16).name = 'CTD fluorescence';
btlLIST(16).units = 'mg/m**3';
btlLIST(16).type = 'CTD';
btlLIST(16).code = 'FLOR'; 	%MEDS: FLU1
btlLIST(16).gf3 = 'FLOR';
btlLIST(16).btl2gf3 = 1;
btlLIST(16).decimal = 3;
btlLIST(16).method = {'FLOR'};
btlLIST(16).desc = {'fluorescence: CTD'};

btlLIST(17).name = 'CTD oxygen';
btlLIST(17).units = 'ml/l';
btlLIST(17).type = 'CTD';
btlLIST(17).code = 'DOXY';
btlLIST(17).gf3 = 'DOXY';
btlLIST(17).btl2gf3 = 1;
btlLIST(17).decimal = 3;
btlLIST(17).method = {'DOXY'};
btlLIST(17).desc = {'oxygen: CTD'};

btlLIST(18).name = 'CTD transmissivity';
btlLIST(18).units = '%';
btlLIST(18).type = 'CTD';
btlLIST(18).code = 'TRAN';
btlLIST(18).gf3 = 'TRAN';
btlLIST(18).btl2gf3 = 1;
btlLIST(18).decimal = 1;
btlLIST(18).method = {'TRAN'};
btlLIST(18).desc = {'transmissivity: CTD'};

btlLIST(19).name = 'CTD irradiance (PAR)';
btlLIST(19).units = 'ueinsteins/s/m**2';
btlLIST(19).type = 'CTD';
btlLIST(19).code = 'PSAR'; 	%MEDS: PAR$
btlLIST(19).gf3 = 'PSAR';
btlLIST(19).btl2gf3 = 1;
btlLIST(19).decimal = 3;
btlLIST(19).method = {'PSAR'};
btlLIST(19).desc = {'water column PAR (photosynthetically active radiation): CTD'};

btlLIST(20).name = 'reversing thermometer temperature ITS-90';
btlLIST(20).units = 'deg C';
btlLIST(20).type = 'terrain';
btlLIST(20).code = 'TEMP_RT';
btlLIST(20).gf3 = 'TE90';
btlLIST(20).btl2gf3 = 1;
btlLIST(20).decimal = 4;
btlLIST(20).method = {'TEMP_RT'};
btlLIST(20).desc = {'reversing thermometer measurement'};

btlLIST(21).name = 'quality flag temperature';
btlLIST(21).units = '(none)';
btlLIST(21).type = 'terrain';
btlLIST(21).code = 'Q_TEMP';
btlLIST(21).gf3 = 'QQQQ';
btlLIST(21).btl2gf3 = 1;
btlLIST(21).decimal = 0;
btlLIST(21).method = {'Q_TEMP'};
btlLIST(21).desc = {'quality flag of temperature'};

btlLIST(22).name = 'secchi depth';
btlLIST(22).units = 'm';
btlLIST(22).type = 'terrain';
btlLIST(22).code = 'SECC';
btlLIST(22).gf3 = 'SECC';
btlLIST(22).btl2gf3 = 1;
btlLIST(22).decimal = 1;
btlLIST(22).method = {'SECC'};
btlLIST(22).desc = {'secchi depth measurement'};

btlLIST(23).name = 'bottle sample salinity PSS-78';
btlLIST(23).units = 'PSU';
btlLIST(23).type = 'labo';
btlLIST(23).code = 'PSAL_BS';
btlLIST(23).gf3 = 'PSAL';
btlLIST(23).btl2gf3 = 1;
btlLIST(23).decimal = 2;
btlLIST(23).method = {'PSAL_BS'};
btlLIST(23).desc = {'autoSAL salinity measurement'};

btlLIST(24).name = 'quality flag of bottle sample salinity';
btlLIST(24).units = '(none)';
btlLIST(24).type = 'labo';
btlLIST(24).code = 'Q_PSAL';
btlLIST(24).gf3 = 'QQQQ';
btlLIST(24).btl2gf3 = 1;
btlLIST(24).decimal = 0;
btlLIST(24).method = {'Q_PSAL'};
btlLIST(24).desc = {'quality flag of bottle sample salinity'};

btlLIST(25).name = 'bottle sample oxygen';
btlLIST(25).units = 'ml/l';
btlLIST(25).type = 'labo';
btlLIST(25).code = 'OXY_';
btlLIST(25).gf3 = 'DOXY';
btlLIST(25).btl2gf3 = 1;
btlLIST(25).decimal = 3;
btlLIST(25).method = {'OXY_01';'OXY_02';'OXY_XX';'OXY_03'};
btlLIST(25).desc = {'Winkler dissolved oxygen titration method: Carpenter (1965) and Carrit and Carpenter (1966)';...
      'Winkler automated dissolved oxygen titration method: Jones, Zemlyak and Stewart (1992)';...
   	'dissolved oxygen: unknown method';...
    'dissolved oxygen measured by laboratory electrode'};

btlLIST(26).name = 'quality flag of bottle sample oxygen';
btlLIST(26).units = '(none)';
btlLIST(26).type = 'labo';
btlLIST(26).code = 'Q_OXY';
btlLIST(26).gf3 = 'QQQQ';
btlLIST(26).btl2gf3 = 1;
btlLIST(26).decimal = 0;
btlLIST(26).method = {'Q_OXY'};
btlLIST(26).desc = {'quality flag of bottle sample oxygen '};

btlLIST(27).name = 'bottle sample chlorophyll content';
btlLIST(27).units = 'mg/m**3';
btlLIST(27).type = 'labo';
btlLIST(27).code = 'CHL_';
btlLIST(27).gf3 = 'CPHL';
btlLIST(27).btl2gf3 = 1;
btlLIST(27).decimal = 2;
btlLIST(27).method = {'CHL_01';'CHL_02';'CHL_03';'CHL_04';'CHL_05';'CHL_XX'};
btlLIST(27).desc = {'chlorophyll-a content: fluorometric method of Holm-Hansen, Lorenzen, Holmes and Strickland (1965)';...
      'chlorophyll-a content: fluorometric method modified from Holm-Hansen, Lorenzen, Holmes and Strickland (1965)';...
      'chlorophyll-a content: Welschmeyer (1994)';...
   	  'chlorophyll-a content: modified from Welschmeyer (1994)';...
      'chlorophylls(a+b+c) content: Richards with Thompson (1952), described in Strickland and Parsons (1968)';...
   	  'chlorophyll-a content: unknown method'};

btlLIST(28).name = 'quality flag of bottle sample chlorophyll content';
btlLIST(28).units = '(none)';
btlLIST(28).type = 'labo';
btlLIST(28).code = 'Q_CHL';
btlLIST(28).gf3 = 'QQQQ';
btlLIST(28).btl2gf3 = 1;
btlLIST(28).decimal = 0;
btlLIST(28).method = {'Q_CHL'};
btlLIST(28).desc = {'quality flag of bottle sample chlorophyll content'};

btlLIST(29).name = 'bottle sample phaeopigment content';
btlLIST(29).units = 'mg/m**3';
btlLIST(29).type = 'labo';
btlLIST(29).code = 'PHA_'; 	%MEDS: PHA$ 
btlLIST(29).gf3 = 'PHA_';
btlLIST(29).btl2gf3 = 1;
btlLIST(29).decimal = 2;
btlLIST(29).method = {'PHA_01';'PHA_02';'PHA_XX'};
btlLIST(29).desc = {'phaeopigment content: fluorometric method of Holm-Hansen, Lorenzen, Holmes and Strickland (1965)';...
      'phaeopigment content: fluorometric method modified from Holm-Hansen, Lorenzen, Holmes and Strickland (1965)';...
      'phaeopigment content: unknown method'};
%removed code PHA_05 because it has been replaced with LCHL (march 2005)

btlLIST(30).name = 'quality flag of bottle sample phaeopigment content';
btlLIST(30).units = '(none)';
btlLIST(30).type = 'labo';
btlLIST(30).code = 'Q_PHA';
btlLIST(30).gf3 = 'QQQQ';
btlLIST(30).btl2gf3 = 1;
btlLIST(30).decimal = 0;
btlLIST(30).method = {'Q_PHA'};
btlLIST(30).desc = {'quality flag of bottle sample phaeopigment content'};

btlLIST(31).name = 'bottle sample organic carbon content';
btlLIST(31).units = 'mmol/m**3';
btlLIST(31).type = 'labo';
btlLIST(31).code = 'POC_';
btlLIST(31).gf3 = 'POC_';	%instead of CORG PX
btlLIST(31).btl2gf3 = 1;
btlLIST(31).decimal = 2;
btlLIST(31).method = {'POC_01';'POC_02';'POC_XX'};
btlLIST(31).desc = {'particulate organic carbon content: Ehrhardt (1983)';...
    'particulate organic carbon content: method described in Therriault & Levasseur 1985, Naturaliste can 112';...
   	'particulate organic carbon content: unknown method'};

btlLIST(32).name = 'quality flag of bottle sample organic carbon content';
btlLIST(32).units = '(none)';
btlLIST(32).type = 'labo';
btlLIST(32).code = 'Q_POC';
btlLIST(32).gf3 = 'QQQQ';
btlLIST(32).btl2gf3 = 1;
btlLIST(32).decimal = 0;
btlLIST(32).method = {'Q_POC'};
btlLIST(32).desc = {'quality flag of bottle sample organic carbon content'};

btlLIST(33).name = 'bottle sample organic nitrogen content';
btlLIST(33).units = 'mmol/m**3';
btlLIST(33).type = 'labo';
btlLIST(33).code = 'PON_';
btlLIST(33).gf3 = 'PON_';	%instead of NORG PX
btlLIST(33).btl2gf3 = 1;
btlLIST(33).decimal = 2;
btlLIST(33).method = {'PON_01';'PON_02';'PON_XX'};
btlLIST(33).desc = {'particulate organic nitrogen content: Ehrhardt (1983)';...
    'particulate organic nitrogen content: method described in Therriault & Levasseur 1985, Naturaliste can 112';...
   	'particulate organic nitrogen content: unknown method'};

btlLIST(34).name = 'quality flag of bottle sample organic nitrogen content';
btlLIST(34).units = '(none)';
btlLIST(34).type = 'labo';
btlLIST(34).code = 'Q_PON';
btlLIST(34).gf3 = 'QQQQ';
btlLIST(34).btl2gf3 = 1;
btlLIST(34).decimal = 0;
btlLIST(34).method = {'Q_PON'};
btlLIST(34).desc = {'quality flag of bottle sample organic nitrogen content'};

btlLIST(35).name = 'bottle sample nitrate (NO3-N) content';
btlLIST(35).units = 'mmol/m**3';
btlLIST(35).type = 'labo';
btlLIST(35).code = 'NO3_';
btlLIST(35).gf3 = 'NTRA';
btlLIST(35).btl2gf3 = 1;
btlLIST(35).decimal = 2;
btlLIST(35).method = {'NO3_01';'NO3_02';'NO3_03';'NO3_99';'NO3_XX'};
btlLIST(35).desc = {'nitrate content: NOx_01-NO2_01';...
    'nitrate content: NOx_02-NO2_02';...
    'nitrate content: NOx_03-NO2_03';...   
   	'nitrate content:  NOx-NO2 not corrected for salinity';...
   	'nitrate content: unknown method'};

btlLIST(36).name = 'quality flag of bottle sample nitrate (NO3-N) content';
btlLIST(36).units = '(none)';
btlLIST(36).type = 'labo';
btlLIST(36).code = 'Q_NO3';
btlLIST(36).gf3 = 'QQQQ';
btlLIST(36).btl2gf3 = 1;
btlLIST(36).decimal = 0;
btlLIST(36).method = {'Q_NO3'};
btlLIST(36).desc = {'quality flag of bottle sample nitrate (NO3-N) content'};

btlLIST(37).name = 'bottle sample nitrite (NO2-N) content';
btlLIST(37).units = 'mmol/m**3';
btlLIST(37).type = 'labo';
btlLIST(37).code = 'NO2_';
btlLIST(37).gf3 = 'NTRI';
btlLIST(37).btl2gf3 = 1;
btlLIST(37).decimal = 2;
btlLIST(37).method = {'NO2_01';'NO2_02';'NO2_03';'NO2_99';'NO2_05';'NO2_XX'};
btlLIST(37).desc = {'nitrite content: American Public Health Association (1971)';...
    'nitrite content: American Public Health Association (1989)';...
    'nitrite content: AA3; American Public Health Association (1971)';...  
   	'nitrite content: not corrected for salinity';...
    'nitrite content: Strain & Clement.1996.Can Data Rep Fish Aquat Sci 1004';...
   	'nitrite content: unknown method'};

btlLIST(38).name = 'quality flag of bottle sample nitrite (NO2-N) content';
btlLIST(38).units = '(none)';
btlLIST(38).type = 'labo';
btlLIST(38).code = 'Q_NO2';
btlLIST(38).gf3 = 'QQQQ';
btlLIST(38).btl2gf3 = 1;
btlLIST(38).decimal = 0;
btlLIST(38).method = {'Q_NO2'};
btlLIST(38).desc = {'quality flag of bottle sample nitrite (NO2-N) content'};

btlLIST(39).name = 'bottle sample phosphate (PO4-P) content';
btlLIST(39).units = 'mmol/m**3';
btlLIST(39).type = 'labo';
btlLIST(39).code = 'PO4_';
btlLIST(39).gf3 = 'PHOS';
btlLIST(39).btl2gf3 = 1;
btlLIST(39).decimal = 2;
btlLIST(39).method = {'PO4_01';'PO4_02';'PO4_03';'PO4_99';'PO4_XX';'PO4_04';'PO4_05'};
btlLIST(39).desc = {'phosphate content: Murphy and Riley (1962)';...
    'phosphate content: EPA (1984)';...
    'phosphate content: AA3; Murphy and Riley (1962)';...  
   	'phosphate content: not corrected for salinity';...
    'phosphate content: unknown method';...
   	'phosphate content: Strickland and Parsons (1968)';...
    'phosphate content: Strain & Clement.1996.Can Data Rep Fish Aquat Sci 1004'};

btlLIST(40).name = 'quality flag of bottle sample phosphate (PO4-P) content';
btlLIST(40).units = '(none)';
btlLIST(40).type = 'labo';
btlLIST(40).code = 'Q_PO4';
btlLIST(40).gf3 = 'QQQQ';
btlLIST(40).btl2gf3 = 1;
btlLIST(40).decimal = 0;
btlLIST(40).method = {'Q_PO4'};
btlLIST(40).desc = {'quality flag of bottle sample phosphate (PO4-P) content'};

btlLIST(41).name = 'bottle sample silicate (SIO4-SI) content';
btlLIST(41).units = 'mmol/m**3';
btlLIST(41).type = 'labo';
btlLIST(41).code = 'Si_';
btlLIST(41).gf3 = 'SLCA';
btlLIST(41).btl2gf3 = 1;
btlLIST(41).decimal = 2;
btlLIST(41).method = {'Si_01';'Si_02';'Si_03';'Si_99';'Si_XX';'Si_04'; 'Si_05'};
btlLIST(41).desc = {'silicate content: Strickland and Parsons (1972)';...
      'silicate content: American Public Health Association (1989)';...
      'silicate content: AA3; Strickland and Parsons (1972)';...
	  'silicate content: not corrected for salinity';...
   	  'silicate content: unknown method.';...
      'silicate content: Strickland and Parsons (1968)';...
      'silicate content: Strain & Clement.1996.Can Data Rep Fish Aquat Sci 1004'};

btlLIST(42).name = 'quality flag of bottle sample silicate (SIO4-SI) content';
btlLIST(42).units = '(none)';
btlLIST(42).type = 'labo';
btlLIST(42).code = 'Q_Si';
btlLIST(42).gf3 = 'QQQQ';
btlLIST(42).btl2gf3 = 1;
btlLIST(42).decimal = 0;
btlLIST(42).method = {'Q_Si'};
btlLIST(42).desc = {'quality flag of bottle sample silicate (SIO4-SI) content'};

btlLIST(43).name = 'bottle sample ammonium (NH4-N) content';
btlLIST(43).units = 'mmol/m**3';
btlLIST(43).type = 'labo';
btlLIST(43).code = 'NH4_';
btlLIST(43).gf3 = 'AMON';
btlLIST(43).btl2gf3 = 1;
btlLIST(43).decimal = 2;
btlLIST(43).method = {'NH4_01';'NH4_02';'NH4_XX'; 'NH4_05'};
btlLIST(43).desc = {'ammonium content: Van Slyke and Hillen (1933)';...
      'ammonium content: EPA (1984)';...
   	  'ammonium content: unknown method';...
      'ammonium content: Strain & Clement.1996.Can Data Rep Fish Aquat Sci 1004'};

btlLIST(44).name = 'quality flag of bottle sample ammonium (NH4-N) content';
btlLIST(44).units = '(none)';
btlLIST(44).type = 'labo';
btlLIST(44).code = 'Q_NH4';
btlLIST(44).gf3 = 'QQQQ';
btlLIST(44).btl2gf3 = 1;
btlLIST(44).decimal = 0;
btlLIST(44).method = {'Q_NH4'};
btlLIST(44).desc = {'quality flag of bottle sample ammonium (NH4-N) content'};

btlLIST(45).name = 'bottle sample urea content';
btlLIST(45).units = 'mmol/m**3';
btlLIST(45).type = 'labo';
btlLIST(45).code = 'Uree_';
btlLIST(45).gf3 = 'URE_';
btlLIST(45).btl2gf3 = 1;
btlLIST(45).decimal = 2;
btlLIST(45).method = {'Uree_01';'Uree_XX'};
btlLIST(45).desc = {'urea content: Aminot and Kerouel (1982); Price and Harrison (1987)';...
   	'urea content: unknown method'};

btlLIST(46).name = 'quality flag of bottle sample urea content';
btlLIST(46).units = '(none)';
btlLIST(46).type = 'labo';
btlLIST(46).code = 'Q_Uree';
btlLIST(46).gf3 = 'QQQQ';
btlLIST(46).btl2gf3 = 1;
btlLIST(46).decimal = 0;
btlLIST(46).method = {'Q_Uree'};
btlLIST(46).desc = {'quality flag of bottle sample urea content'};

btlLIST(47).name = 'dilution pour fichier temporaire de correction Si';
btlLIST(47).units = '(none)';
btlLIST(47).type = 'labo';
btlLIST(47).code = 'DIL_';
btlLIST(47).gf3 = 'DIL_';
btlLIST(47).btl2gf3 = 1;
btlLIST(47).decimal = 0;
btlLIST(47).method = {'DIL_01'};
btlLIST(47).desc = {'dilution'};

btlLIST(48).name = 'bottle sample nitrate (NO3-N) + nitrite (NO2-N) content';
btlLIST(48).units = 'mmol/m**3';
btlLIST(48).type = 'labo';
btlLIST(48).code = 'NOx_';
btlLIST(48).gf3 = 'NTRZ';
btlLIST(48).btl2gf3 = 1;
btlLIST(48).decimal = 2;
btlLIST(48).method = {'NOx_01';'NOx_02';'NOx_03';'NOx_99';'NOx_XX';'NOx_04'; 'NOx_05'};
btlLIST(48).desc = {'nitrate + nitrite content: Armstrong, Stearns and Strickland (1967)';...
    'nitrate + nitrite content: American Public Health Association (1989)';...
    'nitrate + nitrite content: AA3; Armstrong, Stearns and Strickland (1967)';...
   	'nitrate + nitrite content: not corrected for salinity';...
   	'nitrate + nitrite content: unknown method';...
    'nitrate + nitrite content: Strickland and Parsons (1968)';...
    'nitrate + nitrite content: Strain & Clement.1996.Can Data Rep Fish Aquat Sci 1004'};

btlLIST(49).name = 'quality flag of bottle sample nitrate (NO3-N) + nitrite (NO2-N) content';
btlLIST(49).units = '(none)';
btlLIST(49).type = 'labo';
btlLIST(49).code = 'Q_NOx';
btlLIST(49).gf3 = 'QQQQ';
btlLIST(49).btl2gf3 = 1;
btlLIST(49).decimal = 0;
btlLIST(49).method = {'Q_NOx'};
btlLIST(49).desc = {'quality flag of bottle sample nitrate (NO3-N) + nitrite (NO2-N) content'};

btlLIST(50).name = 'bottle sample total suspended matter';
btlLIST(50).units = 'g/m**3';
btlLIST(50).type = 'labo';
btlLIST(50).code = 'TSM_';
btlLIST(50).gf3 = 'TSM_';	
btlLIST(50).btl2gf3 = 1;
btlLIST(50).decimal = 2;
btlLIST(50).method = {'TSM_01';'TSM_02';'TSM_XX'};
btlLIST(50).desc = {'total suspended matter, 0.7um GF/F filters: Strickland and Parsons (1972)';...
      'total suspended matter, 0.4um polycarbonate filters: Strickland and Parsons (1972)';...
   	  'total suspended matter: unknown method'};

btlLIST(51).name = 'quality flag of bottle sample total suspended matter';
btlLIST(51).units = '(none)';
btlLIST(51).type = 'labo';
btlLIST(51).code = 'Q_TSM';
btlLIST(51).gf3 = 'QQQQ';
btlLIST(51).btl2gf3 = 1;
btlLIST(51).decimal = 0;
btlLIST(51).method = {'Q_TSM'};
btlLIST(51).desc = {'quality flag of bottle sample total suspended matter'};

btlLIST(52).name = 'bottle sample particulate organic matter';
btlLIST(52).units = 'g/m**3';
btlLIST(52).type = 'labo';
btlLIST(52).code = 'POM_';
btlLIST(52).gf3 = 'POM_';	
btlLIST(52).btl2gf3 = 1;
btlLIST(52).decimal = 2;
btlLIST(52).method = {'POM_01';'POM_XX'};
btlLIST(52).desc = {'particulate organic matter, 0.7um GF/F filters: Am Pub Health Assoc (1985)';...
         	'particulate organic matter: unknown method'};
    %ref for _01 corrected 19 jan 2006

btlLIST(53).name = 'quality flag of bottle sample particulate organic matter';
btlLIST(53).units = '(none)';
btlLIST(53).type = 'labo';
btlLIST(53).code = 'Q_POM';
btlLIST(53).gf3 = 'QQQQ';
btlLIST(53).btl2gf3 = 1;
btlLIST(53).decimal = 0;
btlLIST(53).method = {'Q_POM'};
btlLIST(53).desc = {'quality flag of bottle sample particulate organic matter'};

btlLIST(54).name = 'bottle sample particulate inorganic matter';
btlLIST(54).units = 'g/m**3';
btlLIST(54).type = 'labo';
btlLIST(54).code = 'PIM_';
btlLIST(54).gf3 = 'PIM_';	
btlLIST(54).btl2gf3 = 1;
btlLIST(54).decimal = 2;
btlLIST(54).method = {'PIM_01';'PIM_XX'};
btlLIST(54).desc = {'particulate inorganic matter, 0.7um GF/F filters: Am Pub Health Assoc (1985)';...
         	'particulate inorganic matter: unknown method'};
    %ref for _01 corrected 19 jan 2006

btlLIST(55).name = 'quality flag of bottle sample particulate inorganic matter';
btlLIST(55).units = '(none)';
btlLIST(55).type = 'labo';
btlLIST(55).code = 'Q_PIM';
btlLIST(55).gf3 = 'QQQQ';
btlLIST(55).btl2gf3 = 1;
btlLIST(55).decimal = 0;
btlLIST(55).method = {'Q_PIM'};
btlLIST(55).desc = {'quality flag of bottle sample particulate inorganic matter'};

btlLIST(56).name = 'bottle sample dissolved organic carbon';
btlLIST(56).units = 'mmol/m**3';
btlLIST(56).type = 'labo';
btlLIST(56).code = 'DOC_'; 	%instead of CORG DX
btlLIST(56).gf3 = 'DOC_';	
btlLIST(56).btl2gf3 = 1;
btlLIST(56).decimal = 2;
btlLIST(56).method = {'DOC_01';'DOC_XX'};
btlLIST(56).desc = {'dissolved organic carbon, METHOD TO BE ADDED!';...
         	'dissolved organic carbon: unknown method'};

btlLIST(57).name = 'quality flag of bottle sample dissolved organic carbon';
btlLIST(57).units = '(none)';
btlLIST(57).type = 'labo';
btlLIST(57).code = 'Q_DOC';
btlLIST(57).gf3 = 'QQQQ';
btlLIST(57).btl2gf3 = 1;
btlLIST(57).decimal = 0;
btlLIST(57).method = {'Q_DOC'};
btlLIST(57).desc = {'quality flag of bottle sample dissolved organic carbon'};

btlLIST(58).name = 'percentage of the incident surface light remaining at the sampled depth';
btlLIST(58).units = '%';
btlLIST(58).type = 'terrain';
btlLIST(58).code = 'PLT_'; %MEDS PLT%
btlLIST(58).gf3 = 'PLT_';
btlLIST(58).btl2gf3 = 1;
btlLIST(58).decimal = 1;
btlLIST(58).method = {'PLT_01'};
btlLIST(58).desc = {'percentage of the incident surface light remaining at the sampled depth'};

btlLIST(59).name = 'CTD oxygen percent saturation';
btlLIST(59).units = '%';
btlLIST(59).type = 'CTD';
btlLIST(59).code = 'OSAT';
btlLIST(59).gf3 = 'OSAT';
btlLIST(59).btl2gf3 = 1;
btlLIST(59).decimal = 2;
btlLIST(59).method = {'OSAT'};
btlLIST(59).desc = {'percentage oxygen saturation: CTD'};

%btlLIST(59).name = 'CTD theoretical oxygen saturation';
%btlLIST(59).units = 'ml/l';
%btlLIST(59).type = 'CTD';
%btlLIST(59).code = 'oxsatML/L';
%btlLIST(59).gf3 = 'NONE';
%btlLIST(59).btl2gf3 = 1;
%btlLIST(59).decimal = 3;
%btlLIST(59).method = {'NONE'};
%btlLIST(59).desc = {'theoretical oxygen sat: CTD'};

btlLIST(60).name = 'CTD oxygen voltage, SBE43';
btlLIST(60).units = 'volts';
btlLIST(60).type = 'CTD';
btlLIST(60).code = 'OXV_';
btlLIST(60).gf3 = 'OXV_';
btlLIST(60).btl2gf3 = 1;
btlLIST(60).decimal = 3;
btlLIST(60).method = {'OXV_'};
btlLIST(60).desc = {'oxygen voltage, SBE43: CTD'};

btlLIST(61).name = 'quality flag: QCFF';
btlLIST(61).units = '(none)';
btlLIST(61).type = 'labo';
btlLIST(61).code = 'QCFF';
btlLIST(61).gf3 = 'QCFF';
btlLIST(61).btl2gf3 = 1;
btlLIST(61).decimal = 0;
btlLIST(61).method = {'QCFF'};
btlLIST(61).desc = {'quality flag: QCFF'};

btlLIST(62).name = 'CTD Surface irradiance (SPAR)';
btlLIST(62).units = 'ueinsteins/s/m**2';
btlLIST(62).type = 'CTD';
btlLIST(62).code = 'SPAR';
btlLIST(62).gf3 = 'SPAR';
btlLIST(62).btl2gf3 = 1;
btlLIST(62).decimal = 3;
btlLIST(62).method = {'SPAR'};
btlLIST(62).desc = {'surface PAR (photosynthetically active radiation): CTD'};

btlLIST(63).name = 'bottle sample chlorophyll-a content from cells >5um';
btlLIST(63).units = 'mg/m**3';
btlLIST(63).type = 'labo';
btlLIST(63).code = 'LCHL_';
btlLIST(63).gf3 = 'LCHL';
btlLIST(63).btl2gf3 = 1;
btlLIST(63).decimal = 2;
btlLIST(63).method = {'LCHL_01'};
btlLIST(63).desc = {'chlorophyll-a content from cells >5um: fluorometric method modified from Holm-Hansen, Lorenzen, Holmes and Strickland (1965)'};
      
btlLIST(64).name = 'quality flag of bottle sample chlorophyll-a content from cells >5um';
btlLIST(64).units = '(none)';
btlLIST(64).type = 'labo';
btlLIST(64).code = 'Q_LCHL';
btlLIST(64).gf3 = 'QQQQ';
btlLIST(64).btl2gf3 = 1;
btlLIST(64).decimal = 0;
btlLIST(64).method = {'Q_LCHL'};
btlLIST(64).desc = {'quality flag of bottle sample chlorophyll-a content from cells >5um'};

btlLIST(65).name = 'bottle sample phaeopigment content from cells >5um';
btlLIST(65).units = 'mg/m**3';
btlLIST(65).type = 'labo';
btlLIST(65).code = 'LPHA_'; 	
btlLIST(65).gf3 = 'LPHA';
btlLIST(65).btl2gf3 = 1;
btlLIST(65).decimal = 2;
btlLIST(65).method = {'LPHA_01'};
btlLIST(65).desc = {'phaeopigment content from cells >5um: fluorometric method modified from Holm-Hansen, Lorenzen, Holmes and Strickland (1965)'};

btlLIST(66).name = 'quality flag of bottle sample phaeopigment content from cells >5um';
btlLIST(66).units = '(none)';
btlLIST(66).type = 'labo';
btlLIST(66).code = 'Q_LPHA';
btlLIST(66).gf3 = 'QQQQ';
btlLIST(66).btl2gf3 = 1;
btlLIST(66).decimal = 0;
btlLIST(66).method = {'Q_LPHA'};
btlLIST(66).desc = {'quality flag of bottle sample phaeopigment content from cells >5um'};

btlLIST(67).name = 'CTD percent fluorescence';
btlLIST(67).units = '%';
btlLIST(67).type = 'CTD';
btlLIST(67).code = 'FLU_'; 	%MEDS: FLU1
btlLIST(67).gf3 = 'FLU_';
btlLIST(67).btl2gf3 = 1;
btlLIST(67).decimal = 3;
btlLIST(67).method = {'FLOR'};
btlLIST(67).desc = {'percent fluorescence: CTD'};

btlLIST(68).name = 'sea surface temperature ITS-90';
btlLIST(68).units = 'deg C';
btlLIST(68).type = 'terrain';
btlLIST(68).code = 'SSTP_BK';
btlLIST(68).gf3 = 'TE90';
btlLIST(68).btl2gf3 = 1;
btlLIST(68).decimal = 4;
btlLIST(68).method = {'SSTP_BK'};
btlLIST(68).desc = {'thermometer measurement'};

btlLIST(69).name = 'quality flag of sea surface temperature';
btlLIST(69).units = '(none)';
btlLIST(69).type = 'terrain';
btlLIST(69).code = 'Q_SSTP_BK';
btlLIST(69).gf3 = 'QQQQ';
btlLIST(69).btl2gf3 = 1;
btlLIST(69).decimal = 0;
btlLIST(69).method = {'Q_SSTP_BK'};
btlLIST(69).desc = {'quality flag of thermometer measurement'};

btlLIST(70).name = 'depth below sea surface';
btlLIST(70).units = '(m)';
btlLIST(70).type = 'terrain';
btlLIST(70).code = 'DEPH';
btlLIST(70).gf3 = 'DEPH';
btlLIST(70).btl2gf3 = 1;
btlLIST(70).decimal = 1;
btlLIST(70).method = {'DEPH'};
btlLIST(70).desc = {'nominal or exact water sample depth'};

btlLIST(71).name = 'bottle sample salinity';
btlLIST(71).units = 'g/kg';
btlLIST(71).type = 'labo';
btlLIST(71).code = 'SSAL_';
btlLIST(71).gf3 = 'SSAL';
btlLIST(71).btl2gf3 = 1;
btlLIST(71).decimal = 2;
btlLIST(71).method = {'SSAL_BS';'SSAL_XX'};
btlLIST(71).desc = {'salinometer'...
                    'salinity measurement, method unknown'};

btlLIST(72).name = 'quality flag of bottle sample salinity';
btlLIST(72).units = '(none)';
btlLIST(72).type = 'labo';
btlLIST(72).code = 'Q_SSAL';
btlLIST(72).gf3 = 'QQQQ';
btlLIST(72).btl2gf3 = 1;
btlLIST(72).decimal = 0;
btlLIST(72).method = {'Q_SSAL'};
btlLIST(72).desc = {'quality flag of bottle sample salinity'};

btlLIST(73).name = 'bottle sample primary production, hourly rate';
btlLIST(73).units = 'mgC/m**3/h';
btlLIST(73).type = 'labo';
btlLIST(73).code = 'PPR_';
btlLIST(73).gf3 = 'PPR_';
btlLIST(73).btl2gf3 = 1;
btlLIST(73).decimal = 2;
btlLIST(73).method = {'PPR_01';'PPR_02';'PPR_03'};
btlLIST(73).desc = {'primary production: method described in Therriault & Levasseur 1985, Naturaliste can 112'...
                    'primary production: Strickland & Parsons (1968), simulated in situ incubations'...
                    'primary production: Strickland & Parsons (1968), in situ incubations'};

btlLIST(74).name = 'bottle sample alkalinity';
btlLIST(74).units = 'mmol/m**3';
btlLIST(74).type = 'labo';
btlLIST(74).code = 'ALKY_';
btlLIST(74).gf3 = 'ALKY';
btlLIST(74).btl2gf3 = 1;
btlLIST(74).decimal = 0;
btlLIST(74).method = {'ALKY_01'};
btlLIST(74).desc = {'alkalinity: determination of carbonate, bicarbonate, and free carbon dioxide from pH and alkalinity measures (Strickland and Parsons 1972)'};

btlLIST(75).name = 'bottle sample adenosine triphosphate';
btlLIST(75).units = 'mg/m**3';
btlLIST(75).type = 'labo';
btlLIST(75).code = 'ATP_';
btlLIST(75).gf3 = 'ATP_';
btlLIST(75).btl2gf3 = 1;
btlLIST(75).decimal = 5;
btlLIST(75).method = {'ATP_01'};
btlLIST(75).desc = {'determination of adenosine triphosphate (ATP) (Strickland and Parsons 1972)'};

btlLIST(76).name = 'CTD fluorescence of CDOM';
btlLIST(76).units = 'mg/m**3';
btlLIST(76).type = 'CTD';
btlLIST(76).code = 'CDOM'; 
btlLIST(76).gf3 = 'CDOM';
btlLIST(76).btl2gf3 = 1;
btlLIST(76).decimal = 3;
btlLIST(76).method = {'CDOM'};
btlLIST(76).desc = {'fluorescence of coloured dissolved organic matter: CTD'};

btlLIST(77).name = 'water temperature';
btlLIST(77).units = 'deg C';
btlLIST(77).type = 'terrain';
btlLIST(77).code = 'TEMP_';
btlLIST(77).gf3 = 'TEMP';
btlLIST(77).btl2gf3 = 1;
btlLIST(77).decimal = 4;
btlLIST(77).method = {'TEMP_XX'};
btlLIST(77).desc = {'temperature measurement, unknown method'};

btlLIST(78).name = 'quality flag of water temperature';
btlLIST(78).units = '(none)';
btlLIST(78).type = 'terrain';
btlLIST(78).code = 'Q_TEMP';
btlLIST(78).gf3 = 'QQQQ';
btlLIST(78).btl2gf3 = 1;
btlLIST(78).decimal = 0;
btlLIST(78).method = {'Q_TEMP'};
btlLIST(78).desc = {'quality flag water temperature'};

btlLIST(79).name = 'bottle sample pH';
btlLIST(79).units = 'NBS scale';
btlLIST(79).type = 'labo';
btlLIST(79).code = 'pH_';
btlLIST(79).gf3 = 'PHPH';
btlLIST(79).btl2gf3 = 1;
btlLIST(79).decimal = 4;
btlLIST(79).method = {'pH_01';'pH_02';'pH_XX'};
btlLIST(79).desc = {'pH: mesuré au laboratoire,converti au pH in situ(Strickland&Parsons 1972)(NBS scale)';...
                    'pH: mesuré au laboratoire(Aminot&Chaussepied 1983)/converti au pH in situ(Lewis&Wallace 1998)(NBS scale)';...
                    'pH: unknown method'};

btlLIST(80).name = 'quality flag of bottle sample pH';
btlLIST(80).units = '(none)';
btlLIST(80).type = 'labo';
btlLIST(80).code = 'Q_pH';
btlLIST(80).gf3 = 'QQQQ';
btlLIST(80).btl2gf3 = 1;
btlLIST(80).decimal = 0;
btlLIST(80).method = {'Q_pH'};
btlLIST(80).desc = {'quality flag water pH'};

btlLIST(81).name = 'bottle sample carbonate alkalinity';
btlLIST(81).units = 'mmol/m**3';
btlLIST(81).type = 'labo';
btlLIST(81).code = 'CALK_';
btlLIST(81).gf3 = 'CALK';
btlLIST(81).btl2gf3 = 1;
btlLIST(81).decimal = 0;
btlLIST(81).method = {'CALK_01'};
btlLIST(81).desc = {'alkalinity: determination of carbonate, bicarbonate, and free carbon dioxide from pH and alkalinity measures (Strickland&Parsons 1972)'};

btlLIST(82).name = 'lab temperature for pH calculation';
btlLIST(82).units = 'deg C';
btlLIST(82).type = 'labo';
btlLIST(82).code = 'LABT_';
btlLIST(82).gf3 = 'LABT';
btlLIST(82).btl2gf3 = 1;
btlLIST(82).decimal = 4;
btlLIST(82).method = {'LABT_01'};
btlLIST(82).desc = {'lab temperature for calculation of pH'};

btlLIST(83).name = 'CTD pH';
btlLIST(83).units = 'NBS scale';
btlLIST(83).type = 'CTD';
btlLIST(83).code = 'PHPH';
btlLIST(83).gf3 = 'PHPH';
btlLIST(83).btl2gf3 = 1;
btlLIST(83).decimal = 3;
btlLIST(83).method = {'PHPH'};
btlLIST(83).desc = {'pH: CTD/NBS scale'};

btlLIST(84).name = 'CTD pH';
btlLIST(84).units = 'Total scale';
btlLIST(84).type = 'CTD';
btlLIST(84).code = 'PHT_';
btlLIST(84).gf3 = 'PHT_';
btlLIST(84).btl2gf3 = 1;
btlLIST(84).decimal = 3;
btlLIST(84).method = {'PHT_'};
btlLIST(84).desc = {'pH: CTD/Calibrated to total scale'};

btlLIST(85).name = 'bottle sample pH, lab measurement';
btlLIST(85).units = 'NBS scale';
btlLIST(85).type = 'labo';
btlLIST(85).code = 'LBPH_';
btlLIST(85).gf3 = 'LBPH';
btlLIST(85).btl2gf3 = 1;
btlLIST(85).decimal = 4;
btlLIST(85).method = {'LBPH_01';'LBPH_02'};
btlLIST(85).desc = {'pH: mesuré au laboratoire/potentiometric determination(Strickland&Parsons 1972)/glass electrode calibrated with NBS standards, NOT sw standards';...
                    'pH: mesuré au laboratoire/potentiometric determination(Aminot&Chaussepied 1983)/glass electrode calibrated with NBS standards, NOT sw standard'};      %Method description

btlLIST(86).name = 'quality flag of bottle sample pH, lab measurement';
btlLIST(86).units = '(none)';
btlLIST(86).type = 'labo';
btlLIST(86).code = 'Q_LBPH';
btlLIST(86).gf3 = 'QQQQ';
btlLIST(86).btl2gf3 = 1;
btlLIST(86).decimal = 0;
btlLIST(86).method = {'Q_LBPH'};
btlLIST(86).desc = {'quality flag water pH, lab measurement'};

btlLIST(87).name = 'bottle sample primary production, daily rate';
btlLIST(87).units = 'mgC/m**3/d';
btlLIST(87).type = 'labo';
btlLIST(87).code = 'PPRD_';
btlLIST(87).gf3 = 'PPRD';
btlLIST(87).btl2gf3 = 1;
btlLIST(87).decimal = 2;
btlLIST(87).method = {'PPRD_01'};
btlLIST(87).desc = {'primary production: 24h simulated in situ incubations; JGOFS core measurements (JGOFS Report No. 19)'};

btlLIST(88).name = 'Lab sigma-t';
btlLIST(88).units = 'kg/m**3';
btlLIST(88).type = 'labo';
btlLIST(88).code = 'SIGT_00';
btlLIST(88).gf3 = 'SIGT';
btlLIST(88).btl2gf3 = 1;
btlLIST(88).decimal = 2;
btlLIST(88).method = {'SIGT_00'};
btlLIST(88).desc = {'sigma-t: calculated from autosal and temp data'};

btlLIST(89).name = 'quality flag of lab sigma-t';
btlLIST(89).units = '(none)';
btlLIST(89).type = 'labo';
btlLIST(89).code = 'Q_SIGT';
btlLIST(89).gf3 = 'QQQQ';
btlLIST(89).btl2gf3 = 1;
btlLIST(89).decimal = 0;
btlLIST(89).method = {'Q_SIGT'};
btlLIST(89).desc = {'quality flag sigma-t calculated from t,s'};

btlLIST(90).name = 'bottle sample pH, in situ calc';
btlLIST(90).units = 'Total scale';
btlLIST(90).type = 'labo';
btlLIST(90).code = 'pHT_';
btlLIST(90).gf3 = 'PHT_';
btlLIST(90).btl2gf3 = 1;
btlLIST(90).decimal = 4;
btlLIST(90).method = {'pHT_01';'pHT_02'};
btlLIST(90).desc = {'pH: mesuré au laboratoire/spectrophotometric determination(SOP6b in Dickson et al. 2007)/converti au pH in situ selon Lewis&Wallace 1998'...
                    'pH: mesuré au laboratoire/spectrophotometric determination(SOP6b in Dickson et al. 2007)BUT on preserved sample/converti au pH in situ selon Lewis&Wallace 1998'};

btlLIST(91).name = 'quality flag of bottle sample pH, in situ calc';
btlLIST(91).units = '(none)';
btlLIST(91).type = 'labo';
btlLIST(91).code = 'Q_pHT';
btlLIST(91).gf3 = 'QQQQ';
btlLIST(91).btl2gf3 = 1;
btlLIST(91).decimal = 0;
btlLIST(91).method = {'Q_pHT'};
btlLIST(91).desc = {'quality flag water pH, in situ calc'};
                
btlLIST(92).name = 'bottle sample pH, lab measurement'; %Variable name in btl-file
btlLIST(92).units = 'Total scale';                      %Variable units in btl-file
btlLIST(92).type = 'labo';                              %Data type
btlLIST(92).code = 'LBPHT_';                            %Variable code in btl-file (unique)
btlLIST(92).gf3 = 'LPHT';                               %Variable GF3 code
btlLIST(92).btl2gf3 = 1;                                %Conversion factor*btl=GF3 (usually 1)
btlLIST(92).decimal = 4;                                %Number of decimal places
btlLIST(92).method = {'LBPHT_01';'LBPHT_02'};           %Method number
btlLIST(92).desc = {'pH: mesuré au laboratoire/spectrophotometric determination(SOP6b in Dickson et al. 2007)';...      %Method description
                    'pH: mesuré au laboratoire/spectrophotometric determination(SOP6b in Dickson et al. 2007) BUT on preserved sample'};
                
btlLIST(93).name = 'quality flag of bottle sample pH, lab measurement';
btlLIST(93).units = '(none)';
btlLIST(93).type = 'labo';
btlLIST(93).code = 'Q_LBPHT';
btlLIST(93).gf3 = 'QQQQ';
btlLIST(93).btl2gf3 = 1;
btlLIST(93).decimal = 0;
btlLIST(93).method = {'Q_LBPHT'};
btlLIST(93).desc = {'quality flag water pH, lab measurement'};

btlLIST(94).name = 'bottle sample NOx uptake';
btlLIST(94).units = 'mmolN/m**3/h';
btlLIST(94).type = 'labo';
btlLIST(94).code = 'UNO3_';
btlLIST(94).gf3 = 'UNO3';
btlLIST(94).btl2gf3 = 1;
btlLIST(94).decimal = 4;
btlLIST(94).method = {'UNO3_01'};
btlLIST(94).desc = {'Nitrate uptake, determination of new production, Vézina 1994'};

btlLIST(95).name = 'bottle sample NH4 uptake';
btlLIST(95).units = 'mmolN/m**3/h';
btlLIST(95).type = 'labo';
btlLIST(95).code = 'UNH4_';
btlLIST(95).gf3 = 'UNH4';
btlLIST(95).btl2gf3 = 1;
btlLIST(95).decimal = 4;
btlLIST(95).method = {'UNH4_01'};
btlLIST(95).desc = {'Ammonium uptake, determination of regenerated production, Vézina 1994'};

btlLIST(96).name = 'CTD turbidity';
btlLIST(96).units = 'NTU';
btlLIST(96).type = 'CTD';
btlLIST(96).code = 'TRB_';
btlLIST(96).gf3 = 'TRB_';
btlLIST(96).btl2gf3 = 1;
btlLIST(96).decimal = 3;
btlLIST(96).method = {'TRB_01'};
btlLIST(96).desc = {'CTD turbidity'};

btlLIST(97).name = 'bottle sample alkalinity';
btlLIST(97).units = 'umol/kg**1';
btlLIST(97).type = 'labo';
btlLIST(97).code = 'ALKW_';
btlLIST(97).gf3 = 'ALKW';
% Extended GF3 list seems to (sometimes!) use "W" as the last letter in the code to
% indicate weight or water--not clear which! anyway. this code was already
% defined to mean alkalinity in umol/kg
btlLIST(97).btl2gf3 = 1;
btlLIST(97).decimal = 0;
btlLIST(97).method = {'ALKW_01'};
btlLIST(97).desc = {'alkalinity: Determination of total alkalinity in seawater using an open-cell titration (SOP 3b in Dickson et al. 2007)'};

btlLIST(98).name = 'bottle sample total inorganic carbon';
btlLIST(98).units = 'umol/kg**1';
btlLIST(98).type = 'labo';
btlLIST(98).code = 'TICW_';
btlLIST(98).gf3 = 'TICW';
btlLIST(98).btl2gf3 = 1;
btlLIST(98).decimal = 0;
btlLIST(98).method = {'TICW_01'};
btlLIST(98).desc = {'TIC: Determination of total dissolved inorganic carbon in seawater (SOP 2 in Dickson et al. 2007)'};

%Cell array of btlLIST.code (for easy strmatch search in btl2odf.m)
[key.type{1:length(btlLIST)}]=deal(btlLIST.type);
[key.code{1:length(btlLIST)}]=deal(btlLIST.code);
[key.gf3{1:length(btlLIST)}]=deal(btlLIST.gf3);
key.null_value=-99;

%Vérification des variables
for i=1:size(btlLIST,2)
    if length(btlLIST(i).method) ~= length(btlLIST(i).desc)
        error(['Le nombre de description n''est pas égal au nombre de méthodes pour la variable dont le code est ' btlLIST(i).code])
    end
end

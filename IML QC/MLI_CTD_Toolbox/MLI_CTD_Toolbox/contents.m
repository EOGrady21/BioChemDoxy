%Write text describing the m-files in this directory
%Write text describing the m-files in this directory (continued)
%   
%ADDQ2ODF - Adds quality flags to ODF structure array 
%CONTROL_Q - Quality control main function 
%CREATE_STD - Creates the quality control structure 
%EAST_MASK - Land mask of eastern Canada
%FILTINDEX - Determines the window size of the median filter in order to reduce density inversion 
%GETVALUE - Gets the value of a field in the ODF structure 
%GF3DEFS - Returns parameter name, units and format for a GF3 code.
%GSL_MASK - Land mask of the Gulf of St.Lawrence
%IN_PETRIE_BOX - Finds the Petrie box number for each STD in (lat,lon)
%MEDFIL - Median filtering of STD profiles
%MEDFILT1_CL - One-dimensional median filter with modified start and end of series
%NAN2NULL - Changes all NaN data into null data in ODF structured Dataset.
%NAN_DOUBTFUL - Doubtful, erroneous and missing data in STD structure are replaced by NaN. 
%NANMAX - Maximum ignoring NaNs 
%NANMEAN - Mean ignoring NaNs 
%NANMIN - Minimum ignoring NaNs 
%NANSTD - Standard deviation ignoring NaNs 
%NULL2NAN - Substitutes NaN data for null data in ODF structured Dataset.
%PLOT_STD - Plots salinity, temperature and sigma-T profiles on the same graph (3 different x-axes). 
%PLOTSTD2JPEG - Writes STD profiles in JPEG format
%QCDEMO - Runs an example of STD QC procedure
%QCFF2TEST - Converts the QCFF overall quality flag to create a listof the tests failed
%REFRESH_Q - Refresh quality flags of related variables. 
%REMOVE_DOUBTFUL - Removes doubtful, erroneous and missing data from the STD-structure 
%REMOVE_ERRONEOUS - Removes erroneous and missing data from the STD-structure 
%REMOVE_PARAMETER - Removes a parameter from the ODF-structure
%REPLACE_ERRONEOUS - Replaces erroneous and missing data in the STD-structure. 
%SALINITY - Salinity validation with salinity bottle measurements
%SETQTO1 - Set quality flag to one in STD structure. 
%STAGE1_Q - Stage 1 of quality control tests (Location and Identification Tests)
%STAGE2_Q - Stage 2 of quality control tests (Profile Tests)
%STAGE3_Q - Stage 3 of quality control tests (Climatology Tests)
%STAGE4_Q - Stage 4 of quality control tests (Profile Consistency Tests)
%STAGE5_Q - Stage 5 of quality control tests (Visual Inspection)
%STAGE_Q_INI - Script for quality control test limits
%STD2TABLE - Convert STD structure to table 
%STD_REPORT - STD profile quality report
%STRMATCHI  Same as strmatch but ignoring case
%SW_T68 - Converts temperature from ITS-90 to IPTS-68
%THERMOMETER - Temperature validation with reversing thermometer measurements
%TS_DEEPWATER - Deep water mass temperature and salinity properties
%TS_DIAGRAM - Basic TS diagram with selected density contours.
%TS_DIAGRAM_DOT  Basic TS diagram with selected density contours
%TSDIAGRAM2JPEG - Writes a TS diagram in JPEG format
%UPDATEODF - Updates all header information stored in an ODF structured array.
%VIEW_QUALITY - Displays the quality header information of an ODF structured array.
%WRITE_IMLODF - Writes an ODF array structure to a file (MLI)

% ROSETTE
%
% Files
%   B_addQ2btl                      - ADDQ2BTL - Adds quality flags to the cell array of bottle data 
%   B_batch_01064                   - B_batch_01064
%   B_control_Q                     - Bottle quality control main function 
%   B_create_btl                    - Creates the bottle quality control structure 
%   B_nan_doubtful                  - Doubtful and erroneous data in bottle-structure are replaced by NaN. 
%   B_nan_erroneous                 - Erroneous data in bottle-structure are replaced by NaN. 
%   B_plot_BOTL_CTD                 - Plots BOTL versus CTD measurements
%   B_plot_NSP                      - Plots nitrate, nitrite, silicate and phosphate profiles 
%   B_plot_pattern                  - Plots bottle data with time and depth 
%   B_plot_profile                  - Plots bottle data with depth 
%   B_plot_replicate                - Plots bottle replicates 
%   B_plot_STD                      - B_PLOT_TSOC - Plots bottle temperature, salinity, dissolved oxygen and chlorophyll profiles on the same graph (4 different x-axes). 
%   B_plot_TSOC                     - Plots temperature, salinity, dissolved oxygen and chlorophyll profiles
%   B_qcff2test                     - Converts the QCFF overall bottle quality flag to create a list of the tests failed
%   B_read_btl_txtfile              - Transfert des données d'un fichier BTL vers un cell-array of strings
%   B_setQto1                       - Set quality flag to one in bottle-structure. 
%   B_stage1_Q                      - Stage 1 of bottle quality control tests (Location and Identification Tests)
%   B_stage2_Q                      - Stage 2 of bottle quality control tests (Profile Tests)
%   B_stage3_Q                      - Stage 3 of bottle quality control tests (Climatology Tests)
%   B_stage5_Q                      - Stage 5 of bottle quality control tests (Visual Inspection)
%   B_stage_Q_ini                   - Script for bottle quality control test limits
%   B_write_btl                     - B_write_btl - Write bottle structure to file 
%   bsr2btlscan                     - Writes a list of bottle start and end scans from BSR files
%   btl2btlscan                     - Writes a list of bottle start and end scans from ROS files
%   btl2odf                         - Converts a BTL TXT-file (BTL_(cruise_number).txt) to an ODF-structure
%   data_btl                        - Script for BTL data code
%   data_btl_new-additions          - DATA_BTL - Script for BTL data code
%   donnees_discretes_algue_toxique - Read toxic algue data files and write the BTL-file
%   labo                            - Separated labo data TXT files are put together
%   linkedzoom                      - linkedzoom: link zooming on all subplots of current figure.
%   mrk2btlscan                     - Writes a list of bottle start and end scans from MRK files
%   odf2btl                         - Writes CTD and bottle data in a TXT file (BTL_(cruise_number).txt)
%   odf2btl_o2cal                   - ODF2BTL - Writes CTD and bottle data in a TXT file (BTL_(cruise_number).txt)
%   odf2btl_orig                    - ODF2BTL - Writes CTD and bottle data in a TXT file (BTL_(cruise_number).txt)
%   odf2btl_seawifs                 - ODF2BTL - Writes CTD and bottle data in a TXT file (BTL_(cruise_number).txt)
%   Procedure_BTL_algues_toxiques   - Procédure pour données bouteilles d'algues toxiques
%   Quality_BOTL                    - Bottle Quality control procedure
%   read_bsr                        - Reads a CTD BSR-file out of Seabird bottle treatment 
%   read_btl                        - Reads a CTD BTL-file out of Seabird bottle treatment 
%   read_mrk                        - Reads a CTD MRK-file out of Seabird bottle treatment 
%   read_qat                        - Read data from a QAT-file (from BIO).
%   read_ros                        - Reads a CTD ROS-file out of Seabird bottle treatment 
%   ros2btlscan                     - Writes a list of bottle start and end scans from ROS files
%   rosette                         - ROSETTE procedure
%   select_btl                      - Automatic bottle scan range detection
%   unique_no                       - Unique sample number, filename and pressure depth
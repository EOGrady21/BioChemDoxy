function test=B_qcff2test(qcff)
%B_QCFF2TEST - Converts the QCFF overall bottle quality flag to create a list of the tests failed
%
%Syntax:  test=B_qcff2test(qcff)
% qcff is the general quality control flag number.
% test is a cell array that contains the names of the tests.
%  Flag added by hand(1)
%  21: Global Impossible Parameter Values (2)
%  22: Regional Impossible Parameter Values (4)
%  23: Incresssing Depth (8)
%  24: Profile Envelope (16)
%  25: Constant Profile (32)
%  26: Freezing Point (64)
%  27: Replicate Comparisons (TEMP, PSAL, DOXY, CPHL, NTRZ, NTRI, PHOS, SLCA) (128)
%  28: Bottle versus CTD Measurements (TEMP, PSAL, DOXY) (256)
%  29: Excessive Gradient or Inversion in Temperature, Salinity, Nitrate and Phosphate (512)
% 210: Surface Dissolved Oxygene Data versus Percent Saturation (1024)
% 36: Brickman Monthly Climatology (NTRA, PHOS, SLCA) (2048)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%February 2004; Last revision: 03-Feb-2004 CL

%List of tests
list={'Flag added by hand(1)';...
      'Test 2.1: Global Impossible Parameter Values (2)';...
      'Test 2.2: Regional Impossible Parameter Values (4)';...
      'Test 2.3: Incresssing Depth (8)';...
      'Test 2.4: Profile Envelope (16)';...
      'Test 2.5: Constant Profile (32)';...
      'Test 2.6: Freezing Point (64)';...
      'Test 2.7: Replicate Comparisons (128)';...
      'Test 2.8: Bottle versus CTD Measurements (TEMP, PSAL, DOXY) (256)';...
      'Test 2.9: Excessive Gradient or Inversion (TEMP, PSAL, NTRZ, PHOS) (512)';...
      'Test 2.10: Surface Dissolved Oxygene Data versus Percent Saturation (1024)';...
      'Test 3.6: Brickman Monthly Climatology (NTRA, PHOS, SLCA) (2048)'};
power=(0:length(list));

%check for max QCFF
max_qcff=sum(2.^power);

%Conversion from decimal interger to binary code
bin=fliplr(dec2bin(qcff));
disp('    ________________________________________________________________________________________')
try
   [test{1:length(find(bin=='1')),1}]=deal(list{bin=='1'});
   for i=1:size(test,1), disp(['    ' test{i}]), end
catch
   disp(['QCFF ' num2str(qcff,'%.0f') ' is not possible'])
end  
disp('    ________________________________________________________________________________________')

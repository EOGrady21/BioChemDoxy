function test=qcff2test(qcff)
%QCFF2TEST - Converts the QCFF overall quality flag to create a listof the tests failed
%
%Syntax:  test=qcff2test(qcff)
% qcff is the general quality control flag number.
% test is a cell array that contains the names of the tests.
%  Flag added by hand(1
%  20: Minimum Descent Rate (2)
%  21: Global Impossible Parameter Values (4)
%  22: Regional Impossible Parameter Values (8)
%  23: Incresssing Depth (16)
%  24: Profile Envelope (32)
%  25: Constant Profile (64)
%  26: Freezing Point (128)
%  27: Spike in temperature and salinity (one point) (256)
%  28: Top and Bottom Spike in temperature and salinity (one point) (512)
%  29: Gradient (point to point) (1024)
%  210: Density Inversion (point to point) (2048)
%  211: Spike (one point or more) (4096)
%  212: Density Inversion (overall profile) (8192)

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%September 1999; Last revision: 23-Nov-1999 CL

%List of tests
list={'Flag added by hand(1)';...
   'Test 2.0: Minimum Descent Rate (2)';...
	'Test 2.1: Global Impossible Parameter Values (4)';...
	'Test 2.2: Regional Impossible Parameter Values (8)';...
	'Test 2.3: Incresssing Depth (16)';...
	'Test 2.4: Profile Envelope (32)';...
	'Test 2.5: Constant Profile (64)';...
	'Test 2.6: Freezing Point (128)';...
	'Test 2.7: Spike in temperature and salinity (one point) (256)';...
	'Test 2.8: Top and Bottom Spike in temperature and salinity (one point) (512)';...
	'Test 2.9: Gradient (point to point) (1024)';...
	'Test 2.10: Density Inversion (point to point) (2048)';...
	'Test 2.11: Spike (one point or more) (4096)';...
	'Test 2.12: Density Inversion (overall profile) (8192)'};
power=(0:length(list));

%check for max QCFF
max_qcff=sum(2.^power);

%Conversion from decimal interger to binary code
bin=fliplr(dec2bin(qcff));
try
   [test{1:length(find(bin=='1')),1}]=deal(list{bin=='1'});
catch
   disp(['QCFF ' num2str(qcff,'%.0f') ' is not possible'])
end  
%$$$ 
%$$$ #undef __PR
%$$$ #include "VARIANT.h"

function c = sw_satN2(S,T)

% SW_SATN2   Satuaration of N2 in sea water
%=========================================================================
% sw_satN2 $Revision: 1.1 $  $Date: 1998/04/22 02:15:56 $
%          Copyright (C) CSIRO, Phil Morgan 1998.
%
% USAGE:  satN2 = sw_satN2(S,T)
%
% DESCRIPTION:
%    Solubility (satuaration) of Nitrogen (N2) in sea water
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   satN2 = solubility of N2  [ml/l] 
% 
% AUTHOR:  Phil Morgan 97-11-05  (morgan@ml.csiro.au)
%
%$$$ #include "disclaimer_in_code.inc"
%
% REFERENCES:
%    Weiss, R. F. 1970
%    "The solubility of nitrogen, oxygen and argon in water and seawater."
%    Deap-Sea Research., 1970, Vol 17, pp721-735.
%=========================================================================

% Modifications
% 99-06-25. Lindsay Pender, Fixed transpose of row vectors.

% CALLER: general purpose
% CALLEE: 

%$$$ #ifdef VARIANT_PRIVATE
%$$$ %***********************************************************
%$$$ %$Id: sw_satN2.M,v 1.1 1998/04/22 02:15:56 morgan Exp $
%$$$ %
%$$$ %$Log: sw_satN2.M,v $

%$$$ %
%$$$ %***********************************************************
%$$$ #endif

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=2
   error('sw_satN2.m: Must pass 2 parameters')
end %if

% CHECK S,T dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);

  
% CHECK THAT S & T HAVE SAME SHAPE
if (ms~=mt) | (ns~=nt)
   error('sw_satN2: S & T must have same dimensions')
end %if

%------
% BEGIN
%------

% convert T to Kelvin
T = 273.15 + T; 

% constants for Eqn (4) of Weiss 1970
a1 = -172.4965;
a2 =  248.4262;
a3 =  143.0738;
a4 =  -21.7120;
b1 =   -0.049781;
b2 =    0.025018;
b3 =   -0.0034861;

% Eqn (4) of Weiss 1970
lnC = a1 + a2.*(100./T) + a3.*log(T./100) + a4.*(T./100) + ...
      S.*( b1 + b2.*(T./100) + b3.*((T./100).^2) );

c = exp(lnC);

return

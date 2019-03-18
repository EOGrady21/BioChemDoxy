function val = getvalue(S, keyword, fsub)
%GETVALUE - Gets the value of a field in the ODF structure
%
%Syntax:  val = getvalue(S,keyword)
% - S is the ODF structure
% - keyword is any fields or subfields included in the S structure
% - keyword can be truncated as long as it is unique. If a keyword occurs
%   more than once then val takes the value of the first occurrence
%   of keyword.
% - keyword is not case sensitive.
% - fsub is a flag (0 or 1) to indicate if the subnames should be used (1) or
% not (0); default is '1'.
%
% Example:
% » val = getvalue(D,'initial_lat')
% val =
%    45.1016
% » val = getvalue(D,'DATA_type')
% val =
%    'CTD'

%Author: Caroline Lafleur, physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: lafleurc@dfo-mpo.gc.ca
%Octobre 1999; Last revision: 01-Nov-1999 CL
% 
% Updated for use at BIO by Jeff Jackson
% Last Updated: 20-APR-2011
%
% Reformatted code and adapted code to work with ODS Toolbox Version 2.
%

% Check to see if at least two input argument were supplied. If this is not
% the case, then stop execution and output an error message to the user.
if nargin < 2
  error('MATLAB:getvalue:NrInputArguments', 'Not enough input arguments were supplied. At least two are expected.');
elseif nargin == 2
	% Check to see if the input variable 'S' is a valid structure. Also check
	% to see if the variable 'keyword' is a valid string. If either of these
	% checks fails, then  output an error message to the user and exit the
	% function. Set the default value for the variable fsub since it was not
	% supplied by the user.
	if ~isstruct(S)
		error('MATLAB:getvalue:InvalidInputArgument', 'The first input variable must be a valid structure array.');
  end
	if ~ischar(keyword)
		error('MATLAB:getvalue:InvalidInputArgument', 'The second input variable must be a valid character array.');
  end
  fsub = 1;
elseif nargin == 3
	% Check to see if the input variable 'S' is a valid structure, the
	% variable 'keyword' is a valid string, and the variable fsub is a valid
	% number and also either a '1' or '0'.
	if ~isstruct(S)
		error('MATLAB:getvalue:InvalidInputArgument', 'The first input variable must be a valid structure array.');
  end
	if ~ischar(keyword)
		error('MATLAB:getvalue:InvalidInputArgument', 'The second input variable must be a valid character array.');
  end
	if ~isnumeric(fsub)
		error('MATLAB:getvalue:InvalidInputArgument', 'The third input variable must be a valid number.');
  else
    if (fsub ~= 0) && (fsub ~= 1)
  		error('MATLAB:getvalue:InvalidInputArgument', 'The third input variable must either be a "1" or a "0".');
    end
  end
% elseif nargin > 3
% 	% Check to see if too many arguments were input.  If there were then exit
% 	% the function issuing a error message to the user.
% 	error('MATLAB:getvalue:TooManyInputArguments', 'Too many input arguments were supplied. The maximum permitted is three.');
% Note that Matlab automatically handles this situation so there is no need
% to enable this code; it is there for logical completeness.
end

% Not case sensitive
keyword = lower(keyword);

if isfield(S,'header')
  S = rmfield(S,'header');
end

% Names
names = fieldnames(S);

n = length(keyword);

% Look through names
I = strncmpi(keyword, names, n);
I = find(I > 0);

% Get the data values.
if ~isempty(I)
  val = eval(['S.' names{I(1)}]);
else
  % Option to look through subnames.
  if fsub
    I = [];
    for i = 1:size(names,1)
      T = eval(['S.' names{i}]);
      if (length(T) <= 1) && isempty(I) && ~isnumeric(T)
        if ~isempty(T) && ~iscell(T)
          subnames = fieldnames(T);
          I = strncmpi(keyword, subnames, n);
          I = find(I > 0);
          if I > 0
            val = eval(['T.' subnames{I(1)}]);
          end
        end
      else
        if ~isempty(T) && isstruct(T)
          subnames = fieldnames(T);
          I = strncmpi(keyword, subnames, n);
          I = find(I > 0);
          if I > 0
            for j = 1:length(subnames)
              v = eval(['T{j}.' subnames{I(1)}]);
              if ischar(v)
                val = [val cellstr(v)]; %#ok<*AGROW>
              else
                val = [val v];
              end
            end
          end
        end
      end
    end
  end
end

% Keyword not found
if ~exist('val', 'var')
  % disp(['Keyword ' keyword  ' not found in ODF structure'])
  val = [];
end

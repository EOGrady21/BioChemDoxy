function outputcell=textcell(fname)
%TEXTCELL  Read a flat ASCII file into a cell array of strings
%
%Syntax: outputcell = textcell(fname)

%Author: Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%May 1999; Last revision: 07-May-1999

%outputcell = textread(fname,'%s','delimiter','\n','whitespace','');
fid=fopen(fname);
n = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    n = n + 1;
    output{n,1} = tline;
end
fclose(fid);

%remove blank lines at the end of file
l=size(output,1);
line=deblank(output{l});
while isempty(line)
   l=l-1;
   line=deblank(output{l});
end
outputcell=output(1:l);


function view_quality(A)
%VIEW_QUALITY - Displays the quality header information of an ODF structured array.
%
%Syntax: view_quality(A)
%  A is the ODF-structure

%Adapted from VIEW_HISTORY: ODSTools of BIO, Ocean Sciences, DFO. (Dave Kellow)
%CLafleur, December 1999

disp(['Quality_Header:']);
disp([' Quality_Date(cell):   ',char(A.Quality_Header.Quality_Date)]);
%disp([' Quality_Tests:']);
for j=(1:(length(A.Quality_Header.Quality_Tests)))
	disp([' Quality_Tests{',num2str(j),'}(Cell): ',char(A.Quality_Header.Quality_Tests{j})]);
end
for j=(1:(length(A.Quality_Header.Quality_Comments)))
	disp([' Quality_Comments{',num2str(j),'}(Cell): ',char(A.Quality_Header.Quality_Comments{j})]);
end




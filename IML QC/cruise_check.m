%test which files will run
%E Chisholm Feb 2019


%small process to check which IML format files are running properly
%during troubleshooting exercises.



filelist=dir('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/IML_QC'); % filenames actually start at position 3 of filelist(3).name to 56

A = zeros(255, 1);
for i=3:length(filelist)        %file names start at position 3
 fn=filelist(i).name; %this is a file name with the path that has to be read
 
B=B_read_btl_txtfile(fn);

c = size(B.data);

if( c(1) < 20)
    disp(fn)
    A(i) = 1;
end


end

F = {A, filelist.name};
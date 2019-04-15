%B_batch_01064
%Controle de qualit� des donn�es bouteilles de la mission IML0164

%Lire le fichier BTL_01064.txt (s�parateur ;)
%B=B_read_btl_txtfile('test_iml.txt');

% This is a batch file that would QC all data in the folder
% For now it is all 27 AZMP cruises

% pathe where the files are
%filepath='C:\Gordana\Biochem_reload\working\IML_QC';
filelist=dir('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/IML_QC'); % filenames actually start at position 3 of filelist(3).name to 56
fn='80029_IML_format.txt';
%data_btl;

for i=  3:length(filelist)        %file names start at position 3
 fn=filelist(i).name; %this is a file name with the path that has to be read
 
B=B_read_btl_txtfile(fn);

%remove last column CTD data to avoid error
%B.data = B.data(:,1:14);

%Structure du controle de qualit�
Q=B_create_btl(B,'cgdg');

%Controle de qualit�
Q=B_control_Q_GL(Q);

%Mise a jour des flags Q dans B
B=B_addQ2btl(B,Q);

%�criture du fichier QC_BTL_01064.txt
B_write_btl(B);

end

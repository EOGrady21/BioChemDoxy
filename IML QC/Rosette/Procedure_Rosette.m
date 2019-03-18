%ROSETTE - ROSETTE procedure
%---------------------------
% Comment cr�er les fichiers BTL_(cruise_number).txt
%
%-1. Se placer dans le r�pertoire ou se trouve les donn�es
%
% >> cd \..\donnees\ctd\iml0001
%
%Pr�paration des fichiers
%------------------------
% 0. Cr�er la struture de donn�es de labo � partir de plusieurs fichiers *.txt 
% Un maximum de 10 fichiers est permis pour l'instant. Cette limite pourra �tre 
% augment�e au beasoin. Les fichiers de donn�es labo doivent absoluement avoir 
% une ligne d'en-t�te qui contient des mots clefs valides du fichiers 
% BTL_(cruise_number).txt en commen�ant par 'echantillon'.
%
% >> L=labo('uniqueno','f1','f2','f3','f4',...,'f10');  -> trie par num�ro unique
% >> L=labo('filepres','f1','f2','f3','f4',...,'f10');  -> trie par fichier-pression
%
% 1. Cr�er le fichier de num�ros uniques: unique_no.txt qui contient les colonnes 
% (1.Num�ro unique, 2.nom du fichier CNV sans extension, 3.pression �chantillonn�e)
% Ce fichier peut �tre cr�er � partir des fichier QAT ou du fichier btlscan.txt avec
%
%  >> unique_no;
% Ne pas cr�er le fichier unique_no.txt s'il n'y a pas de num�ros uniques. 
%
%OPTION == 'deph' (s�lection suivant la pression nominal et les profils en descente)
%----------------------------------------------------------------------------------
% Fichiers n�cessaires: *.MRK ou *.ROS, data.mat (qui contient la descente) 
% Optionels: unique_no.txt, L
% 
% 2. Cr�er le fichier btlscan.txt avec les fichiers MRK ou ROS
%
% >> mrk2btlscan
% >> ros2btlscan
% V�rifier le fichier btlscan.txt et ajouter les bouteilles manquantes.
%
% 3. Obtenir la structure des profils en descente
%
% >> load data
%
% 4. Lancer la fonction odf2btl
%
% >> odf2btl(S,'deph',L);
% V�rifier le fichier BTL_(cruise_number).txt surtout au niveau du transfert des
% donn�es de salinit�, thermom�tre a renversement, O2 winkler, etc...
%
%
%OPTION == 'cntr' (s�lection suivant les num�ros de scan et les profils en remont�e)
%----------------------------------------------------------------------------------
% Fichiers n�cessaires: *.BSR ou *.ROS, *.cnv, *.con, cruise_cnv.m
% Optionels: unique_no.txt, L
%
% 2. Creer le fichier btlscan.txt avec les fichiers BSR ou ROS
%
% >> bsr2btlscan
% >> ros2btlscan
% V�rifier le fichier btlscan.txt et ajouter les bouteilles manquantes.
%
% 3. Obtenir la structure des profils en descente-remont�e
%
% >> S=create_odf('cnv','seabird')
% >> S=add_cruise(S,'Cruise_Number','00001') 
% pour imposer le numero de mission
%
% 4. Lancer la fonction odf2btl
%
% >> odf2btl(S,'cntr',L);
% V�rifier le fichier BTL_(cruise_number).txt surtout au niveau du transfert des
% donnees de salinit�, thermom�tre a renversement, O2 winkler, etc...
%
%
%OPTION == 'fbtl' (utilise les fichier *.BTL et les profils en descente)
%-----------------------------------------------------------------------
% Fichiers n�cessaires: data.mat (qui contient la descente), *.btl 
% Optionels: unique_no.txt, L
%
% >> cd \..\donnees\ctd\iml0001
%
% 2. Obtenir la structure des profils en descente
%
% >> load data
%
% 3. Lancer la fonction odf2btl
%
% >> odf2btl(S,'fbtl',L);
% Verifier le fichier BTL_(cruise_number).txt surtout au niveau du transfert des
% donn�es de salinit�, thermom�tre a renversement, O2 winkler, etc...
%
%!!!AVERTISSEMENTS!!!
%--------------------
% ! ODF2BTL donnera un avertissement s'il ne trouve pas de fichier *.BTL pour 
%    un fichier *.CNV lors de l'execution de l'OPTION 'fbtl'.
% ! Lancer ODF2BTL de pr�f�rence apr�s la calibration de l'O2 en descente.
% ! Ne pas utiliser l'OPTION 'cntr' avec les profils moyennes parce que le
%    num�ro de scan ne correpond plus avec la profondeur.
% 
%Pr�paration des fichiers pour l'archivage � partir du fichier BTL_xxxxx.xls
%---------------------------------------------------------------------------
%
% 1. Enregistrement de la feuille BTL_xxxxx dans le format 'txt' sous le nom 
% BTL2ODF_xxxxx.txt. Prendre soin d'enlever les colonnes vides.
%
% 2. Enregistrement la feuille readme et BTL_xxxxx dans le format 'csv' 
% comma separated value) sous le nom BTL_xxxxx.csv. SVP v�rifier que les 
% enregistrements sont bien s�par�s par des vigures. Si ce n'est pas le cas, 
% modifiez vos param�tres r�gionaux.
%
% 3. R�cup�ration des donn�es CTD de la mission
%
% >> load data
%
% 4. Transfert du fichier BTL_xxxxx.txt dans la structure odf B
% 
% >> B=btl2odf(S,'BTL2ODF_xxxxx.txt','BTL_xxxxx.xls');
%
% 5. �criture des fichiers de B
% 
% >> for i=1:size(B,2), write_imlodf(B(i)), end
%
% 6. Chargement dans le SGDO

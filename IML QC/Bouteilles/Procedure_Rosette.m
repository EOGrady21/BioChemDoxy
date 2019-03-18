%ROSETTE - ROSETTE procedure
%---------------------------
% Comment créer les fichiers BTL_(cruise_number).txt
%
%-1. Se placer dans le répertoire ou se trouve les données
%
% >> cd \..\donnees\ctd\iml0001
%
%Préparation des fichiers
%------------------------
% 0. Créer la struture de données de labo à partir de plusieurs fichiers *.txt 
% Un maximum de 10 fichiers est permis pour l'instant. Cette limite pourra être 
% augmentée au beasoin. Les fichiers de données labo doivent absoluement avoir 
% une ligne d'en-tête qui contient des mots clefs valides du fichiers 
% BTL_(cruise_number).txt en commençant par 'echantillon'.
%
% >> L=labo('uniqueno','f1','f2','f3','f4',...,'f10');  -> trie par numéro unique
% >> L=labo('filepres','f1','f2','f3','f4',...,'f10');  -> trie par fichier-pression
%
% 1. Créer le fichier de numéros uniques: unique_no.txt qui contient les colonnes 
% (1.Numéro unique, 2.nom du fichier CNV sans extension, 3.pression échantillonnée)
% Ce fichier peut être créer à partir des fichier QAT ou du fichier btlscan.txt avec
%
%  >> unique_no;
% Ne pas créer le fichier unique_no.txt s'il n'y a pas de numéros uniques. 
%
%OPTION == 'deph' (sélection suivant la pression nominal et les profils en descente)
%----------------------------------------------------------------------------------
% Fichiers nécessaires: *.MRK ou *.ROS, data.mat (qui contient la descente) 
% Optionels: unique_no.txt, L
% 
% 2. Créer le fichier btlscan.txt avec les fichiers MRK ou ROS
%
% >> mrk2btlscan
% >> ros2btlscan
% Vérifier le fichier btlscan.txt et ajouter les bouteilles manquantes.
%
% 3. Obtenir la structure des profils en descente
%
% >> load data
%
% 4. Lancer la fonction odf2btl
%
% >> odf2btl(S,'deph',L);
% Vérifier le fichier BTL_(cruise_number).txt surtout au niveau du transfert des
% données de salinité, thermomètre a renversement, O2 winkler, etc...
%
%
%OPTION == 'cntr' (sélection suivant les numéros de scan et les profils en remontée)
%----------------------------------------------------------------------------------
% Fichiers nécessaires: *.BSR ou *.ROS, *.cnv, *.con, cruise_cnv.m
% Optionels: unique_no.txt, L
%
% 2. Creer le fichier btlscan.txt avec les fichiers BSR ou ROS
%
% >> bsr2btlscan
% >> ros2btlscan
% Vérifier le fichier btlscan.txt et ajouter les bouteilles manquantes.
%
% 3. Obtenir la structure des profils en descente-remontée
%
% >> S=create_odf('cnv','seabird')
% >> S=add_cruise(S,'Cruise_Number','00001') 
% pour imposer le numero de mission
%
% 4. Lancer la fonction odf2btl
%
% >> odf2btl(S,'cntr',L);
% Vérifier le fichier BTL_(cruise_number).txt surtout au niveau du transfert des
% donnees de salinité, thermomètre a renversement, O2 winkler, etc...
%
%
%OPTION == 'fbtl' (utilise les fichier *.BTL et les profils en descente)
%-----------------------------------------------------------------------
% Fichiers nécessaires: data.mat (qui contient la descente), *.btl 
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
% données de salinité, thermomètre a renversement, O2 winkler, etc...
%
%!!!AVERTISSEMENTS!!!
%--------------------
% ! ODF2BTL donnera un avertissement s'il ne trouve pas de fichier *.BTL pour 
%    un fichier *.CNV lors de l'execution de l'OPTION 'fbtl'.
% ! Lancer ODF2BTL de préférence après la calibration de l'O2 en descente.
% ! Ne pas utiliser l'OPTION 'cntr' avec les profils moyennes parce que le
%    numéro de scan ne correpond plus avec la profondeur.
% 
%Préparation des fichiers pour l'archivage à partir du fichier BTL_xxxxx.xls
%---------------------------------------------------------------------------
%
% 1. Enregistrement de la feuille BTL_xxxxx dans le format 'txt' sous le nom 
% BTL2ODF_xxxxx.txt. Prendre soin d'enlever les colonnes vides.
%
% 2. Enregistrement la feuille readme et BTL_xxxxx dans le format 'csv' 
% comma separated value) sous le nom BTL_xxxxx.csv. SVP vérifier que les 
% enregistrements sont bien séparés par des vigures. Si ce n'est pas le cas, 
% modifiez vos paramètres régionaux.
%
% 3. Récupération des données CTD de la mission
%
% >> load data
%
% 4. Transfert du fichier BTL_xxxxx.txt dans la structure odf B
% 
% >> B=btl2odf(S,'BTL2ODF_xxxxx.txt','BTL_xxxxx.xls');
%
% 5. Écriture des fichiers de B
% 
% >> for i=1:size(B,2), write_imlodf(B(i)), end
%
% 6. Chargement dans le SGDO

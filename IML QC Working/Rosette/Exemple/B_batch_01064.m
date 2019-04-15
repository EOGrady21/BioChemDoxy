%B_batch_01064
%Controle de qualité des données bouteilles de la mission IML0164

%Lire le fichier BTL_01064.txt (séparateur ;)
%B=B_read_btl_txtfile('test_iml.txt');

filepath='

B=B_read_btl_txtfile('18HU04055_IML_format.txt');

%Structure du controle de qualité
Q=B_create_btl(B,'cgdg');

%Controle de qualité
Q=B_control_Q(Q);

%Mise a jour des flags Q dans B
B=B_addQ2btl(B,Q);

%Écriture du fichier QC_BTL_01064.txt
B_write_btl(B);

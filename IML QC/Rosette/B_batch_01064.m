%B_batch_01064
%Controle de qualit� des donn�es bouteilles de la mission IML0164

%Lire le fichier BTL_01064.txt (s�parateur ;)
B=B_read_btl_txtfile('BTL_01064.txt');

%Structure du controle de qualit�
Q=B_create_btl(B,'cgdg');

%Controle de qualit�
Q=B_control_Q(Q);

%Mise a jour des flags Q dans B
B=B_addQ2btl(B,Q);

%�criture du fichier QC_BTL_01064.txt
B_write_btl(B);

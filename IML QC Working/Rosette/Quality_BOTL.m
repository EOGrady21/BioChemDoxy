%QUALITY_BOTL - Bottle Quality control procedure
%-----------------------------------------------
% De BTL_XXXX.csv � ODF en passant par le contr�le de qualit�.
%
% 1. Effectuer le controle de qualit� de donn�es CTD
%
% 2. Effectuer la proc�dure ROSETTE pour cr�er le fichier BTL_XXXXX.txt
% (convertir le fichier .txt en .csv dans excel (delimiter ;)
%
% 3. Lire le fichier BTL_XXXXX.csv
%
% >> B=B_read_btl_txtfile('BTL_XXXXX.csv');
%
% 4. Cr�er la structure utilis�e dans le contr�le de qualit�
%
% >> Q=B_create_btl(B,'call_sign');
%
% 5. Contr�le de qualit�
% 
% >> Q=B_control_Q(Q);
%      - Le contr�le de qualit� s'effectue via la fonction B_control_Q.
%      - Cette fonction contient toutes les sous-�tapes adjacentes telles
%      que B_setQto1 (initialisation des flags de qualit�) et tous les stades
%      de contr�le tels que B_stage1_Q, B_stage2_Q, B_stage3_Q, B_stage4_Q
%      et B_stage5_Q.
%      - Le controle de qualit� cr�e le fichier QC_data_XXXXX.txt qui
%      contient les donn�es qui ont �chou� un des tests de B_stage2_Q
%
% 6. Retour � la structure B
%
% >> B=B_addQ2btl(B,Q);
%
% 7. R��criture du fichier BTL_XXXXX.txt -> QC_BTL_XXXXX.txt
%
% >> B_write_btl(B);
%      - Le fichier contient le r�sultat du controle de qualit� des donn�es bouteilles.
%
% 8. V�rifier le controle de qualit� dans un tabulateur entre autre les flags de qualit� Q=7.
%   - Toutes les donn�es probl�matiques sont regroup�es dans le fichier
%   QC_data_XXXXX.txt. Des Q=7 ont �t� ajout�s s'il faut revoir une ou un
%   ensemble de donn�es. Normalement, il ne devrait plus rester de Q=7 dans
%   le fichier BTL apres cette �tape.
%
% 9. Suivre le restant de la proc�dure ROSETTE pour obtenir les fichiers
% BOTL_*.odf a partir du fichier QC_BTL_XXXXX.txt


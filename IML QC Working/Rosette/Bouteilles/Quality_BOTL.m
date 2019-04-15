%QUALITY_BOTL - Bottle Quality control procedure
%-----------------------------------------------
% De BTL_XXXX.csv à ODF en passant par le contrôle de qualité.
%
% 1. Effectuer le controle de qualité de données CTD
%
% 2. Effectuer la procédure ROSETTE pour créer le fichier BTL_XXXXX.txt
% (convertir le fichier .txt en .csv dans excel (delimiter ;)
%
% 3. Lire le fichier BTL_XXXXX.csv
%
% >> B=B_read_btl_txtfile('BTL_XXXXX.csv');
%
% 4. Créer la structure utilisée dans le contrôle de qualité
%
% >> Q=B_create_btl(B,'call_sign');
%
% 5. Contrôle de qualité
% 
% >> Q=B_control_Q(Q);
%      - Le contrôle de qualité s'effectue via la fonction B_control_Q.
%      - Cette fonction contient toutes les sous-étapes adjacentes telles
%      que B_setQto1 (initialisation des flags de qualité) et tous les stades
%      de contrôle tels que B_stage1_Q, B_stage2_Q, B_stage3_Q, B_stage4_Q
%      et B_stage5_Q.
%      - Le controle de qualité crée le fichier QC_data_XXXXX.txt qui
%      contient les données qui ont échoué un des tests de B_stage2_Q
%
% 6. Retour à la structure B
%
% >> B=B_addQ2btl(B,Q);
%
% 7. Réécriture du fichier BTL_XXXXX.txt -> QC_BTL_XXXXX.txt
%
% >> B_write_btl(B);
%      - Le fichier contient le résultat du controle de qualité des données bouteilles.
%
% 8. Vérifier le controle de qualité dans un tabulateur entre autre les flags de qualité Q=7.
%   - Toutes les données problématiques sont regroupées dans le fichier
%   QC_data_XXXXX.txt. Des Q=7 ont été ajoutés s'il faut revoir une ou un
%   ensemble de données. Normalement, il ne devrait plus rester de Q=7 dans
%   le fichier BTL apres cette étape.
%
% 9. Suivre le restant de la procédure ROSETTE pour obtenir les fichiers
% BOTL_*.odf a partir du fichier QC_BTL_XXXXX.txt


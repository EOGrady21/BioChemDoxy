%QCdemo - Runs an example of STD QC procedure 
%
%Syntax : QCdemo
%lafleurc, 11-Feb-2008

load S
Q=create_std(S,'inconnu_10');
Q=control_Q(Q);
S=addQ2odf(S,Q);
view_quality(S(1))

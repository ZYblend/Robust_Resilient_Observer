function [z] = solver_call_unc(y,u,H,Phi)
%% Function description comments

% Yu Zheng, 2022/09/27

A_in = Phi;
 
b_in = y-H*u;
 
z = quadprog(A_in.'*A_in, -2*A_in.'*b_in);
 

 
end
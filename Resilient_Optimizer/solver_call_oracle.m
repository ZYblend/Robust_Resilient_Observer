function [z] = solver_call_oracle(y,u,H,Phi,q)
%% Function description comments

% Yu Zheng, 2022/09/27

A_in = Phi(q>=0.5,:);
 
b_in = y-H*u;
b_in = b_in(q>=0.5);

z = quadprog(A_in.'*A_in, -2*A_in.'*b_in);
 

 
end
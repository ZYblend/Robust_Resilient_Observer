function [z] = solver_call_oracle(y,Phi,q)
%% Function description comments

% Yu Zheng, 2022/09/27

% A_in = Phi(q>=0.5,:);
A_in = Phi;
%  
% b_in = y-H*u;
% b_in = b_in(q>=0.5);



z = pinv(A_in,0.01)*y;
 

 
end
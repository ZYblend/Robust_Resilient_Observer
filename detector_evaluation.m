%% Evaluate detector
% comment the following lines:
%        line 10,11 "clear all; clc;" in Run_model_WDS.m
%        line 99 "attack_percentage = 0.2;" in Run_model_WDS.m

%% collect dataset
num_dataset = 10;
Attack_percentage = linspace(0.1,0.9,num_dataset);
q = [];
q_hat = [];

for iter = 1:num_dataset
    attack_percentage = Attack_percentage(iter);
    Run_model_WDS;
    
    out = sim('WDS_evaluate_detector.slx');
    
    q = [q;out.q.Data];
    q_hat = [q_hat;out.qhat.Data];
end


%% Evlaute the performance of detector
P = sum(q==q_hat,1)/(size(q,1));
save P.mat P;


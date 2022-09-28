%% Run model for simulation (with attack detection and localization)
% Description: This file is to prepare simulation parameters 
%              In this simulation, four scenarios are compared:
% Content:
%         1. load system
%         2. parameters for sample-based moving-horizon FDIA
%         3. Parameters for MLPs and Pruning algorithm
%
% Yu Zheng, RASLab, FAMU-FSU College of Engineering, Tallahassee, 2021, Aug.
clear all
clc

% add path
currentpath = pwd;
addpath(append(currentpath,'\Attack_Generators'));
addpath(append(currentpath,'\Resilient_Optimizer'));


%% water tank system model matrices
T_sample = 0.01;

A_bar_d = readmatrix('A_bar_d.csv');
B_bar_d = readmatrix('B_bar_d.csv');
C_obsv_d = readmatrix('C_obsv_d.csv');
D_obsv_d = readmatrix('D_obsv_d.csv');


[n_states,n_int] = size(B_bar_d);
n_meas = size(C_obsv_d,1);

Cm = ones(1,n_states);
n_critical = size(Cm,1);

k0 = 42;   % lower bound of number of measurements for which the system remain full observability

%% system matrix unit testing
%controllability and observability
% disp('controllability')
% disp(rank(ctrb(A_bar_d,B_bar_d))) % fully controllable with PID controller
% disp('observability')
% disp(rank(obsv(A_bar_d,C_obsv_d))) % fully observable


%% T time horizon
T = round(2*n_states);
[H0_full,H1_full,F] = opti_params(A_bar_d,B_bar_d,C_obsv_d,T);
% H0: state-ouput linear map                      [n_meas*T-by-n_states]
% H1:  input-output linear map                     [n_meas*T-by-n_int*(T-1)]
% F: Observer input-state propagation matrix      [n_meas-by-n_int*(T-1)]


%% Observer Dynamics for attack-free case
H0_full_pinv = pinv(H0_full,0.001);
Ly = A_bar_d.'*H0_full_pinv;
Lu = F-A_bar_d.'*H0_full_pinv*H1_full;
% A_T = A_bar_d^T;

% residual
H0_full_pinv = pinv(H0_full,0.001);
H0_perp_full = eye(size(H0_full,1)) - H0_full*H0_full_pinv;


%% Gain Controller
Pc = linspace(0.1,0.2, n_states);
K = place(A_bar_d,B_bar_d,Pc);
% disp('discrete controller (A-B*K) eigenvalues: less than 1?')
% disp(eig(A_bar_d-B_bar_d*K).')


%% Simulation Initialization
% state initialization
x0          = zeros(n_states,1);
x0_hat      = zeros(n_states,1);
xd          = 5*ones(n_states,1);

yc_d = Cm*xd;

% Delay tape initialization
Q0          = ones(n_meas,T);    % initial support: all safe
Y0          = zeros(n_meas,T);
U0          = zeros(n_int,T+1);

offset = -inv(B_bar_d)*(A_bar_d-eye(n_states))*xd;

%% runing parameters
N_samples      = 800;                % The total number of samples to run
T_final        = N_samples*T_sample;  % Total time for simulation (20s)
T_start_attack = 0.1*T_final;         % start injecting attack at 10s
T_start_opt(:)    = 1.5*T*T_sample;
T_start_detect = T_start_attack+T*T_sample;

N_start_attack = T_start_attack/T_sample;
N_attack = N_samples-N_start_attack+1;

x_hat_nominal = load('x_hat_nominal.mat').x_hat_nominal;


%% attack parameters
attack_percentage = 0.2;
n_attack =  round(attack_percentage*n_meas);
max_attack = 1000; % maximum allowable attack per channel
% Bad Data Detection
BDD_thresh = 5;  % Bad data detection tolerance
[U,~,~] = svd(C_obsv_d);
U2 = U(:,n_states+1:end);

%% attack detction and Pruning
n_stds = 3;  % number of standard deviations to locate auxiliary mean

% Initial Sigmas
sigma_inv_k = 1e2*(3 + 2*rand(n_meas,1)); % surrogate inverse covariance values. Assume diagonal covariance matrix.
% sigma_inv_k = load('sigma_inv_k.mat').sigma_inv_k;
Sigma_inv_k = diag(sigma_inv_k);

sigma = (1 + 2*rand(n_meas,1));
Sigma = diag(sigma);

U_y_1 = 0;
r_tau = chi2inv(0.1,n_meas);

% Pruning
eta = 0.7;
try
    P = load('P.mat').P.';
catch
    disp("please run detector_eveluation.m first to get the historical performance of detector")
end

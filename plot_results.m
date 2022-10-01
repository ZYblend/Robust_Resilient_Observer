%% Creating visualization and plotting results for the simulation

% Yu Zheng, 2022/09/28


%% Extracting values
time_vec  = out.logsout.getElement('x').Values.Time;

% error vectors
e = out.logsout.getElement('e_no_prior').Values.Data;
e_exact   = out.logsout.getElement('e_exact_prior').Values.Data; 
e_inexact   = out.logsout.getElement('e_AADL').Values.Data; 
e_pruning   = out.logsout.getElement('e_pruning').Values.Data; 

% precision
PPV = out.logsout.getElement('PPV').Values.Data;
PPV_eta = out.logsout.getElement('PPV_eta').Values.Data;



%% Ploting/Visualization/Metric tables
e = vecnorm(e,2,2);
e_exact = vecnorm(e_exact,2,2);
e_inexact = vecnorm(e_inexact,2,2);
e_pruning = vecnorm(e_pruning,2,2);

%% plot error
figure(1) %

LW = 1.3;  % linewidth
FS = 12;   % font size

subplot(4,1,1)
plot(time_vec,e,'k.','LineWidth',LW);
ylabel('e','FontSize',FS)
title('LSE without Support Prior','FontSize',FS);

subplot(4,1,4)
plot(time_vec,e_exact,'k.','LineWidth',LW);
ylabel('e','FontSize',FS)
ylim([0 0.2])
title('LSE with Exact Support Prior','FontSize',FS);

subplot(4,1,2)
plot(time_vec,e_inexact,'k.','LineWidth',LW);
ylabel('e','FontSize',FS)
ylim([0 0.2])
title('LSE with AADL Support Prior','FontSize',FS);

subplot(4,1,3)
plot(time_vec,e_pruning,'k.','LineWidth',LW);
ylabel('e','FontSize',FS)
xlabel('time','FontSize',FS)
ylim([0 0.2])
title('LSE with Pruned Support Prior','FontSize',FS);


%% plot precision
figure(2)

subplot(2,1,1)
plot(time_vec,PPV,'k','LineWidth',LW);
ylabel('PPV','FontSize',FS)
title('Pre-pruning Precision','FontSize',FS);

subplot(2,1,2)
plot(time_vec,PPV_eta,'k','LineWidth',LW);
ylabel('PPV_{\eta}','FontSize',FS)
title('Post-pruning Precision','FontSize',FS);


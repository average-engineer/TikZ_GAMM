clearvars
clc
close all
addpath("C:\Users\ashut\Desktop\Werk\TikZ_Vortrag\illustrationScripts\matlabtikz") % add matlabtikz to matlab path
% Truth
[time,truth] = generateTruthTraj;

% IMU Updates via strapdown
drift = 0.1*time;
imu = truth + drift;

% MEKF
mekf = zeros(size(imu));
mekf(1:10) = imu(1:10);
mekf(11:20) = truth(11:20) + drift(1:10);
mekf(21:30) = truth(21:30) + drift(1:10);
mekf(end) = truth(end);

% Time-step illustrations
line1 = [-0.01:0.00005:mekf(5)];
line2 = [-0.01:0.00005:mekf(6)];
line3 = [-0.01:0.00005:mekf(1)];
line4 = [-0.01:0.00005:mekf(10)];
%% Illustration
hfig = figure;
hold on
a = plot(truth,'--','color','k',LineWidth=2,DisplayName='Truth');
b = plot(imu,'--','color','b',LineWidth=2,DisplayName='Strapdown');
c = plot(mekf,'-o','color','r',LineWidth=2,DisplayName='MEKF');
plot(5*ones(size(line1)),line1,'--','color','k')
plot(6*ones(size(line2)),line2,'--','color','k')
plot(1*ones(size(line3)),line3,'--','color','k')
plot(10*ones(size(line4)),line4,'--','color','k')
grid on
ylabel('$\phi$ [rad]')
xlabel('Time [s]')
legend([a,b,c])
formatFig(hfig);
matlab2tikz('figurehandle',hfig,'strict',true,'strictFontSize',true,'width','0.5\textwidth','filename','mekf.tikz')
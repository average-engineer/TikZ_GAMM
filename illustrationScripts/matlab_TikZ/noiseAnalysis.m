%% Settings
clc
close all
clearvars
addpath("C:\Users\ashut\Desktop\Werk\TikZ_GAMM\illustrationScripts\matlabtikz");
%% Loading sensor data
% file = 'cubeOrange_IMU_100Hz.mat';
file = 'adis16467.mat';
Fs = 100; % 100 Hz sampling rate
t0 = 1/Fs;
data = load(file);

xAcc = data.xAccel;
numSamples = length(xAcc);
yAcc = data.yAccel;
zAcc = data.zAccel;
xGyr = data.xGyro;
yGyr = data.yGyro;
zGyr = data.zGyro;

%% Allan Variance Analysis using allan()
% x.freq = xGyr;
% x.rate = Fs;
% 
% ad = allan(x);

%% Validation 
% Alternate method described in https://de.mathworks.com/help/nav/ug/inertial-sensor-noise-analysis-using-allan-variance.html
maxNumM = 100;
maxM = 2.^floor(log2(numSamples/2));
m = logspace(log10(1), log10(maxM), maxNumM).';
m = ceil(m); % m must be an integer.
m = unique(m); % Remove duplicates.

tau = m*t0;

data = xGyr;

[avar, tauFromFunc] = allanvar(data, m, Fs);
adev = sqrt(avar);

disp(append('Constant Offset Bias = ',num2str(mean(data))));

%% Angle/Velocity Random Walk [Gyr and Acc] OR White-Noise PSD [Mag]
% Find the index where the slope of the log-scaled Allan deviation is equal
% to the slope specified.
slope = -0.5;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the angle random walk coefficient from the line.
logN = slope*log(1) + b;
N = 10^logN
tauN = 1;
lineN = N./ sqrt(tau);
%% Bias Instability
% Find the index where the slope of the log-scaled Allan deviation is equal
% to the slope specified.
slope = 0;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the bias instability coefficient from the line.
scfB = sqrt(2*log(2)/pi);
logB = b - log10(scfB);
B = 10^logB
tauB = tau(i);
lineB = B * scfB * ones(size(tau));
%% Rate/Velocity Random Walk
% Find the index where the slope of the log-scaled Allan deviation is equal
% to the slope specified.
slope = 0.5;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the rate random walk coefficient from the line.
logK = slope*log10(3) + b;
K = 10^logK
tauK = 3;
lineK = K .* sqrt(tau/3);

%% Plot the results
figure
colArr = ["k","r","b","g","r","b","g"];
loglog(tau,adev,tau,lineN,'--',tau,lineB,'--',tau,lineK,'--',tauN,N,'*',tauB,scfB*B,'*',tauK,K,'*','MarkerSize',10,'LineWidth',2)
colororder(colArr)
xlabel('\tau')
ylabel('\sigma(\tau)')
legend('Allan Deviation', 'Angle Random Walk Line','Bias Instability Line','Rate Random Walk Line')
grid on
matlab2tikz()
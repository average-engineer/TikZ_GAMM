
function [time,truth] = generateTruthTraj()
%system parameters
%mass    
m = 750;
%spring stiffness
k = 50000;
%damping
c = 1000;
%time span
time_span = [0:0.01:5];
%displacement initial conditions
x_0 = 0.01;
%velocity initial conditions
xdot_0 = 0;
%initial conditions vector
w0 = [x_0;xdot_0];

%numerical solution using ode45
%results give the state space variables (displacement and velocity) for each second of the simulation time 
[time,results] = ode45(@(time,w)state_space_fun(time,w,m,k,c),time_span,w0);

%the displacment values
truth = results(50:80,1);
time = time(50:80) - time(50);
end

%% State-space function
function [dwdt] = state_space_fun(t,w,mass,spring_stiffness,damping_coeff)
w1 = w(1);%x 
w2 = w(2);%xdot
dw1dt = w2;%xdot = xdot
dw2dt = -(damping_coeff/mass)*w2 - (spring_stiffness/mass)*w1;%x2dot = -(c/m)*xdot - (k/m)*x
dwdt = [dw1dt;dw2dt];
end
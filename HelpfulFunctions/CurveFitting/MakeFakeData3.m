function data = MakeFakeData3
% js 04072015
% use a von Mises (wrapped gaussian) to generate a fake data set 
% note: run this as a standalone script and it will save the fake data 
% in the 'data.mat' file that you can then load and fit in the 'class_xxxx.m' function

close all;
clear all;

% set up a variable that determines how much noise there is...
n = .3;

% set up some parameters that govern the shape of the data
a = 2; % amp
b = 1; % baseline
k = 3; % bandwidth 
u = pi/2; % mean of function
% generate an x-axis over which to eval the function
xsteps = 60; 
xstepSize = pi/xsteps;
x = linspace(0, pi-xstepSize, xsteps);

% note that max resp will be (a+b)
vm = a*exp(k*(cos(u-x)-1))+b;
plot(x, vm, 'b', 'LineWidth', 2), hold on

% then lets add some noise and replot just so you can see what the data
% generating function looks like and also what the actual 'data' look like
% that were gererated based on this function + noise (note: remember that
% noise is a generic term to mean "variance that we don't understand" - could
% be machine noise in our measurement device, biophysical noise, etc
data = vm+randn(size(vm))*n;
plot(x, data, 'k')

legend({'Ideal data', 'Fake data (with IID noise)'})
save data 

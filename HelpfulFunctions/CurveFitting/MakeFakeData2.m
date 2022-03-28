function data = MakeFakeData2
%make a data set that is a mixture of two VM funcs

close all;
clear all;

% set up a variable that determines how much noise there is...
n = .2;

% set up some parameters that govern the shape of the data
a = 1; % amp
b = .1; % baseline
k = 3; % bandwidth 
u = pi; % mean of function

% generate another function to add to the first
% make it small so that it will just be a 'local minima'
a2 = 2; % amp
b2 = 1; % baseline
k2 = 7; % bandwidth (bigger == narrower)
u2 = 2*pi; % mean of function

% generate an x-axis over which to eval the function
xsteps = 60; 
xstepSize = (2*pi)/xsteps;
x = linspace(0, 2*pi-xstepSize, xsteps);

% note that max resp will be (a+b)
vm = a*exp(k*(cos(u-x)-1))+b;
vm2 = a2*exp(k2*(cos(u2-x)-1))+b2;
vm = vm + vm2;

plot(x, vm), hold on


data = vm+randn(size(vm))*n;
plot(x, data, 'k')

save data2 

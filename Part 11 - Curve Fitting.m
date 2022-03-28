%==========================================================================
% MATLAB Mini-Course Part 11: Curve Fitting
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022
% uses software developed by geoff boynton (UWash) and john serences (UCSD)

% for this exercise we'll need a bunch of custom functions stored in
% Helpful Functions\CurveFitting, so add that to the MATLAB path.
addpath([pwd,'\HelpfulFunctions\CurveFitting\']);

%% Overview

% Getting started: set up some parameters to generate a function we'll be 
% fitting to the simulated data - in this case, the function that we're 
% fitting will take the same basic form (a circular normal distribution) as
% the function that we used to generarate the data (although in practice, 
% you will *almost never know the exact function* that generates your 
% observed data... in fact, that is the whole point of this excersise, i.e.
% to figure out what generating function best accounts for your observed
% set of data!

% so to start off with here we're just going to look at our observed data
% and then take some guesses about the parameters that we think will
% generate a good match to this observed data. Then we'll see how well our
% prediction is, we'll iteravely adjust it until the fit is as good as we 
% can get it to be, and then we'll record the parameters of the function 
% that produces the best match to the real data and we'll be able to 
% quantitatively describe our real observed data in terms of an explicit 
% generating function.

% NEXT we can ask: we've got a function that describes our data pretty well
% , but is it the BEST function that we can choose? Does another function 
% better account for our observed data???? And if so, then how much more 
% complex is it than our starting function? Given that we give up 
% explanatory power as model complexity increases, we want to develop 
% methods for formally evaluating the tradeoff between goodness of fit and 
% model complexity to arrive at the most parsimonious model that still does
% a good job of explaining our data. 

% Make up some fake data:
clear; close all;

% set up a variable that determines how much noise there is...
n = .3;

% set up some parameters that govern the shape of the data
a = 2; % amp
b = 1; % baseline
k = 8; % bandwidth 
u = 0; % mean of function

% generate an x-axis over which to eval the function
xsteps = 60; 
xstepSize = (2*pi)/xsteps;
x = linspace(-pi, pi-xstepSize, xsteps);

% note that max resp will be (a+b)
vm = a*exp(k*(cos(u-x)-1))+b;                                               % formula for a von Mises (circular gaussian) distribution
plot(x, vm, 'b', 'LineWidth', 2), hold on

% then lets add some noise and replot just so you can see what the data
% generating function looks like and also what the actual 'data' look like
% that were gererated based on this function + noise (note: remember that
% noise is a generic term to mean "variance that we don't understand" - could
% be machine noise in our measurement device, biophysical noise, etc
data = vm+randn(size(vm))*n;
plot(x, data, 'k')
legend({'Ideal data', 'Fake data (with IID noise)'})

% Now set up params for a function that we're going to use to generate
% predictions and to tweak in order to best match our predictions to the
% real data. In this case, we're using a circular Gaussian or a von Mises
% function. Note the use of the 'structure' data type (the p.XX notation).
% We'll see the utility of this in a minute - its very handy and a good
% coding habit to use in many situations. 

p.a = 1;    %amplitude/ height
p.b = .1;   %baseline (y-axis offset
p.k = 6;    %bandwidth (concentration)
p.u = 0;    %central tendency

xsteps = size(data,2);
xstepSize = (2*pi)/xsteps;

p.x = linspace(-pi, pi-xstepSize, xsteps); 
p.plot = 1;

% take our input seed parameters (our best intial guesses) and generate a 
% predicted function to compare to the observed data. The 'model' function 
% is one that i wrote that will take the 'p' structure as input and then 
% compute a von Mises (in this case) and return the 'pred' function based 
% on the specified input parameters. Go ahead and use the 'step in' button 
% in the toolbar to see what's inside 'model', or just open model and 
% insert a breakpoint in it to stop execution within the function so that 
% you can figure out what's going on.

pred = model(p);

% plot our prediction and the actual data that we're fitting - notice that our
% initial guess based on the seed values above produce a function that is
% sort of similar to the 'real' data that we observed, but not that close.
% This means that we'll have to fine-tune our predictions until we get the
% best possible match between our prediction and the real data. 
close all;
plot(pred, 'b', 'LineWidth', 2), hold on
plot(data, 'k', 'LineWidth', 2)
legend({'Initial Guess (prediction)', 'Real observed data'})
set(gca, 'FontSize', 20)
xlabel('Data feature')
ylabel('Data amplitude')

% calculate the error between pred and actual data. In this case, our error
% function is the sum of squared differences between our prediction and the
% real data. The goal of model fitting, in this case at least, is to
% minimize this error term because when we've found its minimum value, then
% we've maximized the goodness of fit between our prediction and the real
% data. So we want err == 0 in the limit. What is it now? should be pretty
% high because, as you can see, our predicted function doesn't match the
% real data very closely. 

err = errFunction(p,data)

% find best-fitting parameters using fminsearch where matlab will
% systematically explore parameter space (the value of each parameter) to
% find the set of values that minimizes the 'err' term that we defined above
% as the sum of squared differences between prediction and real data. So
% basically, this 'fit' function will minimize the output of the function
% that is called first: 'errFunction')

% first define free parameter list:
freeList = {'a','b','k','u'};                                              % four free parameters that define the VM function above

% now fit!
bestP = fit('errFunction',p,freeList,data);

% get new predicted values based on the best fitting  - note that the error
% has been GREATLY reduced after fitting and optimizing the paraeters of our
% fitting function. Its now much lower (depending on the exact random
% noise in your data set - which will vary from person to person), whereas
% our initial guess resulted in an err of around 70 or so. 

bestErr = errFunction(bestP,data)

% generating restarts to ensure the best fit and to see if you can avoid
% getting stuck in local minima

data = MakeFakeData2;           % make some more fake data - this time with a combo of two VM funcs
nIters = 15;
freeList = {'a','b','k','u'};   % four free parameters that define the VM function above
tmpP = []; pred=[];
p.plot = 0;
for i=1:nIters
    p.a = (max(data)-min(data))+rand-.5;
    p.b = min(data)+rand-.5;
    p.u = unidrnd(180)*(pi/180); 
    p.k = max(1, 3 + (rand-.5)*8);

    tmpP(i).p = fit('errFunction',p,freeList,data);
    pred(i,:) = model(tmpP(i).p);
    bestErr(i) = errFunction(tmpP(i).p,data);    
end

% plot the bestErr (or the error function from each iteration - what do you
% notice???
close all
plot(bestErr, 'LineWidth', 3)
set(gca, 'FontSize', 20)
xlabel('Fitting iteration')
ylabel('Fit Error')

% find the params that yeilded the lowest sse and use that
[~, ind] = min(bestErr);
bestB = tmpP(ind);
bestPred = pred(ind,:);

close all;
plot(p.x,data,'k'), hold on
plot(p.x,pred')
plot(p.x,bestPred,'LineWidth',4)
set(gca,'FontSize',20)
xlabel('Data feature')
ylabel('Data amplitude')

% multiple conditions...fit one with all free params, then select the
% simplest model with the fewest free parameters allowed to vary freely in
% order to account for the differences between the conditions. This kind of
% situation happens very frequently. For example, suppose you're recording
% from mouse visual cortex and trying to identify receptive fields. You
% find an orientation tuned cell, you map out the RF, and then you have the
% mouse run on a track ball (like the Cris Niell studies). You want to know
% what changes between the two experiemental conditions: is it just the
% gain of the TF, or the gain and the bandwidth? or the baseline offset?
% What is the simplest possible model that can explain the observed change
% with the fewest free parameters?  

% IMPORTANT: before we do this, recall that the more free parameters you 
% have, the better fit you'll get - this is just a fact of fitting. 
% However, if you go to an extreme and you have just as many free 
% parameters as you have data points, for example, then you'll be able to 
% fit your data perfectly, and you can explain 100% of the variance. But 
% unfortunately you learn nothing by doing this because you just recreated 
% your data! 

% So, there is an inherent tradeoff between model fit and model complexity 
% (i.e. the number of free params) and you want a model that does a good 
% job of explaining the variance and that has the fewest free params so 
% that its easy to interpret and conveys the most important features of the
% data. 

% make some cleaner data to illustrate
clear all;
close all;

p.a = 1;
p.b = .1;
p.k = 2;
p.u = 0;
xsteps = 360;
xstepSize = (2*pi)/xsteps;
p.x = linspace(-pi, pi-xstepSize, xsteps);
p.plot = 0;

% generate the data
data = model(p);

% then lets make a second experimental condition, and assume that in this
% condition, the data are scaled by a gain factor (i.e. a change in gain,
% characterized by a change in the 'amplitude' parameter, or p.a). Note
% that none of the other factors change, so {b, u, k} should stay the same
% across both models, and that is what we should recover after fitting both
% lines
p2 = p;
p2.a = 3;   % only change amp 
data2 = model(p2);

% plot data and data2 (and notice that only the ampltiude has changed...)
figure(1), clf, hold on
plot(p.x, data)
plot(p.x, data2, 'k')
legend({'condition 1', 'condition 2'})
set(gca, 'FontSize', 24)
xlabel('Data feature')
ylabel('Data amplitude')

% now add some IID noise to both responses, just for fun
data = data + randn(size(data))*.1;
data2 = data2 + randn(size(data2))*.1;

% replot
figure(1), clf, hold on
plot(p.x, data)
plot(p.x, data2, 'k')
legend({'condition 1', 'condition 2'})
set(gca, 'FontSize', 24)
xlabel('Data feature')
ylabel('Data amplitude')

% now lets fit condition 1, and then ask, "what is the simplest model that
% we can adopt to account for data2 based on the best fitting parameters
% for data?" In other words, what is the minimum number of variables we can
% allow to vary freely between the two conditions in order to fit both
% lines?

% first fit data set 1 and allow all 3 variables to vary freely
freeList = {'a','b','k'};                                                   % lets just use 3 params for simplicity (we'll fix u here)
bestP = fit('errFunction',p,freeList,data);

% now, we can consider all possible models that relate data and data2.
% 1) only the amp could vary (which we know is the correct model because 
%    that is how we set it up)
% 2) only the baseline (b) could vary
% 3) only k varies
% 4) a and b vary
% 5) a and k vary
% 6) b and k vary
% 7) a, b, and k vary (most complex)

% through these 7 alternative models using a cell array. fl is freelist
fl{1} = {'a'};
fl{2} = {'b'};
fl{3} = {'k'};
fl{4} = {'a','b'};
fl{5} = {'a','k'};
fl{6} = {'b','k'};
fl{7} = {'a','b','k'};

% loop over models and fit each one, storing the estimated params and the
% error of each model
for i=1:numel(fl)
    display(fl{i})
    freeList = fl{i};                                                       % lets just use params for simplicity (we'll fix u here)
    bestP2{i} = fit('errFunction',bestP,freeList,data2);                    % initialize this with bestP (i.e. estimates from 'data')!!!
    [err(i), bic(i)] = errFunction2(bestP2{i},fl{i},data2);                 % now compute and store error for this model 
end

% NOTE: the "bic" in the above loop is short for "bayesian information
% criterion". It's a measure grounded in bayesian statistics that weights
% how well a model explains a set of data according to how many free
% parameters it has. The more free parameters a model has, the more it is
% penalized by the BIC. In essence, this is just a mathematically
% principled way of evaluating how well a model describes a data set while
% aiming for parsimony.

% The calculation of the BIC is beyond the scope of this tutorial, but you
% can find out more by checking out "errFunction2" and wikipedia..

% note a few things...bestP2 compared to bestP - only the free param(s)
% should be different in each model
bestP2{1} % so for the first model, everything the same except amp (which happens to be the true generating model)
bestP

figure(1), clf, hold on
plot(err)
plot(bic)
set(gca, 'FontSize', 20)
legend({'error', 'BIC'})
xlabel('Model number')
ylabel('Magnitude')

% notice that error will be lowest with the most free parameters...why?
[m,i] = min(err)

% however, BIC will be lowest for the 'best' model (the most parsimonious,
% or the simplest model that best accounts for the data)...and that is
% (almost always) model 1!
[m,i] = min(bic)

% what happens if we vary other parameters like a and b? how does this hold
% up against noise?

% if you wanted to use nested f-tests to see if a more complex model is
% significantly better than a more simple model:
% F(df14, df2) = ((R2_full_model-R2_reduced_model)/df1)/ ((1-R2_full_model)/df2)
% df1 == #params in the full model - # params in reduced model
% df2 == #observations - number of the free params - 1
% where R2 = (1 - (RSS/TSS)), where TSS is the sum(pred-mean(data).^2)

%==========================================================================
% Grid Search
%==========================================================================

% another way to fit data, and one that is sometimes neccessary is to use 
% something called a grid search. So instead of letting matlab find the 
% best fitting fucntion by moving around in a high dimensional space until 
% the fit is optimized, you exhaustively (more or less) explore the full 
% parameter space to find the best fitting function. This will not always 
% work well, depending on how complex your function is, but in many cases 
% its both fast and very robust (more robust than fminsearch).

% The basic idea is to loop over a bunch of values of all free params to
% see which set of them produces the best fit. Below we'll do this with
% some fake data generated with a VM function, and i'll show a few ways to
% speed things up by using a hueristic to find 'u' and a GLM to estimate
% the amplitude and the baseline of the functions. The following example is
% what you might use if you were fitting an orientation or direction
% selective neural tuning function...

clear all
close all

% make some data (can play with this to see how robust this method is to
% changes in params
d = MakeFakeData3;

numDataPnts = numel(d);
k = (.1:.01:30);             % pick a set of concentration (bandwidth) params for the VM functions that we're going to fit.
sse = zeros(numel(k), 1);
baseLine = zeros(numel(k), 1);
amps = zeros(numel(k), 1);

% in this case, we can speed things by using a hueristic to find 'u', or
% the center of the VM distribution - in this case just look within +-10%
% of the center of the function on the assumption that we've lined
% everything up so that the center orientation of our TF is in the middle
% of the data
[~, mind] = max(d(round(numDataPnts/2)-round(numDataPnts*.1):round(numDataPnts/2)+round(numDataPnts*.1)));

% then generate our x-axis
x = linspace(0, pi-pi/numDataPnts, numDataPnts);      

% then find our u param (or center point)
u = x(mind+round(numDataPnts/2)-round(numDataPnts*.1)-1);     

for ii=1:length(k)        
    a = 1;
    b = 0;
    pred = a*exp(k(ii)*(cos(u-x)-1)) + b;  % a Von Mises function to use for fitting
    pred = scaleData(pred, 0, 1);
    X = zeros(numDataPnts,2);
    X(:,1) = pred';
    X(:,2) = ones(size(X,1),1);
    betas = X\d';           % GLM! y = beta * X + e
    amps(ii) = betas(1);    % amplitude    
    baseLine(ii) = betas(2);% intercept
    est = pred*betas(1) + betas(2); % estimate of data given current concentration param
    sse(ii) = sum((est - d).^2);    % sum of squared error
end

% plot the error function! cool!!!
plot(sse)                               % non-monotonic...

% then find the best params
[~, mind] = min(sse);
b = baseLine(mind);
a = amps(mind); 
bwdth = k(mind);

% generate your prediction based on the best params
pred = a*exp(bwdth*(cos(u-x)-1)) + b;

close all
plot(d, 'k', 'LineWidth', 2), hold on
plot(pred, 'b', 'LineWidth', 2)
set(gca, 'FontSize', 20)
xlabel('Data feature')
ylabel('Data amplitude')

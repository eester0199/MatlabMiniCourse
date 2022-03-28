%==========================================================================
% Intro 2 MATLAB Part 8: Correlation & Covariance
%==========================================================================
% eester@unr.edu, Spring 2022. Borrows some examples from Cohen's "MATLAB
% for Brain & Cognitive Sciences" book and unpublished tutorials by john
% serences (jserences@ucsd.edu)

%==========================================================================
% To start, here's a handy method for generating an (artifical) correlation
% between two variables:
%==========================================================================

r = -0.7;                % magnitude of the correlation you want to generate
n = 100;                 % # of data points you want to simulate
x = randn(n,1);          % generate a 100 x 2 matrix of numbers sampled from a standard normal distribution (mean = 0, sd = 1)
y = randn(n,1);

% induce a correlation between x and y by changing the values in y:
y = x*r+y*sqrt(1-r^2);

% let's take a look at the correlation using MATLAB's "scatter" function:
figure(1),clf
scatter(x,y);

% you can calculate the correlation coefficient between two variables (in
% this case, the different columns of the data matrix x) using the
% "corrcoef" function:
rx = corrcoef(x,y);

% title the plot we just made:
tmpr = rx(1,2); figure(1); title('Correlation = ',num2str(tmpr));

% notice that the estimated correlation coefficient isn't exactly the same
% as the magnitude of the correlation we tried to create. this is because
% correlation is defined using a (theoretically) infinite number of data
% points. However, it should be close. As an example let's try re-running
% the above code but sampling 10,000 data points instead of 100:

r = -0.7;                                       % magnitude of the correlation you want to generate
n = 10000;                                      % # of data points you want to simulate
x = randn(n,2);                                 % generate a 100 x 2 matrix of numbers sampled from a standard normal distribution (mean = 0, sd = 1)
x(:,2) = x(:,1)*r + x(:,2)*sqrt(1-r^2);         % using different columns of x instead of two different vectors x and y

figure(2),clf
scatter(x(:,1),x(:,2));
rx = corrcoef(x(:,1),x(:,2));
tmpr = rx(1,2); figure(1); title('Correlation = ',num2str(tmpr));

% now we're much closer to our expected correlation coefficient of r = 0.7
% (or whatever you might've changed r to be above). 

%==========================================================================
% COVARIANCE
%==========================================================================

% covariance is a measure of joint variablity between two (or more)
% measures. 

% generally speaking, if smaller values of one variable occur with smaller
% values of another variable, and if bigger values of one variable occur
% with bigger values of another variable, then covariance is positive. 

% alternately, if smaller values of one variable occur with bigger
% values of another variable, and if bigger values of one variable occur
% with smaller values of another variable, then covariance is negative. 

% Intuition: covariance provides a correlation coefficient with it's sign:
% if the covariance between two variables is positive then the correlation
% coefficient between those variables will be positive. If the covariance
% between two variables is negative then ditto for the correlation.

% This may sound simple, but covariance is a *huge* component of many
% advanced statistical techniques (e.g., PCA, model fitting) that it's
% important to take a moment to understand the fundamentals!

%--------------------------------------------------------------------------
% ok, with that out of the way let's go back to our example using
% correlated data and compute the covariance
%--------------------------------------------------------------------------

r = -0.7;                % magnitude of the correlation you want to generate
n = 10000;               % # of data points you want to simulate
x = randn(n,2);         % generate a 100 x 2 matrix of numbers sampled from a standard normal distribution (mean = 0, sd = 1)
x(:,2) = x(:,1)*r + x(:,2)*sqrt(1-r^2);

% use the MATLAB function "cov" to compute the covariance between the
% columns of x and y:
covx2 = cov(x(:,1),x(:,2));

% notice that the estimated covariances is (almost) the same as the
% correlation between the two variables. There's a specific reason for
% this, and it has to do with the fact that when generating the correlation
% between the two columns of x we sampled from a standard normal
% distribution with a mean of 0 and a standard deviation of 1. 

% in other words, the covariance was computed using **normalized** data
% with 0 mean and unit standard deviation. in this special instance, the
% correlation coefficient between two variables == the covariance between
% the two variables. 

% to illustrate, let's take the two columns of x and add 100 to each value.
% This won't change the variance in each column, but it will change the
% mean (from 0 to 100):
x = x*100; 

% adding 100 to each value is a linear operation, so it shouldn't change
% the correlation coefficient:
xc = corrcoef(x);               % compare with rx above

% but, check out what happens to the covariance:
xcov = cov(x(:,1),x(:,2));

% the covariance is way bigger than it was before! (in fact, scaled by a 
% factor of 100) this is because the magnitude of the covariance depends on
% the scale(s) of the variables being compared (correlation does not). 
% Generally speaking, covariance is only interpretable when:

% (a) two variables have been standardized to have zero mean and unit
% variance (e.g., via a z-transform)

% (b) the (raw) covariance is normalized by the variances of the individual
% variables, i.e., a correlation coefficient. 

%==========================================================================
% super important! most of the time you'll compute covariance using
% matlab's "cov" function, which zero-centers (i.e., removes the mean from)
% your input data. however, if you find yourself computing covariance by
% hand, you MUST SUBTRACT OUT THE MEAN OF EACH VARIABLE BEFORE COMPUTING 
% COVARIANCE. To illustrate:

r = -0.7;                % magnitude of the correlation you want to generate
n = 10000;               % # of data points you want to simulate
x = randn(n,2)+100;      % generate a 100 x 2 matrix of numbers sampled from a standard normal distribution, then add 100 so that (mean = 100, sd = 1)
x(:,2) = x(:,1)*r + x(:,2)*sqrt(1-r^2);

% compute covariance using the dot product (you'll learn more about the dot
% product later)
covx1 = x(:,1)'*x(:,2)/(size(x,1)-1);      

% and using the cov function:
covx2 = cov(x(:,1),x(:,2));

% you should get two different answers. this is because the "cov" function
% automatically subtracts out the mean of each variable being compared
% while the dot product solution doesn't. to fix this:

x = bsxfun(@minus,x,mean(x));               % subtract out the mean of each variable
covx3 = x(:,1)'*x(:,2)/(size(x,1)-1);       % recompute covariance

% covx2 and covx3 should be nearly identical to one another (within <
% 1/1000th digit)

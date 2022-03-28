%==========================================================================
% Intro 2 MATLAB Part 9 - GLM and Multiple Regression
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022; borrows heavily from
% unpublished tutorials by John Serences @ UCSD 

%% Overview:

% Model fitting is an essential component of data analysis in the social
% and physical sciences. For the purposes of this class (and the next,
% where we'll talk about non-linear approaches to model fitting) you can
% think of a model as a mathematical description of some latent
% (unobserved) process that could produce or explain an empirically
% observed data set. 

% Model fitting has several uses. On the one hand, it can be a convenient
% way of summarizing a large or complicated data set using just a handful
% of parameters. Calculating the mean of a data set can be thought of as a
% model fitting process: the goal is to get from a large number of
% observations to a single parameter (the average) that tells us something
% about the data as a whole. (We'll see an example of this in a bit). More
% complicated examples of model-fitting-as-summary include things like the
% Fourier Transform (e.g., where the goal is to represent a time varying 
% signal using a set of complex sinusoids) and structural equation modeling
% (where the goal is to identify relationships between several interacting
% variables. 

% On the other hand, model fitting can also be used as a hypothesis testing
% technique. Suppose we want to know whether there's a positive linear
% relationship between two variables. We could run a regression analysis,
% which would tell us the slope (and intercept) of the best-fitting line
% through the data. If there's indeed a positive relationship between the
% two variables then we should get a positive slope estimate; if there
% isn't we should get a 0 or negative slope estimate. You can also develop 
% models that are predicated on specific theories or hypotheses about the
% nature of some phenomenon, then fit those models to the same data set and
% see which one performs better. We'll see specific examples of this over
% the next few classes, and also learn about different ways to determine
% whether one model is "better" than another. 

%==========================================================================
% Linear (least-squares) model fitting
%==========================================================================

% The simplest and most common method for modeling is called least-squares
% estimation. It's the basis for correlation, regression, ANOVA, and a host
% of other things you learned about in your undergraduate stats class. 

% The general idea of least-squares estimation is to find the model 
% parameters that minimize the sum of the squared distances between a set 
% of empirical observations (our data) and a set of predicted observations 
% (the output of the model). 

% Here is the magic formula:

% Y = (X'*X)\X'*b

% that's the matrix implementation of a "general linear model", where Y is
% a matrix (or vector) of weights that minimize the sum of squared
% differences between the observed data b and predicted data X. 

% Let's take an even simpler example. Calculating the mean of a data set 
% can be though of as a model fitting problem. In this scenario, our model 
% would predict that all observations in a data set have the same value 
% (the mean), and any deviations from this value are due to random noise 
% (error). At the implementation level, our model contains a vector of 
% ones, and the parameter we estimate (the mean) is a constant that
% scales all the elements in that vector. We seek the value of that
% constant that minimizes the sum of squared errors between our model and
% the observed data. Let's try it:

n = 100;                             % # of observations to simulate
b = linspace(1,10,n)+randn(1,n);     % 100 linearly spaced numbers between 1-10, each corrupted by a little IID noise. 
X = ones(n,1);                       % our model, which says that all items in b are identical.
y = (X'*X)\X'*b';                    % GLM solution. 

% Here, "y" is a scalar that minmizes the sum of squared differences
% between our model prediction (X) and the observed data (b). This is
% identical to calculating the mean of b:
estMeans = [y,mean(b)]

% ok, now let's try something a little more complicated. Suppose instead of
% calculating a mean we want to fit a line to our data, like in a 
% regression. To do that, we'll need to estimate two parameters: an 
% intercept and a slope. Thus our model (X) must also contain two 
% parameters:

X = [ones(n,1),(1:n)'];

% here, the first column of X is the same vector of ones we generated
% above. The second column is the set of numbers 1:n and simulates the
% linear increase we expect to observe in our data (i.e., as x increases, 
% y should also increase). Using the same approach described above:
y = (X'*X)\X'*b';

% the variable y should now contain two values - the first is the
% estimate of the y-intercept for the data, and the second is the slope of
% the line. As a sanity, check, plot the data and see whether you think
% these model parameters are accurate given how the data look.
figure(1),clf
plot(b);

%==========================================================================
% This actually segues nicely into the next topic - model evaluation
%==========================================================================

% You now know how to fit a (basic) model to a data set using least-squares
% estimation. But how do you know if the model is a good fit? By "good
% fit", I mean "does the model actually do a good job of describing the
% observed data?"

% There are two broad ways of answering this question. Both involve using
% your fitted model to generate some predicted data and evaluating how
% these predictions match up with your observed data. 

% Using the same example from before, we can generate predicted data from
% our model parameters y and our model predictions X:
yh = y(1)*X(:,1)+y(2)*X(:,2);
yh = sum(bsxfun(@times,X,y'),2);

% those two lines of code should produce identical output; "yh" is
% shorthand for y-hat, which is the typical mathematical way of
% representing predicted data. (For example, if the output of our model was
% stored in a variable "A", then we'd call the predicted values "A-hat"). 

% Let's plot the original data b, and overlay the model preditions in yh.
% If the model does a good job of fitting the observed data, then the two
% plots should overlap to a large extent.
figure,clf
plot(b,'k','LineWidth',2),hold on
plot(yh,'r','LineWidth',2)
legend('Original Data','Predicted Data')

% Not too shabby! This is what i'll refer to as the "qualitative" method of
% evaluating model fits: plot the original data, then overlay the model
% predictions. If the model does a good job of describing the data, then
% the real and synthetic data should line up nicely. 

% Qualitative assessments of model fit can (and should) be supplemented
% with quantitative estimates of fit. There are several different ways of
% quantitatively evaluating model fit, but the most common is to compute
% the proportion of variance in the raw data (b) that's explained by the
% model (X), that is, R^2 (r-squared).

% If the model perfectly accounts for the data (which never happens in
% reality; if it does than odds are something went wonky in your analysis!)
% then r-squared is equal to 1. If the model is terrible at describing your
% data, then r-squared shuold be near 0. It's also possible to get negative
% r-squared values; to understand why check out how r-squared is
% calculated:

rsq = 1-(sse/sst);

% where sse is shorthand for "sum of squared errors" and is computed as:

sse = sum((yh-b').^2);

% sst is shorthand for "total sum of squared errors" and is computed as:

sst = sum((b-mean(b)).^2);

% sst tells you the total amount of variablity in your data set, while sse
% tells you how much variability your model can't account for. The latter
% is based on squaring and summing the differences between the model
% predictions and the actual data. If these differences are small, then sse
% will be small and (sse/sst) will be close to 0. If these differences are
% large, then sse will be large and sse/sst will be close to 1. sse/sst can
% also be greater than 1 if the model is so terrible that it's predictions
% were worse than assuming that each observation is equal to the mean of
% all observations, in which case you get a negative r-squared value. 

% those details aside, let's compute rsq for our model. Run the two
% snippets of code above to get sse and sst, then re-compute r-squared
% using the formula above. I got an r-squared value of around 0.82 (yours
% will vary 'cause the data are randomly generated). That means that the
% model accounted for 82% of the total variance in the raw data - pretty
% good!

% one quick aside: there's no set definition of what constitutes a "good
% model". for example, if you're a social psychologist trying to model the
% effects of personality on risk taking behaviors then a good model might
% account for 20-30% of the variance. If you're a physiologist trying to
% model the spiking output of a neuron from fluctuations in extracellular
% current, then you might expect an r-squared value as high as 0.95. In
% most scenarios you'll want to consult the published literature to get a
% sense of what kinds of r-squared value constitute a "good fit" for the
% phenomenon you're studying. 

%==========================================================================
% Another example
%==========================================================================

% Let's do the same line-fitting exercise, but on a data set with much more
% noise:

n = 100;                             % # of observations to simulate
b = linspace(1,10,n)+10*randn(1,n);  % 100 linearly spaced numbers between 1-10, each corrupted by a little IID noise. 
X = [ones(n,1),(1:n)'];
y = (X'*X)\X'*b';

figure,clf
plot(b,['k','o']),hold on;
yh = sum(bsxfun(@times,X,y'),2);
plot(yh,'r','LineWidth',2)
legend('Original Data','Predicted Data')

sse = sum((yh-b').^2);                  % sum of squared errors
sst = sum((b-mean(b)).^2);              % total sum of squares

rsq = 1-(sse/sst);

%==========================================================================
% polynomial fitting using polyfit
%==========================================================================

% polynomial models are a class of models where the design matrix is a
% series of coefficients of the same term with increasing powers like x^0,
% x^1, x^2, x^3, etc. Remember when we used model fitting to calculate the
% mean of a data set? That's identical to fitting a zero-order polynomial.
% The example where we fit a line to a data set? Same thing as fitting a
% first-order polynomial. Higher order polynomials test for more
% complicated data patterns (quadratic, cubic, etc.). to illustrate, let's
% start by reproducting the mean and slope/intercept estimates we
% calculated earlier using MATLAB's "polyfit" fucntion:

iv = 1:n;                   % base vector of possible values
c = polyfit(iv,b,0)
c = polyfit(iv,b,1)

% the output of the first call to polyfit should be identical to the mean
% of b, while the output of the 2nd call should be identical to the slope
% and intercept parameters we calculated above (albeit in reverse order - 
% polyfit returns coefficients in decending order, while the design matrix 
% we wrote above was organized in ascending order). 

% Let's try another example with a more complex signal. Suppose we have a
% slow time-varying signal (e.g., an eeg waveform) that's corrupted by lots
% of high frequency noise:

sr = 1000;              % sampling rate of signal
time = 0:1/sr:6;        % total sample length
F = griddedInterpolant(0:6,100*rand(7,1),'spline');     % create a 6th order polynomial
data = F(time)+10*randn(size(time));
figure,clf
plot(data),hold on

% it's clear that there's some kind of nth order polynomial present in the
% data, but being swallowed by a bunch of noise. However, we can use
% polyfit to estimate the parameters of the polynomial, then pass these
% parameters to a sister function called polyval to isolate the signal of
% interest:
c = polyfit(time,data,7);
pred = polyval(c,time);
plot(pred,'r','LineWidth',3)
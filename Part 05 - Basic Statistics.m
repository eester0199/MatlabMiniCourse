%==========================================================================
% Intro 2 MATLAB Part 5: Descriptive/Inferential Statistics (NHST)
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

%--------------------------------------------------------------------------
% descriptive statistics:
%--------------------------------------------------------------------------

x = randi(100,1,100);                   % 100 random integers between 1 and 100;

% basic descriptive statistics:
a = mean(x);                            % average
a = median(x);                          % median
a = mode(x);                            % mode 
a = min(x);                             % minimum value
a = max(x);                             % maximum value
a = std(x);                             % standard deviation
a = var(x);                             % variance

% other useful functions:
a = range(x);                           % range of values, i.e., max-min
a = prctile(x,95);                      % 95th percentile of x (you can change 95 to any number between 0.001 and 0.999)
a = zscore(x);                          % convert the data in x to standard measurements with mean 0 and sd 1

%--------------------------------------------------------------------------
% a little more advanced:
%--------------------------------------------------------------------------

x = randi(100,100,100);                 % 100 x 100 matrix of integers between 1 and 100

% take the mean and standard deviation across the first dimension (rows) of x:
m = mean(x,1); 
s = std(x,1);

% take the mean and standard deviation across the second dimension (columns) of x:
m = mean(x,2);
s = std(x,2);

% find the maximum of a vector, then find *where* in the vector the maximum
% is:
x = [1:9,12,7:-1:1];
[a,b] = max(x);
sprintf("The maximum value of x is %s, and this value is located in the %sth position of the vector",num2str(a),num2str(b))

% note conversion of the numeric varables a and b to string variables using
% the function "num2str". 

% find the maximum of a vector, then find *where* in the vector the maximum
% is:
x = [1:9,12,7:-1:1];
[a,b] = min(x);
sprintf("The minimum value of x is %s, and this value is located in the %sth position of the vector",num2str(a),num2str(b))

% careful! note that in the previous example there are two instances of the
% number 1 in the vector x, one in the 1st position and another in the 17th
% position. In this case, the min function will ONLY return the index of
% the first instance of the minimum (i.e., position 1)

%--------------------------------------------------------------------------
% inferential statistics
%--------------------------------------------------------------------------

% fake data:
x = randn(1,250);                       % 250 normally distributed random numbers

% one-sample t-test
[h,p,ci,stats] = ttest(x);              % test whether the mean of x is ~= 0
[h,p,ci,stats] = ttest(x,-3);           % test whether the mean of x is ~= -3

% in the above examples, the output variable h is a binarized outcome,
% returning 1 if the test is significant (at p < 0.05) and 0 otherwise. p
% is the p-value associated with the test, ci is the 95% confidence
% interval of the mean of x, and "stats" is a structure with three fields: 
% tstat - value of the test statistic
% df - degrees of freedom for the test
% sd = estimated population standard deviation
stats.tstat
stats.df
stats.sd

% change the alpha level of a t-test (default is 0.05):
[h,p,ci,stats] = ttest(x,-3,'alpha',.01);

% repeated-measures t-test 
y = randn(1,250);
[h,p,ci,stats] = ttest(x,y);

% between-subjects t-test
[h,p,s,c] = ttest2(x,y);

% change the directionality of a t-test (i.e., one-tailed vs. two-tailed)
[h,p,s,c]=ttest2(x,y,'tail','both');                    % x~=y
[h,p,s,c]=ttest2(x,y,'tail','right');                   % x>y
[h,p,s,c]=ttest2(x,y,'tail','left');                    % x<y

%==========================================================================
% Try it!
%==========================================================================

% One of the cardinal sins in statistics (at least Null-hypothesis 
% significance testing) is to keep collecting data until p < 0.05. To see 
% why, do the following:

% a) initialize two vectors containing numbers from normal distributions
% with equal means and standard deviations. Run a paired-samples t-test to
% determine whether the mean of one variable is greater than the other
% variable.

% b) repeat step a) but embed your code inside of a while loop that
% terminates when the result of your t-test is p < 0.05. Implement a
% variable that counts the number of iterations the loop completes before
% terminating. 
 
% c) Embed the while loop you created in b) that counts from 1 to 1000.
% During each pass, count the number of permutations it takes for the while
% loop to terminate and plot a histogram of the results. (10 bins is fine)

% d) Now create a second for loop that increments from 10 to 1000.
% Implement the instructions from a) inside the loop, but increase the # of
% "subjects" by 1 during every iteration of the loop and compute a p-value
% for each test you run. Then plot the p-values you obtain over
% permutations in a new figure window. 

% Based on what you've learned from a)-d), what have you learned about why
% sampling new participants until obtaining a significant result is a bad 
% idea?

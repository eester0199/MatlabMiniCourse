%==========================================================================
% Intro 2 MATLAB Part 7: Creating Custom Functions
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

%% Overview

% MATLAB comes with many built-in functions; you've seen several of them
% used for statistical analyses (mean, median, ttest) and plotting (plot,
% hist, imagesc). Additional functions can also be found in proprietary
% (i.e., MATLAB-produced) and open-source toolboxes like EEGLAB,
% Psychtoolbox, etc. 

% You can also write your own custom functions that can be called from
% MATLAB. This is especially handy when you're implementing a complicated
% analysis with many lines of code and you don't want to clutter up your
% primary analysis script that contians subject numbers, path definitions,
% etc. 

% There are a couple of different ways of writing custom functions; one
% method involves embedding your function at the bottom of a script,
% another involves creating a new m-file and calling it from a second
% "primary" script. We'll discuss these in turn:

%==========================================================================
% Custom Function Syntax
%==========================================================================

% Every MATLAB function has one or more inputs (e.g., data) and returns one
% or more outputs (e.g., an average or the maximum value of a vector).
% Check out the help documentation for the MATLAB function "mean" by typing
% 'help mean' at the command line (omit the quotes). You should see
% something like this:

% "S = mean(X) is the mean value of the elements in X if X is a vector. For 
% matrices, S is a row vector containing the mean value of each column." 

% This help file tells you the syntax for calling the function mean, i.e.,
% what inputs and outputs you need to supply. Here, the input is a vector
% of numbers X, and the output is an average S. Note that you don't have to
% use the letters/variable names X and S. For example, the three lines of
% code below return the same values of 50.5. All we're doing is changing
% the names of the input and output variables. 

    X = 1:100;
    S = mean(X);    
    mean_data = mean(X);
    md = mean(1:100);

% More complex functions allow multiple inputs and outputs. Let's take the
% MATLAB function "max" as an example. The help documentation for this
% function states:

%     M = max(X) is the largest element in the vector X. If X is a matrix, M 
%     is a row vector containing the maximum element from each column. For 
%     N-D arrays, max(X) operates along the first non-singleton dimension.
%  
%     When X is complex, the maximum is computed using the magnitude
%     max(ABS(X)). In the case of equal magnitude elements the phase angle 
%     max(ANGLE(X)) is used.
%  
%     [M,I] = max(X) also returns the indices corresponding to the maximum
%     values. The values in I index into the dimension of X that is being
%     operated on. If X contains more than one element with the maximum
%     value, then the index of the first one is returned.
%  
%     C = max(X,Y) returns an array with the largest elements taken from X or 
%     Y. X and Y must have compatible sizes. In the simplest cases, they can 
%     be the same size or one can be a scalar. Two inputs have compatible 
%     sizes if, for every dimension, the dimension sizes of the inputs are 
%     either the same or one of them is 1.

% This function has been constructed with some built-in flexibility that
% allows you to do different things. The basic syntax is M = max(X), where
% X is a vector of numbers and M is the maximum value in that vector. But,
% calling [M,I] = max(X) returns two values: the maximum value of the
% vector X, and the index (i.e., ordinal position) of that maximum value in
% the vector X. The third example C = max(X,Y) takes two inputs X and Y
% that can be scalars, vectors, or matrices, and returns the value of the
% largest number among the two inputs. 

% More advanced MATLAB functions can take multiple (5 or more) inputs and
% return as many outputs. When creating custom functions, there are no
% rules on the number of inputs and outputs you can have. BUT, the basic
% structure will always be: [output] = function_name(input);

%==========================================================================
% Writing and calling a custom function in a standalone m-file.
%==========================================================================

% In Part 8 of this tutorial (statistics) you learned about something
% called the false-discovery-rate correction procedure, and saw how it was
% implemented using a custom m-file called "fdr_bh.m" (included in the
% "Helpful Functions" folder that accompanies this tutorial). Calling the
% help file for this function gives you the syntax you'll need to run it,
% i.e.:

% Usage:
% [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvals,q,method,report);
%
% Required Input:
%   pvals - A vector or matrix (two dimensions or more) containing the
%           p-value of each individual test in a family of tests.
%
% Optional Inputs:
%   q       - The desired false discovery rate. {default: 0.05}
%   method  - ['pdep' or 'dep'] If 'pdep,' the original Bejnamini & Hochberg
%             FDR procedure is used, which is guaranteed to be accurate if
%             the individual tests are independent or positively dependent
%             (e.g., Gaussian variables that are positively correlated or
%             independent).  If 'dep,' the FDR procedure
%             described in Benjamini & Yekutieli (2001) that is guaranteed
%             to be accurate for any test dependency structure (e.g.,
%             Gaussian variables with any covariance matrix) is used. 'dep'
%             is always appropriate to use but is less powerful than 'pdep.'
%             {default: 'pdep'}
%   report  - ['yes' or 'no'] If 'yes', a brief summary of FDR results are
%             output to the MATLAB command line {default: 'no'}
%
%
% Outputs:
%   h       - A binary vector or matrix of the same size as the input "pvals."
%             If the ith element of h is 1, then the test that produced the 
%             ith p-value in pvals is significant (i.e., the null hypothesis
%             of the test is rejected).
%   crit_p  - All uncorrected p-values less than or equal to crit_p are 
%             significant (i.e., their null hypotheses are rejected).  If 
%             no p-values are significant, crit_p=0.
%   adj_ci_cvrg - The FCR-adjusted BH- or BY-selected 
%             confidence interval coverage. For any p-values that 
%             are significant after FDR adjustment, this gives you the
%             proportion of coverage (e.g., 0.99) you should use when generating
%             confidence intervals for those parameters. In other words,
%             this allows you to correct your confidence intervals for
%             multiple comparisons. You can NOT obtain confidence intervals 
%             for non-significant p-values. The adjusted confidence intervals
%             guarantee that the expected FCR is less than or equal to q
%             if using the appropriate FDR control algorithm for the  
%             dependency structure of your data (Benjamini & Yekutieli, 2005).
%             FCR (i.e., false coverage-statement rate) is the proportion 
%             of confidence intervals you construct
%             that miss the true value of the parameter. adj_ci=NaN if no
%             p-values are significant after adjustment.
%   adj_p   - All adjusted p-values less than or equal to q are significant
%             (i.e., their null hypotheses are rejected). Note, adjusted 
%             p-values can be greater than 1.

% From this, you know that the function takes one required input (and/or 3
% additional optional inputs) and returns 4 outputs. All of the math
% required to compute the FDR-correction is taken care of by this function;
% you just need to feed it some p-values:

    addpath('HelpfulFunctions');                          
    fake_pvals = unifrnd(.0001,.2,[1,5]);                    % 5 uniformly sampled p-values on the interval [0.0001 - 0.20]
    [a,b,c,d] = fdr_bh(fake_pvals);

% One last note: when creating a custom MATLAB function in a standalone
% m-file you MUST follow a certain syntax. This is shown in the first
% uncommented line of the fdr_bh function:

% function [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvals,q,method,report)

% here, the command "function" tells MATLAB that you're writing a
% standalone function to perform some computation. Everything inside the
% brackets before the left hand of the =fdr_bh call are the outputs;
% everything in parentheses to the right of =fdr_bh are the inputs. If you
% fail to supply the optional inputs p, method, and report, these are set
% for you by fdr_bh (check out the guts of the function to see how this
% works). 

% There are some exceptions to this general structure but ~95% of the
% custom functions you'll see in our lab follow it. 

%==========================================================================
% Embedding custom functions in a live script
%==========================================================================

% If you have a custom function designed to do something simple (e.g.,
% generate some descriptive statistics given some input data) you don't
% have to write it out in a separate m-file. Instead, you can embed a
% function at the bottom of your primary analysis script, like this:

a = randi(10,1,1000);                                     % randi returns a randomly chosen interval on the interval 1:n, where n is the first input of the function. 
[vmean,vmed,vmod,vmax,vmin] = descriptiveStats(a);

% functions can have as many inputs and outputs as you want. here's an example function that'll compute some descriptive statistics:
function [vmean,vmed,vmod,vmax,vmin] = descriptiveStats(x)                   % mean, med, mod, max, min correspond to the average, median, max, mode, max and min of a vector
    vmean = mean(x);
    vmed = median(x);
    vmod = mode(x);
    vmin = min(x);
    vmax = max(x);
end

% Two things about the embedded function approach:
% 1. The embedded function MUST BE at the bottom of your analysis script.
% No other MATLAB code below it (though you can embed multiple custom
% functions at the end of your script). 
% 2. Embedded functions only work when you execute an entire script. For
% example, if you highlight and try to run lines 177-187 by themselves
% you'll get an "unrecognized function or variable" error. But, if you
% click the "run" icon at the top of the editor panel, it should work
% (note: you'll probably have to change the name of this script to
% something MATLAB can interpret, or cut/paste lines 177-187 into a
% different m-file and save it with a legal file name). 
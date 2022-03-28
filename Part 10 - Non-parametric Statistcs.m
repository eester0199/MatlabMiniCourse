%==========================================================================
% MATLAB Mini-Course Part 10: Non-parametric statistics
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022. Uses several unpublished 
% examples developed by john serences (jserences@ucsd.edu)

%--------------------------------------------------------------------------
% Overview
%--------------------------------------------------------------------------

% Our lab typically uses non-parametric statistics (e.g., bootstrap,
% jackknife, and randomization tests) rather than traditional inferential
% statistics you probably learned about in your stats courses (e.g.,
% t-tests, ANOVA)

% Recall that many "classic" inferential statistics like t-tests rely on
% various assumptions like normality (i.e., your data are normally or at
% least approximately normally distributed) and equality of variance across
% conditions. 

% These assumptions are difficult if not impossible to verify in many data
% sets, and the same assumptions are flat-out wrong when dealing with many
% types of neural data (or second-order measurements like inter-trial phase
% clustering). Non-parametric statistics are equivalent ways of evaluating 
% statistical significance that dispatch with many of the assumptions 
% required by inferential statistics. 

% This is easiest to explain with some examples, so let's try one:

% Suppose we've got an experiment where we measure EEG responses evoked
% by a salient stimulus when it's attended (condition #1) vs. unattended
% (condition #2). We want to know whether attending to the stimulus is
% associated with significantly larger brain responses. 

% First let's simulate some data. Suppose we're measuring the amplitude of
% an EEG response (in microvolts) that's uniformly distributed at the
% population level. Further, suppose that there is a real effect of
% attention on this EEG response such that it's modestly larger during the
% attended vs. unattended condition. 

    % generate some summary statistics
    m1 = 7.1;               % mean response in attended condition (in microvolts, though units are unimportant for this demo)
    m2 = 5.8;               % mean response in unattended condition
    noise = 2;              % magnitude of IID noise (independent & identically distributed noise)
    n = 40;                 % number of subjects.
    
    % using the summary statistics, synthesize some data:
    c1 = m1+randn(n,1)*noise;           % synthesize n subjects to have a mean of m1 with variablity = noise.
    c2 = m2+randn(n,1)*noise;           % do the same for the unattended condition. 
    
    % compute the difference between the two conditions:
    realDiff = c1-c2;
    
    % t-test to see whether "realDiff" is greater than 0. Note that this test
    % depends on an assumption of normality. 
    [~,p,~,stat] = ttest(realDiff,0);               % t-test against 0. see help ttest
    
    % Using a t-test here is OK 'cause I sampled data from a normal
    % distribution. But what if I used a different distribution for one
    % condition?
    
    c1 = m1+randn(n,1)*noise;                       % normal distribution
    c2 = m1+exprnd(1,n,1)*noise;                    % exponential distribution
    
    % let's plot the distribution of data across conditions:
    figure(1),clf
    subplot(1,2,1)
    hist(c1);
    subplot(1,2,2)
    hist(c2);

    % Here, c2 is created by sampling from an exponential distribution. 
    % We could compare c1 and c2 with a t-test, but doing so would violate
    % the assumption of normality and return a biased test statistic. How
    % big or bad of a bias? Since we know "ground truth" (i.e., the
    % functions that were used to generate these data) we could figure this
    % out if we wanted. But in practice you almost *never* know what
    % function(s) generated your observed data, so any attempt to estimate
    % or correct for this bias are bankrupt. 

    % Not good! What can we do?

%==========================================================================
% Non-parametric tests & The Central Limit Theorem
%==========================================================================

% Non-parametric tests come in many flavors, but they all rely on the
% central limit theorem. Recall from your stats classes that the central
% limit theorem says (in part) that if we draw repeated subsamples from a
% sample of data, compute an average for each sample, and then plot the
% distribution of samples the result will be normally distributed (no
% matter what the distribution of the original data looks like. 

% Here: I'll prove it to you!

    y = exprnd(10,[1,1000]);                        % 1000 plucks from an exponential distribution with mean 10
    
    % plot a histogram of the values in y.
    figure(2),clf
    subplot(2,1,1)
    hist(y);

    % start grabbing samples of 100 values from the exponential distribution.
    % compute the mean for each sample, and save the output for plotting:

    nIter = 1000;                                   % # of permutations you want to run
    for ii = 1:nIter
        rndInd = randi(length(y),1,length(y));      % grab 100 values from y, with replacement
        my(ii) = mean(y(rndInd));
    end
    
    % plot the distribution of my
    subplot(2,1,2)
    hist(my);

    % Pretty cool, huh? Note that this trick works for data that's distributed
    % in any format - uniform, exponential, logarithmic, poisson, etc.

    % Using the central limit theorem, we can compute p-values for significance
    % using the statistics of the data we've already collected. 

%==========================================================================
% Randomization Tests
%==========================================================================

% In a randomization test, we simulate a distribution of empirical
% differences we might reasoably expect if there's no difference between
% the two experimental conditions, i.e., the null hypothesis. 

% To do this, we'll break dependencies between the data values we recorded
% and the conditions they came from:

    % copying this from above:
    m1 = 7.1;               % mean response in attended condition (in microvolts, though units are unimportant for this demo)
    m2 = 5.8;               % mean response in unattended condition
    noise = 2;              % magnitude of IID noise (independent & identically distributed noise)
    n = 40;                 % number of subjects.
    
    % using the summary statistics, synthesize some data:
    c1 = m1+randn(n,1)*noise;              % synthesize n subjects to have a mean of m1 with variablity = noise.
    c2 = m2+exprnd(1,n,1)*noise;           % do the same for the unattended condition. 
    
    % calculate the difference between the two condition means:
    realDiff = mean(c1-c2);
    
    % regular t-test (biased!)
    [~,p,~,stat] = ttest(c1,c2);
    
    % Randomization test:
    
    nIter = 1000;                                          % # of shuffles you want to run. Should be at least 1000. 
    nullDiff = nan(1,nIter);
    for ii = 1:nIter                                       % loop over permutations
        rndInd = sign(rand(n,1)-.5);                       % cheap way of making a vector of -1 and 1; akin to flipping a coin 
        nullDiff(ii) = mean((c1-c2).*rndInd);              % multiply each pair of observations by the vector we just created.    
    end
    
    % Question: What should the mean of the "nullDiff" variable be
    % (approximately)? Why?
    
    % check out the distribution of null differences:
    figure(3),clf
    hist(nullDiff,50),hold on
    set(gca,'FontSize',24,'box','off');
    ylabel('Frequency')
    xlabel('Difference')
    plot([0,0],get(gca,'YLim'),'k--');
    
    % this is the distribution of responses we'd expect under the null
    % hypothesis, i.e., if the true state of the world is such that the
    % condition means for c1 and c2 are identical!
    
    % let's update figure 3 with a line showing the actual, experimentally
    % observed difference between the two conditions:
    plot([mean(c1-c2),mean(c1-c2)],get(gca,'YLim'),'r--','LineWidth',4)
    
    % figure out where our empricial difference is relative to the null
    % distribution. In this case, count the number of observations in nullDiff
    % that are greater than or equal to the emprical difference we observed.
    % This is akin to estimating a percentile value, and is referred to as an
    % empirically estimated p-value ('cause we're using empirical data to
    % obtain it)
    pval = length(find(nullDiff<=mean(realDiff)))./numel(nullDiff);
    
    % compare to t from the standard parametric test - should be similar
    fprintf('Standard p val: %5.6f, Randomization p val: %5.6f\n', p, pval)
    
    % another method to compute significance: calculate the 95th (or 97.5th) 
    % percentile of the null distribution and determine whether our empirical 
    % difference is greater than this value:
    sigCut = prctile(nullDiff,95);
    if mean(realDiff)>sigCut
        disp('The empirical difference between conditions is > than the 95th percentile of the null distribution, so reject null!')
    else
        disp('The empirical difference between conditions is <= than the 95th percentile of the null distribution, so fail to reject null!')
    end

%==========================================================================
% bootstrapping
%==========================================================================

% bootstrapping (a.k.a. permutation testing) is similar to randomization.
% However, instead of simulating a null distribution we use resampling to
% simulate a population mean from our (much smaller) sample. Let's stick 
% with the same example used above. Again, the goal is to figure out 
% whether attention enhances the amplitude (in microvolts) of an EEG 
% component measured from the scalp. 

    nIter = 1000;                               % # of resampling passes you want to run. Should be at least 1000. 
    bootC1 = nan(1,nIter);
    bootC2 = nan(1,nIter);  
    for ii = 1:nIter
        rndInd = randi(length(c1),1,length(c1));        % random sample of 1:20 participants in each group, WITH REPLACEMENT
        bootC1(ii) = mean(c1(rndInd));                  % average of random sample for attended condition
        bootC2(ii) = mean(c2(rndInd));                  % average of random sample for unattended condition
    end
    
    % now we've got two distributions of sample means - one from the attended
    % condition and another from the unattended condition. Let's take a look at
    % them:
    figure(2),clf
    histogram(bootC1),hold on
    histogram(bootC2)
    set(gca,'FontSize',24,'box','off');
    xlabel('Sample Mean')
    ylabel('Frequency')
    legend('Attended','Unattended')

    % what we're really interested in here is the overlap between the two
    % distributions. If there's virtually no overlap, then it suggests that the
    % samples we collected come from different populations. On the other hand,
    % if there's substantial overlap, then it suggests that the two samples
    % come from the same underlying population. 

    % we can quantify the amount of overlap between the two distributions by
    % computing an empirical p-value. That is, we simply count the number of
    % times we observe a result that's opposite what we'd expect (i.e.,
    % unattended > attended vs. attended > unattended) and normalize by the
    % total number of observations:
    pval = length(find(bootC1-bootC2<0))./numel(bootC1);                % how often was C2 > C1 (or equivalently, C1 < C2, where C1-C2 would return a negative number.
    fprintf('Empirical p val: %5.6f\n', pval)

%--------------------------------------------------------------------------
% bootstrapping and confidence intervals
%--------------------------------------------------------------------------

% Imagine you do a typical experiment in your lab. You run a subject 
% (human/rodent/whatever) through your memory/perception test 
% and you get a 100 numbers, one number that indexes the magnitude of your 
% dependent variable on each trial (RTs/Accuracy/EEG amplitude/spike rate/GSR/etc). 
% Now, you compute your mean over your 100 samples and get 10 (spikes/%cor/etc). 
% Now you might reasonably wonder: this subject produced a mean score of 
% 10 on my test, but what if I were to run her again? Would I get the same 
% number?  What if she participated 1,000 times on the test? Would I get 10
% every time? 

% So the problem is that you're in a situation where you want to know the 
% reliability of a number (i.e. the central tendency of 10), but you only 
% get to make your measurements 1 time (or a limited number of times). 
% There are several ways that you can estimate the number's reliability, 
% but one of the best is to do a bootstrapping analysis, which estimates 
% the variance of your condition mean by resampling the 100 trials you 
% obtained with replacement to see how stable the central tendency is.

% After boot strapping you end up with a confidence interval (CI) on data 
% from this subject - idea is that we can estimate how certain we are of a 
% mean that we observe from this subject - and we can do that either by 
% repeatedly re-sampling from the observed data with replacement, or by 
% re-running the subject N times

    clear all;
    close all;
    
    % in this experiment, condition 1 will be a 'signal' or target present trial,
    % and condition 2 will be a 'noise' or target absent trial 
    
    % means and sigs *of the population*
    m1 = 200;    % mean response or measurements from condition 1 (could be behavior, neural responses, whatever)
    m2 = 250;    % from condition 2
    sig1 = 60;   % variance around means for cond 1 and cond 2
    sig2 = 50;   % assume equal variance for now
    
    % trials and criterion
    nTrls = 50;        % number of trials
    
    % generate sample data for this subject
    s1 = normrnd(m1, sig1, [nTrls, 1]); %good way of generaing from a distibution (whole family of nomrand like things
    s2 = normrnd(m2, sig2, [nTrls, 1]);
    
    % then concatenate these 'samples' as if we gathered the data from a subject
    % over nTrls 
    s = [s1, s2];
    
    % mean - how confident are we in this estimate? if we were to bring this
    % person back into the lab 1,000 times, how often would we observe a
    % similar value? two ways to find out...re-run the subject 1,000 times, or
    % resample the data from the single session. lets do the former first.
    mean(s)
    
    % lets take the original data samples (s) and trial labels (tlabs) and
    % resample with replacement
    nBoots = 1000;
    mean_boot = nan(nBoots,2);
    for i=1:nBoots
       ind = randi(nTrls, [1, nTrls]);          % vector of trial labels, with replacement (duplicates are possible)
       %numel(unique(ind))
       
       ns = s(ind,:);                           % resample 's' and 'tlab' USE SAME RESAMPLE VECTOR FOR BOTH!!!!
       mean_boot(i,:) = mean(ns);
    
    end
    
    % compute mean, CI
    close all
    ci = 95;
    figure(1), hold on
    plot(mean(mean_boot), 'ko-', 'LineWidth', 3)
    set(gca, 'FontSize', 24)
    set(gca, 'XLim', [0 3])
    plot([1 1], prctile(mean_boot(:,1), [(100-ci)/2 100-((100-ci)/2)]), 'k', 'LineWidth', 3)
    plot([2 2], prctile(mean_boot(:,2), [(100-ci)/2 100-((100-ci)/2)]), 'k', 'LineWidth', 3)

%==========================================================================
% Multiple Comparisions
%==========================================================================

% Bootstrapping & Randomization tests are designed to compare two condition
% means. But what if you've got a more complicated experiment with > 2
% experimental conditions?

% Recall from your undergrad stats that with complicated designs you can't
% just run a bunch of t-tests in lieu of running an ANOVA or regression
% model. Why? Every statistical test you run has a probability of error
% (Type 1/False Positive or Type II/False Negative), and these error rates
% are additive across tests. So, if you run 10 t-tests at alpha = 0.05,
% there is a 10*.05 = .50 chance that at least one of your tests will
% return a false positive. Not good!

% There are several ways to deal with this. For example, you probably
% learned about the Bonferroni correction in your undergrad stats class. 
% This correction minimizes the type I error of multiple tests by dividing
% (normalizing) the significance criterion by the number of tests to be 
% performed:

    alpha = 0.05;                               % significance cutoff; pretty standard
    nTests = 10;                                % # of tests you want to run
    bSig = alpha./nTests;                       % bonferonni-corrected significance cutoff

% this works ok if you're running a limited number of tests. But what if
% you want to compare (for example) responses across all possible pairs of
% scalp electrodes to examine the spatial distribution of some EEG effect
% across the scalp. If you've got 64 electrodes, then the number of unique
% combinations of electrodes you can compare is 64^2 = 4096 pairs, and with
% an alpha level of 0.05 the p-value you'd need to reach significance is
% 0.05/1024 = 0.000012 - a pretty high bar to clear!

% The Bonferroni correction is (rightly) called "conservative" because it
% seeks to minimize the likelihood of ever obtaining a type I error, i.e.,
% a significant result that isn't really "real". But, there are alternative
% approaches you can use that are more "liberal" in their criterion.

% One approach we use a lot in the lab involves computing a value called
% the false-discovery rate (FDR). Wikipedia sums it up nicely:

% "FDR-controlling procedures are designed to control the FDR, which is the
% expected proportion of "discoveries" (i.e., rejected null hypotheses)
% that are false (i.e., type I errors). Equivalently, the FDR is the
% expected ratio of the number of false discoveries to the total number of
% discoveries. FDR-controlling procedures provide less stringent control of
% type I errors compaired to familywise error rate-correcting procedures
% such as the Bonferroni correction, which control the probability of at
% least one Type I error. Thus, FDR-controlling procedures have greater
% statistical power, at the cosst of increased numbers of type I errors."

% In our lab, we use the FDR to apply a correction to empirically estimated
% p-values returned by a bootstrap or randomization test. We use the
% approach described by Benjamini & Hochberg (1995), or BH for short. A
% MATLAB function called "fdr_bh.m" is included in the "HelperFunctions"
% folder that accompanies this tutorial. It takes as input a vector of
% p-values estimated from a bootstrap or randomization test and returns
% adjusted p-values. Check out the help documentation for the function
% syntax and optional inputs/outputs.

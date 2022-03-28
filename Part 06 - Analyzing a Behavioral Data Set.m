%==========================================================================
% Intro 2 MATLAB Part 6: Analyzing a simple behavioral data set
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

%==========================================================================
% background
%==========================================================================

% in this (completely made up) experiment, subjects were presented with 
% emotionally arousing or emotionally neutral visual stimuli (e.g. a 
% picture of a snake vs. a car)

% subjects were asked to respond to the stimuli as quickly and accurately 
% as possible by pressing the "1" key after seeing an arousing stimulus and
% the "2" key after seeing a visual stimulus. 

% The experimenters - us - recorded subjects' response times and response 
% accuracy (i.e., did they press the correct or incorrect key on a given 
% trial) to each stimulus.

% We want to know whether arousing images are associated with faster but 
% more *inaccurate* responses (e.g., because subjects are frightened) 
% compared to neutral stimuli. Here, we'll test this hypothesis.

%==========================================================================
% First, let's make up some data
%==========================================================================

nSubs = 20;                           % # of "subjects" you want to simulate
nTrials = 200;                        % # of trials you want to simulate
nCond = 2;                            % # of stimulus conditions (arousing vs. neutral)

% pre-allocate some variables that we'll populate when we synthesize our data
rt = nan(1,nTrials);
acc = nan(1,nTrials);

% create a "subject data" folder in the current directory where we'll save our (fake)
% data file
root = [pwd,'\'];                               % grab an index into the current folder
if ~exist([root,'Subject Data'],'dir')          % quick check to make sure the folder doesn't already exist!
    mkdir([root,'Subject Data']);               % if the folder doesn't exist, make it!
end

% subject loop:
for s = 1:nSubs
  
    % see if you can figure out what this line of code is doing, then try 
    % changing nCond and nTrials to confirm your suspicions. 
    condition = randi(2,1,nTrials);          
  
    % trial loop
    for n = 1:nTrials
        if condition(n)==1                                               % arousing condition, dummy coded as 1
            rt(n) = normrnd(.75,2);                                      % try "help normrnd" (omit quotes) at the command line to get a sense of what this snippet of code is doing
            acc(n) = sign(round(rand));                                  % ignore this for now - it's just a cheap way of making matlab produce 1s and 0s in random order
        else
            rt(n) = normrnd(1,2);
            acc(n) = sign(round(rand));
        end
    end
  
    % save the output for this "subject"
    save([root,'Subject Data\','subject',num2str(s),'.mat'],'rt','acc','condition');
end

% STOP! Check your understanding. Check out the calls to normrnd on lines 55 and
% 56. Try to figure out what's going on. Based on your understanding of these
% lines, in which condition will subjects respond more quickly? (arousing or neutral)?
% what about accuracy?

% clear all variables from the matlab workspace:
clear

%==========================================================================
% Now let's analyze our fake data set
%==========================================================================

addpath('Subject Data');                     % add the subject data directory we just made to MATLAB's path
subs = 1:20;
root = [pwd,'\'];                            % grab an index into the current folder

% pre-allocate some vectors to store output. Not really necessary for this 
% example, but it can massively speed up the execution time on your script 
% when dealing with large data files.
acc_neut = nan(1,length(subs)); acc_arousal = nan(1,length(subs));
rt_neut = nan(1,length(subs)); rt_arousal = nan(1,length(subs));

% subject loop
for s = 1:length(subs)
    sn = num2str(subs(s));                                                % convert the numeric variables in "subs" to string variables so we can read the relevant filesep
    data = load([root,'Subject Data\subject',num2str(s),'.mat'],'rt','acc','condition');       % load the data for this subject. Note that the rt and acc variables will now appear in a structure "data"
  
    acc_neut(s) = mean(data.acc(data.condition==2)); 
    rt_neut(s) = mean(data.rt(data.condition==2));
  
    acc_arousal(s) = mean(data.acc(data.condition==1));
    rt_arousal(s) = mean(data.rt(data.condition==1));
end

% get some descriptive statistics for these data:
mean_acc_neut = mean(acc_neut); std_acc_neut = std(acc_neut);
mean_acc_arousal = mean(acc_arousal); std_acc_arousal = std(acc_arousal);

mean_rt_neut = mean(rt_neut); std_rt_neut = std(rt_neut);
mean_rt_arousal = mean(rt_arousal); std_rt_arousal = std(rt_arousal);

% print the group means to the command window:
sprintf("Average Accuracy is %d in the neutral condition and %d in the arousal condition",mean_acc_neut,mean_acc_arousal)
sprintf("Average RT is %d in the neutral condition and %d in the arousal condition",mean_rt_neut,mean_rt_arousal)

% convert our standard deviation measurements to standard error of the mean
% the standard error of the mean is sd/sqrt(N), where N is the # of subjects
sem_acc_neut = std_acc_neut/sqrt(length(acc_neut));
sem_rt_neut = std_rt_neut/sqrt(length(rt_neut));

sem_acc_arousal = std_acc_arousal/sqrt(length(acc_arousal));
sem_rt_arousal = std_rt_arousal/sqrt(length(rt_arousal));

% run a repeated-measures t-test to determine whether average accuracy in 
% the aroused and neutral conditions are the same:
[h,p,ci,stat] = ttest(acc_neut,acc_arousal);

% same as above, but for RTs:
[h_rt,p_rt,ci_rt,stat_rt] = ttest(rt_neut,rt_arousal);

% generate a bar plot summarizing the accuracy data:
figure(1),clf
bar(1,mean(acc_neut),1,'b'), hold on
bar(3,mean(acc_arousal),1,'r')
errorbar(1,mean(acc_neut),sem_acc_neut,['k','o'],'LineWidth',6,'MarkerSize',50,'CapSize',16)
errorbar(3,mean(acc_arousal),sem_acc_arousal,['k','o'],'LineWidth',6,'MarkerSize',50,'CapSize',16)
set(gca,'FontSize',24,'box','off','XLim',[0,4],'XTick',[1,3],'XTickLabel',{'Neut','Arousal'})
xlabel('Stimulus Condition')
ylabel('Mean Accuracy')

% generate a bar plot summarizing the rt data:
figure(2)
bar(1,mean(rt_neut),1,'b'), hold on
bar(3,mean(rt_arousal),1,'r')
errorbar(1,mean(rt_neut),sem_rt_neut,['k','o'],'LineWidth',6,'MarkerSize',50,'CapSize',16)
errorbar(3,mean(rt_arousal),sem_rt_arousal,['k','o'],'LineWidth',6,'MarkerSize',50,'CapSize',16)
set(gca,'FontSize',24,'box','off','XLim',[0,4],'XTick',[1,3],'XTickLabel',{'Neut','Arousal'})
xlabel('Stimulus Condition')
ylabel('Mean Accuracy')
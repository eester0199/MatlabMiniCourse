%==========================================================================
% Intro 2 MATLAB Part 4: Plotting Data
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

% make some fake data:
y = randn(1,20);                                % create a vector y by sampling 20 values from a standard normal distribution

%==========================================================================
% basic line plot
%==========================================================================

figure(1),clf                                   % Open a figure window and clear the contents. Name it Figure 1
plot(y)                                         % Plot the data in the vector y.
set(gca,'FontSize',24)                          % Set the Font Size for the axes to 24
xlabel('Count')                                 % label the x-axis (can be anything you want)
ylabel('Data')                                  % label the y-axis (like the x-axis, can be anything you want)

figure(2),clf                                   % Open a new figure window and clear the contents. Name it Figure 21
plot(y,'r','LineWidth',4)                       % Plot the data in the vector y, but this time make the line plot red and increase the line thickness to 4
set(gca,'FontSize',24)                          % Set the Font Size for the axes to 24
set(gca,'XLim',[-2,22]);                        % set the limits of the x-axis to -2 and 22
set(gca,'XTick',4:4:20)                         % set the units of the x-axis to 4, 8, 12, 16, 20
set(gca,'YLim',[-3,3]);                         % set the limits of the y-axis to -3 and 3
set(gca,'box','off')                            % turn off the bounding box around the axes (not necessary, but makes for cleaner plots)
xlabel('Count')                                 % label the x-axis (can be anything you want)
ylabel('Data')                                  % label the y-axis (like the x-axis, can be anything you want)
set(gca,'XTickLabel',{'1','2','3','4','5'})     % set the labels on the x-axis to different values (can be anything you want)

% note: the above calls to set can be executed on one line, like this:
set(gca,'FontSize',24,'XLim',[-2,22],'XTick',4:4:20,'YLim',[-3,3],'box','off','XTickLabel',{'1','2','3','4','5'})

%==========================================================================
% Histograms
%==========================================================================

% make some fake data by sampling from a standard normal distribution
y = randn(1,1000);                              % 1000 samples plucked from a standard normal distribution

figure(3),clf   
hist(y);                                        % generate a histogram of the data in y. It should be centered at ~0.

% by default, MATLAB sorts data in calls to the hist function into 10
% equally-sized bins. But we can make the number of bins anything we want:
figure(3),clf
hist(y,25)

% all of the options we used for line plots can be applied here
xlabel('Value'); ylabel('Frequency');           % you can set several plotting values on the same lines as long as you separate them with semicolons
set(gca,'FontSize',24,'XLim',[-4,4],'XTick',-4:2:4,'YLim',[0,150],'box','off','XTickLabel',{'1','2','3','4','5'})

%==========================================================================
% Bar Plots
%==========================================================================

% make some fake data by sampling from a standard normal distribution
y = abs(randn(1,10));                          % 10 samples plucked from a standard normal distribution. taking the absolute value with abs() to make sure all the values are positive

figure(4),clf   
bar(y);                                        % generate a bar plot of the data in y

figure(4),clf   
bar(y,1,'r');                                        % same thing as above, but changing the bar size and bar color

% all of the options we used for line plots can be applied here
xlabel('Observation #'); ylabel('Value');           % you can set several plotting values on the same lines as long as you separate them with semicolons
set(gca,'FontSize',24,'XLim',[0,11],'XTick',2:2:10,'YLim',[0,2],'box','off','XTickLabel',{'1','2','3','4','5'})

%==========================================================================
% Errorbar plots
%==========================================================================

y = abs(randn(10,10));                          % generate a 10 x 10 matrix of data. Rows are "subjects" columns are "observations"
x = 1:size(y,1);                                % vector of values from 1 to the size of the 1st dimension of y (see "help size") 

m = mean(y);                                    % average across the "subjects" in data matrix y
s = std(y);                                     % standard deviation across "subjects"
sem = s/sqrt(size(y,1));                        % SEM is defined as the standard deviation divided by the square root of the # of "subjects"

figure(5),clf
errorbar(x,m,sem,'b','LineWidth',4);            % plot data with SEM errorbars; see help errorbar for more info

% all of the options we used for line plots can be applied here
ylabel('Average');           % you can set several plotting values on the same lines as long as you separate them with semicolons
set(gca,'FontSize',24,'XLim',[0,11],'XTick',2:2:10,'YLim',[0,2],'box','off','XTickLabel',{'1','2','3','4','5'})

%==========================================================================
% Scatterplots
%==========================================================================

% generate two random variables
x = randn(1,50); y = randn(1,50);

figure(6),clf
scatter(x,y)                                    % since the values in x and y are random, the plot should look like a shotgun blast
set(gca,'FontSize',24,'XLim',[-3,3],'XTick',-3:1:3,'YLim',[-3,3],'box','off')

figure(7),clf
scatter(x,y,80,'r','filled')                    % same as above, but sets the marker size to 80 pixes, changes the color of each maker to red, and fills in each marker
set(gca,'FontSize',24,'XLim',[-3,3],'XTick',-3:1:3,'YLim',[-3,3],'box','off')

figure(8),clf
scatter(x,y,80,'r','filled','square')           % but uses squares for markers instead of circles
set(gca,'FontSize',24,'XLim',[-3,3],'XTick',-3:1:3,'YLim',[-3,3],'box','off')

%==========================================================================
% Plotting Color Options:
%==========================================================================

figure(1),clf                                   % Open a figure window and clear the contents. Name it Figure 1
plot(y,'k')                                     % black
plot(y,'r')                                     % red
plot(y,'m')                                     % maroon
plot(y,'c')                                     % cyan
plot(y,'b')                                     % blue
plot(y,'y')                                     % yellow
plot(y,'g')                                     % green

%==========================================================================
% Shaded Errorbars
%==========================================================================

% it's often useful to plot the mean +/- 1 SEM (or a 95% CI; see the
% non-parametric statistics tutorial) for a point estimate. But, when
% you've got lots of estimates, this can get gnarly. For example:

data = randn(10,100);                   % 1 sec of fake EEG data for 10 subjects sampled at 100 Hz
md = squeeze(mean(data));               % average over subjects
sd = std(data)./sqrt(size(data,1));     % SEM voer subjects

% plot:
figure(1),clf
errorbar(1:1:size(data,2),md,sd,'r','LineWidth',2)
set(gca,'FontSize',24,'box','off','XLim',[1,100]);

% That's a lot of errorbars - far more than can be useful for
% visualization. Fortunately, you can replace errorbars with shaded regions
% around the mean using the MATLAB function "patch". To do this, we'll use
% a subfunction called "bandedError" in the "Helpful Functions" folder.
% This function was written by my old postdoc advisor, John Serences. 

addpath('HelpfulFunctions');

patchTrans = .33;                                                           % desired contrast of the patch around the average, can be any number between 0-1. 
figure(2),clf
a = plot(1:1:size(data,2),md,'r','LineWidth',2);                            % plot the data, and grab a plot handle for later updating (this is what the "a = " part does)
bandedError(1:1:size(data,2),md,sd,a,patchTrans);                           % inputs are: x-axis, mean data, SEM data, plot handle, patch translucense
set(gca,'FontSize',24,'box','off','XLim',[1,100]);

% voila. much prettier. There's an analog of this function I've written for
% plotting 95% confidence intervals around the mean, but we'll get to that
% later. 

%==========================================================================
% plotx
%==========================================================================

% Sometimes it's necessary to create a plot with lots of different lines in
% it, e.g., when visually inspecting EEG data from ~60 electrodes. In these
% instances, it's helpful to have a way to map each line in a plot with a
% corresponding entry (row) in a data matrix. You can do that using a
% function called "plotx", which I stole from Ramesh Srinivasan's lab at UC
% Irvine. It works the same way as the plot function, but you can click on
% different lines to get matrix indices for each line. Using the fake data
% we generated in the previous section:

figure(3),clf
plotx(data');                                       % plot all 10 lines

% try clicking on different lines in the plot and see what happens!

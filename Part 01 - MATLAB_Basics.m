%==========================================================================
% Intro 2 MATLAB Part 1: Basics
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

%--------------------------------------------------------------------------
% NOTE: This code is not designed to be run in a single go. You should step
% through different examples piece-wise, e.g., by highlighting the code you
% want to run with your mouse, right clicking, and selecting "evaluate
% selection" (e.g., if you're on a PC). I'm not a mac guy but there should
% be something similar for Apple products, Google?
%--------------------------------------------------------------------------

% define a (numeric) variable:
a = 10;                         % a variable can be anything you want, but must begin with a letter. (there are some exceptions, which we'll get to later)
                                % variables are case-sensitive! A is not the same as a

% define another variable:
b = 5;

% perform some basic operations on your variables:
c_mult = a*b;
c_add = a+b;
c_div = a/b;
e_exp = a^b;

%==========================================================================
% MATLAB is short for "matrix laboratory" and organizes data into vectors
% and matrices. So, it's important to get used to thinking in these terms. 
%==========================================================================

% create a row vector:
rvec = [1,2,3];

% vectors can also contain variables, i.e.:
rvec = [a,b,c_mult]; 

% create a column vector:
cvec = [1;2;3];                                 % use commas for rows, semicolons for columns

% you can transpose a column vector into a row vector (or vice versa) using the apostrophe symbol:
cvec = rvec';   

% make a 2 x 2 matrix:
matrix = [1,2;2,1];

% transpose the matrix:
matrix = matrix';

% sometimes it's helpful to build "placeholder" or "null" matrices full of
% ones, zeros, or "not a number" (NaN)
new_mat = zeros(2,2);                           % returns a 2 x 2 matix full of zeroes

% or, NaN:
new_mat = nan(12,6);                            % returns a 12 x 6 matrix of nans

% or, ones:
new_mat = ones(4,8,3);                          % returns a 4 x 8 x 3 matrix

% there are no limitations on the sizes of data matrices you can create (or
% load, or save), except the computing power of your system (i.e., RAM,
% disk space). 

%==========================================================================
% path definitions (introductory; more on this in part 2)
%==========================================================================

% grab an index into MATLAB's current working directory
root = pwd;

% save a .mat file in the current working directory
save('dataFile.mat');

% load a .mat file in the current working directory
load('dataFile.mat');

% we can assign names to the variables in the data files we're loading,
% e.g.:
data = load('dataFile.mat');

% we can give MATLAB access to data files and support functions (i.e.,
% matlab scripts that do "behind the scenes" work to solve some problem)
% using the "addpath" function:
addpath('HelpfulFunctions');

% note that MATLAB does NOT perform any checks to see if you're overwriting
% an existing file. Be very careful about what you save or how you index
% your data files to avoid overwriting existing data!!

% we can also do some basic error checking to see if we're overwriting a
% file:
fName = [pwd,'\dataFile.mat'];
if ~exist(fName,'file')
    save(fName,'a','file*');
else
    error('File Name Already Exists!')
end

% the if-then logic shown above is a good example of a conditional
% statement. more on those soon.

% delete the files we made so we don't clutter up our hard drive
delete('dataFile.mat');

%==========================================================================
% plotting (introduction; more on this in Part 4)
%==========================================================================

% Matlab has TONS of plotting functions that allow you to visualize data.
% Some useful ones are:

plot                              % simple line plot, used extensively for EEG/ERP data
scatter                           % plots a scatter plot of variable X
bar                               % simple bar plot, useful for discrete variables like averages
errorbar                          % line plot with errorbars (e.g., +/- 1 SEM or 95% CI)
imagesc                           % 2-D topographical plot, used often in visualizing Fourier series

% let's try a few. build some variables to plot; a corresponds to the
% x-axis of the plot and b corresponds to the y-axis of the plot

a = 1:1:20;                       % sequential index of integers from 1:20; 
b = randn(1,length(a));           % randn = random numbers from a normal distribution [mean = 0 and sd = 1]. length(b) returns how many objects are in vector a. 
                                  % so, b will be a 1 x 20 vector of numbers sampled from a normal distribution

figure(1), clf;                   % open a figure window, name it figure 1, and clear the figure (no native axes)
plot(a,b);                        % plot b as a function of a
ax = get(gca);                    % grab an index into the current plot; ax is a "structure" containing plotting variables we can manipulate
set(gca,'FontSize',24)            % change the font size
set(gca,'XLim',[-5,25])           % change the limits of the x-axis
set(gca,'YLim',[-4,4],'box','off')% change the limits of the x-axis AND turn off the shader box enclosing the figure

% now let's use imagesc to generate a 2-D heat-map-style plot
c = randn(length(a),length(a));   % 20 x 20 matrix of IID numbers
figure(2),clf
imagesc(c);                       

% all of the things we did to Figure 1 can also be done to this new Figure. 
set(gca,'FontSize',24)
set(gca,'XTick',[4:4:20]);        % change the scaling on the x-axis

% let's add a colorbar so we can interpret the values in the plot.
colorbar

% we can also change the scaling on the color axis:
caxis([-4,4])

%==========================================================================
% conditionals & logicals
%==========================================================================

% conditionals return 1 if a mathematical statement is true and 0
% otherwise. They're a convenient way to index vectors and matrices.
a = 5; b = 10;

a > b;                                              % is a > b?
a < b;                                              % is a < b?
a == b;                                             % are the two values the same?
a ~= b;                                             % are a and b different?
a == 0;                                             % is a = 0?
(b-a) == 5;                                         % is b-a equal to 5?

% you can use conditionals & logicals to index matrices:
a = [2,4,6,8,2,4,6,8];
b = [1,2,3,4,1,2,3,4];
c = b(a==2);                                        % grab values of b where a = 2;

b = [1,2,3,4;2,1,3,4;3,2,1,4;4,3,2,1;2,3,4,1];      
c = b(b(:,1)==2,:);                                 % grab only the rows of b that begin with 2. 

%==========================================================================
% indexing
%==========================================================================

% the last few demos are good examples of indexing, i.e., using one set of
% variables to single out a second set of variables. 

% this sort of thing is useful if you're trying to (for example) plot an
% event-related potential using only data from trials where stimulus A was
% shown. 

% MATLAB indexes vectors linearly, i.e., the a(2) corresponds to the second
% element in vector a (whether it's a row or column vector)
a(2)

% MATLAB indexes matricies by dimensions. b(2,4) returns the element in the
% 2nd row and 4th column of a matrix; c(2,5,3) returns the element in the
% 2nd row, 4th column, and 3rd level of the 3rd dimension of a matrix

% you can also use colons to grab entire sections of a matrix, e.g.:
b(2,:)         % returns the entire second row of matrix b
b(:,2)         % returns the entire second column of matrix b

%==========================================================================
% Structures
%==========================================================================

% Structures are groups of variables. You can save several variable names
% as part of the same structure. 

% Suppose we ran an experiment where we presented a stimulus (1 or 2) and
% required to press button A when they saw stimulus 1 and button B when
% they saw stimulus 2. We measure their accuracy and response time to each
% stimulus. We can save all of this information in a single structure,
% which we'll call "behav". 

nTrial = 10;
behav.condition = randi(2,1,nTrial);                    % dummy coded stimulus condition labels. see "help randi" (omit quotes) to see what the randi function is doing
behav.rt = randn(1,nTrial);                             % simulated RT data
behav.acc = randi(2,1,nTrial)-1;                        % simulated accuracy data; subtract 1 so all values are either 0 or 1.

% now type "behav" at the command line and see what happens. 

% Structures have the same naming rules as variables, e.g., they have to
% start with a letter and they're case-sensitive. 

% There are no limits on the number of variables you can save in a
% structure, and you can even embed one structure in another (we'll see
% this when we get to EEG data in a bit). MATLAB also has several functions
% you can use to query the contents of a structure, e.g., "getfield", 
% "setfield", "fieldnames", "rmfield", "isstruct", "isfield".
% Check out the help documentation for these functions to learn more. 
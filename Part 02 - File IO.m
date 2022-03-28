%==========================================================================
% Intro 2 MATLAB Part 2: Reading/Writing Files
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

%--------------------------------------------------------------------------
% Saving & Loading MATLAB files (.mat)
%--------------------------------------------------------------------------

% first let's generate a 10x10 matrix of normally distributed numbers:
data = randn(10,10);

% now let's save the data in a .mat file in the current directory:
save('example.mat','data');

clear                                   % clear the workspace
load('example.mat');                    % now try loading the data file we just created:
whos                                    % check to make sure the variable "data" still exists.

% clear the workspace again - this time we'll try something different:
clear
mydata = load('example.mat');
whos

% note that whos returns mydata, but not the variable "data". This is
% because assigning the output of a load function to a (new) variable name
% tells matlab to load the data in the named file and assign it to a new
% structure variable (in this case, mydata). 

% you can access the original data by doing this:
mydata.data

% structures are a useful way of organizing many different variables under
% the same general heading. Suppose we have a bunch of variables in our
% workspace, but only want to save some of them:
a = 10; b = 4; c = 11; d = 19; e = 9; f = 17; g = 12; h = 3;
save('anotherExample.mat','a','e','f','g');                     % this line will create a new .mat file containing the variables a, e, f, and g while omitting all other variables. 

% you can also use the wildcard operator "*" to save files that begin with
% a letter or character string:
acc_cond1 = 1; acc_cond2 = .7; acc_cond3 = .9; rt_cond1 = 2; rt_cond2 = 1; rt_cond3 = 3;
save('anotherExample.mat','acc*');                              % this line will create a new .mat file containing all variables that start with "acc" (we could've also used "a*", but this would've saved extra variables. Why??). 

% we could make our lives easier by organizing a, e, f, and g into a
% structure like mydata:
mydata.a = 10; mydata.e = 9; mydata.f = 17; mydata.g = 12;
save('anotherExample.mat','mydata');

% this is a somewhat trivial example, but this trick becomes much more
% useful when you've got lots of variables (100s) and only want to save a
% subset of them!

% delete the dummy files we just made so we don't clog our hard drives:
delete('anotherExample.mat','example.mat');

%--------------------------------------------------------------------------
% Path Definitions
%--------------------------------------------------------------------------

% SUPER IMPORTANT! Every time you try to load a data file and get a "file
% doesn't exist" error, it's probably because your path definition was
% incorrect. 

% Path definitions are "directions" to the location of a file on your
% computer. They're made up of string variables surrounded by single
% quotes, like 'C:\Users\'

% If you're using the default MATLAB layout, the address bar at the top of
% the GUI shows you the current MATLAB path, and the Current Folder Window
% on the left shows you all of the files in the current folder. 

% You can move to different folders on your computer in MATLAB the same way
% you can on your computer: point-and-click. Or, you can create variables
% that specify the path to some folder on your computer that MATLAB needs
% to do something. Here are some examples of the latter approach:

% we can give MATLAB access to data files and support functions (i.e.,
% matlab scripts that do "behind the scenes" work to solve some problem)
% using the "addpath" function:

addpath('C:\Users\Edward Ester\Desktop')                                    % NOTE - you WILL have to change this to match the file structure on your local computer

% or, equivalently:
filePath = 'C:\Users\Edward Ester\Desktop');
addpath(filePath); 

% NOTE IF YOU'RE USING A MAC! Use forward slashes, "/", to specify
% directories rather than backward slashes. 

% let's save a couple of variables we've already created in the current
% directory.
save('myData','a','b','c_mult');                    % the first entry is the name you want to give the file, remaining entries are variables you want to save.

% we can save any combination of variables we want:
save('myData','filePath','a','data'); 

% we can also use wildcards to save all variables that begin with a single
% letter or the first few letters:
save('myData','a','file*');                         % the "*" symbol acts as a wildcard and will return any variables that start with "file"

% we can also save our data file somewhere else on our computer by
% specifying a filepath:
save([filePath,'myData.mat'],'a','file*');

% or, equivalently:
save(['C:\Users\Edward Ester\Desktop\myData.mat'],'a','file*');

% NOTE THAT MATLAB DOES NOT PERFORM ANY CHECKS TO SEE IF YOU'RE OVERWRITING
% AN EXISTING FILE. Be very careful about what you save or how you index
% your data files to avoid overwriting existing data!!

% we can also do some basic error checking to see if we're overwriting a
% file:
fName = 'C:\Users\Edward Ester\Desktop\myData.mat';
if ~exist(fName,'file')
    save(fName,'a','file*');
else
    error('File Name Already Exists!')
end

% check to see whether a folder already exists. if it doesn't, make it:
if ~exist('C:\Users\Edward Ester\Desktop\SubjectData\','dir')
    mkdir('C:\Users\Edward Ester\Desktop\SubjectData\')
end

% or equivalently:
path = 'C:\Users\Edward Ester\Desktop\SubjectData\';
if ~exist(path,'dir')
    mkdir(path)
end

%==========================================================================
% reading/writing text files
%==========================================================================

% for some simple experiments and analyses, it may be more convenient to
% save data in a tab or space-deliminted .txt file that can be opened with
% a text editor or spreadsheet software like excel. 

% suppose we've got a 10 x 10 matrix of numbers where each row is a subject
% and each column is a score on some independent variable. Let's simulate
% this with some random data:
data = randn(10,10);

% let's say we want to save these data in a tab-delimited text file so we
% can analyze them in excel. We start by picking a file name and using the
% "fopen" command to generate a blank .txt file with that name:
fid = 'textFileExample.txt';                    % fid = "file ID", or the name you want the file to have.
f = fopen(fid,'w');                             % check the help file for fopen for specifics, but in this instance the 'w' stands for "write" and tells matlab we're gonna be writing data to the file. 

% if we want to get fancy we could write a row of column headers to the
% first row of the text file using the fprintf function. Like this:
fprintf(f,'IV1\t'); fprintf(f,'IV2\t'); fprintf(f,'IV1\t'); fprintf(f,'IV2\t');
fprintf(f,'IV5\t'); fprintf(f,'IV6\t'); fprintf(f,'IV7\t'); fprintf(f,'IV8\t');
fprintf(f,'IV9\t'); fprintf(f,'IV10\n');

% in the above example, IV* (where * = a number) is the name we want to
% give each column. The \t or \n operator tells MATLAB to follow that
% string with a tab (equivalent to moving one column in excel) or a new
% line (respectively). 

% now we can actually write some data to the file:
fprintf(f,'%6.2f\t',data(1,1)); fprintf(f,'%6.2f\t',data(1,2)); 

% ... etc. etc. ...

fprintf(f,'%6.2f\t',data(10,9)); fprintf(f,'%6.2f\t',data(10,10));
fclose(f);

% in order to print the data in the correct format, you're gonna have to
% write the whole thing by hand (100 operations). Or you could use a couple
% of for loops to speed things up, but you'll need a way to keep track of
% the \t and \n operators to make sure MATLAB starts a new line for each
% subject which can be tricky (and really mess up your file formatting if
% you make an error). This is why it's usually much easier to deal with
% .mat files!! (plus it allows you to take advantage of all of matlab's
% plotting functions)

% if you do go this route, the '%6.2f' operator in the above code stands
% for hexidecimal (the 6), 2 decimals (the 2), and floating point (the f).
% Don't worry if you don't know what those things are. The only thing
% you'll ever want to mess with is the 2, because you can use it to round
% numbers to whatever digit you choose (10s, 100s, 1000s, etc.). For most
% purposes 2-3 significant digits are appropriate. 

%--------------------------------------------------------------------------

% here's another example where I create, save, and then read data from a
% .txt file. Say I've got an experiment with three independent variables,
% and I want to make sure that all three variables are fully crossed (i.e.,
% latin square design) in a single block of 72 trials. For simplicity we'll
% assume each variable has two different levels. I can generate a single
% design matrix, X, by doing this:
nTrials = 72;
X(:,1) = [ones(nTrials/2,1);ones(nTrials/2,1)+1];                                                   % first IV, dummy coded as 1s and 2s
tmp = [ones(nTrials/4,1);ones(nTrials/4,1)+1]; X(:,2) = repmat(tmp,size(X,1)/length(tmp),1);      % second IV, dummy coded as 1s and 2s. Check the helpfile for repmat to see what it's doing
tmp = [ones(nTrials/8,1);ones(nTrials/8,1)+1]; X(:,3) = repmat(tmp,size(X,1)/length(tmp),1);
imagesc(X)          % shorthand way of visualizing the data to make sure all variables are fully crossed - we'll learn more about it when we talk about plotting

% now let's save the design matrix as a .txt file. It's much easier to read
% .txt files into matlab's workspace if they don't contain column headers,
% so we'll omit those for this example:
f = fopen('designMatrix.txt','w');
for ii = 1:size(X,1)
    for jj = 1:size(X,2)
        if jj < 3
            fprintf(f,'%i\t',X(ii,jj));                 % here the '%i' function tell matlab to print an integer, which we can do since we're just dealing with whole numbers. 
        else
            fprintf(f,'%i\n',X(ii,jj));
        end
    end
end
fclose(f);                      % close the file after we're done saving to it. 

% clear the workspace, then load the .txt file we just created:
clear
load('designMatrix.txt');

% voila, we should see our design matrix X. We could also load X as a
% subfield in a structure if we chose (see example at the top of this
% script). 
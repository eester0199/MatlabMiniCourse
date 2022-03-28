%==========================================================================
% Intro 2 MATLAB Part 3: Control Statements
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

% three major kinds:

% if/then
% for/while
% try/catch

%--------------------------------------------------------------------------
% if-then statements
%--------------------------------------------------------------------------

% if something is true, do something. 
x = 10;
if x == 10                              % note the use of double equals for logical operations
    y = 1;
else
    y = -1;
end

% you can condition if-then statements on combinations of logical outcomes:
x = 10; y = 5;
if x == 10 && y == 5                    % if x == 10 AND y == 5
    z = 1;
else
    z = -1;
end

% use double ampersands for "and" operations and double vertical lines "||"
% for "or" operations
if x == 10 || y == 5                    % if x == 10 OR y == 5
    z = 1;
else
    z = -1;
end

% if-then statements can also include "elseif" statements
if x == 10 && y == 3
    z = 1;
elseif x == 5 && y == 10
    z = -1;
else
    z = 0;
end

% there are no limits on the number of "elseif" statements you can have, and you can use them with combinations of and/or comparisons:
if x == 5 && y == 3
    z = 1;
elseif x==5 || y == 3
    z = pi;
elseif x==y
    z = nan;
else
    z = 0;
end

%==========================================================================
% FOR/WHILE LOOPS
%==========================================================================

% for loops perform some operation a specified number of times:
% example for loop
nIter = 1000;                       % # of desired iterations
for ii = 1:nIter                    % variable ii will count from 1 to 1000 
    z(ii) = randn;                  
end

% the use of "ii" above is arbitrary and can be anything you want; the
% logic stays the same:
clear z
nIter = 1000;                       % # of desired iterations
for xx = 1:nIter                    % variable ii will count from 1 to 1000 
    z(xx) = randn;                  
end

% you can nest for loops inside one another:
clear z
for ii = 1:nIter
    for jj = 1:nIter
        z(ii,jj) = randn;
    end
end

% you can also nest if-then loops inside for loops:
clear z
for ii = 1:nIter
    tmp = randn;
    if tmp>0
        z(ii) = 1;
    elseif tmp<0
        z(ii) = 0;
    elseif tmp==0
        z(ii) = nan;
    end
end

%==========================================================================
% a note on pre-allocating matrices in for/while operations:
%==========================================================================

clear all;

% allocating memory (pre-defining) matrices. Why do it? This is slow:
tic
for i=1:5000
    for j=1:1000
        n(i,j)=rand;
    end
end
toc

% on my laptop, (2021 Dell XPS i9) this takes ~6.5 sec

% instead preallocate so that matlab doesn't have to dynamically resize 
% the matrix
nn = zeros(5000,1000); 
tic
for i=1:5000
    for j=1:1000
        nn(i,j)=rand;
    end
end
toc

% this takes ~0.07 sec.

%==========================================================================
% while loops execute until some outcome is reached:
%==========================================================================

x = 1;
while x < 100
    x = x+1;
    fprintf('The value of x is %f\n', x);                       % use fprintf to print outcomes to the MATLAB command window
end

% beware the infinite loop! (use ctrl+c to "break out" of an infinite loop)
while 1
    x = rand;                                                   % random numbers on the interval [0,1]
    fprintf('The value of x is %f\n', x);
    if x>1                  % exit condition
        break;              % break the infinite while true loop
    end
end

% a (nearly) infinite loop
nIter = 1;
while 1
    x = randn;                                                   % random numbers from a standard normal distribution
    nIter = nIter+1;
    fprintf('Iteration %f\t value of x is %f\n',[floor(nIter),x]);
    if x>4                    % exit condition
        break;                % break the infinite while true loop
    end
end

% you can nest a for loop within a while loop or vice-versa. we'll see more
% of that when we get to more difficult operations

%==========================================================================
% try-catch 
%==========================================================================

% these are like if-then loops, but allow for more flexibility in handling
% errors. As MATLAB's documentation puts it:

% Normally, only the statements between the try and CATCH are executed.
% However, if an error occurs while executing any of the statements, the
% error is captured into an object, ME, of class MException, and the 
% statements between the CATCH and END are executed. If an error occurs 
% within the CATCH statements, execution stops, unless caught by another 
% try...CATCH block. 

% example:
try
    x = madeupfunctionthatdoesnotexist(200);
catch
    warning('the function you tried to use doesnt exist')
    n = nan;                                                                % note that you still have to assign x a value
end

% another example that will allow for more sophisticated error handling
try
    x = madeUpFunctionThatDoesNotExist(200);
catch ME
    switch ME.identifier
        case 'MATLAB:UndefinedFunction'
            warning(ME.message); % present the error message
            x = NaN;             % assign a value to x
           
        %case -> other stuff to handle here    
        
        otherwise
            rethrow(ME)  % reissue error message that would have been displayed by default
    end
end

% that last example also uses a "switch-case" logic. these are handy for
% situations where you're waiting on user (keyboard) input or you have
% known values you're using for indexing:
% switch, case, otherwise statements
n = input('Enter an even or odd number: ');
switch mod(n,2)   % return remainder after division
    case 0
        disp('even number')
    case 1
        disp('odd number')
    otherwise
        disp('you didn''t enter an integer')
end

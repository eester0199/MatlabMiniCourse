function pred = model(p)

% function parameter
%a - amplitude
%b - baseline response
%k - bandwidth
%u - mean (mu)
%x - x axis 

% note that max resp will be (a+b)
pred = p.a*exp(p.k*(cos(p.u-p.x)-1))+p.b;


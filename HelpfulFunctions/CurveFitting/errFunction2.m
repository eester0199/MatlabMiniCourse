function [err, bic] = errFunction2(p,fl,data)
% this version will also return BIC (will slow it down a bit, but this
% will make model comparison easier)

%get a prediction of the data
pred = p.a*exp(p.k*(cos(p.u-p.x)-1))+p.b;

% then compute the SSE between pred and data
err = sum((pred-data).^2); % note that this is equal to RSS

% bic = number of data points * log(mse) + (number of parameters *
% log(number of data points))
n = numel(pred);
k = numel(fl);
bic = n * log(err/n) + (k*log(n));

if p.plot==1
    figure(1);
    clf
    plot(p.x, pred), hold on
    plot(p.x, data, 'k')
    drawnow
end


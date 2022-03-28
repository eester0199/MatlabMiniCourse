function [err, pred] = fitCos(p, data)

%Circular Gaussian fn
pred = p.a*exp(p.sig*(cos(0-p.x)-1)) + p.b;
err = sum((data-pred).^2);

% add some penalties for crazy data
if p.sig <= 0 || p.sig > 30
    err = 1e10;
end

if p.a < -5 || p.a > 8
    err = 1e10;
end

if p.plot==1
    figure(1)
    clf
    plot(data,'o');
    hold on
    plot(pred);
    xlabel('Direction');
    drawnow
end
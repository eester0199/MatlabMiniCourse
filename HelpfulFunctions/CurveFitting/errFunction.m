function err = errFunction(p,data)

%get a prediction of the data
pred = model(p); %p.a*exp(p.k*(cos(p.u-p.x)-1))+p.b;

% then compute the SSE between pred and data
err = sum((pred-data).^2);

% % error walls
% if p.u<80*(pi/180) | p.u>100*(pi/180)
%    err = 10000000; 
% end
% 
% if p.b<0
%     err = 10000000; 
% end
% 
if p.a<0
    err = 10000000; 
end
% 
% if p.k<1
%     err = 10000000; 
% end

if p.plot==1
    figure(1);
    clf
    plot(p.x, pred, 'b', 'LineWidth', 2), hold on
    plot(p.x, data, 'k', 'LineWidth', 2)
    drawnow
end


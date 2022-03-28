function h = bandedError(x, y, se, plotHandle, alpha);
%h = bandedError(x, y, se, plotHandle, alpha)
%js (serences@salk.edu) 07.03.2006...inspired by some data presented
%       by clay curtis

nLines = size(x',2);

if size(x,1)>size(x,2) % column vectors
    x = x';
    y = y';
    se = se';
end

for l=1:nLines

tmpx = [x(l,:),fliplr(x(l,:))];                                   %wrap around the xData for passing to patch
tmpy = [y(l,:)+se(l,:),fliplr(y(l,:)-se(l,:))];                             %make the y-data (again, 'wrapping it around')
h = patch(tmpx, tmpy, get(plotHandle(l), 'Color'));
set(h, 'FaceAlpha', alpha);
set(h, 'EdgeColor','none');

end
function h = bandedError_CIs(x, y, se1, se2, plotHandle, alpha)
nLines = size(x',2);
if size(x,1)>size(x,2) % column vectors
    x = x';
    y = y';
    se1 = se1';
    se2 = se2';
end

for l=1:nLines

tmpx = [x(l,:),fliplr(x(l,:))];                                   %wrap around the xData for passing to patch
tmpy = [se1(l,:),fliplr(se2(l,:))];                             %make the y-data (again, 'wrapping it around')
h = patch(tmpx, tmpy, get(plotHandle(l), 'Color'));
set(h, 'FaceAlpha', alpha);
set(h, 'EdgeColor','none');

end
function out = plotx(varargin)
%PLOTX shows number of lineseries when clicked.
%   H = PLOTX(...) accepts exactly same input arguments as PLOT, and
%   returns the handles of lineseries as vector H; click on any lineseries
%   object and the index will be shown in upper left corner.

% Written by Siyi Deng; 08-22-2008;

h = plot(varargin{:});
hTxt = text('unit','norm','position',[.05 .9],...
    'string',' ','edgecolor','none','linewidth',2);
for k = 1:numel(h)
    set(h(k),'HitTest','on','DisplayName',num2str(k),...
        'ButtonDownFcn',{@lineseriescall,k,hTxt});
end    
if nargout > 0, out = h; end
end % PLOTX;

function lineseriescall(src,evt,k,h)
set(h,'edgecolor',get(src,'color'),'string',num2str(k));
end % LINESERIESCALL;
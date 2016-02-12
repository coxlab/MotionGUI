function moveObj(varargin)

h=varargin{1};
%event=varargin{2};

handles=guidata(h);

%%% start tracking
set(gcf,'WindowButtonMotionFcn',{@trackMarker,h})
set(gcf,'WindowButtonUpFcn',@stopTracking)
guidata(h,handles)
end

function trackMarker(varargin)
h=varargin{3};
handles=guidata(h);
temp=get(gca,'CurrentPoint');
[x, y]=list(temp(1,1:2));
x=restrictRange(x,handles.plot_handles(1).p(1).default([1 3]));
y=restrictRange(y,handles.plot_handles(1).p(1).default([2 4]));
set(h,'Xdata',x,'Ydata',y)
end

function stopTracking(varargin)
set(gcf,'WindowButtonMotionFcn','')
end
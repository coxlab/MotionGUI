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
temp=get(gca,'CurrentPoint');
[x, y]=list(temp(1,1:2));
x=restrictRange(x,[0 13]);
y=restrictRange(y,[0 13]);
set(h,'Xdata',x,'Ydata',y)
end

function stopTracking(varargin)
set(gcf,'WindowButtonMotionFcn','')
end
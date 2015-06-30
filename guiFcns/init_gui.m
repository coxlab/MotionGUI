function init_gui(varargin)

handles=guidata(varargin{1});

handles.hAxis01=subplot(1,4,[1 3]);
set(handles.hAxis01,'Parent',handles.hPanel_axis)

% plot max outline
cla
hold on
this_rect=[0 0 13 13];
handles.plot_handles(1).p(1).h=plotRect(this_rect,'k');
handles.plot_handles(1).p(1).default=this_rect;

% plot place holder headplate
handles.plot_handles(1).p(2).h=circle([-10 -10],0,100,'r-',1);

% plot place holder window and crosshairs
handles.plot_handles(1).p(3).h=circle([-10 -10],0,100,'b-',1);
handles.plot_handles(1).p(4).h=plot([0 0],[-10 10],'k'); % AP
handles.plot_handles(1).p(5).h=plot([-10 -10],[0 0],'k'); % ML

% initiate current position marker
handles.plot_handles(1).p(7).h=plot(0,0,'ko:'); % grid

h=plot(6.5,6.5,'m*'); % indicator
set(h,'ButtonDownFcn',@moveObj)
handles.plot_handles(1).p(6).h=h;

hold off
axis equal
axis ([-1 14 -1 14])
xlabel('Medial <-> Lateral')
ylabel('Posterior <-> Anterior')


handles.hAxis02=subplot(1,4,4);
set(handles.hAxis02,'Parent',handles.hPanel_axis)
handles.plot_handles(2).p(1)=bar(1,0);
handles.plot_handles(2).p(2)=xlabel('0');
ylabel('Z-depth relative to coverslip')
axis([0 2 -3 3])
axis ij


guidata(handles.hFig,handles);

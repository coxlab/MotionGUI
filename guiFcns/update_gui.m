function update_gui(varargin)

handles=guidata(varargin{1});
Calibration=handles.Calibration;
replotRect(handles.plot_handles(1).p(1).h,handles.Calibration.coordinate_system.rect,'k')

if Calibration.headplate.calibrated==1
    % plot headplate inner diameter    
    replotCircle(handles.plot_handles(1).p(2).h,handles.Calibration.headplate.center_coords,handles.Calibration.headplate.radius,100,'-');
else
    % plot place holder
    replotCircle(handles.plot_handles(1).p(2).h,[-10 -10],0,100,'-');
end

if Calibration.window.show_AP==1&&handles.Calibration.window.calibrated==0
    AP=Calibration.window.coords([1 2],1:2);
    set(handles.plot_handles(1).p(4).h,'Xdata',AP(:,1),'Ydata',AP(:,2))
else
    set(handles.plot_handles(1).p(4).h,'Xdata',[0 0],'Ydata',[-10 -10])
end
if Calibration.window.show_ML==1&&handles.Calibration.window.calibrated==0
    ML=Calibration.window.coords([3 4],1:2);
    set(handles.plot_handles(1).p(5).h,'Xdata',ML(:,1),'Ydata',ML(:,2))
else
    set(handles.plot_handles(1).p(5).h,'Xdata',[-10 -10],'Ydata',[0 0])
end

if handles.Calibration.window.calibrated==1
    % plot coverslip outer diameter        
    replotCircle(handles.plot_handles(1).p(3).h,handles.Calibration.window.center_coords,handles.Calibration.window.radius,100,'-');
else
    % plot place holder
    replotCircle(handles.plot_handles(1).p(3).h,[-10 -10],0,100,'-');    
end

guidata(handles.hFig,handles);
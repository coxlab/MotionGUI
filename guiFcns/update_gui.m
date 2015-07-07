function update_gui(varargin)
% This function deserves a massive upgrade!
% All objects will be read out and synced up to the GUI using this function
% E.g. the number of coordinates!
% Only when changes are to be plotted, have flag attached to each object to
% indicate update is needed


H=varargin{1};
handles=guidata(H);

%%% Serial interface
interface=handles.interface;
if interface.do_update==1    
    if interface.update_position==1        
        plot_coords=interface.plot_coords;
        disp_coords=interface.disp_coords;
        
        set(handles.plot_handles(1).p(6).h,'Xdata',plot_coords(1),'Ydata',plot_coords(2))
        set(handles.plot_handles(2).p(1),'Ydata',plot_coords(3))
        set(handles.plot_handles(2).p(2),'String',sprintf('%3.4f',plot_coords(3)))
        
        string=sprintf('X=%03.4f ; Y=%03.4f ; Z=%03.4f',disp_coords);
        set(handles.hEdit02,'String',string)
        
        % Reset flag
        interface.update_position=0;
        %disp('Position updated')
    end
    
    if interface.connected==1
        str=interface.conn_str;
    else
        str=interface.deconn_str;
    end
    set(handles.hEdit01,'String',str)
    
    %%% Remove flag
    interface.do_update=0;
end

%%% Trajectory go2pos
T=handles.T_go2pos;
if T.do_update==1
    
    if T.running==1
        str='Abort';
    else
        str='GO';
    end
    set(T.button_handle,'String',str)
    
    %%% Reset flag
    T.do_update=0;
end

%%% Trajectory stack/grid
if handles.stack_grid==1
    T=handles.T_zStack;
else
    T=handles.T_grid;
end
if T.do_update==1
    str=sprintf('N=%d',T.nCoords);
    set(handles.hEdit03,'String',str)
    
    if T.running==1
        str='Abort';
    else
        str=T.default_string;
    end
    set(T.button_handle,'String',str)
    
    %%% Remove flag
    T.do_update=0;
end


%%% Calibration
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

guidata(H,handles);
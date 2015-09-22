function setWindowCoord(varargin)
handles=guidata(varargin{1});
mode=varargin{3};
interface=handles.interface;
cur_pos=interface.cur_coords;

Calibration=handles.Calibration;

if Calibration.window.calibrated==1
    Calibration.window.calibrated=0;
    Calibration.window=Calibration.window_reset;
    Calibration.window.coords_collected=zeros(1,size(Calibration.window.coords,1));
    disp('Recalibrating')
    interface.correctCoords(Calibration.window);
    interface.do_update=1;
    interface.update_position=1;
else
    %disp('Starting new calibration')    
end

switch lower(mode)
    case 'anterior'
        loc=1;
    case 'posterior'
        loc=2;
    case 'medial'
        loc=3;
    case 'lateral'
        loc=4;
    case 'center'
        loc=5;
        Calibration.window.Z_offset=cur_pos(3);
end

Calibration.window.coords_collected(loc)=1;
Calibration.window.coords(loc,:)=cur_pos;

if all(Calibration.window.coords_collected([1 2]))
    Calibration.window.show_AP=1;
else
    Calibration.window.show_AP=0;
end

if all(Calibration.window.coords_collected([3 4]))
    Calibration.window.show_ML=1;
else
    Calibration.window.show_ML=0;
end

if all(Calibration.window.coords_collected)
     Calibration.window.calibrated=1;
     
     %% get additional information out of coords
     % center, radius, real distance between AP and ML coords, pitch, roll
     coords=Calibration.window.coords;          
     center=coords(5,1:2);
     x_dev=coords(1:4,1)-center(1);
     y_dev=coords(1:4,2)-center(2);
     Calibration.window.center_coords=center;
     
     Calibration.window.radius=mean(sqrt(x_dev.^2+y_dev.^2));
     
     Calibration.window.AP_dist=range(y_dev(1:2));
     Calibration.window.ML_dist=range(x_dev(3:4));
     
     % calculate angles of window, invert because our z-direction is
     % inverted
     Calibration.window.pitch=-calc_heading([coords(1,[2 3]) coords(2,[2 3])])/pi*180;
     Calibration.window.roll=-calc_heading([coords(3,[1 3]) coords(4,[1 3])])/pi*180;    
     
     interface.correctCoords(Calibration.window);
     interface.do_update=1;
     interface.update_position=1;
end

handles.Calibration=Calibration;
handles.interface=interface;
guidata(varargin{1},handles);

update_gui(handles.hFig)
function varargout=toggleJoystick(varargin)
H=varargin{1};
handles=guidata(H);
interface=handles.interface;
Trajectory=handles.Trajectory;
switch 2
    case 1
        %%% Enable joystick control
        msg='EX JOYSTICK ON';
        fprintf(handles.s,msg);
        Trajectory.Joystick=1;       
    case 2
        interface.toggleJoystick('ON')
end
handles.Trajectory=Trajectory;
guidata(H,handles);
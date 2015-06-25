function varargout=toggleJoystick(varargin)
H=varargin{1};
handles=guidata(H);
Trajectory=handles.Trajectory;

%%% Enable joystick control
msg='EX JOYSTICK ON';
fprintf(handles.s,msg);
Trajectory.Joystick=1;

handles.Trajectory=Trajectory;
guidata(H,handles);
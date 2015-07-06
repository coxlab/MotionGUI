function toggleJoystick(varargin)
H=varargin{1};
handles=guidata(H);
interface=handles.interface;
interface.joystickOn()
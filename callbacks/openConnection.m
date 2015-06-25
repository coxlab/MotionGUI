function varargout=openConnection(varargin)

handles=guidata(varargin{1});
if nargin>=3&&not(isempty(varargin{3}))
    comport=varargin{3};
else
    comport='COM5';
end

s=serial(comport);
s.name='ESP301';
s.BaudRate=921600;
s.FlowControl='software';
s.Terminator='CR/LF';
s.Timeout=2;
 
fopen(s);

handles.s=s;

msg='EX JOYSTICK ON';
fprintf(handles.s,msg);

set(handles.hEdit01,'String','Connected')

guidata(varargin{1},handles)


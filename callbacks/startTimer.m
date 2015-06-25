function varargout=startTimer(varargin)
handles=guidata(varargin{1});

if strcmpi(handles.hTimer.running,'Off')
    %handles.coords=getMotorPosition(handles.s);
    %guidata(varargin{1},handles);
    
    start(handles.hTimer)
end
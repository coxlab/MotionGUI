function startTimer(varargin)
handles=guidata(varargin{1});

if strcmpi(handles.hTimer.running,'Off')
    handles.interface.last_coords=[-1 -1 -1];
    start(handles.hTimer)
end

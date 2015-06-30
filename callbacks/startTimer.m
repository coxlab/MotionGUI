function startTimer(varargin)
handles=guidata(varargin{1});

if strcmpi(handles.hTimer.running,'Off')    
    start(handles.hTimer)
end
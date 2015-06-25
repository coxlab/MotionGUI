function varargout=stopTimer(varargin)
handles=guidata(varargin{1});

if strcmpi(handles.hTimer.running,'On')
    stop(handles.hTimer)
    handles.coords=[0 0 0];
    guidata(varargin{1},handles)
    set(handles.hEdit02,'String','Not Running')
end


function varargout=closeConnection(varargin)

handles=guidata(varargin{1});
fclose(handles.s);

set(handles.hEdit01,'String','Disconnected')
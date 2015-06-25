function toggleCCD2p(varargin)

H=varargin{1};
handles=guidata(H);
handles.ccd2p=get(H,'value');
guidata(H,handles)
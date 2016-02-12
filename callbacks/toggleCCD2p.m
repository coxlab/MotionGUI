function toggleCCD2p(varargin)

H=varargin{1};
handles=guidata(H);
handles.ccd2p=get(H,'value')+1;
guidata(H,handles)
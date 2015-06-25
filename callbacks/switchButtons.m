function switchButtons(varargin)

H=varargin{1};
mode=varargin{3};
handles=guidata(H);

switch mode
    case 'moveStack'
        set(handles.hBut08a,'visible','On')
        set(handles.hBut09a,'visible','On')
        set(handles.hBut10a,'visible','On')
        set(handles.hBut11a,'visible','On')
        set(handles.hBut12a,'visible','On')
        
        set(handles.hBut08b,'visible','Off')
        set(handles.hBut09b,'visible','Off')
        set(handles.hBut10b,'visible','Off')
        set(handles.hBut11b,'visible','Off')
        set(handles.hBut12b,'visible','Off')
    case 'Calibrate'
        set(handles.hBut08b,'visible','On')
        set(handles.hBut09b,'visible','On')
        set(handles.hBut10b,'visible','On')
        set(handles.hBut11b,'visible','On')
        set(handles.hBut12b,'visible','On')
        
        set(handles.hBut08a,'visible','Off')
        set(handles.hBut09a,'visible','Off')
        set(handles.hBut10a,'visible','Off')
        set(handles.hBut11a,'visible','Off')
        set(handles.hBut12a,'visible','Off')
end
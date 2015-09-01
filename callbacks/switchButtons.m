function switchButtons(varargin)
global state
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
    case 'makeGrid'
        %handles.T_grid=;
        %handles.T_grid.name='grid';        
        if handles.ccd2p==1            
            handles.T_grid.makeGrid(handles.T_zStack)
        else % 2p
            state.init.allowUsePockels_duringGrab=1;
            handles.T_grid.makeGrid3D(handles.T_zStack)
        end
        handles.stack_grid=2;
    case 'clearGrid'
        disp('Clearing grid')
        %handles.T_zStack.clear()
        handles.T_grid.clear();
        handles.stack_grid=1;
        handles.T_zStack.do_update=1;
end
guidata(H,handles);
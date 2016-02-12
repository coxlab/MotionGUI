function removeLast(varargin)

handles=guidata(varargin{1});

if handles.stack_grid==2
    handles.T_grid.clear()
end
handles.T_zStack.clear_last()
%handles.T_zStack.update_GUI()

guidata(varargin{1},handles)
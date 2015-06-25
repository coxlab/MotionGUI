function varargout=removeLast(varargin)

handles=guidata(varargin{1});

if handles.Trajectory.nCoords>0   
    handles.Trajectory.coords_matrix=handles.Trajectory.coords_matrix(1:end-1,:);
    handles.Trajectory.nCoords=handles.Trajectory.nCoords-1;
end
set(handles.hEdit03,'String',sprintf('nCoords=%d',handles.Trajectory.nCoords))
%handles.selected_coords-repmat([0 0 handles.coverslip.Z_offset],handles.nCoords,1)
%handles.selected_coords-repmat([0 0 handles.Calibration.window.Z_offset],handles.nCoords,1);
guidata(varargin{1},handles)
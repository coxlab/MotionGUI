function grabCoordinate(varargin)
global state
H=varargin{1};
handles=guidata(H);

interface=handles.interface;
new_coord=interface.cur_coords;

switch 3
    case 1
        A=handles.Trajectory.coords_matrix-repmat([handles.Calibration.window.center_coords handles.Calibration.window.Z_offset],handles.Trajectory.nCoords,1);
        
        for iCoord=1:handles.Trajectory.nCoords
            coord=A(iCoord,:);
            fprintf('X=%03.4f ; Y=%03.4f ; Z=%03.4f \n',coord);
        end
    case 2
        Trajectory=handles.Trajectory;
        coords=Trajectory.coords_matrix;
        if handles.Calibration.window.calibrated==1
            coords=convertAbsRel(H,coords); % abs to rel
        end
        fprintf('X=%03.4f ; Y=%03.4f ; Z=%03.4f \n',coords');
        if isfield(Trajectory,'track_velocities')
            T=sum(abs(diff(Trajectory.coords_matrix([1 end],:))./Trajectory.track_velocities));
            fprintf('Estimated duration %3.2f seconds\n',T)
            if isfield(state,'acq')
                nFrames=ceil(T*state.acq.frameRate);
                fprintf('#frames given current sampling rate (%3.2fHz): %04d frames\n',[state.acq.frameRate nFrames])
            else
                disp('#frames unknown: scanimage is not running...')
            end
        end
    case 3
        if handles.stack_grid==2
            handles.T_grid.clear()
        end
        handles.T_zStack.append(new_coord)
        coord_matrix=cat(1,handles.T_zStack.coords.coord);
        disp(coord_matrix)
        %set(handles.hEdit03,'String',sprintf('nCoords=%d',handles.T_zStack.nCoords))
end

guidata(H,handles)
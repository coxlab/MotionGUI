function varargout=grabCoordinate(varargin)
global state
H=varargin{1};
handles=guidata(H);

new_coord=getMotorPosition(handles.s);
handles.Trajectory.coords_matrix(handles.Trajectory.nCoords+1,:)=new_coord;
handles.Trajectory.nCoords=handles.Trajectory.nCoords+1;

%%% Update GUI
%set(handles.hEdit02,'String',sprintf('X=%03.3f; Y=%03.3f; Z=%03.3f',new_coord))
set(handles.hEdit03,'String',sprintf('nCoords=%d',handles.Trajectory.nCoords))

%handles.selected_coords-repmat([0 0 handles.coverslip.Z_offset],handles.nCoords,1)
%handles.Trajectory.coords_matrix-repmat([0 0 handles.Calibration.window.Z_offset],handles.Trajectory.nCoords,1)
%[handles.Calibration.window.center_coords handles.Calibration.window.Z_offset*0]
%handles.Trajectory.coords_matrix-repmat([handles.Calibration.window.center_coords handles.Calibration.window.Z_offset],handles.Trajectory.nCoords,1)

switch 2
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
end


guidata(H,handles)
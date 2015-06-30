function runTrajectory(varargin)
% completely rewritten, start here, but rest is handled by the timer
% function
global state

H=varargin{1};
handles=guidata(H);

switch 2
    case 1
        Trajectory=handles.Trajectory;
        
        Trajectory.nCoords=size(Trajectory.coords_matrix,1);
        
        if Trajectory.running==0
            if Trajectory.nCoords>0
                Trajectory.target_index=1;
                Trajectory.target_coord=Trajectory.coords_matrix(Trajectory.target_index,:);
                Trajectory.running=1;
                Trajectory.moving=0;
                Trajectory.Joystick=1;
                Trajectory.max_velocities=read_max_velocity(handles.s);
                Trajectory.track_velocities=[1 1 1]*0.003; % default 0.003
                Trajectory.default_velocities=[.2 .2 .2];
                Trajectory.abort=0;
                Trajectory.finished=0;
                Trajectory.button_handle=H;
                Trajectory.default_string='Start Trajectory';
                
                %%% give time indication
                if Trajectory.nCoords==2
                    T=sum(abs(diff(Trajectory.coords_matrix)./Trajectory.track_velocities));
                    fprintf('Estimated duration %3.2f\n',T)
                    
                    if isfield(state,'acq')
                        nFrames=ceil(T*state.acq.frameRate);
                        fprintf('#frames given current sampling rate (%3.2fHz): %04d frames\n',[state.acq.frameRate nFrames])
                    else
                        disp('#frames unknown: scanimage is not running...')
                    end
                    
                end
                
                set(H,'String','Abort?')
            else
                disp('No coordinates loaded...')
            end
        else
            Trajectory.abort=1;
        end
        handles.Trajectory=Trajectory;
        
    case 2
        handles.stack_grid
        switch handles.stack_grid
            case 1
                T_stack=handles.T_zStack;
            case 2
                T_stack=handles.T_grid;
        end
        interface=handles.interface;
        if T_stack.running==0            
            interface.iStep=0;
            
            T_stack.running=1;
            T_stack.abort=0;
            T_stack.finished=0;
            T_stack.moving=0;
            T_stack.target_index=1;
            T_stack.target_coord=T_stack.coords(T_stack.target_index).coord;
            set(H,'String','Abort?')
        else
            T_stack.abort=1;
        end
        handles.T_grid=T_stack;
        handles.Trajectory=T_stack;
        handles.interface=interface;
end

guidata(H,handles);


function varargout=go2Position(varargin)
% should be replaced by something like the trajectory but then with only 1
% coord and adaptable speed
H=varargin{1};
handles=guidata(H);
Trajectory=handles.Trajectory;

%%% Read coordinates from the box
str=get(handles.hEdit02,'string');
if strcmpi(str,'not running')
    % do nothing
else
    % attempt to decode the string
    str=strrep(str,'=',' '); % remove =-signs to allow decoding
    coords=sscanf(str,'%*s %f ; ')';
        
    if handles.ccd2p % add offset camera vs 2p
        %% BV20150416: incorporated known offset between centers of camera and 2p fields
        offset=[0.4724   -0.3665   -0.0488]; % in mm.
        coords=coords+offset;
    end
    
    % check whether we are showing abs or relative coordinates
    % if rel, convert to abs
    if handles.Calibration.window.calibrated==1
        coords=convertRelAbs(varargin{1},coords); % abs to rel
    else
        % do nothing
    end    
end



switch 2
    case 1 % first order solution
        %%% Enable computer control
        msg='EX JOYSTICK OFF';
        fprintf(handles.s,msg);
        Trajectory.Joystick=0;               
        
        %%% Sent abs coordinates and execute move
        setMotorPosition(handles.s,coords)
        
        %%% Wait until position is reached!!!
        % or not and push go upon arrival
        
        %%% Enable joystick control
        msg='EX JOYSTICK ON';
        fprintf(handles.s,msg);
        Trajectory.Joystick=1;
        
    case 2 % second order solution
        if Trajectory.running==0
            %if Trajectory.nCoords>0
                Trajectory.target_index=1;
                Trajectory.target_coord=coords; % just one coord, make sure trajectory coords are not being used when arriving at position 
                Trajectory.nCoords=1;
                Trajectory.running=1;
                Trajectory.moving=0;
                Trajectory.Joystick=1;
                Trajectory.max_velocities=read_max_velocity(handles.s);
                Trajectory.track_velocities=[1 1 1]*0.003;
                Trajectory.default_velocities=[.2 .2 .2];
                Trajectory.abort=0;
                Trajectory.finished=0;
                Trajectory.button_handle=H;
                Trajectory.default_string='GO';
                
                %%% give time indication
                if Trajectory.nCoords==2
                    T=sum(abs(diff(Trajectory.coords_matrix)./Trajectory.track_velocities));
                    fprintf('Estimated duration %3.2f\n',T)
                end
                
                set(H,'String','Abort?')
            %else
            %    disp('No coordinates loaded...')
            %end
        else
            Trajectory.abort=1;
        end
end

%%% Save stuff to handles
handles.Trajectory=Trajectory;
guidata(H,handles)
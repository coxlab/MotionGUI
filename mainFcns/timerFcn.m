function timerFcn(varargin)
%tic
global state
try
    hTimer=varargin{1};
    userData=get(hTimer,'Userdata');
    H=userData.hFig;
    handles=guidata(H);
    
    %%% Load trajectory data
    Trajectory=handles.Trajectory;
    %handles.coords=Trajectory.target_coord;
    %target=Trajectory.target_coord;
    
    % get position in absolute coordinates
    %raw_coords=getMotorPosition(handles.s);
    interface=handles.interface;
    interface.getPos();
    raw_coords=interface.cur_coords;
    %Trajectory.target_coord
        
    if handles.ccd2p % add offset camera vs 2p
        %% BV20150416: incorporated known offset between centers of camera and 2p fields
        %offset=[0.4724   -0.3665   -0.0488]; % in mm.
        %raw_coords=raw_coords-offset;
    end
        
    % convert to window centered coordinates, if defined
    if handles.Calibration.window.calibrated==1
        plot_coords=raw_coords-[0 0 handles.Calibration.window.Z_offset];
        %coords=raw_coords-[handles.Calibration.window.center_coords handles.Calibration.window.Z_offset];
        coords=convertAbsRel(userData.hFig,raw_coords);
    else
        plot_coords=raw_coords;
        coords=raw_coords;
    end
    %distance=calc_dist([handles.coords(1:2) coords(1:2)]);
    
%     if handles.ccd2p % add offset camera vs 2p
%         %% BV20150416: incorporated known offset between centers of camera and 2p fields
%         offset=[0.4724   -0.3665   -0.0488]; % in mm.        
%         %handles.coords
%         %coords
%         distance=abs(sum(diff([handles.coords; coords])));
%     else
%         distance=abs(sum(diff([handles.coords; coords])));
%     end
%     
        
    %BV20150304 make sure scanimage has the coords, even if it started later
    
    if ~isempty(state) && isfield(state,'init') && ~isfield(state.init,'xyz')
        state.init.xyz.coords=coords;
        disp('coords sent to scanimage')
    end
    
    %BV20150304 show z-bar in red when objective is not where it is
    %supposed to be
    if ~isempty(state) && isfield(state,'init') && isfield(state.init,'PI') && isfield(state.init.PI,'hitting') % indicate position of objective is compromised
        if state.init.PI.hitting==1
            set(handles.plot_handles(2).p(1),'faceColor','r')           
        else
            set(handles.plot_handles(2).p(1),'faceColor','b')
        end
    end
       
    %distance=abs(sum(diff([target; coords])));
    %[interface.cur_coords ; interface.target_coords]
    distance=abs(sum(diff([interface.cur_coords ; interface.target_coords])));

    

    %[handles.coords;coords]    
    if distance>.000001 % update coord on position chance        
        %%% Move position indicator on x-y plot
        set(handles.plot_handles(1).p(6).h,'Xdata',plot_coords(1),'Ydata',plot_coords(2))
        set(handles.plot_handles(2).p(1),'Ydata',coords(3))
        set(handles.plot_handles(2).p(2),'String',sprintf('%3.4f',coords(3)))
        
        string=sprintf('X=%03.4f ; Y=%03.4f ; Z=%03.4f',coords);
        set(handles.hEdit02,'String',string)
        
        handles.coords=coords;
        if isfield(state,'init')
            state.init.xyz.coords=coords;
        end
    end        
    
    %Trajectory
    %interface    
    % are we running a trajectory?    
    if Trajectory.running==1
        if Trajectory.Joystick==1
            interface.toggleJoystick('OFF')
            %%% Enable computer control
            %msg='EX JOYSTICK OFF';
            %fprintf(handles.s,msg);
            Trajectory.Joystick=interface.joystick;
        end
              
        %target=Trajectory.target_coord-[0 0 handles.Calibration.window.Z_offset];
        %target=Trajectory.target_coord-[handles.Calibration.window.center_coords handles.Calibration.window.Z_offset];
        if handles.Calibration.window.calibrated==1 %BV20150302 made conform to the conversion scripts
            %target=convertAbsRel(H,Trajectory.target_coord); % abs to rel            
        else
            %target=Trajectory.target_coord;
        end
                
        if Trajectory.moving==0
            % handles velocities
            
            if Trajectory.target_index==1
                % go max velocity
                interface.set_velocities(Trajectory.max_velocities)
                %set_velocity(handles.s,Trajectory.max_velocities)
            else
                % go according to set speed
                %set_velocity(handles.s,Trajectory.track_velocities)
                interface.set_velocities(Trajectory.track_velocities)
                
                %%% Take time stamp as we arrive at first position and move
                %%% to second
                %if Trajectory.target_index==2
                    % record total duration of track
                %    Trajectory.start_time=clock;
                %end
            end            
            
            % go to next target position
            %setMotorPosition(handles.s,Trajectory.target_coord);
            interface.target_coords=Trajectory.target_coord
            interface.setPos();           
            
            % indicate motors are moving and we need to check for arrival
            % at target
            Trajectory.moving=1;
        end
                
        if Trajectory.moving==1
            % check difference between current and target positions            
            
            interface.mockMove() % only for detached mode
            
            if distance<.001                
                Trajectory.moving=0;
                
                if Trajectory.target_index<Trajectory.nCoords
                    % switch to next target
                    %Trajectory.target_index=Trajectory.target_index+1;
                    %Trajectory.target_coord=Trajectory.coords_matrix(Trajectory.target_index,:);
                    Trajectory.target_index=Trajectory.target_index+1;
                    Trajectory.target_coord=Trajectory.coords(Trajectory.target_index).coord;
                else                    
                    Trajectory.finished=1;
                end
            else
                % keep moving
%                distance
            end
            
            % allow abort trajectory, is possible with command to ESP301
            if Trajectory.abort==1
                Trajectory.finished=1;
                %stopMoving(handles.s)
                interface.stop()
            end
            
            % check whether running trajectory is finished, replacing the obnocious
            % while loop            
            if Trajectory.finished==1
                %Trajectory.start_time=clock;
                %etime(clock,Trajectory.start_time)
                
                if Trajectory.abort==1
                    disp('Trajectory aborted by user')
                    Trajectory.abort=0;
                    pause(1)
                else
                    %disp('Trajectory completed')
                end
                
                % turn running flag off when last coord is reached
                Trajectory.running=0;
                Trajectory.moving=0;
                
                % switch button text back
                %set(Trajectory.button_handle,'String','Start Trajectory')
                set(Trajectory.button_handle,'String',Trajectory.default_string)
                
                %%% Enable joystick control
                %msg='EX JOYSTICK ON';
                %fprintf(handles.s,msg);
                interface.toggleJoystick('ON')
                Trajectory.Joystick=1;
                
                % reset velocities
                %set_velocity(handles.s,Trajectory.default_velocities)
                interface.set_velocities(Trajectory.default_velocities)
            end
        end
    end    
    handles.Trajectory=Trajectory;
catch
    rethrow(lasterror)
    A=lasterror;
    disp(A.message)
end
guidata(H,handles)
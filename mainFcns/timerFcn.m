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
    %interface
    
    %[handles.coords;coords]
    %%% Update position on gui
    if interface.update_position==1
        handles.coords=coords;
        if isfield(state,'init')
            state.init.xyz.coords=coords;
        end
    end
    
    %Trajectory
    %interface
    % are we running a trajectory?
    % this could be replaced by all methods
    % trajectory will have a run method, which will be called upon button
    % press
    % in this fcn timerFcn we check whether is still running using the is_running method
    % also check is_paused to see if user paused the trajectory
    % also check is_aborted to see if user interrupted the trajectory
    % this will be done separately for each trajectory object
    
    switch 2
        case 1
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
                    interface.target_coords=Trajectory.target_coord;
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
                    if Trajectory.aborted==1
                        Trajectory.finished=1;
                        %stopMoving(handles.s)
                        interface.stop()
                    end
                    
                    % check whether running trajectory is finished, replacing the obnocious
                    % while loop
                    if Trajectory.finished==1
                        %Trajectory.start_time=clock;
                        %etime(clock,Trajectory.start_time)
                        
                        if Trajectory.aborted==1
                            disp('Trajectory aborted by user')
                            Trajectory.aborted=0;
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
        case 2
            
            %%% Handle go2pos moves
            T=handles.T_go2pos;
            
            %[T.is_running interface.motionDone() interface.getDist()>interface.tolerance interface.joystick]
            %[T.is_running interface.is_moving interface.getDist()>interface.tolerance interface.joystick]
                        
            if T.is_running==1
                if interface.motionDone()==1
                    % we are not moving
                    
                    % are we at target?
                    %interface.mockMove() % only for detached mode                    
                    if interface.getDist()>interface.tolerance
                        % no
                        if interface.joystick==1 % initiate
                            interface.joystickOff()
                            pause(.1)
                            disp('Setting coordinates')
                            interface.go2target()                            
                            
                            interface.is_moving=1;
                        end
                    else % clean up
                        % yes
                        
                        T.finish()
                        %interface.is_moving=0;
                        %interface.set_velocities(interface.default_velocities)
                        %interface.joystickOn()
                    end
                    
                else
                    % moving
                    interface.mockMove() % only for detached mode
                end
            else
                %disp('why here')
            end
            
            
            %%% STACK / GRID
            if handles.stack_grid==1
                %%% Handle zStack moves
                T=handles.T_zStack;
            else
                %%% Handle zStack moves
                T=handles.T_grid;
            end
            %handles.ccd2p=1;
            
            %handles.ccd2p
            switch 1
                case 1
                    %[T.is_running interface.motionDone() interface.getDist()>interface.tolerance interface.joystick]
                    %[T.is_running interface.is_moving interface.getDist()>interface.tolerance interface.joystick]
                    
                    %interface.is_moving=0;
                    %T.is_running
                    
                    if T.is_running==1                        
                        if interface.motionDone()==1                            
                            % we are not moving

                            % are we at target?
                            if interface.getDist()>interface.tolerance
                                % no
                                %interface.joystick   
                                interface.is_moving=1;
                                %interface.motionDone()
                            else % clean up
                                % yes
                                %%% execute arbitrary function
                                if handles.ccd2p==1&&handles.stack_grid==2
                                    % take picture
                                    if isempty(handles.ccd01)
                                        fprintf('Taking picture #%03d\n',T.target_index)
                                    else
                                        for vid_nr=1:2
                                            im=getsnapshot(handles.(sprintf('ccd%02d',vid_nr)));
                                            im=rot90(rot90(im));
                                            saveFolder='temp';
                                            saveName=fullfile(saveFolder,sprintf('ccd_%02d_%03d.png',[vid_nr T.target_index]));
                                            savec(saveName)
                                            imwrite(im,saveName)
                                            C_abs=cat(1,T.coords.coord);
                                            C_rel=interface.abs2rel(C_abs);
                                            dlmwrite(fullfile(saveFolder,'abs_coords.txt'),C_abs,'delimiter',';','newline','pc')
                                            dlmwrite(fullfile(saveFolder,'rel_coords.txt'),C_rel,'delimiter',';','newline','pc')
                                            if 0
                                                figure(1)
                                                subplot(1,2,vid_nr)
                                                imshow(im,[])
                                                title(T.target_index)
                                            end
                                        end
                                    end
                                else
                                    % recording scim file, no need to take
                                    % special action, unless we want to
                                    % pause when scim file is getting to
                                    % big...
                                    nFrames=1500;
                                    % check if scanimage is still recording
                                    % and pause if not
                                    
                                    % maybe just linger
                                end
                                                                
                                if T.target_index==T.nCoords
                                    disp('no more coordinates')
                                    T.finish()
                                    toc
                                else % advance to next position                                                                        
                                    
                                    %disp('what now?')
                                    T.target_index=T.target_index+1;
                                    T.target_coord=T.coords(T.target_index).coord;
                                    interface.iStep=0;
                                    %interface.target_coords=T.target_coord;
                                    
                                    %disp('Setting coordinates')
                                    interface.setTarget(T.target_coord)
                                    interface.is_moving=1;
                                                                           
                                    if handles.ccd2p==2 % make sure toggle switch is engaged
                                        upstroke=T.target_coord(3)==T.coords(1).coord(3);
                                        if upstroke==0                                           
                                            interface.track_speed=.01; % change this manually to get a good sampling of the stack
                                            interface.calc_velocities() % get velocities for each axis separately                                            
                                            fprintf('ETA: ~%3.2f seconds.\n',interface.track_time)
                                            interface.set_velocities(interface.track_velocities)
                                        else % given a 3D grid, we move back to the surface at max speed
                                            interface.set_velocities(interface.max_velocities)
                                        end
                                    else % in 2D grid, move fast all the time
                                        interface.set_velocities(interface.max_velocities)
                                    end
                                    
                                    %%% Move!
                                    interface.go2target()
                                    tic
                                end
                            end
                        else
                            % moving
                            interface.mockMove() % only for detached mode
                        end
                    end
                    
                case 2
                    if T.is_moving
                        interface.joystickOff()
                        interface.set_velocities(interface.max_velocities)
                        %interface.setVelocties(interface.max_velocities)
                        interface.mockMove() % only for detached mode
                        
                        if interface.getDist()<interface.tolerance
                            if T.target_index<T.nCoords
                                T.target_index=T.target_index+1;
                                T.target_coord=T.coords(T.target_index).coord;
                                interface.iStep=0;
                                
                                interface.target_coords=T.target_coord;
                                
                                interface.calc_velocities() % get velocities for each axis separately
                                interface.set_velocities(interface.track_velocities)
                            else
                                T.finish()
                            end
                        end
                        interface.set_velocities(interface.default_velocities)
                        pause(1)
                        interface.joystickOn()
                    end
            end
    end
    handles.Trajectory=Trajectory;
catch
    rethrow(lasterror)
    A=lasterror;
    disp(A.message)
end

interface.getStatus();
%interface.joystickOn()
%interface.getErrorMsg()

update_gui(H)
guidata(H,handles)
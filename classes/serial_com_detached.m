classdef serial_com_detached < handle
    
    properties
        name='';
        s=[];
        status=[];
        connected=0;
        conn_str='';
        deconn_str='';
        H=[];
        
        max_velocities=[]; % max possible
        default_velocities=[]; % nice average
        track_velocities=[]; % placeholder for calculated coords
        track_speed=[];
        cur_velocities=[]; % used for current/next move
        is_moving=[];
        
        joystick=0;
        
        cur_coords=[];
        last_coords=[];
        target_coords=[];
        distance=[];
        tolerance=1e-5;
        update_position=1;
        
        iStep=[];
        nStep=[];
        do_update=0;
    end
    
    methods
        
        %%% Constructor
        function self=serial_com_detached(varargin)
            self.name='detached';
            if nargin>=1
                self.H=varargin{1};
            else
                self.H=gcf;
            end
            
            self.max_velocities=[.4 .4 .4];
            self.cur_velocities=[0 0 0];
            self.default_velocities=[.2 .2 .2];
            self.conn_str='Detached';
            self.deconn_str='Not connected';
        end
        
        %%% Open
        function open(varargin)
            self=varargin{1};
            
            self.getPos();
            self.status=0;
            self.target_coords=[0 0 0];
            self.track_speed=.1;
            self.connected=1;
            self.do_update=1;
            self.is_moving=0;
        end
        
        %%% Get position
        function getPos(varargin)
            %varargin
            self=varargin{1};
            
            handles=guidata(self.H);
            h_xy=handles.plot_handles(1).p(6).h;
            h_z=handles.plot_handles(2).p(1);
            
            %%% Hacky way of getting to current actual stage positions,
            %%% read it from the GUI since we have no access to the ESP301
            %%% motion controller.
            window=handles.Calibration.window;
            coords=[get(h_xy,'Xdata') get(h_xy,'Ydata') get(h_z,'Ydata')];
            %if window.calibrated==1
            %    self.cur_coords=coords+[window.center_coords*0 window.Z_offset];
            %else
                self.cur_coords=coords;
            %end
            
            %%% Only update position on GUI once
            self.distance=self.getDistMoved();
            if self.distance>self.tolerance
                self.update_position=1;
                self.do_update=1;
                self.last_coords=self.cur_coords;
            end
        end
        
        %%% Toggle joystick dummy
        function toggleJoystick(varargin)
            self=varargin{1};
            self.joystick=0;
            return
        end
        
        function joystickOn(varargin)
            self=varargin{1};
            self.joystick=1;
            return
        end
                
        function joystickOff(varargin)
            self=varargin{1};
            self.joystick=0;
            return
        end
        
        %%% calc and set velocities
        function calc_velocities(varargin)
            self=varargin{1};
            distances=diff([self.cur_coords;self.target_coords]);
            self.track_velocities=abs(distances./self.getDist()*self.track_speed);
            %self.track_velocities
        end
        
        function set_velocities(varargin)
            self=varargin{1};
            self.cur_velocities=varargin{2};
            %velocity=varargin{2};            
        end
        
        
        %%% Set position
        function setTarget(varargin)
            self=varargin{1};
            if nargin>=2
                self.target_coords=varargin{2};    
            end            
        end
        
        function go2target(varargin)
            self=varargin{1};
            self.iStep=0;
            self.nStep=20;
        end
        
        
        function d=getDistMoved(varargin)
            self=varargin{1};
            d=sqrt(sum(diff([self.cur_coords; self.last_coords]).^2));
        end
        
        function d=getDist(varargin)
            self=varargin{1};
            d=sqrt(sum(diff([self.cur_coords; self.target_coords]).^2));
        end
        
        %%% Build trajectory
        
        
        %%% Mock move
        function mockMove(varargin)
            self=varargin{1};
            %self.target_coords
                        
            %%% move gently for current position to another
            factor=self.iStep/self.nStep;
            distance_vector=diff([self.cur_coords ; self.target_coords])*factor;
            
            handles=guidata(self.H);
            
            h_xy=handles.plot_handles(1).p(6).h;
            set(h_xy,'Xdata',self.cur_coords(1)+distance_vector(1),'Ydata',self.cur_coords(2)+distance_vector(2))
            
            h_z=handles.plot_handles(2).p(1);
            set(h_z,'Ydata',self.cur_coords(3)+distance_vector(3));
            
            self.iStep=self.iStep+1;
            
            if self.getDist()<self.tolerance
                self.is_moving=0;
            end
            %self.iStep
        end
        
        %%% STOP
        function stop(varargin)
            disp('Stopping motion...')
            return
            %self=varargin{1};
            %msg='ST';
            %self.send(msg);
        end
        
        function done=motionDone(varargin)
            self=varargin{1};
            if self.is_moving==0
                done=1;
            else
                done=0;
            end
        end
        
        function status=getStatus(varargin)
            self=varargin{1};
            status=[0 0 0 0 1 0 1 0];
            self.status=status;
        end
        
    end
    
end
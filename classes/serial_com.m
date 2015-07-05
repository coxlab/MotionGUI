classdef serial_com < handle
    
    properties
        s=[];
        %H=[];
        %joystick=0;
        %coords=[0 0 0];
        connected=0;
        conn_str='';
        deconn_str='';
        name='';
        H=[];
        
        max_velocities=[]; % max possible
        default_velocities=[]; % nice average
        track_velocities=[]; % placeholder for calculated coords
        cur_velocities=[]; % used for current/next move
        
        joystick=0;
        cur_coords=[];
        last_coords=[];
        target_coords=[];
        distance=[];
        tolerance=1e-7;
        update_position=1;
        iStep=[];
        nStep=[];
        do_update=0;
    end
    
    methods
        %%% Constructor
        function self=serial_com(varargin)
            %varargin
            self.H=varargin{1};
            comport=varargin{2};
            
            self.s=serial(comport);
            self.s.name='ESP301';
            self.s.BaudRate=921600;
            self.s.FlowControl='software';
            self.s.Terminator='CR/LF';
            self.s.Timeout=2;
            
            self.conn_str='Connected';
            self.deconn_str='Disconnected';
                         
            self.get_max_velocities()
            self.cur_velocities=[0 0 0];
            self.default_velocities=[.2 .2 .2];            
        end
        
        %%% Open
        function open(varargin)
            self=varargin{1};
            
            %%% Open serial connection to ESP301
            fopen(self.s)
            get(self.s)
            
            self.target_coords=[0 0 0];            
            self.getPos(); % Update position
            self.connected=1;
            self.do_update=1;
        end
        
        %%% Wrapper for fprintf, in case we need extra security
        function send(varargin)
            self=varargin{1};
            msg=varargin{2};
            fprintf(self.s,msg);
        end
        
        %%% Joystick
        function toggleJoystick(varargin)
            self=varargin{1};
            target_state=varargin{2};
            switch target_state
                case 'ON'
                    msg='EX JOYSTICK ON';
                    cur_state=1;
                case 'OFF'
                    msg='EX JOYSTICK OFF';
                    cur_state=0;
                case 'TOGGLE'
                    if self.joystick==0
                        msg='EX JOYSTICK ON';
                        cur_state=1;
                    else
                        msg='EX JOYSTICK OFF';
                        cur_state=0;
                    end
            end
            self.send(msg)
            self.joystick=cur_state;
        end
        
        function joystickOn(varargin)
            self=varargin{1};
            msg='EX JOYSTICK ON';
            self.send(msg)
            self.joystick=1;
            return
        end
        
        function joystickOff(varargin)
            self=varargin{1};
            msg='EX JOYSTICK OFF';
            self.send(msg)
            self.joystick=0;
            return
        end
        
        %%% get current position
        function getPos(varargin)
            self=varargin{1};
            coords=zeros(1,3);
            for iAxis=1:3
                msg=sprintf('%02dTP',iAxis);
                self.send(msg)
                coords(iAxis)=fscanf(self.s,'%f');
            end
            self.cur_coords=coords;
            
            %%% Only update position on GUI once
            self.distance=self.getDistMoved();
            if self.distance>self.tolerance
                self.update_position=1;
                self.do_update=1;
                self.last_coords=self.cur_coords;
            end
        end
                        
        %%% get,calc and set velocities
        function get_max_velocities(varargin)
            self=varargin{1};
            velocities=zeros(1,3);
            for iAxis=1:3
                msg=sprintf('%02dVU?',iAxis);
                self.send(msg);
                if strfind(msg,'?')
                    a=str2double(fscanf(self.s,'%c'));
                    velocities(iAxis)=a;
                end
            end
            self.max_velocities=velocities;
        end
                
        function calc_velocities(varargin)
            self=varargin{1};
            distances=diff([self.cur_coords;self.target_coords]);
            self.track_velocities=abs(distances./self.getDist()*self.track_speed);
            %self.track_velocities
        end
        
        function set_velocities(varargin)
            self=varargin{1};
            velocities=varargin{2};
            msg=sprintf('01VA%3.4f;02VA%3.4f;03VA%3.4f',velocities);
            self.send(msg)
        end
        
        %%% Set position
        function setPos(varargin)            
            self=varargin{1};
            if nargin>=2
                self.target_coords=varargin{2};            
            end
            switch 2
                case 1
                    msg=sprintf('01PA%3.4f;02PA%3.4f;03PA%3.4f',self.target_coords);
                    self.send(msg)
                case 2
                    for iMot=1:3
                        msg=sprintf('%02dPA%3.4f;',[iMot self.target_coords(iMot)]);
                        self.send(msg)
                    end
            end
            %self.iStep=0;
            %self.nStep=20;
        end
        
        %%% mockmove dummy
        function mockMove(varargin)            
        end
        
        %%% Distance functions
        function d=getDistMoved(varargin)
            self=varargin{1};
            d=sqrt(sum(diff([self.cur_coords; self.last_coords]).^2));
        end
        
        function d=getDist(varargin)
            self=varargin{1};
            d=sqrt(sum(diff([self.cur_coords; self.target_coords]).^2));
        end
        
        
        
        %%% STOP
        function stop(varargin)
            self=varargin{1};
            msg='ST';
            self.send(msg);
        end
        
        
        
    end
end
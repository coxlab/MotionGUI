classdef serial_com < handle
    
    properties
        s=[];
        %H=[];
        %joystick=0;
        %coords=[0 0 0];
        status=[];
        connected=0;
        conn_str='';
        deconn_str='';
        name='';
        H=[];
        
        max_velocities=[]; % max possible
        default_velocities=[]; % nice average
        track_velocities=[]; % placeholder for calculated coords
        track_time=[];
        track_speed=[];
        cur_velocities=[]; % used for current/next move
        stages_moving=[];
        is_moving=[]; % dummy variable to make code run, not used in real version of the code
        
        joystick=0;
        cur_coords=[];
        last_coords=[];
        plot_coords=[];
        disp_coords=[];
        target_coords=[];
        
        distance=[];
        tolerance=1e-4;
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
        end
        
        %%% Open
        function open(varargin)
            self=varargin{1};
            
            %%% Open serial connection to ESP301
            fopen(self.s)
            %get(self.s)
            
            self.get_max_velocities()
            self.cur_velocities=[0 0 0];
            self.default_velocities=[.2 .2 .2];
            self.stages_moving=[0 0 0];
            self.track_speed=.01;
            
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
        
        function str=readString(varargin)
           self=varargin{1};  
           if nargin>=2
               format=varargin{2};
           else
               format='%f';
           end
           if get(self.s,'BytesAvailable')>0
               str=fscanf(self.s,format);
           else
               str='';
           end
        end
        
        function joystickOn(varargin)
            self=varargin{1};
            
%             self.getMoving()
%             if any(self.stages_moving)
%                 disp('Stage are still running..')
            if self.motionDone()
                msg='EX JOYSTICK ON';
                self.send(msg)
                self.joystick=1;
            end                                    
        end
        
        function joystickOff(varargin)
            self=varargin{1};
            if self.motionDone()
                msg='EX JOYSTICK OFF';
                self.send(msg)
                self.joystick=0;
            end
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
            self.correctCoords()
            
            %%% Only update position on GUI once
            self.distance=self.getDistMoved();
            if self.distance>self.tolerance
                self.update_position=1;
                self.do_update=1;
                self.last_coords=self.cur_coords;
            end
        end
        
        function correctCoords(varargin)
            self=varargin{1};
            handles=guidata(self.H);
            window=handles.Calibration.window;
            if window.calibrated==1                
                self.plot_coords=self.cur_coords-[0 0 window.Z_offset];
                self.disp_coords=self.cur_coords-[window.center_coords window.Z_offset];
            else
                self.plot_coords=self.cur_coords;
                self.disp_coords=self.cur_coords;
            end
        end
        
        function coords=rel2abs(varargin)
            self=varargin{1};
            coords_read=varargin{2};
            handles=guidata(self.H);
            window=handles.Calibration.window;
            if window.calibrated==1
                N=size(coords_read,1);
                coords=coords_read+repmat([window.center_coords window.Z_offset],N,1);
            else
                coords=coords_read;
            end
        end
        
        function coords=abs2rel(varargin)
            self=varargin{1};
            coords_read=varargin{2};
            handles=guidata(self.H);
            window=handles.Calibration.window;
            if window.calibrated==1
                N=size(coords_read,1);
                coords=coords_read-repmat([window.center_coords window.Z_offset],N,1);
            else
                coords=coords_read;                
            end
        end
        
        function getMoving(varargin)
            self=varargin{1};
            moving=zeros(1,3);
            for iAxis=1:3
                msg=sprintf('%02dMD',iAxis);
                self.send(msg)
                moving(iAxis)=fscanf(self.s,'%f');
            end
            %%% MD stands for Motion Done, so 1 when stopped
            self.stages_moving=moving==0;
        end
        
        function done=motionDone(varargin)
            self=varargin{1};
            self.getMoving()
            if any(self.stages_moving)
                %disp('Stage are still running..')
                done=0;
            else
                done=1;
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
            if any(distances)
                self.track_time=self.getDist()/self.track_speed;                                
                self.track_velocities=abs(distances./self.getDist()*self.track_speed);                
            end                        
            
            %self.track_velocities
        end
        
        function set_velocities(varargin)
            self=varargin{1};
            velocities=varargin{2};
            msg=sprintf('01VA%3.4f;02VA%3.4f;03VA%3.4f',velocities);
            self.send(msg)
        end
        
        %%% Set position
        function setTarget(varargin)
            self=varargin{1};
            if nargin>=2
                self.target_coords=varargin{2};
            else
                disp('empty coords, nothing changed...')
            end
        end
        
        function go2target(varargin)
            self=varargin{1};
            msg=sprintf('01PA%3.4f;02PA%3.4f;03PA%3.4f',self.target_coords);
            self.send(msg)
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
            %[self.cur_coords; self.target_coords]
            d=sqrt(sum(diff([self.cur_coords; self.target_coords]).^2));
        end
        
        
        
        %%% STOP
        function stop(varargin)
            self=varargin{1};
            msg='ST';
            self.send(msg);
        end
        
        function status=getStatus(varargin)
            self=varargin{1};
            msg='TS'; % PH for hardware status
            self.send(msg);
            status=fscanf(self.s,'%c');
            self.status=dec2binvec(double(status(1)),8);
        end
        
        %%% Error handling
        function getErrorMsg(varargin)
            self=varargin{1}; 
            msg='TE'; % TB for msg
            self.send(msg);
            err=self.readString();
            if err~=0
                msg='TB';
                self.send(msg);
                msg=self.readString('%s');
                disp(msg)
            end
        end               
    end
end
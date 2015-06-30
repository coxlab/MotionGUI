classdef serial_com < handle
    
    properties
        s=[];
        %H=[];
        %joystick=0;
        %coords=[0 0 0];
        
        name='';
        H=[];
        max_velocities=[];
        joystick=0;
        cur_coords=[];
        target_coords=[];
        iStep=[];
        nStep=[];
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
        end
        
        %%% Open
        function open(varargin)
            self=varargin{1};
            
            fopen(self.s)
            self.getPos();
            handles=guidata(self.H);
            set(handles.hEdit01,'String','Connected')
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
        
        %%% getpos
        function getPos(varargin)
            self=varargin{1};
            coords=zeros(1,3);
            for iAxis=1:3
                msg=sprintf('%02dTP',iAxis);
                self.send(msg)
                coords(iAxis)=fscanf(self.s,'%f');
            end    
            self.cur_coords=coords;            
        end
                        
        %%% set_velocities
        function set_velocities(varargin)
            self=varargin{1};
            velocity=varargin{2};
            msg=sprintf('01VA%3.4f;02VA%3.4f;03VA%3.4f',velocity);
            self.send(msg)
            return
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
        
        %%% STOP
        function stop(varargin)
            self=varargin{1};
            msg='ST';
            self.send(msg);
        end
        
        %%% mockmove dummy
        function mockMove(varargin)            
        end
        
    end
end
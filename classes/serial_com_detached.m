classdef serial_com_detached < handle
    
    properties
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
        function self=serial_com_detached(varargin)
            self.name='detached';
            if nargin>=1
                self.H=varargin{1};
            else
                self.H=gcf;
            end
            self.max_velocities=[.4 .4 .4];
        end
        
        %%% Open
        function open(varargin)
            self=varargin{1};
            handles=guidata(self.H);
            set(handles.hEdit01,'String','Detached mode')
        end
        
        %%% Get position
        function getPos(varargin)
            %varargin
            self=varargin{1};
            
            handles=guidata(self.H);
            h_xy=handles.plot_handles(1).p(6).h;
            h_z=handles.plot_handles(2).p(1);
            self.cur_coords=[get(h_xy,'Xdata') get(h_xy,'Ydata') get(h_z,'Ydata')];
        end
        
        %%% Toggle joystick dummy
        function toggleJoystick(varargin)
            self=varargin{1};
            self.joystick=0;
            return
        end
        
        %%% set_velocities
        function set_velocities(varargin)
            %self=varargin{1};
            %velocity=varargin{2};
            return
        end
        
        %%% Set position
        function setPos(varargin)
            self=varargin{1};
            self.target_coords=varargin{2};
            self.iStep=0;
            self.nStep=20;
        end
        
        %%% Build trajectory
        
        
        %%% Mock move
        function mockMove(varargin)
            self=varargin{1};
            %sself.target_coords
            handles=guidata(self.H);
            
            %%% move gently for current position to another
            factor=self.iStep/self.nStep;
            distance_vector=diff([self.cur_coords ; self.target_coords])*factor;
            
            h_xy=handles.plot_handles(1).p(6).h;
            set(h_xy,'Xdata',self.cur_coords(1)+distance_vector(1),'Ydata',self.cur_coords(2)+distance_vector(2))
            
            h_z=handles.plot_handles(2).p(1);
            set(h_z,'Ydata',self.cur_coords(3)+distance_vector(3));
            
            self.iStep=self.iStep+1;
        end
        
        %%% STOP
        function stop(varargin)
            disp('Stopping motion...')
            return
            %self=varargin{1};
            %msg='ST';
            %self.send(msg);
        end
    end
    
end
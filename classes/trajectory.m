classdef trajectory < handle
    % create separate trajectory for nextpos, z-trajectory and grid
    properties
        name='';
        
        coords_blank=struct('coord',[],'laser_power',[]);
        coords=[];
        nCoords=0;
        
        target_index=[];
        target_coord=[];
        
        running=0;
        moving=0;
        paused=0;
        aborted=0;
        finished=0;
        start_time=[];
        
        Joystick=[];
        max_velocities=[];
        track_velocities=[];
        default_velocities=[];
        
        button_handle=[];
        default_string='';
        hFig=[];
        N_field=[];
        
        do_update=0;
    end
    
    
    methods
        %%% Constructor
        function self=trajectory(varargin)
            self.name=varargin{1};
            self.hFig=varargin{2};
            self.N_field=varargin{3};
            self.button_handle=varargin{4};
            
            self.default_string=get(self.button_handle,'string');
            self.coords=self.coords_blank;
        end
        
        %%% Add coord
        function append(varargin)
            %disp('appending...')
            self=varargin{1};
            new_coord=varargin{2};
            if nargin>=3
                laser_power=varargin{3};
            else
                laser_power=0;
            end
            self.nCoords=self.nCoords+1;
            self.coords(self.nCoords).coord=new_coord;
            self.coords(self.nCoords).laser_power=laser_power;
            self.do_update=1;
            %self.update_GUI();
        end
        
        %%% Take vectors and make trajectory
        function batch_add(varargin)
            self=varargin{1};
            new_batch=varargin{2};
            %self.clear()
            
            N=size(new_batch,1);
            self.nCoords=N;
            for iCoord=1:N
                self.coords(iCoord).coord=new_batch(iCoord,1:3);
                self.coords(iCoord).laser_power=new_batch(iCoord,4);
            end
            %cat(1,self.coords.coord)
            self.drawGrid()
            self.do_update=1;
            %self.update_GUI();
        end
        
        %%% Create 2D grid
        function makeGrid(varargin)
            self=varargin{1};
            
            T_zStack=varargin{2};
            if nargin>=3
                shape=varargin{3};
            else
                shape=1; % 1:rect | 2:circle
            end
            
            %self.clear()
            if T_zStack.nCoords==0
                disp('No coords...')
            else
                disp('Creating 2D grid')
                M=cat(1,T_zStack.coords.coord);
                if size(M,1)==2                    
                    FOV_size=[710 946]/1000;
                    overlap_factor=.80;
                    
                    V=FOV_size(1)*overlap_factor;
                    H=FOV_size(2)*overlap_factor;
                    D=abs(diff(M));                    
                    nRows=max([1 ceil(D(2)/V)]);
                    nCols=max([1 ceil(D(1)/H)]);
                    X=linspace(M(1,1),M(2,1),nCols);
                    Y=linspace(M(1,2),M(2,2),nRows);
                    % tilt in AP direction
                    %Z=repmat(linspace(M(1,3),M(2,3),nRows),nCols,1);
                    % tilt in ML direction
                    Z=repmat(linspace(M(1,3),M(2,3),nCols),1,nRows);
                    G_z=Z(:);
                    [G_x,G_y]=meshgrid(X,Y);
                    G_x=G_x';
                    G_y=G_y';
                    %abs([mean(diff(X)) mean(diff(Y))])
                    if shape==1
                        mask=true(size(G_x));
                    elseif shape==2 % circle
                        x=G_x-mean(G_x(:));
                        y=G_y-mean(G_y(:));
                        dist=sqrt(x.^2+y.^2);
                        mask=dist<max([max(x(:)) max(y(:))]);
                        mask=mask(:)==1;
                    end
                    %output=[G_x(:) G_y(:) G_x(:)*0+M(1,3) G_x(:)*0];                    
                    output=[G_x(mask) G_y(mask) G_z(mask) G_x(mask)*0];
                    self.batch_add(output);
                else
                    disp('Makegrid needs exactly 2 coordinates...')
                end
            end
        end
        
        %%% Create 3D grid
        function makeGrid3D(varargin)
            %disp('Under construction')
            
            self=varargin{1};
            
            T_zStack=varargin{2};
            
            %self.clear()
            if T_zStack.nCoords==0
                disp('No coords...')
            else
                disp('Creating 3D grid')
                M=cat(1,T_zStack.coords.coord);
                FOV_size=[336 430]/1000;
                overlap_factor=1.80;
                
                V=FOV_size(1)*overlap_factor;
                H=FOV_size(2)*overlap_factor;
                D=abs(diff(M));
                nRows=ceil(D(2)/V);
                nCols=ceil(D(1)/H);
                X=linspace(M(1,1),M(2,1),nCols)
                Y=linspace(M(1,2),M(2,2),nRows)
                [G_x,G_y]=meshgrid(X,Y);
                G_x=G_x(:);
                G_y=G_y(:);
                
                depth_values=M(:,3);
                depth_values=depth_values(:);
                N=length(G_x(:));
                repeater=repmat(1:N,2,1);
                depth_selector=repmat([1 2],1,N)';
                
                output=[G_x(repeater(:)) G_y(repeater(:)) depth_values(depth_selector(:)) G_x(repeater(:))*0];
                self.batch_add(output);
            end
        end
        
        function drawGrid(varargin)
            self=varargin{1};
            handles=guidata(self.hFig);
            h=handles.plot_handles(1).p(7).h;
            M=cat(1,self.coords.coord);
            if self.nCoords==0
                set(h,'xdata',[],'ydata',[])
            else
                set(h,'xdata',M(:,1),'ydata',M(:,2))
            end
        end
        
        function run(varargin)
            self=varargin{1};
            
            handles=guidata(self.hFig);
            interface=handles.interface;
            
            interface.iStep=0;
            interface.nStep=100;
            interface.set_velocities(interface.max_velocities)            
            
            %%% Set properties
            self.running=1;
            self.moving=0;
            self.paused=0;
            self.aborted=0;
            self.finished=0;
            
            %%% Raise flag to update
            self.do_update=1;
        end
        
        function finish(varargin)
            self=varargin{1};
            disp('Trajectory finished')
            self.stop();
        end
        
        
        function abort(varargin)
            self=varargin{1};
            self.aborted=1;
            self.stop();
        end
        
        function stop(varargin)
            self=varargin{1};
            handles=guidata(self.hFig);
            interface=handles.interface;
            
            if self.aborted==1
                handles=guidata(self.hFig);
                handles.interface.stop()
                
                disp('Aborted by user')
                self.aborted=0;
            end
            
            interface.set_velocities(interface.default_velocities)
            interface.joystickOn()
            
            self.running=0;
            %disp('Not running')
            %self.moving=0;
            self.do_update=1;
        end
        
        function out=run_checks(varargin)
            self=varargin{1};
            out=[self.is_running() self.is_moving()];
            if self.is_aborted()==1
                self.running=0;
            end
        end
        
        function check=is_running(varargin)
            self=varargin{1};
            check=self.running;
        end
        
        function check=is_moving(varargin)
            self=varargin{1};
            check=self.moving;
        end
        
        function check=is_paused(varargin)
            self=varargin{1};
            check=self.paused;
        end
        
        function check=is_aborted(varargin)
            self=varargin{1};
            check=self.aborted;
        end
        
        function check=is_finished(varargin)
            self=varargin{1};
            check=self.finished;
        end
        
        %%% Clear last
        function clear_last(varargin)
            self=varargin{1};
            if self.nCoords>=1
                self.coords(self.nCoords)=[];
                %self.nCoords=self.nCoords-1;
                self.nCoords=length(self.coords);
                self.do_update=1;
                %self.update_GUI();
            else
                disp('No coords to delete')
            end
        end
        
        %%% Clear
        function clear(varargin)
            self=varargin{1};
            self.coords=self.coords_blank;
            self.nCoords=0;
            self.drawGrid()
            self.do_update=1;
        end
        
    end
end
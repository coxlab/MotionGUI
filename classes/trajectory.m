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
        abort=0;
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
            self.update_GUI();
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
            cat(1,self.coords.coord)
            self.drawGrid()
            self.update_GUI();
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
            
            self.clear()
            if T_zStack.nCoords==0
                disp('No coords...')
            else
                disp('Creating 2D grid')
                M=cat(1,T_zStack.coords.coord);
                FOV_size=[700 900]/1000;
                overlap_factor=.80;
                
                
                V=FOV_size(1)*overlap_factor;
                H=FOV_size(2)*overlap_factor;
                D=abs(diff(M));
                nRows=ceil(D(2)/V);
                nCols=ceil(D(1)/H);
                X=linspace(M(1,1),M(2,1),nCols);
                Y=linspace(M(1,2),M(2,2),nRows);
                Z=repmat(linspace(M(1,3),M(2,3),nRows),nCols,1);
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
            end
        end
        
        %%% Create 3D grid
        function makeGrid3D(varargin)
            %disp('Under construction')
            
            self=varargin{1};
                        
            T_zStack=varargin{2};
            
            self.clear()
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
                X=linspace(M(1,1),M(2,1),nCols);
                Y=linspace(M(1,2),M(2,2),nRows);
                [G_x,G_y]=meshgrid(X,Y);
                G_x=G_x';
                G_y=G_y';

                depth_values=M(:,3);
                N=length(G_x(:));
                repeater=repmat(1:N,2,1);
                depth_selector=repmat([1 2],1,N)';
                output=[G_x(repeater(:)) G_y(repeater(:)) depth_values(depth_selector) G_x(repeater(:))*0];
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
        
        %%% Clear last
        function clear_last(varargin)
            self=varargin{1};
            if self.nCoords>=1
                self.coords(self.nCoords)=[];
                self.nCoords=self.nCoords-1;
                self.update_GUI();
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
            self.update_GUI();
        end
        
        %%% Update N
        function update_GUI(varargin)
            disp('update')
            self=varargin{1};
            set(self.N_field,'string',sprintf('N=%d',self.nCoords))
        end
    end
    
end
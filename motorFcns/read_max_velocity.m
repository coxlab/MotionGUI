function varargout=read_max_velocity(varargin)
s=varargin{1};

switch s.name
    case 'ESP301'
        max_velocities=zeros(1,3);
        for iAxis=1:3
            msg=sprintf('%02dVU?',iAxis);
            fprintf(s,msg);
            if strfind(msg,'?')
                a=str2double(fscanf(s,'%c'));
                max_velocities(iAxis)=a;
            end
        end
    case 'detached'
        max_velocities=[.04 .04 .04];
end
varargout{1}=max_velocities;

function varargout=getMotorPosition(varargin)
s=varargin{1};

switch s.name
    case 'ESP301'
        %tic
        switch 1
            case 1
                coords=zeros(1,3);
                for iAxis=1:3
                    msg=sprintf('%02dTP',iAxis);
                    fprintf(s,msg);
                    coords(iAxis)=fscanf(s,'%f');
                end
            case 2
                msg=('01TP;02TP;03TP');
                fprintf(s,msg);
                coords=fscanf(s,'%f');
        end
    case 'detached'
        handles=guidata(s.H);
        h=handles.plot_handles(1).p(6).h;
        coords=[get(h,'Xdata') get(h,'Ydata') 0];
end
%toc
varargout{1}=coords;


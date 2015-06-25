function varargout=read_velocity(varargin)
s=varargin{1};
% msg='01VA?';
% fprintf(s,msg);
% varargout{1}=str2double(fscanf(s,'%c'));

velocities=zeros(1,3);
for iAxis=1:3    
    msg=sprintf('%02dVA?',iAxis);
    fprintf(s,msg);    
    a=str2double(fscanf(s,'%c'));
    velocities(iAxis)=a;
end
varargout{1}=velocities;
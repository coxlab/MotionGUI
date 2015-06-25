function set_velocity(varargin)
% velocity needs to be 3 values
s=varargin{1};
velocity=varargin{2};
msg=sprintf('01VA%3.4f;02VA%3.4f;03VA%3.4f',velocity);
fprintf(s,msg);

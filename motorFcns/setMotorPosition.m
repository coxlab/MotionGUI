function varargout=setMotorPosition(varargin)
s=varargin{1};
coords_requested=varargin{2};

%%% Move stages to requested position
msg=sprintf('01PA%3.4f;02PA%3.4f;03PA%3.4f',coords_requested);
fprintf(s,msg);

%sprintf('going to X=%03.2f Y=%03.2f Z=%03.2f',coords_requested)

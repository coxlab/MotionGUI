function setVelocity(varargin)

handles=guidata(varargin{1});


axis_vector=[1 2 3];
switch 3    % low velocties of joystick
    case 0 % default
        velocities_low=[.08 .08 .05];
    case 1 % typical
        velocities_low=[.05 .05 .02];
    case 2 % super slow
        velocities_low=[.001 .001 .001];
    case 3 % less super slow
        velocities_low=[.001 .001 .001]*3;        
end

switch 0 % high velocities of joystick
    case 0
        velocities_high=[.2 .2 .1];
end

switch 2
    case 1                
        msg=sprintf('%02dJW%3.3f;',[axis_vector; velocities_low]);
        fprintf(handles.s,msg);
        %msg=sprintf('%02dJH%3.3f;',[axis_vector; velocities_high]);
        %fprintf(handles.s,msg);
        
    case 2
        interface=handles.interface;
        interface.set_velocities_low(velocities_low)
        velocities_low
end
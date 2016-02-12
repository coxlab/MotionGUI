function Remote_adjust_laser_power(varargin)
global state gh

if nargin>=1&&~isempty(varargin{1})
    laser_power=varargin{1};
else
    laser_power=1;
end

if nargin>=2&&~isempty(varargin{2})
    beam=varargin{2};
else
    beam=2;
end

if state.init.eom.maxPower(beam)~=laser_power
    set(gh.powerControl.maxPower_Slider,'Value',laser_power)
    state.init.eom.maxPowerDisplaySlider=laser_power;
    state.init.eom.maxPower(beam)=laser_power;
    
    state.init.eom.maxPowerDisplaySlider = state.init.eom.maxPower(beam);
    set(gh.powerControl.maxPowerText,'String',num2str(laser_power))
    updateGUIByGlobal('state.init.eom.maxPowerDisplaySlider');
    
    %%% Send actual command to NIDAQ
    state.init.eom.(['hAOPark' num2str(beam)]).writeAnalogData(state.init.eom.lut(beam,laser_power),1,true); %VI122909A\B
end
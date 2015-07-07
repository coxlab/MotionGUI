% This gui will create trajectories based on coordinates grabbed from the
% ESP-301 controller when user clicks the 'grab coordinate' button.
% Based on the state of a toggle switch one of two modes will be used.
% 1 continuous mode: will create continuous linear (equal velocity) trajectory from one point to
% another.
% 2 discrete mode: will create longer stops going from one of n intermediate positions
% between two or more set coordinates. These will allow the use of
% averaging to create smoother images. Both n-steps and dwell time can be
% specified.
% To get cleaner images, the shutter will be closed before and after motor
% movements and, for mode 2, when moving from one step to the next.

% New features list:
% - separate pause button
% - allow function to pause trajectory and execute arbitrary code
% - make display and target coord a separate box, with copy function to
% grab current coordinate
% - change velocities with parameter selection
% - plot image on bg of trace, might need rainbow marker
% - plot current and past FOVs
% - make grid button show dialogue where properties can be selected: 2d or
% 3d and rect vs. circle
% - make easy conversion for mm to pixel space
% add update gui function to sync objects to GUI and vice versa, take all
% reference to the GUI out of the class definitions

% ways to tackle no coord update issue (in order of feasibility)
% - do nothing, and hope issue resolved itself
% - check properties of serial object: are we using the right baudrate and
% such?
% - add callback to coord-box, already implemented, does this work?
% - add separate current coord and target coord boxes. no interplay between
% showing and setting
% - ...



%clear all
delete(instrfindall)
delete(timerfind)
delete(imaqfind)
clc


%% create main fig
hFig=figure(3);
set(hFig,'Name','Create motion trajectories','NumberTitle','Off','MenuBar','None','Position',[824    50   444   436],'Resize','On');
%WinOnTop(hFig,true);

%%% Add subfolders
path_dir=fileparts(mfilename('fullpath'));
addpath(genpath(path_dir))

%% Variables
comport = 'COM5';
timerPeriod=0.050; % in seconds

%%

clf
hPanel_main=uipanel(hFig,'Position',[.03 .03 .94 .94]);
hPanel_axis=uipanel(hPanel_main,'Position',[.03 .26 .94 .70]);
hPanel_buttons=uipanel(hPanel_main,'Position',[.03 .03 .94 .20]);


range_X_translation=[0 13];
range_Y_translation=[0 13];
coordinate_system.rect=[range_X_translation(1) range_Y_translation(1) range_Y_translation(2) range_Y_translation(2)];
coordinate_system.center_coords=coordinate_system.rect([3 4])/2;
headplate=struct('calibrated',1,'center_coords',[9.4639 7.1563],'radius',12/2);
window_reset=struct('calibrated',0,'coords',zeros(5,3),'Z_offset',0,'coords_collected',zeros(5,1),'show_AP',0,'show_ML',0);


calibration_folder=fullfile(path_dir,'calibrations');
Calibration=struct('coordinate_system',coordinate_system,'headplate',headplate,'window',window_reset,'window_reset',window_reset);
%Trajectory=struct('coords_matrix',[],'nCoords',0,'target_coord',0,'target_index',0,'velocity',0,'running',0);

handles=struct('hFig',hFig,'hPanel_axis',hPanel_axis,'comport',comport,'coords',[0 0 0],'mode',0,'velocity',[],'nSteps',0,'dwell_time',1,'s',[],'current_config',0,'ccd2p',0,'calibration_folder',calibration_folder);
handles.Calibration=Calibration;
%handles.Trajectory=Trajectory;
handles.coords=[0 0 0];

%%% Add video capture capabilities
if ismac
    handles.ccd01=[];
    handles.ccd02=[];
else
    highres=0;
    if highres==0
        %vid = videoinput('winvideo', 1, 'Y800_1280x960');
        vid = videoinput('winvideo', 2, 'Y16 _1024x768');
    else
        vid = videoinput('winvideo', 2, 'Y16 _2592x1944');
    end
    %src = getselectedsource(vid);
    handles.ccd01=vid;
    
    if highres==0
        %vid = videoinput('winvideo', 1, 'Y800_1280x960');
        vid = videoinput('winvideo', 3, 'Y16 _1024x768');
    else
        vid = videoinput('winvideo', 3, 'Y16 _2592x1944');
    end
    %src = getselectedsource(vid);
    handles.ccd02=vid;
end




%%% Create timer
hTimer=timer('Name','TrajectoryTimer','Period',timerPeriod,'ExecutionMode','FixedSpacing','TimerFcn',@timerFcn,'userdata',handles);
handles.hTimer=hTimer;

button_width=.15;
button_height=.25;
button_init=.03;
button_spacing_left=button_width+button_init;
button_spacing_up=button_height+button_init;
hBut01=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Connect','Units','Normalized','Position',[button_init button_init button_width button_height],'Callback',@openConnection);
hBut02=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Disconnect','Units','Normalized','Position',[button_init+button_spacing_left button_init button_width button_height],'Callback',@closeConnection);

hBut03=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Start timer','Units','Normalized','Position',[button_init+2*button_spacing_left button_init button_width button_height],'Callback',@startTimer);
hBut04=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Stop timer','Units','Normalized','Position',[button_init+3*button_spacing_left button_init button_width button_height],'Callback',@stopTimer);
hBut05=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Grab Coordinate','Units','Normalized','Position',[button_init button_init+2*button_spacing_up button_width button_height],'Callback',@grabCoordinate);

hBut06=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Remove last','Units','Normalized','Position',[button_init+2*button_spacing_left button_init+2*button_spacing_up button_width button_height],'Callback',@removeLast);
hBut07=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Start Trajectory','Units','Normalized','Position',[button_init+3*button_spacing_left button_init+2*button_spacing_up button_width button_height],'Callback',@runTrajectory);

handles.hEdit01=uicontrol(hPanel_buttons,'Style','Edit','Units','Normalized','Position',[button_init button_init+button_spacing_up button_width button_height],'String','Disconnected');
handles.hEdit02=uicontrol(hPanel_buttons,'Style','Edit','Units','Normalized','Position',[button_init+button_spacing_left button_init+button_spacing_up button_width*3 button_height],'String','Not Running','Callback',@coord_callback);
handles.goButton=uicontrol(hPanel_buttons,'Style','Pushbutton','Units','Normalized','Position',[button_init+button_spacing_left+button_width*3 button_init+button_spacing_up button_width*.4 button_height],'String','GO','Callback',@go2Position);
handles.hEdit03=uicontrol(hPanel_buttons,'Style','Edit','Units','Normalized','Position',[button_init+button_spacing_left button_init+2*button_spacing_up button_width button_height],'String','nCoords=0');

%%% Buttons to easily recalibrate the window positions
hBut_calibrate=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Cal','Units','Normalized','Position',[button_init+4*button_spacing_left button_init+2*button_spacing_up button_width/3 button_height],'Callback',{@switchButtons,'Calibrate'});
hBut_moveStack=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Mov','Units','Normalized','Position',[button_init+4.6*button_spacing_left button_init+2*button_spacing_up button_width/2.5 button_height],'Callback',{@switchButtons,'moveStack'});
hBut_makeGrid=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Grid','Units','Normalized','Position',[button_init+4*button_spacing_left button_init+0*button_spacing_up button_width/2.5 button_height],'Callback',{@switchButtons,'makeGrid'});
hBut_clearGrid=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Clr','Units','Normalized','Position',[button_init+4.6*button_spacing_left button_init+0*button_spacing_up button_width/2.5 button_height],'Callback',{@switchButtons,'clearGrid'});

% move stack buttons
handles.hBut08a=uicontrol(hPanel_buttons,'Style','Pushbutton','String','^','Units','Normalized','Position',[button_init+4.3*button_spacing_left button_init+2*button_spacing_up button_width/3 button_height],'Callback',{@moveStack,'Anterior'});
handles.hBut09a=uicontrol(hPanel_buttons,'Style','Pushbutton','String','v','Units','Normalized','Position',[button_init+4.3*button_spacing_left button_init+0*button_spacing_up button_width/3 button_height],'Callback',{@moveStack,'Posterior'});
handles.hBut10a=uicontrol(hPanel_buttons,'Style','Pushbutton','String','<','Units','Normalized','Position',[button_init+4*button_spacing_left button_init+1*button_spacing_up button_width/3 button_height],'Callback',{@moveStack,'Medial'});
handles.hBut11a=uicontrol(hPanel_buttons,'Style','Pushbutton','String','>','Units','Normalized','Position',[button_init+4.6*button_spacing_left button_init+1*button_spacing_up button_width/3 button_height],'Callback',{@moveStack,'Lateral'});
handles.hBut12a=uicontrol(hPanel_buttons,'Style','Pushbutton','String','0','Units','Normalized','Position',[button_init+4.3*button_spacing_left button_init+1*button_spacing_up button_width/3 button_height],'Callback',{@moveStack,'Center'});

% calibration buttons
handles.hBut08b=uicontrol(hPanel_buttons,'Style','Pushbutton','String','A','Units','Normalized','Position',[button_init+4.3*button_spacing_left button_init+2*button_spacing_up button_width/3 button_height],'Callback',{@setWindowCoord,'Anterior'});
handles.hBut09b=uicontrol(hPanel_buttons,'Style','Pushbutton','String','P','Units','Normalized','Position',[button_init+4.3*button_spacing_left button_init+0*button_spacing_up button_width/3 button_height],'Callback',{@setWindowCoord,'Posterior'});
handles.hBut10b=uicontrol(hPanel_buttons,'Style','Pushbutton','String','M','Units','Normalized','Position',[button_init+4*button_spacing_left button_init+1*button_spacing_up button_width/3 button_height],'Callback',{@setWindowCoord,'Medial'});
handles.hBut11b=uicontrol(hPanel_buttons,'Style','Pushbutton','String','L','Units','Normalized','Position',[button_init+4.6*button_spacing_left button_init+1*button_spacing_up button_width/3 button_height],'Callback',{@setWindowCoord,'Lateral'});
handles.hBut12b=uicontrol(hPanel_buttons,'Style','Pushbutton','String','C','Units','Normalized','Position',[button_init+4.3*button_spacing_left button_init+1*button_spacing_up button_width/3 button_height],'Callback',{@setWindowCoord,'Center'});

hBut13=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Save','Units','Normalized','Position',[button_init+5*button_spacing_left button_init+2*button_spacing_up button_width/2 button_height],'Callback',{@config_file,'save'});
hBut14=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Load','Units','Normalized','Position',[button_init+5*button_spacing_left button_init+1*button_spacing_up button_width/2 button_height],'Callback',{@config_file,'load'});
hBut15=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Joystick','Units','Normalized','Position',[button_init+5*button_spacing_left button_init button_width/2 button_height],'Callback',@toggleJoystick);
hBut16=uicontrol(hPanel_buttons,'Style','Pushbutton','String','Vel','Units','Normalized','Position',[button_init+5*button_spacing_left button_init-1*button_spacing_up button_width/2 button_height],'Callback',@changeVelocities);

%% add button to axis panel
modality = uibuttongroup(hPanel_axis,'Visible','off','Units','Normalized','Position',[.01 .9 .3 .08]);%,'SelectionChangedFcn',@toggle_ccd2p);
r1 = uicontrol(modality,'Style','radiobutton','String','CCD','Units','Normalized','Position',[.1 .1 .5 .5],'HandleVisibility','off');
r2 = uicontrol(modality,'Style','radiobutton','String','2p','Units','Normalized','Position',[.5 .1 .5 .5],'HandleVisibility','off');
modality.Visible = 'on';
%uicontrol(hPanel_axis,'Style','togglebutton','String','CCD/2p','Units','Normalized','Position',[0 .95 .15 .05 ],'Callback',@toggleCCD2p);

handles.stack_grid=1;
handles.T_go2pos=trajectory('nextPos',hFig,handles.hEdit03,handles.goButton);
handles.T_zStack=trajectory('zStack',hFig,handles.hEdit03,hBut07);
handles.T_grid=trajectory('grid',hFig,handles.hEdit03,hBut07);

%%% Use T_go2pos as default Trajectory
handles.Trajectory=handles.T_go2pos;

guidata(hFig,handles)

%%
init_gui(hFig) % init all plot elements, ignorant of current settings






























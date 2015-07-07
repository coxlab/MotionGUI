function config_file(varargin)

handles=guidata(varargin{1});
mode=varargin{3};

current_folder=pwd;
%calibration_folder='C:\Users\labuser\Documents\ben\Matlab\GUIs\MotionGUI\Calibrations';
cd(handles.calibration_folder)
switch lower(mode)
    case 'save'
        [filename, pathname]=uiputfile('*.mat','Save your settings');
        saveName=fullfile(pathname,filename);
        Calibration=handles.Calibration;
        save(saveName,'Calibration')
    case 'load'
        [filename, pathname]=uigetfile('*.mat','Load your settings');
        loadName=fullfile(pathname,filename);
        load(loadName,'Calibration')
        handles.Calibration=Calibration;
        guidata(handles.hFig,handles)
        update_gui(handles.hFig)
end

cd(current_folder)
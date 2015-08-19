function config_file(varargin)

handles=guidata(varargin{1});
mode=varargin{3};

interface=handles.interface;

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
        
        switch filename
            case 'AH02_20150803.mat'
                im_name='C:\Users\labuser\Documents\Repos\MotionGUI\Images\2015-08-10_AH02_resaved_im.png';
            case 'AH03_20150807.mat'
                im_name='C:\Users\labuser\Documents\Repos\MotionGUI\Images\2015-08-10_AH03_im.png';
            case 'AH05_20150814.mat'
                im_name='C:\Users\labuser\Documents\Repos\MotionGUI\Images\2015-08-14_AH05_im.png';
            otherwise
                im_name='C:\Users\labuser\Documents\Repos\MotionGUI\Images\2015-08-14_AH05_im.png';
        end
        bg_im=double(imread(im_name));
        bg_im(:,:,2)=flipud(bg_im(:,:,2));
        bg_im=bg_im./max(bg_im(:));
        set(handles.plot_handles(1).p(1).im,'Cdata',bg_im)
        
        
        interface.do_update=1;
        interface.update_position=1;
        handles.interface=interface;
        guidata(handles.hFig,handles)
        update_gui(handles.hFig)
end

cd(current_folder)
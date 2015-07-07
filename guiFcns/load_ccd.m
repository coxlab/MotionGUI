function load_ccd(varargin)

H=varargin{1};
handles=guidata(H);

delete(imaqfind)
%%% Add video capture capabilities
if ismac
    handles.ccd01=[];
    handles.ccd02=[];
else
    highres=1;
    props=imaqhwinfo('winvideo',2);
    props.SupportedFormats
    if highres==0
        %vid = videoinput('winvideo', 1, 'Y800_1280x960');
        vid = videoinput('winvideo', 2, 'Y16 _1024x768');
    else
        vid = videoinput('winvideo', 2, 'Y16 _2592x1944');
    end
    vid.ReturnedColorspace = 'grayscale';
    %get(vid)        
    src = getselectedsource(vid);
    src.ExposureMode='manual';
    src.Exposure=-2;
    src.GainMode='manual';
    src.Gain=4;
    
    handles.ccd01=vid;
    
    if highres==0
        %vid = videoinput('winvideo', 1, 'Y800_1280x960');
        vid = videoinput('winvideo', 3, 'Y16 _1024x768');
    else
        vid = videoinput('winvideo', 3, 'Y16 _2592x1944');
    end
    vid.ReturnedColorspace = 'grayscale';
    src = getselectedsource(vid);
    src.ExposureMode='manual';
    src.Exposure=1;
    src.GainMode='manual';
    src.Gain=4;
    %get(src)
    handles.ccd02=vid;
    
    
    figure(1)
    subplot(121)
    imshow(getsnapshot(handles.ccd01),[])
    subplot(122)
    imshow(getsnapshot(handles.ccd02),[])
end

guidata(H,handles)
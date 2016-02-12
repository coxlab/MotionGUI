function toggle_ccd2p(varargin)
H=varargin{1};
event=varargin{2};
handles=guidata(H);

switch event.NewValue.String
    case 'CCD'
        handles.ccd2p=1;
    case '2p'
        handles.ccd2p=2;
    otherwise
        disp('Unkown modality...')
end
%handles.ccd2p
guidata(H,handles)
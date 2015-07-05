function openConnection(varargin)

H=varargin{1};
handles=guidata(H);

if ispc
    if nargin>=3&&not(isempty(varargin{3}))
        comport=varargin{3};
    else % use default value for 2p PC
        comport='COM5';
    end
    
    switch 2
        case 1
            s=serial(comport);
            s.name='ESP301';
            s.BaudRate=921600;
            s.FlowControl='software';
            s.Terminator='CR/LF';
            s.Timeout=2;
            
            fopen(s);
            
            handles.s=s;
            
            msg='EX JOYSTICK ON';
            fprintf(handles.s,msg);
            
            set(handles.hEdit01,'String','Connected')
        case 2
            handles.interface=serial_com(handles.hFig,comport);
            handles.interface.open();
            %set(handles.hEdit01,'String','Connected')
    end
else % not on pc or not running scim, go in detached mode
    
    %%% Create instance of detached class
    interface=serial_com_detached(handles.hFig);
    interface.open();
    handles.interface=interface;
end


guidata(H,handles)
update_gui(H)


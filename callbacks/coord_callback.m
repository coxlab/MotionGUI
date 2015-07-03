function coord_callback(varargin)
H=varargin{1};
handles=guidata(H);

str=get(H,'string');
str=strrep(str,'=',' '); % remove =-signs to allow decoding
coords=sscanf(str,'%*s %f ; ')';

handles.target_coords=coords;
guidata(H,handles);

handles.target_coords
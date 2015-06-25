function varargout=convertAbsRel(varargin)
%BV20150302 added support for matrices of coords
handles=guidata(varargin{1});
coords=varargin{2};
offset=[handles.Calibration.window.center_coords handles.Calibration.window.Z_offset];
offset=repmat(offset,size(coords,1),1);
varargout{1}=coords-offset;


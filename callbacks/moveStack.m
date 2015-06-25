function moveStack(varargin)

H=varargin{1};
mode=varargin{3};
handles=guidata(H);

step_size=0.300;
switch mode
    case 'Anterior'
        offset_matrix=repmat([0 step_size 0],2,1);
    case 'Posterior'
        offset_matrix=repmat([0 -step_size 0],2,1);
    case 'Medial'
        offset_matrix=repmat([-step_size 0 0],2,1);
    case 'Lateral'
        offset_matrix=repmat([step_size 0 0],2,1);
    case 'Center'
        offset_matrix=repmat([0 0 0],2,1);
end

handles.Trajectory.coords_matrix=handles.Trajectory.coords_matrix+offset_matrix;

coords=handles.Trajectory.coords_matrix;
if handles.Calibration.window.calibrated==1
    coords=convertAbsRel(H,coords); % abs to rel
end
fprintf('X=%03.4f ; Y=%03.4f ; Z=%03.4f \n',coords');

guidata(H,handles)

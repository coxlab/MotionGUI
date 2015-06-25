function loadSettings(varargin)

handles=guidata(varargin{1});

%%% Load settings for animal
handles.config=3;
switch handles.config
    case 1
        objective_settings='N16x_animal';
        subject_id='AE04';
    case 2
        objective_settings='O20x_animal';
        subject_id='AE04';
    case 3
        objective_settings='N16x_animal';
        subject_id='AE03';
    case 4
        objective_settings='O20x_animal';
        subject_id='AE03';        
    case 5
        objective_settings='N16x_animal';
        subject_id='Jrat2';                     
    case 6
        objective_settings='O20x_animal';
        subject_id='Jrat2';
    case 7
        objective_settings='N16x_animal';
        subject_id='Jrat3';                     
    case 8
        objective_settings='O20x_animal';
        subject_id='Jrat3';         
        
        
        
    case 101
        objective_settings='N16x_slide';
        subject_id='BeadSlide_03';
    case 102
        objective_settings='N16x_slide';
        subject_id='PollenSlide_01';
    case 103
        objective_settings='O20x_slide';
        subject_id='BeadSlide_03';
    case 104
        objective_settings='O20x_slide';
        subject_id='PollenSlide_01';        
end

% 3 axis system defines a 3d cube in which the focal point can move
% or through which we can move the specimen into the focal point
% each axis has a 13mm range. Unconstrainted, this will result in a
% 13x13x13mm cube. However, the headplate holding block is already
% constraining the AP (Y) axis at low ML (X) values.
% The headplate and the animal will further constrain the explorable area.
% Of course we are only interested in the small 5mm diameter cylinder under
% the coverslip. For safety, we also need to know the outline of the hole
% in the headplate. This will be different for different objectives.
% So for each session, we will need to load a combination of objective
% settings and animal properties.

% General properties
range_X_translation=[0 13];
range_Y_translation=[0 13];
coordinate_system.rect=[range_X_translation(1) range_Y_translation(1) range_Y_translation(2) range_Y_translation(2)];
coordinate_system.center_coords=coordinate_system.rect([3 4])/2;

% Define relation headplate-objective
switch objective_settings
    case 'O20x_animal'       
        %%% coordinate defines top of headplate, so coverslip and brain
        %%% will be BELOW this value!
        X=12.9636 ; Y=11.0417 ; Z=5.8592;
        headplate.Z_offset=Z; % use absolute values
        
        %%% Move objective to innermost point of headplate, deepest point
        X=7.8549 ; Y=7.4969 ; Z=4.6984; % use headplate.Z_offset corrected values        
        headplate.center_coords=[X Y];        
        headplate.max_depth=Z;
        
        headplate.inner_diameter=12;
        headplate.radius=headplate.inner_diameter/2;

        % In the center we can go down max headplate.max_depth mm, this is beyond the upper
        % edge of the headplate, so if we placed our coverslip less then
        % 3mm below that edge, we should get at least 1mm deep into the
        % brain. Only in the center that is, more peripherally, we would
        % get increasingly less depth.
        % At the edge, we can go down max 3mm.
        % Headplate itself is 1.58mm thick, so that little space
        % in between plate and skull should be achieved.
        
    case 'N16x_animal'
        %%% coordinate defines top of headplate, so coverslip and brain
        %%% will be BELOW this value!
        headplate.Z_offset=5.7357; % use absolute values
        
        %X=11.2903 ; Y=5.2429 ; Z=2.5189; top of headplate ring (top flat
        %edge)
        %headplate.Z_offset = 10.6419;
        
        %%% Move objective to innermost point of headplate, deepest point
        X=7.6904 ; Y=7.3708 ; Z=5.7427; % use headplate.Z_offset corrected values
        %X=12.5473 ; Y=7.3941 ; Z=-1.9518;
        headplate.center_coords=[X Y];
        headplate.max_depth=Z;
        
        headplate.inner_diameter=12;
        headplate.radius=headplate.inner_diameter/2;
        
        % A massive 5.7427mm below top of headplate. This is why this
        % particular objective will prove really useful. The lower NA does
        % make it a non-prefered choice for pristine imaging, but in some
        % cases it will allow data collection where we would otherwise have
        % no data.

        
    case 'O20x_slide'
        headplate.center_coords=coordinate_system.center_coords;
        
        %%% coordinate of top of slide holder plate, will be our reference,
        %%% so all specimen will appear ABOVE this value!
        %X=8.5609 ; Y=4.9399 ; Z=1.4141;
        X=5.8528 ; Y=7.4969 ; Z=1.5195;        
        headplate.Z_offset=Z;
    case 'N16x_slide'
        headplate.center_coords=coordinate_system.center_coords;
        
        %%% coordinate of top of slide holder plate, will be our reference,
        %%% so all specimen will appear ABOVE this value!
        X=8.5609 ; Y=4.9399 ; Z=1.4141;
        headplate.Z_offset=Z;
        
        
    case 'N40x_animal' % not using the 40x Nikon anymore, borrowed it from the patch rig (Jonathan, Bence lab)
        headplate.inner_diameter=11.5;
        X=2.8900 ; Y=5.1549 ; Z=6.3098;
        headplate.medial_edge=[X Y Z];
        headplate.lateral_edge=[X+headplate.inner_diameter Y Z];
        X=8.3986 ; Y=10.3314 ; Z=6.5256;
        headplate.anterior_edge=[X Y Z];
        headplate.posterior_edge=[X Y-headplate.inner_diameter Z];
        
        X=headplate.medial_edge(1)+headplate.inner_diameter/2;
        Y=headplate.anterior_edge(2)-headplate.inner_diameter/2;
        %X=2.7071 ; Y=4.0670 ; Z=6.1907;
        headplate.center_coords=[X Y];
        headplate.radius=headplate.inner_diameter/2;
        % this value will bring us center above the headplate
   
end

triplet=zeros(1,3);
coords=struct('anterior',triplet,'posterior',triplet,'medial',triplet,'lateral',triplet);
coverslip=struct('coords',coords,'coords_complete',0);
% Coords coverslip
switch subject_id
    case 'dummy'
        coverslip.inner_diameter=5; % mm
        coverslip.center_coords=headplate.center_coords;
        coverslip.radius=coverslip.inner_diameter/2;
        coverslip.Z_offset=headplate.Z_offset;
    case 'Jrat3'
        %Posterior edge at
        % X=10.6055 ; Y=5.0356 ; Z=2.3032;
        %X=10.2464 ; Y=4.7870 ; Z=-0.3075;
        X=10.2233 ; Y=4.8906 ; Z=2.1363;
        coverslip.coords.posterior=[X Y Z];
        
        %Anterior edge
        % X=10.7634 ; Y=10.0552 ; Z=2.0901;
        %X=10.2300 ; Y=9.5081 ; Z=-0.5106;
        X=10.4747 ; Y=10.1800 ; Z=2.0765;
        coverslip.coords.anterior=[X Y Z];
        
        %Medial edge
        % X=8.5785 ; Y=7.5547 ; Z=0.3613;
        %X=8.1730 ; Y=7.2011 ; Z=-0.7131;
        X=8.1850 ; Y=7.3589 ; Z=1.8039;
        coverslip.coords.medial=[X Y Z];
        
        %Lateral edge
        % X=13.0414 ; Y=7.5547 ; Z=0.0246;
        %X=12.7450 ; Y=7.2715 ; Z=0.1360;
        X=12.7866 ; Y=7.3941 ; Z=2.6053;
        coverslip.coords.lateral=[X Y Z];
        
        %Z=0; % defines depth of coverslip below top off headplate
        X=8.7712 ; Y=7.8037 ; Z=2.6143;
        %X=9.9864 ; Y=6.0282 ; Z=-0.4948;
        %X=9.9436 ; Y=7.6585 ; Z=1.9801;
        
        % First landmark pos:
        % X=10.8725 ; Y=9.2697 ; Z=1.9163;
        %X=9.8829 ; Y=7.5183 ; Z=-0.5199;
        %X=9.9065 ; Y=7.5504 ; Z=1.9801;
        %X=9.9436 ; Y=7.6585 ; Z=0.3118;
        
        headplate.Z_offset=headplate.Z_offset+2.6143;
        coverslip.Z_offset=headplate.Z_offset+Z;
        
    case 'Jrat2'
        %Posterior edge at
        % X=8.7486 ; Y=5.1228 ; Z=-0.4679;
        %X=8.5558 ; Y=5.2502 ; Z=0.1065;
        
        X=10.1272 ; Y=3.9080 ; Z=-0.8862;
        
        coverslip.coords.posterior=[X Y Z];
        %Anterior edge
        % X=8.7486 ; Y=9.2819 ; Z=-0.2439;
        %X=8.5558 ; Y=8.8750 ; Z=-0.3096;
        
        X=10.1272 ; Y=8.1449 ; Z=-0.7663;
        coverslip.coords.anterior=[X Y Z];
        %Medial edge
        % X=7.1555 ; Y=7.1777 ; Z=-0.2926;
        %X=6.4654 ; Y=7.1047 ; Z=0.0910;
        
        X=8.3361 ; Y=5.9290 ; Z=-0.7776;
        coverslip.coords.medial=[X Y Z];
        %Lateral edge
        % X=11.4226 ; Y=7.1777 ; Z=-0.2507;
        %X=10.4133 ; Y=7.1047 ; Z=-0.1730;
        
        X=12.9206 ; Y=6.0377 ; Z=-0.2816;
        coverslip.coords.lateral=[X Y Z];
        
        %Z=0; % defines depth of coverslip below top off headplate
        %X=8.7712 ; Y=7.8037 ; Z=2.6143;
        X=9.9864 ; Y=6.0282 ; Z=-0.4948;
        headplate.Z_offset=headplate.Z_offset+2.6143;
        coverslip.Z_offset=headplate.Z_offset+Z;
    case 'AE03'        
        %Posterior edge at
        %X=8.5558 ; Y=5.2502 ; Z=0.1065;
        %X=8.3803 ; Y=4.0683 ; Z=2.4034;
        %X=8.5291 ; Y=4.3155 ; Z=-0.1217;
        %X=8.2393 ; Y=6.1445 ; Z=3.0498;
        %X=10.8359 ; Y=6.5437 ; Z=1.0939;
        X=9.8189 ; Y=3.2387 ; Z=1.0052;
        coverslip.coords.posterior=[X Y Z];
        %Anterior edge
        %X=8.5558 ; Y=8.8750 ; Z=-0.3096;
        %X=8.4433 ; Y=8.6622 ; Z=2.4281;
        %X=8.2439 ; Y=8.6943 ; Z=-0.0689;
        %X=8.2393 ; Y=10.0638 ; Z=2.9668;
        %X=10.0931 ; Y=11.2676 ; Z=-0.9314;
        X=9.8189 ; Y=7.2727 ; Z=1.1363;
        coverslip.coords.anterior=[X Y Z];
        %Medial edge
        %X=6.4654 ; Y=7.1047 ; Z=0.0910;
        %X=6.0113 ; Y=6.3960 ; Z=2.6351;
        %X=6.3163 ; Y=6.4561 ; Z=0.0601;
        %X=6.3400 ; Y=8.1082 ; Z=3.0908;
        %X=9.1864 ; Y=8.3300 ; Z=1.1583; % not completely
        X=8.1402 ; Y=5.2586 ; Z=1.0933;
        coverslip.coords.medial=[X Y Z];
        %Lateral edge
        %X=10.4133 ; Y=7.1047 ; Z=-0.1730;
        %X=10.3072 ; Y=6.3960 ; Z=2.3292;
        %X=10.6368 ; Y=6.4561 ; Z=-0.2314;
        %X=10.6215 ; Y=8.1082 ; Z=2.7708;
        %X=12.8583 ; Y=8.8472 ; Z=0.9443;
        X=12.2830 ; Y=5.2586 ; Z=0.7979;
        coverslip.coords.lateral=[X Y Z];
        
        Z=0; % defines depth of coverslip below top off headplate
        %X=8.3772 ; Y=6.2397 ; Z=2.4325;
        %X=8.3807 ; Y=8.1082 ; Z=2.9896;        
        %X=10.8923 ; Y=8.7937 ; Z=4.0716;
        X=10.0992 ; Y=5.1034 ; Z=5.0510;
        coverslip.Z_offset=headplate.Z_offset+Z;
    case 'AE04'
        % coverslip depth X=8.5557 ; Y=6.3768 ; Z=6.9962
        %Posterior edge at
        X=8.5558 ; Y=5.2502 ; Z=0.1065;        
        coverslip.coords.posterior=[X Y Z];
        %Anterior edge
        X=8.5558 ; Y=8.8750 ; Z=-0.3096;        
        coverslip.coords.anterior=[X Y Z];
        
        % midline:
        p1=coverslip.coords.anterior(2);
        p2=coverslip.coords.posterior(2);
        Y_mid=p1-(p1-p2)/2;
        
        % midpoint X=8.5558 ; Y=7.1047 ; Z=-0.1445
        
        %Medial edge
        X=6.4654 ; Y=7.1047 ; Z=0.0910;        
        coverslip.coords.medial=[X Y Z];
        %Lateral edge
        X=10.4133 ; Y=7.1047 ; Z=-0.1730;
        coverslip.coords.lateral=[X Y Z];
        
        %coverslip.Z_offset=6.9962+0.7546-0.1263;
        
        %Z=0;
        X=11.6704 ; Y=7.4169 ; Z=10.7708;
        coverslip.Z_offset=Z;
        
    case 'AD15'
        %Posterior edge at
        X=4.0577 ; Y=0.3821 ; Z=0.0351;
        coverslip.coords.posterior=[X Y Z];
        %Anterior edge
        X=3.9442 ; Y=4.6411 ; Z=0.0099;
        coverslip.coords.anterior=[X Y Z];
        %Medial edge
        X=1.8424 ; Y=2.4636 ; Z=0.1245;
        coverslip.coords.medial=[X Y Z];
        %Lateral edge
        X=6.2126 ; Y=2.5353 ; Z=-0.0231;
        coverslip.coords.lateral=[X Y Z];
        coverslip.Z_offset=0;
    case 'AD02'
        %Posterior edge at (not really correct)
        X=-1.5998 ; Y=-1.5579 ; Z=1.0246;
        coverslip.coords.posterior=[X Y Z];
        %Anterior edge
        X=-1.5998 ; Y=2.9464 ; Z=1.0410;
        coverslip.coords.anterior=[X Y Z];
        
        % midline:
        p1=coverslip.coords.anterior(2);
        p2=coverslip.coords.posterior(2);
        Y_mid=p1-(p1-p2)/2;
        
        %Medial edge
        X=-3.5977 ; Y=0.6938 ; Z=1.1192;
        coverslip.coords.medial=[X Y Z];
        %Lateral edge (can't really reach it)
        X=-0.2939 ; Y=0.5081 ; Z=1.0590;
        coverslip.coords.lateral=[X Y Z];
        coverslip.Z_offset=1.04;       
        
    case 'PollenSlide_01'
        % location of pollen layer
        %X=7.3377 ; Y=5.3195 ; Z=-0.9269;                
        X=6.5049 ; Y=7.4561 ; Z=-0.9573;
        %Z=0;
        coverslip.Z_offset=headplate.Z_offset+Z;
        
    case 'BeadSlide_03'
        % location of bead layer
        X=8.5609 ; Y=4.9399 ; Z=-0.9636;   
        %Z=0;
        coverslip.Z_offset=headplate.Z_offset+Z;
end

if sum(coverslip.coords.anterior)>0&&sum(coverslip.coords.anterior)>0
        coverslip.coords_complete=1/2;    
end

if sum(coverslip.coords.anterior)>0&&sum(coverslip.coords.anterior)>0 ...
    &&sum(coverslip.coords.posterior)>0&&sum(coverslip.coords.lateral)>0
        coverslip.coords_complete=1;
end

if coverslip.coords_complete>=.5
    % midline:
    p1=coverslip.coords.anterior(2);
    p2=coverslip.coords.posterior(2);
    Y_mid=p1-(p1-p2)/2;
end

% headplate.Z_offset=0;
%coverslip
% coverslip.Z_offset=0;
if coverslip.coords_complete==1
    %coverslip.Z_offset=0;
    %headplate.Z_offset=coverslip.Z_offset
    
    %% plot circle using coords
    if ~isfield(coverslip,'center_coords')
        points=cat(1,coverslip.coords.posterior(1:2),coverslip.coords.anterior(1:2),coverslip.coords.medial(1:2),coverslip.coords.lateral(1:2));
        center=mean(points,1);
        distances=points-repmat(center,4,1);
        [rho,dist]=cart2pol(distances(:,1),distances(:,2));
        radius=mean(dist);
        
        coverslip.center_coords=center;
        coverslip.radius=radius;
    end
    
    %% measure angles of coverslip relative to objective
    % consider correcting entire movement scheme by these angles, at least
    % for stitching the whole brain surface in brightfield to keep the
    % specimen in focus
    pos1=coverslip.coords.anterior([2 3]);
    pos2=coverslip.coords.posterior([2 3]);
    
    coverslip.AP_dist=calc_dist([pos1 pos2]);
    coverslip.pitch=calc_heading([pos1 pos2])/pi*180;
    
    pos1=coverslip.coords.medial([1 3]);
    pos2=coverslip.coords.lateral([1 3]);
    
    coverslip.ML_dist=calc_dist([pos1 pos2]);
    coverslip.roll=calc_heading([pos1 pos2])/pi*180;
end
%coverslip;
handles.coordinate_system=coordinate_system;
handles.headplate=headplate;
handles.coverslip=coverslip;

guidata(varargin{1},handles);


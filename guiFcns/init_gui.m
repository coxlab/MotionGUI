function init_gui(varargin)

handles=guidata(varargin{1});

handles.hAxis01=subplot(1,4,[1 3]);
set(handles.hAxis01,'Parent',handles.hPanel_axis)

% plot max outline
switch 2
    case 1
        bg_im=double(imread('/Users/benvermaercke/Dropbox (coxlab)/2p-data/surgery_rig_images/AF17/IMG_6479.JPG'))/255;
        bg_im=fliplr(bg_im);
        
        surgery_im_scaling_factor=355.347;
        surgery_im_center=[1791 1392];
    case 2
        bg_im=double(imread('C:\Users\labuser\Documents\Repos\MotionGUI\Images\2015-08-10_AH03_im.png'))/256;
        bg_im(:,:,2)=flipud(bg_im(:,:,2));
                
        surgery_im_scaling_factor=1;
        surgery_im_center=[6.5 6.5];
        
    otherwise
        surgery_im_scaling_factor=1;
        surgery_im_center=[6.5 6.5];
end

this_rect=[0 0 13 13];
this_rect_scaled=ScaleRect(this_rect,surgery_im_scaling_factor,surgery_im_scaling_factor);
this_rect_scaled_centered=CenterRectOnPoint(this_rect_scaled,surgery_im_center(1),surgery_im_center(2));

cla
hold on
if exist('bg_im','var')
    handles.plot_handles(1).p(1).im=imshow(bg_im,[]);
end
plot(surgery_im_center(1),surgery_im_center(2),'wo')
circle(surgery_im_center,2*surgery_im_scaling_factor,100,'r-',2);
%handles.plot_handles(1).p(1).h=plotRect(this_rect,'k');
handles.plot_handles(1).p(1).h=plotRect(this_rect_scaled_centered,'k');
%handles.plot_handles(1).p(1).default=this_rect;
handles.plot_handles(1).p(1).default=this_rect_scaled_centered;


% plot place holder headplate
handles.plot_handles(1).p(2).h=circle([-10 -10],0,100,'r-',1);

% plot place holder window and crosshairs
handles.plot_handles(1).p(3).h=circle([-10 -10],0,100,'r-',2);
handles.plot_handles(1).p(4).h=plot([0 0],[-10 10],'k'); % AP
handles.plot_handles(1).p(5).h=plot([-10 -10],[0 0],'k'); % ML

% initiate current position marker
handles.plot_handles(1).p(7).h=plot(0,0,'ko:'); % grid

h=plot(surgery_im_center(1),surgery_im_center(2),'m*'); % indicator
set(h,'ButtonDownFcn',@moveObj)
handles.plot_handles(1).p(6).h=h;

hold off
axis equal
%axis ([-1 14 -1 14])
xlabel('Medial <-> Lateral')
ylabel('Posterior <-> Anterior')
axis xy

handles.hAxis02=subplot(1,4,4);
set(handles.hAxis02,'Parent',handles.hPanel_axis)
handles.plot_handles(2).p(1)=bar(1,0);
handles.plot_handles(2).p(2)=xlabel('0');
ylabel('Z-depth relative to coverslip')
axis([0 2 -3 3])
axis ij


guidata(handles.hFig,handles);

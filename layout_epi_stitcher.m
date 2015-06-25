clear all
clc

% remove ccd/2p button

% select two coords

% define circle or rect arrangement of fields
% use camera FOV size and percentage of overlap
% to generate grid coords

% move to each subsequent grid coord and take both brightfield and epi images

% the resulting images will be projected onto the background of the
% motionGUI to make things more realistic. 
% 2p and CCD should be aligned perfectly, need to adjust the dichroic and
% try to get registration of both images better, can happen offline.
% Brightness of PMT is suboptimal with current dichroic alignment, so this
% could be the reason for the large difference between both image modalities.
% Recalibration should happen without having to rerun the epi stitcher...
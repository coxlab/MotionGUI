%%% Make this into a class with methods
% constructor needs root folder, filename template, grid_size and FOV props

clear all
clc

data_root='/Users/benvermaercke/Dropbox (coxlab)/2p-data/';
im_folder=fullfile(data_root,'2015-07-07_AF17','AF17_stitch04');

FOV_size=[710 946]/1000;
overlap_factor=.80;


nRows=3;
nCols=3;

[X,Y]=meshgrid(1:nRows,1:nCols);
X=X(:);
Y=Y(:);

N=prod([nRows nCols]);

M=struct;
for iFile=1:N
    im_name=fullfile(im_folder,sprintf('ccd_01_%03d.png',iFile));
    M(iFile).row_nr=X(iFile);
    M(iFile).col_nr=Y(iFile);
    M(iFile).index=iFile;
    M(iFile).im=double(imread(im_name))/255;
    M(iFile).im_size=size(M(iFile).im);
    M(iFile).name=im_name;
    
    G(X(iFile),Y(iFile)).im=M(iFile).im;
end

mm2px=mean(M(1).im_size./FOV_size);

spacing_mm=FOV_size.*[1 overlap_factor];
spacing_px=floor(spacing_mm*mm2px);

%%
figure(1)
for iFile=1:N
    subplot(nRows,nCols,iFile)
    imshow(M(iFile).im,[])
end

%% stitch non-cropped
stitch=[];
for iRow=1:nRows
    for iCol=1:nCols
        sel=cat(1,M.row_nr)==iRow;
        Row=cat(2,M(sel).im);
    end
    stitch=cat(1,stitch,Row);
end
figure(2)
imshow(stitch,[])

%%

for iFile=1:N
    im=M(iFile).im;
    if M(iFile).row_nr==nRows&&M(iFile).col_nr==nCols
        im_cropped=im;
    elseif M(iFile).row_nr<nRows&&M(iFile).col_nr==nCols
        im_cropped=im(1:spacing_px(1),:);
    elseif M(iFile).row_nr==nRows&&M(iFile).col_nr<nCols
        im_cropped=im(:,1:spacing_px(2));
    else
        im_cropped=im(1:spacing_px(1),1:spacing_px(2));
    end
    M(iFile).im_cropped=im_cropped;
end

%% stitch cropped
stitch=[];
for iRow=1:nRows
    for iCol=1:nCols
        sel=cat(1,M.row_nr)==iRow;
        Row=cat(2,M(sel).im_cropped);
    end
    stitch=cat(1,stitch,Row);
end
figure(3)
imshow(stitch,[])

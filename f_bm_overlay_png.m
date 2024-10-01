
function f_bm_overlay_png(scanID,underlay,overlay,dim,outname,linkdir)

% Load anatomical underlay
UL=niftiread(underlay);

% Load Binary Mask (BM) overlays
if isstruct(overlay)
    for oi=1:length(overlay)
        OL{oi}=niftiread(overlay(oi).name);
    end
else
    OL{1}=niftiread(overlay);
end

% Select representative slices from T1 volume
if dim==3
    sz1=size(UL,1);
elseif dim==2
    sz1=size(UL,3);
elseif dim==1
    sz1=size(UL,2);
end
sz=size(UL,dim);

% first and last are dim1 sagittal additions
slc = [.4 .2 .35 .45 .55 .65 .8 .6 ];
slices=zeros(1,length(slc));
for ii=1:length(slc)
    if ii==1
        slices(ii)=floor(sz1*slc(ii));
    elseif ii==length(slc)
        slices(ii)=floor(sz1*slc(ii));
    else
        slices(ii)=floor(sz*slc(ii));
    end
end

% initialize figure
fig_out=figure('Units','inches','Position',[1 1 15 3*length(OL)],'Color','k'); 

% generate a grayscale colormap with red as the highest intensity color
cmap=colormap(gray(128));
cmap(129,:)=[1 0 0];
colormap(cmap)

% For each representative slice
tiledlayout(length(OL),length(slices),'TileSpacing','none','Padding','none')
for j=1:length(OL)
for i=1:length(slices)
    nexttile
    if dim==3
        if i==1 || i==length(slices)
            tslice=rot90(squeeze((UL(slices(i),:,:)))); % select & display T1 slice
            mslice=rot90(squeeze(OL{j}(slices(i),:,:))); % select matching brain mask slice
        else
            tslice=rot90(squeeze((UL(:,:,slices(i))))); % select & display T1 slice
            mslice=rot90(squeeze(OL{j}(:,:,slices(i)))); % select matching brain mask slice
        end
    elseif dim==2
        if i==1 || i==length(slices)
            tslice=rot90(squeeze((UL(:,:,slices(i))))); % select & display T1 slice
            mslice=rot90(squeeze(OL{j}(:,:,slices(i)))); % select matching brain mask slice
        else
            tslice=rot90(squeeze((UL(:,slices(i),:)))); % select & display T1 slice
            mslice=rot90(squeeze(OL{j}(:,slices(i),:))); % select matching brain mask slice
        end
    elseif dim==1
        if i==1 || i==length(slices)
            tslice=rot90(squeeze((UL(:,slices(i),:)))); % select & display T1 slice
            mslice=rot90(squeeze(OL{j}(:,slices(i),:))); % select matching brain mask slice
        else
            tslice=rot90(squeeze((UL(slices(i),:,:)))); % select & display T1 slice
            mslice=rot90(squeeze(OL{j}(slices(i),:,:))); % select matching brain mask slice
        end
    end

    fig_out(1)=imagesc(tslice); axis image
    hold on
    
    % set mask value to 1+ highest intensity in T1 slice
    mslice(mslice==1)=max(max(tslice))+1;
    fig_out(2)=imagesc(mslice); % overlay mask
    fig_out(2).AlphaData = 0.3; % set mask transparency
    set(gca,'Visible','off') % hide axes
    hold off
    clear tslice mslice
end
end

% Add title to figure and save as high resolution png
sgtitle(sprintf('%s %s',scanID{1},scanID{2}),'Interpreter','none')    
print([outname '.png'],'-dpng','-r300');
close all

if exist('linkdir','var')
    system(['ln -sf ' outname '.png ' linkdir '/']);
end

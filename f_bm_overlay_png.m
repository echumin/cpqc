
function f_bm_overlay_png(subjID,ses,underlay,overlay,dim,outname,linkdir)

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
sz=size(UL,dim);
slc = [.1 .2 .35 .5 .65 .8 .85 ];
slices=zeros(1,length(slc));
for ii=1:length(slc)
    slices(ii)=floor(sz*slc(ii));
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
        tslice=rot90(squeeze((UL(:,:,slices(i))))); % select & display T1 slice
        mslice=rot90(squeeze(OL{j}(:,:,slices(i)))); % select matching brain mask slice
    elseif dim==2
        tslice=rot90(squeeze((UL(:,slices(i),:)))); % select & display T1 slice
        mslice=rot90(squeeze(OL{j}(:,slices(i),:))); % select matching brain mask slice
    elseif dim==1
        tslice=rot90(squeeze((UL(slices(i),:,:)))); % select & display T1 slice
        mslice=rot90(squeeze(OL{j}(slices(i),:,:))); % select matching brain mask slice
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
sgtitle(sprintf('%s %s',subjID,ses),'Interpreter','none')    
print([outname '.png'],'-dpng','-r300');
close all

if exist('linkdir','var')
    system(['ln -sf ' outname '.png ' linkdir '/']);
end

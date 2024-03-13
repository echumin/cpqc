function f_xyz_overlay_png(subjID,ses,underlay,overlay,outname,linkdir)

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

% initialize figure
fig_out=figure('Units','inches','Position',[1 1 6 6],'Color','k'); 

% generate a grayscale colormap with red as the highest intensity color
cmap=colormap(gray(128));
cmap(129,:)=[1 0 0];
colormap(cmap)

% For each representative slice
tiledlayout(2,2,'TileSpacing','none','Padding','none')
for j=1:length(OL)
    mask=OL{j};
    [x,y,z]=ind2sub(size(mask),find(mask>0));
    [~,ind_min]=min(sqrt((mean(x)-x).^2+(mean(y)-y).^2+(mean(z)-z).^2)); 
    coor=[x(ind_min(1)),y(ind_min(1)),z(ind_min(1))]; 

for i=1:4
    nexttile
 switch i
     case 1
        tslice=rot90(squeeze((UL(:,:,coor(3))))); % select & display T1 slice
        mslice=rot90(squeeze(OL{j}(:,:,coor(3)))); % select matching brain mask slice
     case 2
        tslice=rot90(squeeze((UL(:,coor(2)+10,:)))); % select & display T1 slice
        mslice=rot90(squeeze(OL{j}(:,coor(2)+10,:))); % select matching brain mask slice
     case 3
        tslice=rot90(squeeze((UL(coor(1)-10,:,:)))); % select & display T1 slice
        mslice=rot90(squeeze(OL{j}(coor(1)-10,:,:))); % select matching brain mask slice
     case 4
        tslice=rot90(squeeze((UL(coor(1)+10,:,:)))); % select & display T1 slice
        mslice=rot90(squeeze(OL{j}(coor(1)+10,:,:))); % select matching brain mask slice
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

function f_bm_overlay_gif(subjID,ses,underlay,overlay,outname)

UL=niftiread(underlay);
OL=niftiread(overlay);

% set representative slices
midAslice=round(size(UL,3)/2);
midSslice=round(size(UL,2)/2);
midCslice=round(size(UL,1)/2);
        
mn=floor(min([midAslice midCslice midSslice])/10)*10;

Aslices=(midAslice-mn:4:midAslice+mn); Aslices(Aslices==0)=1;
Sslices=(midSslice-mn:4:midSslice+mn); Sslices(Sslices==0)=1;
Cslices=(midCslice-mn:4:midCslice+mn); Cslices(Cslices==0)=1;

clear Stacks
for ix=1:length(Sslices)
    Stacks{1}(:,:,ix) = rot90(squeeze(UL(Cslices(ix),:,:)));
    Stacks{2}(:,:,ix) = rot90(squeeze(UL(:,Sslices(ix),:)));
    Stacks{3}(:,:,ix) = rot90(UL(:,:,Aslices(ix)));
end
Tmax=max(vertcat(Stacks{1}(:),Stacks{2}(:),Stacks{3}(:))); 
clear midAslice midSslice midCslice
        
clear BMStacks
mx=max(OL(:))+(1.2*Tmax);
for ix=1:length(Sslices)
    BMStacks{1}(:,:,ix) = rot90(squeeze(OL(Cslices(ix),:,:)));
    BMStacks{2}(:,:,ix) = rot90(squeeze(OL(:,Sslices(ix),:)));
    BMStacks{3}(:,:,ix) = rot90(OL(:,:,Aslices(ix)));
end
for ii=1:3
    BMStacks{ii}=BMStacks{ii}+(2*Tmax);
    BMStacks{ii}(BMStacks{ii}<=(2*Tmax))=0;
end

f=figure('Units','inches','Position',[1 1 10 10],'Color','k'); 
c2map=gray(128);
cbmap=vertcat(c2map,[1 0 0]);
        
% For each representative slice
for n=1:length(Sslices)
    tiledlayout(2,2,'TileSpacing','none')
    for ii=[1,2,3]
        %subplot(2,2,ii)
        nexttile
        imagesc(Stacks{ii}(:,:,n)); axis image; % plot T1
        hold on
        h(1)=imagesc(BMStacks{ii}(:,:,n)); % overlay mask
        a=BMStacks{ii}(:,:,n); a(a>0)=0.3;
        h(1).AlphaData = a; % set transparency
    set(gca,'XTickLabel',[],'YTickLabel',[])
    colormap(cbmap)
    clim([0 mx])
    hold off
    end
       
    sgtitle(sprintf('%s %s',subjID,ses),'Interpreter','none','Color','white')
    drawnow
    % convert plots into iamges
    frame=getframe(f);
    im=frame2im(frame);
    [imind,cm]=rgb2ind(im,256);
    % write the gif file
    if n==1
        imwrite(imind,cm,[outname '.gif'],'gif','DelayTime',.3,'Loopcount',inf);
    else
        imwrite(imind,cm,[outname '.gif'],'gif','DelayTime',.3,'WriteMode','append')
    end
end 
close all
function f_parc_overlay_gif(subjID,ses,underlay,parcpath,parcnames,outname,linkdir)

UL=niftiread(underlay);

nP=length(parcnames);
for p=1:nP
    if p==1
        parcLabels = parcnames{p};
    else
        parcLabels = [parcLabels '  -  ' parcnames{p}];
    end
end

% set representative slices
midAslice=floor(size(UL,3)/2);
midSslice=floor(size(UL,2)/2);

mn=min([midAslice midSslice]);

Aslices=(midAslice-mn:10:midAslice+mn);
Sslices=(midSslice-mn:10:midSslice+mn);
if Aslices(1)==0; Aslices(1)=1; end
if Sslices(1)==0; Sslices(1)=1; end

clear Stack
for ix=1:length(Sslices)
    Stack(:,:,ix) = repmat(vertcat(rot90(UL(:,:,Aslices(ix))),...
        rot90(squeeze(UL(:,Sslices(ix),:)))),[1 nP]); 
end
Tmax=max(Stack(:)); 
clear midAslice midSslice 
        
% build a stack for each parcellation
maxIdx=double.empty;
clear Pvols
for p=1:nP
    pFile = dir(fullfile(parcpath,['*T1_GM_parc_' parcnames{p} '.nii.gz']));
    T1p=niftiread(fullfile(parcpath,pFile.name)); % load parcellation
    Pvols{p}=T1p;
    maxIdx(end+1)=max(unique(T1p)); % find max index value in parcellation
    clear T1p
end
for p=1:nP     
    % get slice stacks
    for ix=1:length(Sslices)
        Pvols{2,p}(:,:,ix) = vertcat(rot90(Pvols{1,p}(:,:,Aslices(ix))),...
        rot90(squeeze(Pvols{1,p}(:,Sslices(ix),:)))); 
    end
end
Pstack=double.empty;
maxIdx=max(maxIdx);
for p=1:nP
    % concatenate
    Pstack = cat(2,Pstack,Pvols{2,p});
end
f=figure('Units','inches','Position',[1 1 3*nP 6],'Color','k','Visible','off'); 
c2map=gray(128);
c3map=lines(maxIdx);
           
% For each representative slice
for n=1:size(Pstack,3)
    ax1=axes;
    ax2=axes;
    imagesc(ax1,Stack(:,:,n)); % plot T1
    a=single(Pstack(:,:,n)); a(a>0)=0.7;
    imagesc(ax2,Pstack(:,:,n),AlphaData=a); % overlay mask
    axis(ax1,'image')
    colormap(ax1,c2map);
    axis(ax2,'image')
    colormap(ax2,c3map)
    ax2.Color = 'none'; 
    ax2.Visible = 'off'; 
    linkaxes([ax1 ax2])
    ax1.Visible='off';
    sgtitle([subjID ' ' ses ' Parcellations:  ' parcLabels],'Interpreter','none','Color','white')
    drawnow
    % convert plots into iamges
    frame=getframe(f);
    im=frame2im(frame);
    [imind,cm]=rgb2ind(im,256);
    % write the gif file
    if n==1
       imwrite(imind,cm,[outname '.gif'],'gif','DelayTime',.4,'Loopcount',inf);
    else
       imwrite(imind,cm,[outname '.gif'],'gif','DelayTime',.4,'WriteMode','append')
    end
end
close all

if exist('linkdir','var')
    system(['ln -sf ' outname '.gif ' linkdir '/']);
end

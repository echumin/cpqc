function f_fig_mni_contour(configs,scanID,flag,linkdir)

MNI = fullfile(configs.path2SM,'MNI_templates','MNI152_T1_1mm_brain.nii.gz');

sub_path=fullfile(configs.path2data,scanID{1},scanID{2});
if ~exist(sub_path,'dir')
    fprintf(2,'%s/%s - Directory does not exist! Exiting...\n',scanID{1},scanID{2})
    return
else
    qcpath=fullfile(sub_path,'qc'); %output directory
    if ~exist(qcpath,'dir')
        mkdir(qcpath) % make output directory if it doesn't exist
    end
end

T1mnifile = fullfile(sub_path,'anat/registration','T1_warped.nii.gz');

if exist(T1mnifile,'file')
    T1mni=niftiread(T1mnifile);
    upperT1=.9*(max(max(max(T1mni))));
    MNIt=niftiread(MNI);

    filename=fullfile(qcpath,[scanID{1} '_' scanID{2} '_2-mni_contour']);
    count=length(dir(strcat(filename,'*')));
    if count > 0
        filename = [filename '_v' num2str(count+1)];
    end

    switch flag
        case 1
            dim=3;
            % Select representative slices from T1 volume
            if dim==3
                sz1=size(T1mni,1);
            elseif dim==2
                sz1=size(T1mni,3);
            elseif dim==1
                sz1=size(T1mni,2);
            end
            sz=size(T1mni,dim);

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
            figure('Units','inches','Position',[1 1 15 3],'Color','k'); 

            % generate a grayscale colormap with red as the highest intensity color
            cmap=colormap(gray(128));
            colormap(cmap)
            
            % For each representative slice
            tiledlayout(1,length(slices),'TileSpacing','none','Padding','none')
            warning('off','MATLAB:contour:ConstantData')

            for i=1:length(slices)
                nexttile
                if dim==3
                    if i==1 || i==length(slices)
                        tslice=rot90(squeeze((T1mni(slices(i),:,:)))); % select & display T1 slice
                        mslice=rot90(squeeze(MNIt(slices(i),:,:))); % select matching brain mask slice
                    else
                        tslice=rot90(squeeze((T1mni(:,:,slices(i))))); % select & display T1 slice
                        mslice=rot90(squeeze(MNIt(:,:,slices(i)))); % select matching brain mask slice
                    end
                elseif dim==2
                    if i==1 || i==length(slices)
                        tslice=rot90(squeeze((T1mni(:,:,slices(i))))); % select & display T1 slice
                        mslice=rot90(squeeze(MNIt(:,:,slices(i)))); % select matching brain mask slice
                    else
                        tslice=rot90(squeeze((T1mni(:,slices(i),:)))); % select & display T1 slice
                        mslice=rot90(squeeze(MNIt(:,slices(i),:))); % select matching brain mask slice
                    end
                elseif dim==1
                    if i==1 || i==length(slices)
                        tslice=rot90(squeeze((T1mni(:,slices(i),:)))); % select & display T1 slice
                        mslice=rot90(squeeze(MNIt(:,slices(i),:))); % select matching brain mask slice
                    else
                        tslice=rot90(squeeze((T1mni(slices(i),:,:)))); % select & display T1 slice
                        mslice=rot90(squeeze(MNIt(slices(i),:,:))); % select matching brain mask slice
                    end
                end
            
                imagesc(tslice); axis image
                hold all
    
                contour(mslice,5,'LineWidth',1,'LineColor','r','LineStyle','-'); % overlay mask
                clim([0 upperT1])
                set(gca,'Visible','off') % hide axes
                hold off
                clear tslice mslice
            end

            % Add title to figure and save as high resolution png
            sgtitle(sprintf('%s %s',scanID{1},scanID{2}),'Interpreter','none')    
            print([filename '.png'],'-dpng','-r300');
            close all

            if exist('linkdir','var')
                system(['ln -sf ' filename '.png ' linkdir '/']);
            end

        case 2
            % open figure
            h=figure('Units','inches','Position',[1 1 10 10],'Color','k');     
            colormap(gray(128))
    
            warning('off','MATLAB:contour:ConstantData')
            for n=1:5:size(MNIt,3) % for every 5th slice in MNI volume
                tiledlayout(2,2,'TileSpacing','none')
                nexttile
                imagesc(rot90(T1mni(:,:,n))); % plot MNI
                axis image
                hold all
            % overlay contour image of subject MNI space transforment T1
                contour(rot90(MNIt(:,:,n)),'LineWidth',1,'LineColor','r','LineStyle','-')
                set(gca,'XTickLabel',[],'YTickLabel',[])
                caxis([0 upperT1])
                hold off

                nexttile
                imagesc(rot90(squeeze(T1mni(:,n,:)))); % plot MNI
                axis image
                hold all
            % overlay contour image of subject MNI space transforment T1
                contour(rot90(squeeze(MNIt(:,n,:))),'LineWidth',1,'LineColor','r','LineStyle','-')
                set(gca,'XTickLabel',[],'YTickLabel',[])
                caxis([0 upperT1])
                hold off

                nexttile
                imagesc(rot90(squeeze(T1mni(n,:,:)))); % plot MNI
                axis image
                hold all
            % overlay contour image of subject MNI space transforment T1
                contour(rot90(squeeze(MNIt(n,:,:))),'LineWidth',1,'LineColor','r','LineStyle','-')
                set(gca,'XTickLabel',[],'YTickLabel',[])
                caxis([0 upperT1])
                hold off

                sgtitle(sprintf('%s %s: MNI space T1 with MNI template contour overlay',scanID{1},scanID{2}),'Interpreter','none','Color','white')
                drawnow
                % convert plots into iamges
                frame=getframe(h);
                im=frame2im(frame);
                [imind,cm]=rgb2ind(im,256);
                % write the gif file
                if n==1
                    imwrite(imind,cm,[filename '.gif'],'gif','DelayTime',.4,'Loopcount',inf);
                else
                    imwrite(imind,cm,[filename '.gif'],'gif','DelayTime',.4,'WriteMode','append')
                end
            end
            close all

            if exist('linkdir','var')
                system(['ln -sf ' filename '.gif ' linkdir '/']);
            end

            fprintf('done.\n')

        otherwise
            fprintf(2,'Unrecognized toggle.fig2 variable setting.\n')
    end

else
    fprintf('%s %s: No T1_warped.nii.gz found.\n',scanID{1},scanID{2})
end

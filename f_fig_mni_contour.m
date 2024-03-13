function f_fig_mni_contour(configs,subjID)

MNI = fullfile(configs.path2SM,'MNI_templates','MNI152_T1_1mm.nii.gz');

if isempty(configs.ses)
    sesList=dir(fullfile(configs.path2data,subjID,'ses*'));
    sesList = struct2cell(sesList)';
    sesList = sesList(:,1);
else
    sesList{1}=configs.ses;
end

for se=1:length(sesList)
    ses = sesList{se};
    fprintf('---- %s -> ', ses)
    sub_path=fullfile(configs.path2data,subjID,ses);
    if ~exist(sub_path,'dir')
        fprintf(2,'%s/%s - Directory does not exist! Exiting...\n',subjID,ses)
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
        upperT1=.75*(max(max(max(T1mni))));
        MNIt=niftiread(MNI);

        filename=fullfile(qcpath,[subjID '_' ses '_2-mni_contour']);
        count=length(dir(strcat(filename,'*')));
        if count > 0
            filename = [filename '_v' num2str(count+1)];
        end

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

            sgtitle(sprintf('%s %s: MNI space T1 with MNI template contour overlay',subjID,ses),'Interpreter','none','Color','white')
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
        fprintf('done.\n')
    else
        fprintf('%s: No T1_warped.nii.gz found.\n',subjID)
    end
end
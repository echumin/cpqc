% ==================== IUSM-ConnPipe QC Plot Generation ===================
% File: f_fig1_regression.m
% Purpose: Generate plots for regression visualization
% =========================================================================

function f_fig_residual(path2EPI,funcvolpaths,subjID,ses,linkdir)

    if ~exist(path2EPI,'dir')
        fprintf(2,'func directory does not exist!\n')
        return
    else
        qcpath=fullfile(path2EPI,'../qc'); %output directory
        if ~exist(qcpath,'dir')
            mkdir(qcpath) % make output directory if it doesn't exist
        end
    end
    
     % Load tissue masks
        wm_mask = niftiread(fullfile(path2EPI, 'rT1_WM_mask.nii.gz'));
        csf_mask = niftiread(fullfile(path2EPI, 'rT1_CSF_mask.nii.gz'));
        gm_mask = niftiread(fullfile(path2EPI, 'rT1_GM_mask.nii.gz'));
    
    for ii=1:length(funcvolpaths)

        func_vol = niftiread(funcvolpaths{ii});
        [~,~,~,T] = size(func_vol);
        [~,flname,~] = fileparts(funcvolpaths{ii});
        rt=extractBetween(flname,'epi_','_DCT');

        for slice = 1:T
           func_slice = func_vol(:,:,:,slice);
           gm_func(:,slice) = func_slice(logical(gm_mask));
           wm_func(:,slice) = func_slice(logical(wm_mask));
           csf_func(:,slice) = func_slice(logical(csf_mask));
           clear func_slice
        end 

        f = figure('Units','inches','Position',[1 1 8 6],'Color','k');
        h(1)=subplot(3,1,1);
        imagesc(gm_func)
        set(h(1),'XColor',[1 1 1],'YColor',[1 1 1])
        ylabel('GM (vox)','Color','white')
        mx=prctile(gm_func(:),95); mn=prctile(gm_func(:),5); 
        clim([mn mx]); colorbar('Color','white')
        xlim([0.5 T]); xticks(0:10:T)
        h(2)=subplot(3,1,2);
        imagesc(wm_func)
        set(h(2),'XColor',[1 1 1],'YColor',[1 1 1])
        ylabel('WM (vox)','Color','white')
        mx=prctile(wm_func(:),95); mn=prctile(wm_func(:),5); 
        clim([mn mx]); colorbar('Color','white')
        xlim([0.5 T]); xticks(0:10:T)
        h(3)=subplot(3,1,3);
        imagesc(csf_func)
        set(h(3),'XColor',[1 1 1],'YColor',[1 1 1])
        ylabel('CSF (vox)','Color','white')
        mx=prctile(csf_func(:),95); mn=prctile(csf_func(:),5); 
        clim([mn mx]); colorbar('Color','white')
        xlim([0.5 T]); xticks(0:10:T)
        colormap('gray')
        
        sgtitle([subjID ' ' ses ' ' flname],'Interpreter','none','Color','white')

        fileout = fullfile(qcpath,[subjID '_' ses '_8-' rt{1} '_tissue_resid']);
        count=length(dir(strcat(fileout,'*')));
        if count > 0
           fileout = [fileout '_v' num2str(count+1)];
        end
        print(f,[fileout '.png'],'-dpng','-r600')
        if exist('linkdir','var')
            system(['ln -sf ' fileout '.png ' linkdir '/']);
        end
        clear fileout
    end
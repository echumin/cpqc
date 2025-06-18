function f_fig_epi_mask(configs,scanID,flag,linkdir)

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

    path2EPI = fullfile(sub_path,'func',configs.funcTAG);

    if ~exist(path2EPI,'dir')
        fprintf([' no func/' configs.funcTAG ' directory.\n'])
    else
        % Set filenames/read in data
        MeanVol=fullfile(path2EPI,'2_epi_meanvol.nii.gz');
        if ~exist(MeanVol,'file')
            MeanVol=fullfile(path2EPI,[scanID{1} '_' scanID{2} '_' configs.funcTAG '_echo-1_moco_brain.nii.gz']);
            if ~exist(MeanVol,'file')
                fprintf(' no *_echo-1_moco_brain.nii.gz file.\n')
                return
            end
        end

        mask=fullfile(path2EPI,'rT1_GM_mask.nii.gz');
        if ~exist(mask,'file')
            mask=fullfile(path2EPI,'t1parc_registration','rT1_GM_mask.nii.gz');
            if ~exist(mask,'file')
                fprintf(' no t1parc_registration/rT1_GM_mask.nii.gz file.\n')
                return
            end
        end
    
        fileout = fullfile(qcpath,[scanID{1} '_' scanID{2} '_6-epi_rGMmask']);
        count=length(dir(strcat(fileout,'*')));
        if count > 0
            fileout = [fileout '_v' num2str(count+1)];
        end
        
        if flag==1
            if exist('linkdir','var')
                f_bm_overlay_png(scanID,MeanVol,mask,3,fileout,linkdir)
            else
                f_bm_overlay_png(scanID,MeanVol,mask,3,fileout)
            end
        elseif flag == 2
                f_bm_overlay_gif(scanID,MeanVol,mask,3,fileout)
        end
        fprintf('done.\n')
    end
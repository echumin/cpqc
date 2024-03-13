function f_fig_epi_mask(configs,subjID,flag,linkdir)


if isempty(configs.ses)
    sesList=dir(fullfile(configs.path2data,subjID,'ses*'));
    sesList = struct2cell(sesList)';
    sesList = sesList(:,1);
else
    sesList{1}=configs.ses;
end

for se=1:length(sesList)
    ses = sesList{se};
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
    %%
    path2EPI = fullfile(sub_path,'func');
    fprintf('---- %s -> ', ses)
    if ~exist(path2EPI,'dir')
        fprintf(' no func directory.\n')
    else
        % Set filenames/read in data
        MeanVol=(fullfile(path2EPI,'2_epi_meanvol.nii.gz'));
        mask=(fullfile(path2EPI,'rT1_GM_mask.nii.gz'));
    
        fileout = fullfile(qcpath,[subjID '_' ses '_6-epi_rGMmask']);
        count=length(dir(strcat(fileout,'*')));
        if count > 0
            fileout = [fileout '_v' num2str(count+1)];
        end
        
        if flag==1
            if exist('linkdir','var')
                f_bm_overlay_png(subjID,ses,MeanVol,mask,3,fileout,linkdir)
            else
                f_bm_overlay_png(subjID,ses,MeanVol,mask,3,fileout)
            end
        elseif flag == 2
                f_bm_overlay_gif(subjID,ses,MeanVol,mask,3,fileout)
        end
        fprintf('done.\n')
    end
end
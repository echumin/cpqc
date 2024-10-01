function f_fig_t1_mask(configs,scanID,flag,linkdir)

sub_path=fullfile(configs.path2data,scanID{1},scanID{2});
if ~exist(sub_path,'dir')
    fprintf(2,'%s/%s - Directory does not exist! Exiting...\n',scanID,ses)
    return
else
    qcpath=fullfile(sub_path,'qc'); %output directory
    if ~exist(qcpath,'dir')
        mkdir(qcpath) % make output directory if it doesn't exist
    end
end

%% 1-Brain Mask Check   
% 
    Subj_T1=fullfile(sub_path,'anat/T1_fov_denoised.nii');
    Subj_BM=fullfile(sub_path,'anat/T1_brain_mask_filled.nii.gz');
    
    if isfile(Subj_T1) && isfile(Subj_BM)
        filename = fullfile(qcpath,[scanID{1} '_' scanID{2} '_1-brain_mask']);
        count=length(dir(strcat(filename,'*')));
        if count > 0
            filename = [filename '_v' num2str(count+1)];
        end 
        
        if flag==1
            if exist('linkdir','var')
                f_bm_overlay_png(scanID,Subj_T1,Subj_BM,1,filename,linkdir)
            else
                f_bm_overlay_png(scanID,Subj_T1,Subj_BM,1,filename)
            end
        elseif flag==2
            f_bm_overlay_gif(scanID,Subj_T1,Subj_BM,1,filename)
        end
        fprintf('done.\n')
  
    end
        close all
        clear ses

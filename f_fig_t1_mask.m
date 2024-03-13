function f_fig_t1_mask(configs,subjID,flag,linkdir)

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
    
    %% 1-Brain Mask Check   
    % 
        Subj_T1=fullfile(sub_path,'anat/T1_fov_denoised.nii');
        Subj_BM=fullfile(sub_path,'anat/T1_brain_mask_filled.nii.gz');
        
        if isfile(Subj_T1) && isfile(Subj_BM)
            fprintf('---- %s -> ', ses)
            filename = fullfile(qcpath,[subjID '_' ses '_1-brain_mask']);
            count=length(dir(strcat(filename,'*')));
            if count > 0
                filename = [filename '_v' num2str(count+1)];
            end 
            
            if flag==1
                if exist('linkdir','var')
                    f_bm_overlay_png(subjID,ses,Subj_T1,Subj_BM,3,filename,linkdir)
                else
                    f_bm_overlay_png(subjID,ses,Subj_T1,Subj_BM,3,filename)
                end
            elseif flag==2
                f_bm_overlay_gif(subjID,ses,Subj_T1,Subj_BM,3,filename)
            end
            fprintf('done.\n')
      
        end
            close all
            clear ses
end
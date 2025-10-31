function f_fig_t1_roi(configs,scanID,linkdir)

sub_path=fullfile(configs.path2data,scanID{1},scanID{2});
qcpath=fullfile(sub_path,'qc'); %output directory

%% Defined connpipe roi images
Subj_anat=fullfile(sub_path,'anat');
masks=struct;
masks(1).name = [Subj_anat, '/registration/Cerebellum_bin.nii.gz'];
masks(2).name = [Subj_anat, '/T1_mask_CSFvent.nii.gz'];

filename = fullfile(qcpath,[scanID{1} '_' scanID{2} '_3-subcort_vols']);
count=length(dir(strcat(filename,'*')));
if count > 0
    filename = [filename '_v' num2str(count+1)];
end 

% Checking if T1B run has been completed. 
if exist(fullfile(masks(1).name),'file')
    
    Subj_T1=fullfile(Subj_anat,'T1_fov_denoised.nii');
    if exist('linkdir','var')
        f_bm_overlay_png(scanID,Subj_T1,masks,1,filename,linkdir)
    else
        f_bm_overlay_png(scanID,Subj_T1,masks,1,filename)
    end

    fprintf('done.\n')
else
    nofig(scanID,{'Not found: anat/registration/Cerebellum_bin.nii.gz'},filename,linkdir)
    fprintf(2,'no Cerebellum mask found!\n')
end
close all

function f_fig_t1_parc(configs,scanID,linkdir)

sub_path=fullfile(configs.path2data,scanID{1},scanID{2});
qcpath=fullfile(sub_path,'qc'); %output directory

%% Define a list of parcellations
Subj_T1=fullfile(sub_path,'anat');

if isempty(configs.parcs)
    % get a list of parcellation files 
    parcs=dir(fullfile(Subj_T1,'T1_GM_parc*'));
    % remove the dilated versions
    idx=double.empty;
    for j=1:length(parcs)
        if ~isempty(strfind(parcs(j).name,'dil'))
            idx(end+1)=j; %#ok<*SAGROW>
        end
    end
    parcs(idx)=[];
    nP=length(parcs);
    for p=1:nP
        pt = extractBetween(parcs(p).name,'parc_','.nii');
        configs.parcs{p}=pt{1};
    clear pt
    end
end

filename = fullfile(qcpath,[scanID{1} '_' scanID{2} '_4-parc_vols']);
count=length(dir(strcat(filename,'*')));
if count > 0
    filename = [filename '_v' num2str(count+1)];
end

%% Generate figure
T1f=fullfile(Subj_T1,'T1_fov_denoised.nii');
if exist(T1f,'file')
    
    if exist('linkdir','var')
        f_parc_overlay_gif(scanID,T1f,Subj_T1,configs.parcs,filename,linkdir)
    else
        f_parc_overlay_gif(scanID,T1f,Subj_T1,configs.parcs,filename)
    end

    fprintf('done.\n')
else
    nofig(scanID,'No anat/T1_fov_denoised',filename,linkdir)
    fprintf(2,'%s - %s - no T1_fov_denoised found.\n',scanID{1},scanID{2})
end
close all

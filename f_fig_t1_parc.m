function f_fig_t1_parc(configs,subjID,linkdir)


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
        fprintf(2,'%s/%s - Directory does not exist! Exiting...\n',subjID,configs.ses)
        return
    else
        qcpath=fullfile(sub_path,'qc'); %output directory
        if ~exist(qcpath,'dir')
            mkdir(qcpath) % make output directory if it doesn't exist
        end
    end

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

    %% Generate figure
    T1f=fullfile(Subj_T1,'T1_fov_denoised.nii');
    if exist(T1f,'file')
        filename = fullfile(qcpath,[subjID '_' configs.ses '_4-parc_vols']);
        count=length(dir(strcat(filename,'*')));
        if count > 0
            filename = [filename '_v' num2str(count+1)];
        end

        if exist('linkdir','var')
            f_parc_overlay_gif(subjID,ses,T1f,Subj_T1,configs.parcs,filename,linkdir)
        else
            f_parc_overlay_gif(subjID,ses,T1f,Subj_T1,configs.parcs,filename)
        end

        fprintf('done.\n')
    else
        fprintf(2,'%s - %s - no T1_fov_denoised found.\n',subjID,ses)
    end
    close all
    clear ses
end
function f_fig_epi_parc(configs,scanID,linkdir)

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

    %%
    path2EPI = fullfile(sub_path,'func',configs.funcTAG);

    if ~exist(path2EPI,'dir')
        fprintf([' no func/' configs.funcTAG ' directory.\n'])
    else
        MeanVol=fullfile(path2EPI,'2_epi_meanvol.nii.gz');
        if ~exist(MeanVol,'file')
            MeanVol=fullfile(path2EPI,[scanID{1} '_' scanID{2} '_' configs.funcTAG '_echo-1_moco_brain.nii.gz']);
            if ~exist(MeanVol,'file')
                fprintf(' no *_echo-1_moco_brain.nii.gz file.\n')
                return
            else
                parcpath=fullfile(path2EPI,'t1parc_registration');
            end
        else
            parcpath=path2EPI;
        end

        if isempty(configs.parcs)
            % get a list of parcellation files 
            parcs=dir(fullfile(parcpath,'rT1_GM_parc*clean*'));
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

        if exist(MeanVol,'file')
            filename = fullfile(qcpath,[scanID{1} '_' scanID{2} '_7-epi_parc_vols']);
            count=length(dir(strcat(filename,'*')));
            if count > 0
                filename = [filename '_v' num2str(count+1)];
            end
    
            if exist('linkdir','var')
                f_parc_overlay_gif(scanID,MeanVol,path2EPI,configs.parcs,filename,linkdir)
            else
                f_parc_overlay_gif(scanID,MeanVol,path2EPI,configs.parcs,filename)
            end
   
            fprintf('done.\n')
        else
            fprintf(2,'%s - %s - no EPI Meanvol found.\n',scanID{1},scanID{2})
        end
    end
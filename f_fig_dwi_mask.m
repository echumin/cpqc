function f_fig_dwi_mask(configs,subjID,flag,linkdir)

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

    path2DWI = fullfile(sub_path,'dwi');
    path2EDDY = fullfile(path2DWI,'EDDY');
    path2FIT = fullfile(path2DWI,'DTIfit');

    if ~exist(path2DWI,'dir')
        fprintf('no dwi dir.\n')
    else

    Meanb0=fullfile(path2EDDY,'meanb0.nii.gz');
    Emask=fullfile(path2EDDY,'b0_brain_mask.nii.gz');
    Fmask=fullfile(path2FIT,'b0_1st_mask.nii.gz');

    if exist(Meanb0,'file')
        if exist(Emask,'file')
            filename = fullfile(qcpath,[subjID '_' configs.ses '_10_dwi_eddy_mask']);
            count=length(dir(strcat(filename,'*')));
            if count > 0
                filename = [filename '_v' num2str(count+1)];
            end

            if flag==1
                if exist('linkdir','var')
                    f_bm_overlay_png(subjID,ses,Meanb0,Emask,3,filename,linkdir)
                else
                    f_bm_overlay_png(subjID,ses,Meanb0,Emask,3,filename)
                end
            elseif flag==2
                f_bm_overlay_gif(subjID,ses,Meanb0,Emask,3,filename)
            end
            fprintf('eddy mask done. - ')
        else
            fprintf(2,'no b0 brain mask in EDDY directory.\n')
        end

        if exist(path2FIT,'dir')
            filename = fullfile(qcpath,[subjID '_' configs.ses '_10_dwi_dtifit_mask']);
            count=length(dir(strcat(filename,'*')));
            if count > 0
                filename = [filename '_v' num2str(count+1)];
            end

            if flag==1
                if exist('linkdir','var')
                    f_bm_overlay_png(subjID,ses,Meanb0,Fmask,3,filename,linkdir)
                else
                    f_bm_overlay_png(subjID,ses,Meanb0,Fmask,3,filename)
                end
            elseif flag==2
                f_bm_overlay_gif(subjID,ses,Meanb0,Fmask,3,filename)
            end
            fprintf('dtifit mask done.\n')
        else
            fprintf(2,'no b0 brain mask in DTIFIT directory.\n')
        end
    else
        fprintf(2,'no mean b0 in EDDY directory.\n')
    end
    end
end






            % for ix=1:length(Cslices)
            %     B1stack = horzcat(B1stack,rot90(squeeze(Emask(Cslices(ix),:,:)))); 
            %     B2stack = horzcat(B2stack,rot90(squeeze(Fmask(Cslices(ix),:,:))));
            % end
            % if hdr.Qfactor==1
            %     Bstack = flipud(vertcat(B1stack,B2stack));
            % else
            %     Bstack = vertcat(B1stack,B2stack);
            % end
            % 
         



% ==================== IUSM-ConnPipe QC Plot Generation ===================
% File: run_QC.m
% Purpose: Perform QC plot generation
%
% Run steps:
%     1. Edit f_set_configs.m parameters
%     2. Edit f_subj_configs.m parameters
%     3. Toggle figures & data to load in run_QC.m
%     4. Run run_QC.m
%
% Additional guiding documentation can be found here:
% https://link/to/documentation.com
% =========================================================================

%% -- Pipeline Supplement -- %%
configs.path2SM = '/N/u/echumin/Quartz/img_proc_tools/ConnPipelineSM';

%% -- Dataset Info -- %
configs.path2data = '/N/project/HCPaging/iadrc2024q3/derivatives/connpipe';
%configs.path2data = '/N/project/kbase-imaging/kbase1-bids/derivatives/connpipe';

% Leave empty to compile from path2data directories; otherwise a cell of IDs
configs.scans = subj_reqc;

%% -- Links -- %%
% Create symbolic links in new deriv directory for QC.
LinkOut = 1;
LinkDirName = 'connQC/mask_and_mni_run3';

%% -- Toggle figures on/off -- %%
% -- anat -- %
toggle.fig1 = 1; % T1 brain masks: 1=png 2=gif
toggle.fig2 = 1; % MNI contour 1=png 2=gif
toggle.fig3 = 0; % ROI masks (subcortical, ventricle, cerebellar)
toggle.fig4 = 0; % T1 parcellations

% -- func -- %
toggle.fig5 = 0; % Subject motion
toggle.fig6 = 0; % EPI brain masks: 1=png 2=gif
toggle.fig7 = 0; % EPI parcellations

% -- nuissance regression func -- "
% funcreg is a global flag that needs to be on for subcequent flags to prevent unnecessary overhead.
funcreg = 0; 
    toggle.fig8 = 0; % Regression plots
    toggle.fig9 = 0; % Time-Series, ROI size, and FC

% -- dwi -- %
toggle.fig10 = 0; % DWI EDDY and DTIFIT brain masks: 1=png 2=gif
% registration
% connectivity


%% -- Optional Parameter Presets -- %%
% For any variable left empty, figures for all identified options will be
% ran, otherwise only preselected parameters will be searched for.

configs.parcs = {};
% or
%configs.parcs = {'DKT','schaefer200y7','Tian2','FSLsubcort','buckner-crblm','suit-crblm'};
%configs.parcs = {'DKT','FSLsubcort','Tian2'};

configs.nuisanceMOT = {};
% or
%configs.nuisanceMOT = {'AROMA'};
%configs.nuisanceMOT = {'HMPreg'};

configs.nuisanceTIS = {};
% or
%configs.nuisanceTIS = {'aCompCor'};
%configs.nuisanceTIS = {'meanPhysReg'};

configs.GS = [];
% or
%configs.GS = 1;
%configs.GS = 0;

%% --------------------------------------------------------------------- %%
sub = buildscanlist(configs.scans,configs.path2data);

if LinkOut == 1
    Linkdir=[fileparts(configs.path2data) '/' LinkDirName];
    if ~exist(Linkdir,'dir')
        mkdir(Linkdir)
    end
end

%% -- anat -- %
% T1 brain masks
if toggle.fig1 ~= 0
    disp('Generating T1_brain_mask figures for:')
    for ss = 1:size(sub,1)
        fprintf('-- %s %s -> \n', sub{ss,1}, sub{ss,2})
        if LinkOut==1
            f_fig_t1_mask(configs,sub(ss,:),toggle.fig1,Linkdir); %DONE - NEEDS COMMENTING
        else
            f_fig_t1_mask(configs,sub(ss,:),toggle.fig1); %DONE - NEEDS COMMENTING
        end
    end
end

% MNI contour
if toggle.fig2 ~= 0
    disp('Generating MNI CONTOUR figures for:')
    for ss = 1:size(sub,1)
        fprintf('-- %s %s -> \n', sub{ss,1}, sub{ss,2})
        if LinkOut==1
            f_fig_mni_contour(configs,sub(ss,:),toggle.fig2,Linkdir);
        else
            f_fig_mni_contour(configs,sub(ss,:),toggle.fig2);
        end
    end   
end

% T1 subcortical roi masks
if toggle.fig3 == 1
    disp('Generating T1 ROI figures for:')
    for ss = 1:length(sub)
        fprintf('-- %s -> \n', sub{ss})
        if LinkOut==1
            fprintf('CSF and Cerebellum:\n')
            f_fig_t1_roi(configs,sub{ss},Linkdir)
            fprintf('Subcortical:\n')
            f_fig_t1_subc(configs,sub{ss},Linkdir)
        else
            fprintf('CSF and Cerebellum:\n')
            f_fig_t1_roi(configs,sub{ss})
            fprintf('Subcortical:\n')
            f_fig_t1_subc(configs,sub{ss})
        end
    end
end

% T1 parcellations
if toggle.fig4 == 1
    disp('Generating T1_GM_parc figures for:')
    for ss = 1:length(sub)
        fprintf('-- %s -> \n', sub{ss})
        if LinkOut==1
            f_fig_t1_parc(configs,sub{ss},Linkdir);
        else
            f_fig_t1_parc(configs,sub{ss});
        end
    end
end

%% -- func -- %%
% Subject motion
if toggle.fig5 == 1
    disp('Generating MCFLIRT MOTION figures for:')
    for ss = 1:length(sub)
        fprintf('-- %s -> \n', sub{ss})
        if LinkOut==1
            f_fig_mcflirt_mot(configs,sub{ss},Linkdir);
        else
            f_fig_mcflirt_mot(configs,sub{ss});
        end
    end
end

% EPI brain masks
if toggle.fig6 ~= 0
    disp('Generating EPI MASK figures for:')
    for ss = 1:length(sub)
        fprintf('-- %s -> \n', sub{ss})
        if LinkOut==1
            f_fig_epi_mask(configs,sub{ss},toggle.fig6,Linkdir);
        else
            f_fig_epi_mask(configs,sub{ss},toggle.fig6);
        end
    end
end

% EPI parcellations
if toggle.fig7 == 1
    disp('Generating EPI PARC figures for:')
    for ss = 1:length(sub)
        fprintf('-- %s -> \n', sub{ss})
        if LinkOut==1
            f_fig_epi_parc(configs,sub{ss},Linkdir);
        else
            f_fig_epi_parc(configs,sub{ss});
        end
    end
end

%%  -- func - nuissance regression checks -- %%
if funcreg == 1
for ss=1:length(sub)
    disp('Generating EPI Nuisance Regression figures for:')
    fprintf('-- %s -> \n', sub{ss})
    
    if isempty(configs.ses)
        sesList=dir(fullfile(configs.path2data,sub{ss},'ses*'));
        sesList = struct2cell(sesList)';
        sesList = sesList(:,1);
    else
        sesList{1}=configs.ses;
    end
    
    % ------------- Initialize path locations and file names --------------

    for se=1:length(sesList)
        ses = sesList{se};
        sub_path=fullfile(configs.path2data,sub{ss},ses);
        configs.path2EPI = fullfile(sub_path,'func');
        fprintf('---- /%s -> ',ses)

        if ~exist(configs.path2EPI,'dir')
            fprintf(2,'func directory does not exist.\n')
        else

            if isempty(configs.nuisanceMOT)
                tmp = dir(configs.path2EPI);
                tmp(1:2)=[];
                tmp(~[tmp.isdir])=[];
                tmp=struct2cell(tmp);
                configs.nuisanceMOT = tmp(1,:); clear tmp
            end
        
            for nM = 1:length(configs.nuisanceMOT)
                configs.path2nuisance = fullfile(configs.path2EPI,configs.nuisanceMOT{nM});
        
                if isempty(configs.nuisanceTIS)
                    if exist([configs.path2nuisance '/aCompCor'],'dir')
                        configs.nuisanceTIS{1} = 'aCompCor';
                    elseif exist([configs.path2nuisance '/aCompCorr'],'dir')
                        configs.nuisanceTIS{1} = 'aCompCorr';
                    end
                    if exist([configs.path2nuisance '/meanPsysReg'],'dir')
                        if isempty(configs.nuisanceTIS)
                            configs.nuisanceTIS{1} = 'meanPhysReg';
                        else
                            configs.nuisanceTIS{2} = 'meanPhysReg';
                        end
                    end
                end
        
                for nT = 1:length(configs.nuisanceTIS)
                    configs.path2nuisanceTIS = fullfile(configs.path2nuisance,configs.nuisanceTIS{nT});
        
                    funcvolfiles = dir([configs.path2nuisanceTIS '/7_epi*nii.gz']);
                    funcvolfiles=struct2cell(funcvolfiles); 
                    funcvolfiles=funcvolfiles(1,:);
                    gsidx=~cellfun(@isempty,(cellfun(@(x) strfind(x,'Gs'),funcvolfiles,'UniformOutput',false)));
                    if configs.GS == 1
                        idx=find(gsidx);
                        for ii=1:length(idx)
                            funcvolpaths{ii} = fullfile(configs.path2nuisanceTIS,funcvolfiles{idx(ii)});
                        end
                    elseif configs.GS == 0
                        idx=find(~gsidx);
                        for ii=1:length(idx)
                            funcvolpaths{ii} = fullfile(configs.path2nuisanceTIS,funcvolfiles{idx(ii)});
                        end
                    elseif isempty(configs.GS)
                        for ii= 1:length(gsidx)
                            funcvolpaths{ii} = fullfile(configs.path2nuisanceTIS,funcvolfiles{ii});
                        end
                    end
         
                    % Residual plots
                    if toggle.fig8 == 1
                        disp('Generating voxel residuals figure...')
                        if LinkOut==1
                            f_fig_residual(configs.path2EPI,funcvolpaths,sub{ss},ses,Linkdir);
                        else
                            f_fig_residual(configs.path2EPI,funcvolpaths,sub{ss},ses);
                        end             
                        fprintf('done.\n')
                    end
                    close all
                
                    % Regional Time-series
                    if toggle.fig9 == 1
                        if nT==1 && nM==1
                            disp('-- -- Generating time-series summaries figures:')
                        end
                        fprintf('-- -- -- %s %s -> \n',configs.nuisanceMOT{nM},configs.nuisanceTIS{nT})
                        if LinkOut==1
                            f_fig_timeseries(configs.path2EPI,configs.parcs,funcvolpaths,sub{ss},ses,Linkdir);
                        else
                            f_fig_timeseries(configs.path2EPI,configs.parcs,funcvolpaths,sub{ss},ses);
                        end
                        fprintf('done.\n')
                    end
                    close all
                end
            end
        end
        clear ses
    end
    clear sesList
end
end

%% -- dwi -- %
% Check DWI brain masks
if toggle.fig10 ~= 0
    disp('Generating DWI mask figures for:')
    for ss = 1:length(sub)
        fprintf('-- %s -> \n', sub{ss})
        if LinkOut==1
            f_fig_dwi_mask(configs,sub{ss},toggle.fig10,Linkdir);
        else
            f_fig_dwi_mask(configs,sub{ss},toggle.fig10);
        end
    end
end


% registration

% connectivity




%%
function scans = buildscanlist(scans,pathderiv)
    if isempty(scans)
        disp('Building scan list from derivative directory (All subjects and sessions).')
        scans=cell.empty;
        sub = dir([pathderiv '/sub-*']);
        for ss=1:length(sub)
            ses=dir(fullfile(sub(ss).folder,sub(ss).name,'ses*'));
            for ee=1:length(ses)
                scans{end+1,1}=sub(ss).name;
                scans{end,2}=ses(ee).name;
            end
            clear ses
        end
    end
    disp('Checking format of input subject list')
    if iscell(scans) == 1
        [~,cc] = size(scans);
        if cc ~= 2
            disp('Number of columns not 2! [sub- ses-].')
            disp('Scan list must be a two column cell of sub- and ses-')
            return
        end
   
    else
        fprintf(2,'Input must be a cell.\n')
        return
    end
end











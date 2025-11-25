function f_fig_epi_nuis(configs,scanID,toggle,LinkOut,Linkdir)

epi_path=fullfile(configs.path2data,scanID{1},scanID{2},'func',configs.funcTAG{1});
qcpath=fullfile(configs.path2data,scanID{1},scanID{2},'qc',configs.funcTAG{1}); %output directory

%%
fileNUIS = fullfile(qcpath,[scanID{1} '_' scanID{2} '_8-nuisanceDIRcheck']);
count=length(dir(strcat(fileNUIS,'*')));
if count > 0
    fileNUIS = [fileNUIS '_v' num2str(count+1)];
end

% set motion regression directory
if isempty(configs.nuisanceMOT)
    configs.nuisanceMOT=cell.empty;
    if exist(fullfile(epi_path,'AROMA'),'dir')
        configs.nuisanceMOT{end+1} = 'AROMA';
    end
    if exist(fullfile(epi_path,'AROMA_HMP'),'dir')
        configs.nuisanceMOT{end+1} = 'AROMA_HMP';
    end
    if exist(fullfile(epi_path,'HMPreg'),'dir')
        configs.nuisanceMOT{end+1} = 'HMPreg';
    end

    if isempty(configs.nuisanceMOT)
        nofig(scanID,{'congigs.nuisanceMOT: No AROMA or HMP directories found.',['Do not exist in: func/' configs.funcTAG{1}]},fileNUIS,Linkdir)
        fprintf([' no func/' configs.funcTAG{1} '/ AROMA or HMP directories.\n'])
        return
    end
end
                
for ii=1:length(configs.nuisanceMOT)

    % set tissue regression directory
    if isempty(configs.nuisanceTIS)
        configs.nuisanceTIS=cell.empty;
        if exist(fullfile(epipath,configs.nuisanceMOT{ii},'meanPhysReg'),'dir')
            configs.nuisanceTIS{end+1} = 'meanPhysReg';
        end
        if exist(fullfile(epipath,configs.nuisanceMOT{ii},'aCompCor'),'dir')
            configs.nuisanceTIS{end+1} = 'aCompCor';
        end

        if isempty(configs.nuisanceTIS)
            nofig(scanID,{'congigs.nuisanceTIS: No meanPhysReg or aCompCor directories found.',['Do not exist in: func/' configs.funcTAG{1} '/' configs.nuisanceMOT{ii}]},fileNUIS,Linkdir)
            fprintf([' no func/' configs.funcTAG{1} '/' configs.nuisanceMOT{ii} 'meanPhysReg or aCompCor directories.\n'])
            return
        end
    end

    for jj=1:length(configs.nuisanceTIS)
    
        path2EPI = fullfile(configs.path2data,scanID{1},scanID{2},'func',configs.funcTAG{1});
        
        % build epi file name
        fName=fullfile(path2EPI,configs.nuisanceMOT{ii},configs.nuisanceTIS{jj},'*_epi');
        switch configs.nuisanceMOT{ii}
            case 'AROMA'
                fName=[fName '_aroma'];
            case 'AROMA_HMP'
                fName=[fName '_aroma_hmp*'];
            case 'HMPreg'
                fName=[fName '_hmp*'];
        end
        switch configs.nuisanceTIS{jj}
            case 'aCompCor'
                fName=[fName '_pca*'];
            case 'meanPhysReg'
                fName=[fName '_mPhys*'];
        end
        if configs.GS==1
            fName=[fName '_Gs*'];
        end
        fName=[fName '.nii.gz'];
        nfName=dir(fName);

        if isempty(nfName)
            nofig(scanID,{'No files matching pattern: ',fName})
            fprintf([' NOTHING MATCHED: ' fName])
            return
        end

        % Residual plots
        if toggle.fig8 == 1
            disp('-- -- Generating voxel residuals figure...')
            if LinkOut==1
                f_fig_residual(path2EPI,nfName,qcpath,scanID,Linkdir);
            else
                f_fig_residual(path2EPI,nfName,qcpath,scanID);
            end             
            fprintf('done.\n')
        end
        close all

        % Regional Time-series
        if toggle.fig9 == 1
            disp('-- -- Generating time-series summaries figures:')
            if LinkOut==1
                f_fig_timeseries(configs.parcs,nfName,qcpath,scanID,Linkdir);
            else
                f_fig_timeseries(configs.parcs,nfName,qcpath,scanID);
            end
            fprintf('done.\n')
        end
        close all

    end % end TIS
end % end MOT







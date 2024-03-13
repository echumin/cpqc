function f_fig_timeseries(path2EPI,parcList,funcvolpaths,subjID,ses,linkdir)

    if ~exist(path2EPI,'dir')
        fprintf(2,'func directory does not exist!\n')
        return
    else
        qcpath=fullfile(path2EPI,'../qc'); %output directory
        if ~exist(qcpath,'dir')
            mkdir(qcpath) % make output directory if it doesn't exist
        end
    end

    for ii=1:length(funcvolpaths)

        [func_path,flname,~] = fileparts(funcvolpaths{ii});
        rt=extractBetween(flname,'epi_','.nii');

        tspath = fullfile(func_path,['TimeSeries_' rt{1}]);

        parcs = dir(fullfile(tspath,'*_ROIs.mat'));
        parcs=struct2cell(parcs);
        parcs=parcs(1,:);
        if ~isempty(parcList)
            clear pidx
            for jj=1:length(parcList)
                pidx(jj,:)=~cellfun(@isempty,(cellfun(@(x) strfind(x,parcList{jj}),parcs,'UniformOutput',false)));
            end
            pidx=logical(sum(pidx,1));
            parcs=parcs(pidx);
        end

        for jj=1:length(parcs)
            rtsdata = load(fullfile(tspath,parcs{jj}));
            [N,~]=size(rtsdata.restingROIs);

            close all
            f=figure('Units','inches','Position',[1 1 6 8]);
            tiledlayout(3,4,'TileSpacing','compact')

            nexttile([1 2])
            histogram(rtsdata.ROIs_numVoxels,'NumBins',round(N/4))
            title('ROI size'); xlabel('Voxels')
            
            nexttile([1 1])
            histogram(rtsdata.ROIs_numVoxels(rtsdata.ROIs_numVoxels<100),'NumBins',round(N/4))
            xlim([0 100])
            title('size < 100'); xlabel('Voxels')

            nexttile([1 1])
            histogram(sum(rtsdata.ROIs_numNans,2),'NumBins',round(N/4),'DisplayStyle','stairs','LineStyle','-')
            hold on
            histogram(sum(rtsdata.ROIs_numNans,1),'NumBins',round(N/4),'DisplayStyle','stairs','LineStyle','--')
            title('Number of NaN'); legend({'by region','by time'},'Location','southoutside')

            nexttile([1 4])
            plot(rtsdata.restingROIs'); xlabel('Time (TR)'); ylabel('BOLD')
            title('Regional Time-Series')

            nexttile([1 2])
            fc=corr(rtsdata.restingROIs');
            imagesc(fc);axis square; colorbar; clim([-.8 .8])
            xticks([]); xlabel('ROI');
            yticks([]); ylabel('ROI');
            title('Pearson FC')

            nexttile([1 2])
            mask=logical(triu(ones(N,N),1));
            ufc=fc(mask);
            histogram(ufc,'NumBins',round(N/4)); xlim([-1 1])
            title('Pearson Distribution')

            sgtitle({[subjID ' ' ses ' ' rt{1}],...
                parcs{jj}(1:end-4)},'interpreter','none')

            fileout = fullfile(qcpath,[subjID '_' ses '_9-' rt{1} '_' parcs{jj}(7:end-9)   '_timeseries']);
            count=length(dir(strcat(fileout,'*')));
            if count > 0
               fileout = [fileout '_v' num2str(count+1)];
            end
            print(f,[fileout '.png'],'-dpng','-r600')
            if exist('linkdir','var')
                system(['ln -sf ' fileout '.png ' linkdir '/']);
            end
            clear fileout
        end
    end
    












            

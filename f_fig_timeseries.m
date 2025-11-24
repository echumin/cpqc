function f_fig_timeseries(parcList,funcvolpaths,qcpath,scanID,linkdir)

% build a colormap
n = 25;
mid = 13;
% Interpolate from blue to white
blue_to_white = [linspace(0,1,mid)', linspace(0,1,mid)', ones(mid,1)];
% Interpolate from white to red
white_to_red = [ones(n-mid+1,1), linspace(1,0,n-mid+1)', linspace(1,0,n-mid+1)'];
% Combine, but avoid duplicating the middle row
bwr = [blue_to_white; white_to_red(2:end,:)];

for ii=1:height(funcvolpaths)

    rt=extractBetween(funcvolpaths(ii).name,'epi_','.nii');
    tspath = fullfile(funcvolpaths(ii).folder,['TimeSeries_' rt{1}]);

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
        imagesc(rtsdata.restingROIs); xlabel('Time (TR)'); ylabel('Regions')
        mx=prctile(abs(rtsdata.restingROIs(:)),99);
        clim([-mx mx]); colorbar; colormap(bwr)
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

        sgtitle({[scanID{1} ' ' scanID{2} ' ' rt{1}],...
            parcs{jj}(1:end-4)},'interpreter','none')

        fileout = fullfile(qcpath,[scanID{1} '_' scanID{2} '_9-' rt{1} '_' parcs{jj}(7:end-9)   '_timeseries']);
        count=length(dir(strcat(fileout,'*')));
        if count > 0
           fileout = [fileout '_v' num2str(count+1)];
        end
        print(f,[fileout '.png'],'-dpng','-r300')
        if exist('linkdir','var')
            system(['ln -sf ' fileout '.png ' linkdir '/']);
        end
        clear fileout
    end
end













            

function f_fig_mcflirt_mot(configs,scanID,linkdir)

sub_path=fullfile(configs.path2data,scanID{1},scanID{2});
qcpath=fullfile(sub_path,'qc',configs.funcTAG{1}); %output directory

%%
fileout = fullfile(qcpath,[scanID{1} '_' scanID{2} '_5-mcflirt_motion']);
count=length(dir(strcat(fileout,'*')));
if count > 0
    fileout = [fileout '_v' num2str(count+1)];
end

path2EPI = fullfile(sub_path,'func',configs.funcTAG{1});

if ~exist(path2EPI,'dir')
    nofig(scanID,{['congigs.funcTAG{1}: ' configs.funcTAG{1}],['Does not exist: func/' configs.funcTAG{1}]},filename,linkdir)
    fprintf([' no func/' configs.funcTAG{1} ' directory.\n'])
else
    % checking for fmri or fmri_ME motion file
    mtfile=fullfile(path2EPI,'motion.txt');
    if ~exist(mtfile,'file')
        mtfile=fullfile(path2EPI,[scanID{1} '_' scanID{2} '_' configs.funcTAG{1} '_echo-1_moco.par']);
        if ~exist(mtfile,'file')
            nofig(scanID,{['congigs.funcTAG{1}: ' configs.funcTAG{1}],'Not Found: motion parameter .par file'},filename,linkdir)
            fprintf(' no motion parameter file.\n')
            return
        end
    end
    motion=readmatrix(mtfile,'FileType','text');
    rmax = max(max(abs(motion(:,1:3))));
    h=figure('Units','inches','Position',[1 1 8 10.5],'Visible','off');
    h(1)=subplot(4,1,1);
    plot(zeros(length(motion),1),'k--')
    hold all
    plot(motion(:,1:3))
    l=rmax+(.25*rmax);
    ylim([-l l])
    title('rotation relative to mean'); legend('','x','y','z','Location','eastoutside')
    ylabel('radians')
    hold off
    
    tmax = max(max(abs(motion(:,4:6))));
    h(2)=subplot(4,1,2); %#ok<*NASGU>
    plot(zeros(length(motion),1),'k--')
    hold all
    plot(motion(:,4:6))
    l=tmax+(.25*tmax);
    ylim([-l l])
    title('translation relative to mean'); legend('','x','y','z','Location','eastoutside')
    ylabel('millimeters')
    hold off
    
    fd_file = fullfile(path2EPI,'motionMetric_fd.txt');
    if ~exist(fd_file,'file')
        fd_file = fullfile(path2EPI,'motionMetric_FD.txt');
    end
    if ~exist(fd_file,'file')
        fprintf(2,' No mcflirt fd file. ')
    else
        fd=load(fd_file);
        h(3)=subplot(4,1,3);
        plot(fd)
        ul=max(fd)+(.25*max(fd));
        ylim([0 ul])
        title('frame dispacement'); legend('fd','Location','eastoutside')
        ylabel('FD (mm)')
        clear ul
    end

    dvars_file = fullfile(path2EPI,'motionMetric_dvars.txt');
    if ~exist(dvars_file,'file')
        dvars_file = fullfile(path2EPI,'motionMetric_DVARS.txt');
    end
    if ~exist(dvars_file,'file')
        fprintf(2,' No mcflirt dvars file. ')
    else
        dvars=load(dvars_file);
        h(4)=subplot(4,1,4);
        plot(dvars)
        ul=max(dvars)+(.25*max(dvars));
        ylim([0 ul])
        title('dvars'); legend('dvars','Location','eastoutside')
        ylabel('dvars') 
        clear ul
    end

    sgtitle(sprintf('%s - %s: mcFLIRT motion parameters',scanID{1},scanID{2}),'Interpreter','none')
    print([fileout '.png'],'-dpng','-r300')

    if exist('linkdir','var')
        system(['ln -sf ' fileout '.png ' linkdir '/']);
    end

    close all
    fprintf('done.\n')
end
function nofig(scanID,msg,outname,linkdir)

f=figure('units','inches','Position',[1 1 5 5]);
text(.1,.7,[scanID{1},' ',scanID{2}],'Interpreter','none')
text(.1,.6,msg,'Interpreter','none')
axis off

% Add title to figure and save as high resolution png
sgtitle(sprintf('%s %s',scanID{1},scanID{2}),'Interpreter','none')    
print([outname '.png'],'-dpng','-r300');
close(f)

if exist('linkdir','var')
    system(['ln -sf ' outname '.png ' linkdir '/']);
end

end

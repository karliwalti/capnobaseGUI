%% script to move files into subfolders for capnobase

clear all

run configure.m

handles.parameters.dataset=param.move.target; %
sourcefolder=param.move.source; %

counter=1;

foldercontent=dir([conf.data.rootfolder filesep filesep handles.parameters.dataset]);
for i=3:length(foldercontent)
    
    if(foldercontent(i).isdir)
        try
            movefile([conf.data.rootfolder filesep sourcefolder filesep foldercontent(i).name filesep '*'],[conf.data.rootfolder filesep handles.parameters.dataset filesep foldercontent(i).name filesep],'f');
        catch
            disp([foldercontent(i).name ' not present or other problem'])
        end
    end
    
end



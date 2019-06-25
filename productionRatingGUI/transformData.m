%% script to move files into subfolders for capnobase

clear all

handles.parameters.dataset='july29_10ratings';%'CapnoBaseBenchmark';%'CapnoBaseInVivo';%'CB8minLongData'; %'SimulationMarkAnsermino08_04';
counter=1;
foldercontent=dir(['data/' handles.parameters.dataset]);
for i=3:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
        idx=strfind(name,'_signal');
        if strcmp(ext,'.mat') && ~isempty(idx)
            mkdir(['data/' handles.parameters.dataset '/' name(1:idx-1) ]);
          %    mkdir(['data/' handles.parameters.dataset '/' name(1:4) 'l' ]); % version for long data
            handles.data.name{counter}=name(1:idx-1);%foldercontent(i).
          %  handles.data.name{counter}=[name(1:4) 'l']
            counter=counter+1;
        end
        
    
    end
    
end

for i=3:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
        idx=strfind(name,'_');
        if strcmp(ext,'.mat') && ~isempty(idx)
            
           copyfile(['data/' handles.parameters.dataset '/' foldercontent(i).name],['data/' handles.parameters.dataset '/' name(1:idx(end)-1)]);
   %copyfile(['data/' handles.parameters.dataset '/' foldercontent(i).name],['data/' handles.parameters.dataset '/' name([1:idx(1)-1]) 'l/' name([1:idx(1)-1]) 'l' name([idx(2):end]) '.mat' ]);
        end
        
    
    end
    
end
% now the files have to be removed from folder!
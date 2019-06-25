%add model/manufaturer

clear all

counter=1;
    foldercontent=dir('data');
    for i=1:length(foldercontent)
        
        if(~foldercontent(i).isdir)
           [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
           if strcmp(ext,'.mat')
            handles.data.name{counter}=foldercontent(i).name;
            counter=counter+1;
           end
        end
        
    end
    
%     for i=1:length(handles.data.name)
%         load(['data/' handles.data.name{i}],'meta')
%      
%         meta.sensor.co2.manufacturer=['Datex-Ohmeda'];
%         meta.sensor.co2.model=['M-CAiOVX'];
% 
%         meta.sensor.flow.model=['M-CAiOVX'];
%         meta.sensor.flow.manufacturer=['Datex-Ohmeda'];
% 
%         meta.sensor.pressure.model=['M-CAiOVX'];
%         meta.sensor.pressure.manufacturer=['Datex-Ohmeda'];
% save(['data/' handles.data.name{i}],'meta','-append')
%     end
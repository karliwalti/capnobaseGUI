function [handles, counter]=readDataDir(hObject,eventdata,handles)
% read the data directory
%Wk
% update 10/4/2010 : added compatibility with capnobase, reads also from
% second level folder
counter=1;
handles.data.name=[];
foldercontent=dir(['data/' handles.parameters.dataset]);
for i=3:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
        idx=strfind(name,'_signal');
        if strcmp(ext,'.mat') && ~isempty(idx)
            handles.data.name{counter}=name(1:idx-1);%foldercontent(i).
            counter=counter+1;
        end
        
    else %update 10/4/2010
        subfoldercontent=dir(['data/' handles.parameters.dataset '/' foldercontent(i).name]); %browse subfolder
        for k=3:length(subfoldercontent)
            if(~subfoldercontent(k).isdir)
                [pathstr, name, ext, versn]= fileparts(subfoldercontent(k).name);
                idx=strfind(name,'_signal');
                if strcmp(ext,'.mat') && ~isempty(idx) % && strcmp(name(1:idx-1),foldercontent(i).name) % additional test if name is same
                    handles.data.name{counter}=[foldercontent(i).name '/' name(1:idx-1)];%foldercontent(i).
                    counter=counter+1;
                end
            end
        end
        
    end
    
end

if isempty(handles.data.name)
    handles.data.name={'No_data_available'};
    disp('Warning: The selected dataset contains no data.')
    counter=2;
end
try
    for z=1:length(handles.data.name) %replace path with filename
         idx=strfind(handles.data.name{z},'/');
          if ~isempty(idx) 
              nicename{z}=['(' num2str(z) ') ' handles.data.name{z}(idx+1:end)];
          else
               nicename{z}=['(' num2str(z) ') ' handles.data.name{z}];
          end
    end
    set(handles.popupmenuJump, 'String', nicename);
   % set(handles.popupmenuJump, 'String', handles.data.name);
  
catch
end
% save the changes to the structure
guidata(hObject,handles)
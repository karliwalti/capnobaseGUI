function [handles, counter]=readDataDir(hObject,eventdata,handles)
% read the data directory
%Wk
% update 10/4/2010 : added compatibility with capnobase, reads also from
% second level folder
% update 1/7/2022 : added single file support
% update 1/12/2022 : added configuration file
run configure.m

counter=1;
handles.data.name=[];
handles.data.singlefile=0;
foldercontent=dir([conf.data.rootfolder filesep handles.parameters.dataset]);
foldercontent = foldercontent(~ismember({foldercontent.name},{'.','..'}));
for i=1:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext]= fileparts(foldercontent(i).name);
        idx=strfind(name,'_signal');
        if strcmp(ext,'.mat') && ~isempty(idx)
            handles.data.name{counter}=name(1:idx-1);%foldercontent(i).
            counter=counter+1;
        end
    else %update 10/4/2010 subfolders instead of all files in same
        subfoldercontent=dir([conf.data.rootfolder filesep handles.parameters.dataset filesep foldercontent(i).name]); %browse subfolder
        subfoldercontent = subfoldercontent(~ismember({subfoldercontent.name},{'.','..'}));
        for k=1:length(subfoldercontent)
            if(~subfoldercontent(k).isdir)
                [pathstr, name, ext]= fileparts(subfoldercontent(k).name);
                idx=strfind(name,'_signal');
                if strcmp(ext,'.mat') && ~isempty(idx) % && strcmp(name(1:idx-1),foldercontent(i).name) % additional test if name is same
                    handles.data.name{counter}=[foldercontent(i).name filesep name(1:idx-1)];%foldercontent(i).
                    counter=counter+1;
                end
            end
        end
        
    end
    
end

if isempty(handles.data.name)
    % there was no classical data available
    % check for single file format (all in one mat file)
   disp('Warning: The selected dataset contains no _signal.mat files. checking alternative format.')
    
   for i=1:length(foldercontent)
       
       if(~foldercontent(i).isdir)
           [pathstr, name, ext]= fileparts(foldercontent(i).name);
           
           if strcmp(ext,'.mat')
               handles.data.name{counter}=name;%foldercontent(i).
               handles.data.singlefile=1;
               counter=counter+1;
           end
       end
   end
   
    if isempty(handles.data.name)
        handles.data.name={'No_data_available'};
        disp('Warning: The selected dataset contains no compatible data.')
        counter=2;
    else
          disp('Warning: Single file format detected. There might be compatibility issues.')
    end
end
try
    for z=1:length(handles.data.name) %replace path with filename
         idx=strfind(handles.data.name{z},filesep);
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
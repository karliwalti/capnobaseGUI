function err=saveMeta(handles)
%this does not return updated handles because not used anymore
err=[];

handles=grabForm(handles); %fill structure with field content


meta=handles.current.meta;
param=handles.current.param;
%rating.startinsp.x=round(GetAllCursorLocations('Insp').*handles.current.param.samplingrate);
%rating.startexp.x=round(GetAllCursorLocations('Exp').*handles.current.param.samplingrate);
try
    if exist([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_param.mat'],'file')
save([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_param'],'param','-append');
    else
        save([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_param'],'param');

    end
    if exist([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_meta.mat'],'file')
save([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_meta'],'meta','-append');
    else
        save([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_meta'],'meta');

    end

catch
    disp('Error: Could not write meta data.')
    err=1;
end
err=0;



function [handles]=grabForm(handles)


%gets all text form fields, dynamic fields are set by callback

strfnames=fieldnames(handles);
idx = strncmp(strfnames', 'edit_', 5);

for k=find(idx)
    
    namefields = regexp(strfnames(k), '_', 'split');
    name='';
    for i=2:length(namefields{1})
        
        name=[name '.' char(namefields{1}(i))];
    end
    if strcmp(char(namefields{1}(3)),'samplingrate')
        eval(['handles.current' name '=  str2num(get(handles.(char(strfnames(k))),''String''));'])
    else
        eval(['handles.current' name '=  get(handles.(char(strfnames(k))),''String'');'])
    end
end
handles.current.meta.treatment.cuff=get(handles.checkboxCuff,'Value');
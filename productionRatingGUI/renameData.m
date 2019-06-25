%script to add Letter at the end of case

foldercontent=dir('data');
counter=1;
    for i=1:length(foldercontent)
        
        if(~foldercontent(i).isdir)
            
            handles.data.name{counter}=foldercontent(i).name;
            counter=counter+1;
        end
        
    end
    
    for i=1:length(handles.data.name)
        s=regexp(handles.data.name{i},'_','split');
        
        newname=[s{1} '_' char(str2num(s{2})+65)];
        load ( ['data/' handles.data.name{i}])
        save(['data/' newname],'meta','data','param')
        delete (['data/' handles.data.name{i}])
    end